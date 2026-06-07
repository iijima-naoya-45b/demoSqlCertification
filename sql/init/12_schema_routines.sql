-- ============================================================
-- 関数・ストアドプロシージャ（plpgsql）
-- ============================================================

-- ------------------------------------------------------------
-- 関数
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_calcOrderTotal(p_orderId INTEGER)
RETURNS NUMERIC(12, 2)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_subtotal NUMERIC(12, 2);
    v_shippingFee NUMERIC(12, 2);
    v_couponDiscount NUMERIC(12, 2);
BEGIN
    IF p_orderId IS NULL THEN
        RAISE EXCEPTION '注文IDがNULLです'
            USING ERRCODE = 'P0001',
                  DETAIL = 'fn_calcOrderTotal(orderId=NULL): orderId パラメータは必須です',
                  HINT = '有効な注文ID（正の整数）を指定してください';
    END IF;

    SELECT
        COALESCE(SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)), 0),
        o.shippingFee
    INTO v_subtotal, v_shippingFee
    FROM orders o
    LEFT JOIN orderItems oi ON oi.orderId = o.orderId
    WHERE o.orderId = p_orderId
    GROUP BY o.shippingFee;

    IF NOT FOUND THEN
        RAISE EXCEPTION '注文ID % は存在しません', p_orderId
            USING ERRCODE = 'P0002',
                  DETAIL = format('fn_calcOrderTotal(orderId=%s): orders テーブルに該当レコードがありません', p_orderId),
                  HINT = '存在する orderId を指定してください';
    END IF;

    SELECT COALESCE(SUM(cr.discountAmount), 0)
    INTO v_couponDiscount
    FROM couponRedemptions cr
    WHERE cr.orderId = p_orderId;

    RETURN v_subtotal + v_shippingFee - v_couponDiscount;
END;
$$;

COMMENT ON FUNCTION fn_calcOrderTotal(INTEGER) IS '注文合計金額を算出する（明細小計 + 送料 - クーポン割引）';

CREATE OR REPLACE FUNCTION fn_getCustomerTierDiscount(p_customerId INTEGER)
RETURNS NUMERIC(5, 2)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_membershipTier VARCHAR(20);
    v_discountPercent NUMERIC(5, 2);
BEGIN
    IF p_customerId IS NULL THEN
        RAISE EXCEPTION '顧客IDがNULLです'
            USING ERRCODE = 'P0001',
                  DETAIL = 'fn_getCustomerTierDiscount(customerId=NULL): customerId パラメータは必須です',
                  HINT = '有効な顧客ID（正の整数）を指定してください';
    END IF;

    SELECT c.membershipTier
    INTO v_membershipTier
    FROM customers c
    WHERE c.customerId = p_customerId;

    IF NOT FOUND THEN
        RAISE EXCEPTION '顧客ID % は存在しません', p_customerId
            USING ERRCODE = 'P0002',
                  DETAIL = format('fn_getCustomerTierDiscount(customerId=%s): customers テーブルに該当レコードがありません', p_customerId),
                  HINT = '存在する customerId を指定してください';
    END IF;

    SELECT m.discountPercent
    INTO v_discountPercent
    FROM membershipTierMaster m
    WHERE m.tierCode = v_membershipTier
      AND m.isActive = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION '会員ランク % の割引率が見つかりません', v_membershipTier
            USING ERRCODE = 'P0003',
                  DETAIL = format(
                      'fn_getCustomerTierDiscount(customerId=%s, membershipTier=%s): membershipTierMaster に有効な定義がありません',
                      p_customerId, v_membershipTier
                  ),
                  HINT = 'membershipTierMaster に tierCode を登録してください';
    END IF;

    RETURN v_discountPercent;
END;
$$;

COMMENT ON FUNCTION fn_getCustomerTierDiscount(INTEGER) IS '顧客の会員ランクに応じた割引率（%）を返す';

