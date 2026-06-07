-- ============================================================
-- トリガー（監査・整合性・自動履歴）
-- ============================================================

-- customers テーブルに更新日時カラムを追加
ALTER TABLE customers
    ADD COLUMN IF NOT EXISTS updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

COMMENT ON COLUMN customers.updatedAt IS '最終更新日時（UPDATE トリガーで自動更新）';

-- ------------------------------------------------------------
-- トリガー関数
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION trgfn_orders_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditLogs (tableName, recordId, actionType, oldValues, newValues)
        VALUES (
            TG_TABLE_NAME,
            NEW.orderId,
            'INSERT',
            NULL,
            row_to_json(NEW)::jsonb
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditLogs (tableName, recordId, actionType, oldValues, newValues)
        VALUES (
            TG_TABLE_NAME,
            NEW.orderId,
            'UPDATE',
            row_to_json(OLD)::jsonb,
            row_to_json(NEW)::jsonb
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditLogs (tableName, recordId, actionType, oldValues, newValues)
        VALUES (
            TG_TABLE_NAME,
            OLD.orderId,
            'DELETE',
            row_to_json(OLD)::jsonb,
            NULL
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION trgfn_orders_audit() IS 'orders テーブルの INSERT/UPDATE/DELETE を auditLogs に記録する';

CREATE OR REPLACE FUNCTION trgfn_orderItems_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_orderStatus VARCHAR(20);
    v_currentStock INTEGER;
    v_productName VARCHAR(200);
BEGIN
    SELECT o.status
    INTO v_orderStatus
    FROM orders o
    WHERE o.orderId = NEW.orderId;

    IF NOT FOUND THEN
        RAISE EXCEPTION '注文ID % が存在しません', NEW.orderId
            USING ERRCODE = 'P0001',
                  DETAIL = format(
                      'trgfn_orderItems_stock(orderId=%s, productId=%s): 親注文が見つかりません',
                      NEW.orderId, NEW.productId
                  ),
                  HINT = '有効な orderId を持つ注文を先に作成してください';
    END IF;

    IF v_orderStatus <> 'confirmed' THEN
        RETURN NEW;
    END IF;

    SELECT p.stockQuantity, p.productName
    INTO v_currentStock, v_productName
    FROM products p
    WHERE p.productId = NEW.productId
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION '商品ID % は存在しません', NEW.productId
            USING ERRCODE = 'P0002',
                  DETAIL = format(
                      'trgfn_orderItems_stock(orderId=%s, productId=%s): products に該当レコードなし',
                      NEW.orderId, NEW.productId
                  ),
                  HINT = '存在する productId を指定してください';
    END IF;

    IF v_currentStock < NEW.quantity THEN
        RAISE EXCEPTION '在庫不足のため明細を追加できません（商品: %, 在庫: %, 注文数: %）',
            v_productName, v_currentStock, NEW.quantity
            USING ERRCODE = 'P0003',
                  DETAIL = format(
                      'trgfn_orderItems_stock(orderId=%s, productId=%s): 在庫 %s < 数量 %s',
                      NEW.orderId, NEW.productId, v_currentStock, NEW.quantity
                  ),
                  HINT = 'sp_restockProduct で在庫を補充するか、注文数量を減らしてください';
    END IF;

    UPDATE products
    SET stockQuantity = stockQuantity - NEW.quantity
    WHERE productId = NEW.productId;

    UPDATE stockLevels
    SET quantityOnHand = quantityOnHand - NEW.quantity
    WHERE productId = NEW.productId
      AND quantityOnHand >= NEW.quantity;

    INSERT INTO stockMovements (
        productId,
        warehouseId,
        movementType,
        quantity,
        referenceType,
        referenceId
    )
    SELECT
        NEW.productId,
        sl.warehouseId,
        'sale',
        -NEW.quantity,
        'orderItem',
        NEW.orderItemId
    FROM stockLevels sl
    WHERE sl.productId = NEW.productId
      AND sl.quantityOnHand >= 0
    ORDER BY sl.quantityOnHand DESC
    LIMIT 1;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION trgfn_orderItems_stock() IS '確定済み注文の明細追加時に在庫を減算する';

CREATE OR REPLACE FUNCTION trgfn_customers_updated()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updatedAt := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION trgfn_customers_updated() IS 'customers 更新時に updatedAt を現在時刻へ自動設定する';

CREATE OR REPLACE FUNCTION trgfn_salaryHistory_validate()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.newSalary IS NULL OR NEW.newSalary <= 0 THEN
        RAISE EXCEPTION '新給与は正の値である必要があります（newSalary: %）', NEW.newSalary
            USING ERRCODE = 'P0001',
                  DETAIL = format(
                      'trgfn_salaryHistory_validate(employeeId=%s, newSalary=%s): newSalary > 0 の制約違反',
                      NEW.employeeId, NEW.newSalary
                  ),
                  HINT = '0より大きい newSalary を指定してください';
    END IF;

    IF NEW.oldSalary IS NOT NULL AND NEW.oldSalary < 0 THEN
        RAISE EXCEPTION '旧給与が不正です（oldSalary: %）', NEW.oldSalary
            USING ERRCODE = 'P0002',
                  DETAIL = format(
                      'trgfn_salaryHistory_validate(employeeId=%s, oldSalary=%s): oldSalary は0以上である必要があります',
                      NEW.employeeId, NEW.oldSalary
                  ),
                  HINT = '正しい oldSalary を指定してください';
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION trgfn_salaryHistory_validate() IS 'salaryHistory の新給与が正の値であることを検証する';

CREATE OR REPLACE FUNCTION trgfn_orders_status_history()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO orderStatusHistory (
            orderId,
            oldStatus,
            newStatus,
            changedBy,
            reason
        )
        VALUES (
            NEW.orderId,
            OLD.status,
            NEW.status,
            CURRENT_USER,
            format('ステータス変更: %s → %s', OLD.status, NEW.status)
        );
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION trgfn_orders_status_history() IS 'orders のステータス変更時に orderStatusHistory へ自動記録する';

-- ------------------------------------------------------------
-- トリガー定義
-- ------------------------------------------------------------

CREATE TRIGGER trg_orders_audit
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trgfn_orders_audit();

COMMENT ON TRIGGER trg_orders_audit ON orders IS '注文の追加・更新・削除を監査ログ（auditLogs）に記録する';

CREATE TRIGGER trg_orderItems_stock
    AFTER INSERT ON orderItems
    FOR EACH ROW
    EXECUTE FUNCTION trgfn_orderItems_stock();

COMMENT ON TRIGGER trg_orderItems_stock ON orderItems IS '確定済み注文への明細追加時に商品在庫を減算する';

CREATE TRIGGER trg_customers_updated
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION trgfn_customers_updated();

COMMENT ON TRIGGER trg_customers_updated ON customers IS '顧客情報更新時に updatedAt を自動更新する';

CREATE TRIGGER trg_salaryHistory_validate
    BEFORE INSERT OR UPDATE ON salaryHistory
    FOR EACH ROW
    EXECUTE FUNCTION trgfn_salaryHistory_validate();

COMMENT ON TRIGGER trg_salaryHistory_validate ON salaryHistory IS '給与履歴登録時に新給与が正の値であることを検証する';

CREATE TRIGGER trg_orders_status_history
    AFTER UPDATE OF status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trgfn_orders_status_history();

COMMENT ON TRIGGER trg_orders_status_history ON orders IS '注文ステータス変更時に orderStatusHistory へ履歴を自動挿入する';