CREATE OR REPLACE FUNCTION fn_getEmployeeTenureMonths(p_employeeId INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_hireDate DATE;
    v_tenureMonths INTEGER;
BEGIN
    IF p_employeeId IS NULL THEN
        RAISE EXCEPTION '従業員IDがNULLです'
            USING ERRCODE = 'P0001',
                  DETAIL = 'fn_getEmployeeTenureMonths(employeeId=NULL): employeeId パラメータは必須です',
                  HINT = '有効な従業員ID（正の整数）を指定してください';
    END IF;

    SELECT e.hireDate
    INTO v_hireDate
    FROM employees e
    WHERE e.employeeId = p_employeeId;

    IF NOT FOUND THEN
        RAISE EXCEPTION '従業員ID % は存在しません', p_employeeId
            USING ERRCODE = 'P0002',
                  DETAIL = format('fn_getEmployeeTenureMonths(employeeId=%s): employees テーブルに該当レコードがありません', p_employeeId),
                  HINT = '存在する employeeId を指定してください';
    END IF;

    v_tenureMonths := (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, v_hireDate)) * 12
        + EXTRACT(MONTH FROM AGE(CURRENT_DATE, v_hireDate))
    )::INTEGER;

    RETURN v_tenureMonths;
END;
$$;

COMMENT ON FUNCTION fn_getEmployeeTenureMonths(INTEGER) IS '従業員の入社からの在籍月数を返す';

CREATE OR REPLACE FUNCTION fn_isBusinessDay(p_targetDate DATE)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_isWeekend BOOLEAN;
    v_isHoliday BOOLEAN;
BEGIN
    IF p_targetDate IS NULL THEN
        RAISE EXCEPTION '日付がNULLです'
            USING ERRCODE = 'P0001',
                  DETAIL = 'fn_isBusinessDay(date=NULL): date パラメータは必須です',
                  HINT = 'YYYY-MM-DD 形式の日付を指定してください';
    END IF;

    v_isWeekend := EXTRACT(ISODOW FROM p_targetDate) IN (6, 7);

    SELECT EXISTS (
        SELECT 1
        FROM holidays h
        WHERE h.holidayDate = p_targetDate
    )
    INTO v_isHoliday;

    RETURN NOT v_isWeekend AND NOT v_isHoliday;
END;
$$;

COMMENT ON FUNCTION fn_isBusinessDay(DATE) IS '指定日が営業日かどうかを判定する（土日・祝日を除外）';

CREATE OR REPLACE FUNCTION fn_getProductStock(p_productId INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_stockFromLevels INTEGER;
    v_stockFromProduct INTEGER;
BEGIN
    IF p_productId IS NULL THEN
        RAISE EXCEPTION '商品IDがNULLです'
            USING ERRCODE = 'P0001',
                  DETAIL = 'fn_getProductStock(productId=NULL): productId パラメータは必須です',
                  HINT = '有効な商品ID（正の整数）を指定してください';
    END IF;

    SELECT p.stockQuantity
    INTO v_stockFromProduct
    FROM products p
    WHERE p.productId = p_productId;

    IF NOT FOUND THEN
        RAISE EXCEPTION '商品ID % は存在しません', p_productId
            USING ERRCODE = 'P0002',
                  DETAIL = format('fn_getProductStock(productId=%s): products テーブルに該当レコードがありません', p_productId),
                  HINT = '存在する productId を指定してください';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM stockLevels sl
        WHERE sl.productId = p_productId
    ) THEN
        SELECT COALESCE(SUM(sl.quantityOnHand), 0)
        INTO v_stockFromLevels
        FROM stockLevels sl
        WHERE sl.productId = p_productId;

        RETURN v_stockFromLevels;
    END IF;

    RETURN v_stockFromProduct;
END;
$$;

COMMENT ON FUNCTION fn_getProductStock(INTEGER) IS '商品の現在庫数を返す（倉庫別在庫の合計、なければ商品マスタの在庫数）';

-- ------------------------------------------------------------
-- ストアドプロシージャ
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE sp_confirmOrder(p_orderId INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_currentStatus VARCHAR(20);
    v_item RECORD;
    v_availableStock INTEGER;
BEGIN
    IF p_orderId IS NULL THEN
        RAISE EXCEPTION '注文IDがNULLです'
            USING ERRCODE = 'P0001',
                  DETAIL = 'sp_confirmOrder(orderId=NULL): orderId パラメータは必須です',
                  HINT = '有効な注文ID（正の整数）を指定してください';
    END IF;

    SELECT o.status
    INTO v_currentStatus
    FROM orders o
    WHERE o.orderId = p_orderId
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION '注文ID % は存在しません', p_orderId
            USING ERRCODE = 'P0002',
                  DETAIL = format('sp_confirmOrder(orderId=%s): orders テーブルに該当レコードがありません', p_orderId),
                  HINT = '存在する orderId を指定してください';
    END IF;

    IF v_currentStatus = 'cancelled' THEN
        RAISE EXCEPTION 'キャンセル済みの注文は確定できません（注文ID: %）', p_orderId
            USING ERRCODE = 'P0003',
                  DETAIL = format('sp_confirmOrder(orderId=%s, status=%s): キャンセル済み注文のステータス変更は不可', p_orderId, v_currentStatus),
                  HINT = '新規注文を作成するか、別の注文IDを指定してください';
    END IF;

    IF v_currentStatus = 'confirmed' THEN
        RAISE EXCEPTION '注文ID % は既に確定済みです', p_orderId
            USING ERRCODE = 'P0004',
                  DETAIL = format('sp_confirmOrder(orderId=%s): 二重確定は許可されていません', p_orderId),
                  HINT = '確定済み注文に対しては sp_recordPayment 等を使用してください';
    END IF;

    FOR v_item IN
        SELECT oi.productId, oi.quantity, p.productName
        FROM orderItems oi
        JOIN products p ON p.productId = oi.productId
        WHERE oi.orderId = p_orderId
    LOOP
        v_availableStock := fn_getProductStock(v_item.productId);

        IF v_availableStock < v_item.quantity THEN
            RAISE EXCEPTION '在庫不足のため注文を確定できません（商品: %, 必要数: %, 在庫数: %）',
                v_item.productName, v_item.quantity, v_availableStock
                USING ERRCODE = 'P0005',
                      DETAIL = format(
                          'sp_confirmOrder(orderId=%s, productId=%s): 在庫 %s < 注文数量 %s',
                          p_orderId, v_item.productId, v_availableStock, v_item.quantity
                      ),
                      HINT = 'sp_restockProduct で在庫を補充するか、注文明細の数量を見直してください';
        END IF;
    END LOOP;

    UPDATE orders
    SET status = 'confirmed'
    WHERE orderId = p_orderId;
END;
$$;

COMMENT ON PROCEDURE sp_confirmOrder(INTEGER) IS '注文を確定する（在庫チェック後にステータスを confirmed に更新）';

CREATE OR REPLACE PROCEDURE sp_cancelOrder(
    p_orderId INTEGER,
    p_reason VARCHAR(200) DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_currentStatus VARCHAR(20);
BEGIN
    IF p_orderId IS NULL THEN
        RAISE EXCEPTION '注文IDがNULLです'
            USING ERRCODE = 'P0001',
                  DETAIL = 'sp_cancelOrder(orderId=NULL): orderId パラメータは必須です',
                  HINT = '有効な注文ID（正の整数）を指定してください';
    END IF;

    SELECT o.status
    INTO v_currentStatus
    FROM orders o
    WHERE o.orderId = p_orderId
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION '注文ID % は存在しません', p_orderId
            USING ERRCODE = 'P0002',
                  DETAIL = format('sp_cancelOrder(orderId=%s): orders テーブルに該当レコードがありません', p_orderId),
                  HINT = '存在する orderId を指定してください';
    END IF;

    IF v_currentStatus IN ('delivered', 'cancelled') THEN
        RAISE EXCEPTION '注文ID % はキャンセルできません（現在のステータス: %）', p_orderId, v_currentStatus
            USING ERRCODE = 'P0003',
                  DETAIL = format(
                      'sp_cancelOrder(orderId=%s, status=%s, reason=%s): 配送完了済みまたはキャンセル済みの注文は変更不可',
                      p_orderId, v_currentStatus, COALESCE(p_reason, '（理由未指定）')
                  ),
                  HINT = '返品処理（returns テーブル）を検討してください';
    END IF;

    UPDATE orders
    SET status = 'cancelled'
    WHERE orderId = p_orderId;
END;
$$;

COMMENT ON PROCEDURE sp_cancelOrder(INTEGER, VARCHAR) IS '注文をキャンセルする（配送完了済みを除く）';

CREATE OR REPLACE PROCEDURE sp_applyCoupon(
    p_orderId INTEGER,
    p_couponCode VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_orderStatus VARCHAR(20);
    v_coupon RECORD;
    v_orderSubtotal NUMERIC(12, 2);
    v_discountAmount NUMERIC(12, 2);
    v_alreadyRedeemed BOOLEAN;
BEGIN
    IF p_orderId IS NULL OR p_couponCode IS NULL OR TRIM(p_couponCode) = '' THEN
        RAISE EXCEPTION '注文IDまたはクーポンコードが未指定です'
            USING ERRCODE = 'P0001',
                  DETAIL = format(
                      'sp_applyCoupon(orderId=%s, couponCode=%s): 両方のパラメータが必須です',
                      p_orderId, COALESCE(p_couponCode, 'NULL')
                  ),
                  HINT = '有効な orderId と couponCode を指定してください';
    END IF;

    SELECT o.status
    INTO v_orderStatus
    FROM orders o
    WHERE o.orderId = p_orderId
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION '注文ID % は存在しません', p_orderId
            USING ERRCODE = 'P0002',
                  DETAIL = format('sp_applyCoupon(orderId=%s, couponCode=%s): 注文が見つかりません', p_orderId, p_couponCode),
                  HINT = '存在する orderId を指定してください';
    END IF;

    IF v_orderStatus IN ('cancelled', 'delivered') THEN
        RAISE EXCEPTION 'ステータス % の注文にクーポンは適用できません', v_orderStatus
            USING ERRCODE = 'P0003',
                  DETAIL = format(
                      'sp_applyCoupon(orderId=%s, couponCode=%s, status=%s): キャンセル済み・配送完了済み注文は対象外',
                      p_orderId, p_couponCode, v_orderStatus
                  ),
                  HINT = 'pending または confirmed 状態の注文に適用してください';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM couponRedemptions cr
        WHERE cr.orderId = p_orderId
    )
    INTO v_alreadyRedeemed;

    IF v_alreadyRedeemed THEN
        RAISE EXCEPTION '注文ID % には既にクーポンが適用されています', p_orderId
            USING ERRCODE = 'P0004',
                  DETAIL = format('sp_applyCoupon(orderId=%s, couponCode=%s): 1注文につき1クーポンのみ適用可能', p_orderId, p_couponCode),
                  HINT = '別の注文にクーポンを適用するか、既存の適用を確認してください';
    END IF;

    SELECT
        c.couponId,
        c.discountType,
        c.discountValue,
        c.minOrderAmount,
        c.validFrom,
        c.validUntil,
        c.maxRedemptions,
        c.currentRedemptions,
        c.isActive
    INTO v_coupon
    FROM coupons c
    WHERE c.couponCode = p_couponCode;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'クーポンコード % は存在しません', p_couponCode
            USING ERRCODE = 'P0005',
                  DETAIL = format('sp_applyCoupon(orderId=%s, couponCode=%s): coupons テーブルに該当コードがありません', p_orderId, p_couponCode),
                  HINT = '正しいクーポンコードを入力してください';
    END IF;

    IF NOT v_coupon.isActive THEN
        RAISE EXCEPTION 'クーポンコード % は無効化されています', p_couponCode
            USING ERRCODE = 'P0006',
                  DETAIL = format('sp_applyCoupon(orderId=%s, couponCode=%s): isActive=FALSE', p_orderId, p_couponCode),
                  HINT = '有効なクーポンコードを指定してください';
    END IF;

    IF CURRENT_DATE NOT BETWEEN v_coupon.validFrom AND v_coupon.validUntil THEN
        RAISE EXCEPTION 'クーポンコード % は有効期間外です（% 〜 %）',
            p_couponCode, v_coupon.validFrom, v_coupon.validUntil
            USING ERRCODE = 'P0007',
                  DETAIL = format(
                      'sp_applyCoupon(orderId=%s, couponCode=%s): 本日=%s は有効期間外',
                      p_orderId, p_couponCode, CURRENT_DATE
                  ),
                  HINT = '有効期間内のクーポンを指定してください';
    END IF;

    IF v_coupon.maxRedemptions IS NOT NULL
       AND v_coupon.currentRedemptions >= v_coupon.maxRedemptions THEN
        RAISE EXCEPTION 'クーポンコード % は利用上限に達しています', p_couponCode
            USING ERRCODE = 'P0008',
                  DETAIL = format(
                      'sp_applyCoupon(orderId=%s, couponCode=%s): 利用数 %s >= 上限 %s',
                      p_orderId, p_couponCode, v_coupon.currentRedemptions, v_coupon.maxRedemptions
                  ),
                  HINT = '別のクーポンコードを使用してください';
    END IF;

    SELECT COALESCE(SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)), 0)
    INTO v_orderSubtotal
    FROM orderItems oi
    WHERE oi.orderId = p_orderId;

    IF v_orderSubtotal < v_coupon.minOrderAmount THEN
        RAISE EXCEPTION '注文金額 % がクーポンの最低購入金額 % を下回っています',
            v_orderSubtotal, v_coupon.minOrderAmount
            USING ERRCODE = 'P0009',
                  DETAIL = format(
                      'sp_applyCoupon(orderId=%s, couponCode=%s): 小計 %s < 最低金額 %s',
                      p_orderId, p_couponCode, v_orderSubtotal, v_coupon.minOrderAmount
                  ),
                  HINT = '注文明細を追加して最低購入金額を満たしてください';
    END IF;

    IF v_coupon.discountType = 'percent' THEN
        v_discountAmount := ROUND(v_orderSubtotal * v_coupon.discountValue / 100, 2);
    ELSIF v_coupon.discountType = 'fixed' THEN
        v_discountAmount := LEAST(v_coupon.discountValue, v_orderSubtotal);
    ELSE
        RAISE EXCEPTION '未対応の割引種別です: %', v_coupon.discountType
            USING ERRCODE = 'P0010',
                  DETAIL = format(
                      'sp_applyCoupon(orderId=%s, couponCode=%s): discountType=%s はサポート外',
                      p_orderId, p_couponCode, v_coupon.discountType
                  ),
                  HINT = 'discountType は percent または fixed を指定してください';
    END IF;

    INSERT INTO couponRedemptions (couponId, orderId, discountAmount)
    VALUES (v_coupon.couponId, p_orderId, v_discountAmount);

    UPDATE coupons
    SET currentRedemptions = currentRedemptions + 1
    WHERE couponId = v_coupon.couponId;
END;
$$;

COMMENT ON PROCEDURE sp_applyCoupon(INTEGER, VARCHAR) IS '注文にクーポンを適用する（有効性検証・割引額記録）';

CREATE OR REPLACE PROCEDURE sp_recordPayment(
    p_orderId INTEGER,
    p_amount NUMERIC(12, 2),
    p_paymentMethodId INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_orderStatus VARCHAR(20);
    v_paymentMethodActive BOOLEAN;
BEGIN
    IF p_orderId IS NULL OR p_paymentMethodId IS NULL THEN
        RAISE EXCEPTION '注文IDまたは決済手段IDが未指定です'
            USING ERRCODE = 'P0001',
                  DETAIL = format(
                      'sp_recordPayment(orderId=%s, amount=%s, paymentMethodId=%s): orderId と paymentMethodId は必須です',
                      p_orderId, p_amount, p_paymentMethodId
                  ),
                  HINT = '有効な orderId と paymentMethodId を指定してください';
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION '支払金額が不正です（金額: %）', p_amount
            USING ERRCODE = 'P0002',
                  DETAIL = format(
                      'sp_recordPayment(orderId=%s, amount=%s, paymentMethodId=%s): 金額は正の数である必要があります',
                      p_orderId, p_amount, p_paymentMethodId
                  ),
                  HINT = '0より大きい amount を指定してください';
    END IF;

    SELECT o.status
    INTO v_orderStatus
    FROM orders o
    WHERE o.orderId = p_orderId
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION '注文ID % は存在しません', p_orderId
            USING ERRCODE = 'P0003',
                  DETAIL = format(
                      'sp_recordPayment(orderId=%s, amount=%s, paymentMethodId=%s): 注文が見つかりません',
                      p_orderId, p_amount, p_paymentMethodId
                  ),
                  HINT = '存在する orderId を指定してください';
    END IF;

    IF v_orderStatus = 'cancelled' THEN
        RAISE EXCEPTION 'キャンセル済み注文には支払いを記録できません（注文ID: %）', p_orderId
            USING ERRCODE = 'P0004',
                  DETAIL = format(
                      'sp_recordPayment(orderId=%s, amount=%s, paymentMethodId=%s, status=%s)',
                      p_orderId, p_amount, p_paymentMethodId, v_orderStatus
                  ),
                  HINT = '有効な注文に対して支払いを記録してください';
    END IF;

    SELECT pm.isActive
    INTO v_paymentMethodActive
    FROM paymentMethods pm
    WHERE pm.paymentMethodId = p_paymentMethodId;

    IF NOT FOUND THEN
        RAISE EXCEPTION '決済手段ID % は存在しません', p_paymentMethodId
            USING ERRCODE = 'P0005',
                  DETAIL = format(
                      'sp_recordPayment(orderId=%s, amount=%s, paymentMethodId=%s): paymentMethods に該当レコードなし',
                      p_orderId, p_amount, p_paymentMethodId
                  ),
                  HINT = '有効な paymentMethodId を指定してください';
    END IF;

    IF NOT v_paymentMethodActive THEN
        RAISE EXCEPTION '決済手段ID % は無効化されています', p_paymentMethodId
            USING ERRCODE = 'P0006',
                  DETAIL = format(
                      'sp_recordPayment(orderId=%s, amount=%s, paymentMethodId=%s): isActive=FALSE',
                      p_orderId, p_amount, p_paymentMethodId
                  ),
                  HINT = '有効な決済手段を指定してください';
    END IF;

    INSERT INTO payments (orderId, paymentMethodId, amount, status)
    VALUES (p_orderId, p_paymentMethodId, p_amount, 'completed');
END;
$$;

COMMENT ON PROCEDURE sp_recordPayment(INTEGER, NUMERIC, INTEGER) IS '注文の支払いを記録する（決済手段・金額の検証付き）';

CREATE OR REPLACE PROCEDURE sp_generatePayroll(
    p_fiscalYear INTEGER,
    p_month SMALLINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_fiscalYearId INTEGER;
    v_payrollRunId INTEGER;
    v_existingRun BOOLEAN;
    v_employee RECORD;
    v_netPay NUMERIC(10, 2);
BEGIN
    IF p_fiscalYear IS NULL OR p_month IS NULL THEN
        RAISE EXCEPTION '会計年度または月が未指定です'
            USING ERRCODE = 'P0001',
                  DETAIL = format(
                      'sp_generatePayroll(fiscalYear=%s, month=%s): 両方のパラメータが必須です',
                      p_fiscalYear, p_month
                  ),
                  HINT = 'fiscalYear（例: 2024）と month（1〜12）を指定してください';
    END IF;

    IF p_month < 1 OR p_month > 12 THEN
        RAISE EXCEPTION '月の値が不正です（月: %）', p_month
            USING ERRCODE = 'P0002',
                  DETAIL = format(
                      'sp_generatePayroll(fiscalYear=%s, month=%s): month は 1〜12 の範囲である必要があります',
                      p_fiscalYear, p_month
                  ),
                  HINT = '1 から 12 の整数を指定してください';
    END IF;

    SELECT fy.fiscalYearId
    INTO v_fiscalYearId
    FROM fiscalYears fy
    WHERE EXTRACT(YEAR FROM fy.startDate) = p_fiscalYear
       OR fy.fiscalYearCode = p_fiscalYear::TEXT
    ORDER BY fy.fiscalYearId
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION '会計年度 % が見つかりません', p_fiscalYear
            USING ERRCODE = 'P0003',
                  DETAIL = format(
                      'sp_generatePayroll(fiscalYear=%s, month=%s): fiscalYears テーブルに該当年度がありません',
                      p_fiscalYear, p_month
                  ),
                  HINT = 'fiscalYears マスタに会計年度を登録してください';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM payrollRuns pr
        WHERE pr.fiscalYearId = v_fiscalYearId
          AND pr.payrollMonth = p_month
          AND pr.status IN ('draft', 'completed')
    )
    INTO v_existingRun;

    IF v_existingRun THEN
        RAISE EXCEPTION '会計年度 % 月 % の給与計算は既に実行済みです', p_fiscalYear, p_month
            USING ERRCODE = 'P0004',
                  DETAIL = format(
                      'sp_generatePayroll(fiscalYear=%s, month=%s): 重複する payrollRuns が存在します',
                      p_fiscalYear, p_month
                  ),
                  HINT = '既存の給与計算結果を確認するか、別の月を指定してください';
    END IF;

    INSERT INTO payrollRuns (fiscalYearId, payrollMonth, status)
    VALUES (v_fiscalYearId, p_month, 'draft')
    RETURNING payrollRunId INTO v_payrollRunId;

    FOR v_employee IN
        SELECT e.employeeId, e.salary
        FROM employees e
        WHERE e.isActive = TRUE
    LOOP
        v_netPay := v_employee.salary;

        INSERT INTO payrollDetails (
            payrollRunId,
            employeeId,
            baseSalary,
            deductions,
            netPay
        )
        VALUES (
            v_payrollRunId,
            v_employee.employeeId,
            v_employee.salary,
            0,
            v_netPay
        );
    END LOOP;

    UPDATE payrollRuns
    SET status = 'completed'
    WHERE payrollRunId = v_payrollRunId;
END;
$$;

COMMENT ON PROCEDURE sp_generatePayroll(INTEGER, SMALLINT) IS '指定月の給与計算を実行する（在籍中従業員の給与明細を生成）';

CREATE OR REPLACE PROCEDURE sp_restockProduct(
    p_productId INTEGER,
    p_quantity INTEGER,
    p_warehouseId INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_warehouseActive BOOLEAN;
BEGIN
    IF p_productId IS NULL OR p_warehouseId IS NULL THEN
        RAISE EXCEPTION '商品IDまたは倉庫IDが未指定です'
            USING ERRCODE = 'P0001',
                  DETAIL = format(
                      'sp_restockProduct(productId=%s, quantity=%s, warehouseId=%s): productId と warehouseId は必須です',
                      p_productId, p_quantity, p_warehouseId
                  ),
                  HINT = '有効な productId と warehouseId を指定してください';
    END IF;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION '補充数量が不正です（数量: %）', p_quantity
            USING ERRCODE = 'P0002',
                  DETAIL = format(
                      'sp_restockProduct(productId=%s, quantity=%s, warehouseId=%s): quantity は正の整数である必要があります',
                      p_productId, p_quantity, p_warehouseId
                  ),
                  HINT = '1以上の quantity を指定してください';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM products p WHERE p.productId = p_productId) THEN
        RAISE EXCEPTION '商品ID % は存在しません', p_productId
            USING ERRCODE = 'P0003',
                  DETAIL = format(
                      'sp_restockProduct(productId=%s, quantity=%s, warehouseId=%s): products に該当レコードなし',
                      p_productId, p_quantity, p_warehouseId
                  ),
                  HINT = '存在する productId を指定してください';
    END IF;

    SELECT w.isActive
    INTO v_warehouseActive
    FROM warehouseMaster w
    WHERE w.warehouseId = p_warehouseId;

    IF NOT FOUND THEN
        RAISE EXCEPTION '倉庫ID % は存在しません', p_warehouseId
            USING ERRCODE = 'P0004',
                  DETAIL = format(
                      'sp_restockProduct(productId=%s, quantity=%s, warehouseId=%s): warehouseMaster に該当レコードなし',
                      p_productId, p_quantity, p_warehouseId
                  ),
                  HINT = '存在する warehouseId を指定してください';
    END IF;

    IF NOT v_warehouseActive THEN
        RAISE EXCEPTION '倉庫ID % は無効化されています', p_warehouseId
            USING ERRCODE = 'P0005',
                  DETAIL = format(
                      'sp_restockProduct(productId=%s, quantity=%s, warehouseId=%s): isActive=FALSE',
                      p_productId, p_quantity, p_warehouseId
                  ),
                  HINT = '有効な倉庫を指定してください';
    END IF;

    INSERT INTO stockLevels (productId, warehouseId, quantityOnHand, reorderPoint)
    VALUES (p_productId, p_warehouseId, p_quantity, 10)
    ON CONFLICT (productId, warehouseId)
    DO UPDATE SET quantityOnHand = stockLevels.quantityOnHand + EXCLUDED.quantityOnHand;

    UPDATE products
    SET stockQuantity = stockQuantity + p_quantity
    WHERE productId = p_productId;

    INSERT INTO stockMovements (
        productId,
        warehouseId,
        movementType,
        quantity,
        referenceType,
        referenceId
    )
    VALUES (
        p_productId,
        p_warehouseId,
        'restock',
        p_quantity,
        'warehouse',
        p_warehouseId
    );
END;
$$;

COMMENT ON PROCEDURE sp_restockProduct(INTEGER, INTEGER, INTEGER) IS '商品を倉庫に補充する（在庫数更新・入庫履歴記録）';
