-- ============================================================
-- 注文ドメイン (Order)
-- テーブル数: 13
-- ============================================================

CREATE TABLE orders (
    orderId            SERIAL PRIMARY KEY,
    customerId         INTEGER NOT NULL REFERENCES customers(customerId),
    employeeId         INTEGER REFERENCES employees(employeeId),
    orderDate          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status             VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    shippingFee        NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (shippingFee >= 0),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    orderStatusId      INTEGER REFERENCES orderStatusMaster(orderStatusId)
);

COMMENT ON TABLE orders IS '注文ヘッダ（大量データ・日付範囲検索の実行計画演習用）';

CREATE TABLE orderItems (
    orderItemId        SERIAL PRIMARY KEY,
    orderId            INTEGER NOT NULL REFERENCES orders(orderId) ON DELETE CASCADE,
    productId          INTEGER NOT NULL REFERENCES products(productId),
    quantity           INTEGER NOT NULL CHECK (quantity > 0),
    unitPrice          NUMERIC(10, 2) NOT NULL CHECK (unitPrice >= 0),
    discountRate       NUMERIC(5, 4) NOT NULL DEFAULT 0
        CHECK (discountRate >= 0 AND discountRate < 1),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (orderId, productId)
);

COMMENT ON TABLE orderItems IS '注文明細（JOIN・集計の主要ファクトテーブル）';

CREATE TABLE orderStatusHistory (
    orderStatusHistoryId SERIAL PRIMARY KEY,
    orderId            INTEGER NOT NULL REFERENCES orders(orderId) ON DELETE CASCADE,
    orderStatusId      INTEGER REFERENCES orderStatusMaster(orderStatusId),
    status             VARCHAR(20) NOT NULL
        CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    changedAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changedByEmployeeId INTEGER REFERENCES employees(employeeId),
    notes              VARCHAR(200)
);

COMMENT ON TABLE orderStatusHistory IS '注文ステータス変更履歴（正規化・レガシー両対応）';

CREATE TABLE coupons (
    couponId           SERIAL PRIMARY KEY,
    couponCode         VARCHAR(30) NOT NULL UNIQUE,
    couponName         VARCHAR(100) NOT NULL,
    discountTypeId     INTEGER REFERENCES discountTypeMaster(discountTypeId),
    discountValue      NUMERIC(10, 2) NOT NULL CHECK (discountValue >= 0),
    minOrderAmount     NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (minOrderAmount >= 0),
    maxUsageCount      INTEGER CHECK (maxUsageCount IS NULL OR maxUsageCount > 0),
    validFrom          TIMESTAMP NOT NULL,
    validTo            TIMESTAMP NOT NULL,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (validTo > validFrom)
);

COMMENT ON TABLE coupons IS 'クーポンマスタ（値引種別・有効期間）';

CREATE TABLE couponRedemptions (
    couponRedemptionId SERIAL PRIMARY KEY,
    couponId           INTEGER NOT NULL REFERENCES coupons(couponId),
    orderId            INTEGER NOT NULL REFERENCES orders(orderId),
    customerId         INTEGER NOT NULL REFERENCES customers(customerId),
    discountAmount     NUMERIC(10, 2) NOT NULL CHECK (discountAmount >= 0),
    redeemedAt         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (couponId, orderId)
);

COMMENT ON TABLE couponRedemptions IS 'クーポン利用履歴（注文・顧客紐付け）';

CREATE TABLE orderPromotions (
    orderPromotionId   SERIAL PRIMARY KEY,
    orderId            INTEGER NOT NULL REFERENCES orders(orderId) ON DELETE CASCADE,
    campaignId         INTEGER,
    promotionName      VARCHAR(100) NOT NULL,
    discountAmount     NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (discountAmount >= 0),
    appliedAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE orderPromotions IS '注文適用プロモーション（キャンペーン参照）';

CREATE TABLE invoices (
    invoiceId          SERIAL PRIMARY KEY,
    orderId            INTEGER NOT NULL REFERENCES orders(orderId),
    invoiceNumber      VARCHAR(30) NOT NULL UNIQUE,
    invoiceDate        DATE NOT NULL DEFAULT CURRENT_DATE,
    dueDate            DATE NOT NULL,
    subtotalAmount     NUMERIC(12, 2) NOT NULL CHECK (subtotalAmount >= 0),
    taxAmount          NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (taxAmount >= 0),
    totalAmount        NUMERIC(12, 2) NOT NULL CHECK (totalAmount >= 0),
    invoiceStatus      VARCHAR(20) NOT NULL DEFAULT 'issued'
        CHECK (invoiceStatus IN ('draft', 'issued', 'paid', 'void')),
    currencyId         INTEGER NOT NULL REFERENCES currencies(currencyId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (dueDate >= invoiceDate)
);

COMMENT ON TABLE invoices IS '請求書（税込合計・支払期日）';

CREATE TABLE invoiceLines (
    invoiceLineId      SERIAL PRIMARY KEY,
    invoiceId          INTEGER NOT NULL REFERENCES invoices(invoiceId) ON DELETE CASCADE,
    orderItemId        INTEGER REFERENCES orderItems(orderItemId),
    description        VARCHAR(200) NOT NULL,
    quantity           INTEGER NOT NULL CHECK (quantity > 0),
    unitPrice          NUMERIC(10, 2) NOT NULL CHECK (unitPrice >= 0),
    lineAmount         NUMERIC(12, 2) NOT NULL CHECK (lineAmount >= 0),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE invoiceLines IS '請求書明細行';

CREATE TABLE payments (
    paymentId          SERIAL PRIMARY KEY,
    orderId            INTEGER REFERENCES orders(orderId),
    customerId         INTEGER NOT NULL REFERENCES customers(customerId),
    paymentMethodId    INTEGER NOT NULL REFERENCES paymentMethods(paymentMethodId),
    paymentAmount      NUMERIC(12, 2) NOT NULL CHECK (paymentAmount > 0),
    paymentDate        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paymentStatus      VARCHAR(20) NOT NULL DEFAULT 'completed'
        CHECK (paymentStatus IN ('pending', 'completed', 'failed', 'refunded')),
    transactionReference VARCHAR(100),
    currencyId         INTEGER NOT NULL REFERENCES currencies(currencyId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE payments IS '入金記録（決済手段・ステータス）';

CREATE TABLE paymentAllocations (
    paymentAllocationId SERIAL PRIMARY KEY,
    paymentId          INTEGER NOT NULL REFERENCES payments(paymentId) ON DELETE CASCADE,
    invoiceId          INTEGER NOT NULL REFERENCES invoices(invoiceId),
    allocatedAmount    NUMERIC(12, 2) NOT NULL CHECK (allocatedAmount > 0),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (paymentId, invoiceId)
);

COMMENT ON TABLE paymentAllocations IS '入金消込（請求書への充当）';

CREATE TABLE returns (
    returnId           SERIAL PRIMARY KEY,
    orderId            INTEGER NOT NULL REFERENCES orders(orderId),
    customerId         INTEGER NOT NULL REFERENCES customers(customerId),
    returnReasonId     INTEGER REFERENCES returnReasonMaster(returnReasonId),
    returnStatus       VARCHAR(20) NOT NULL DEFAULT 'requested'
        CHECK (returnStatus IN ('requested', 'approved', 'received', 'refunded', 'rejected')),
    requestedAt        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processedAt        TIMESTAMP,
    refundAmount       NUMERIC(12, 2) CHECK (refundAmount IS NULL OR refundAmount >= 0),
    notes              TEXT,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE returns IS '返品ヘッダ（返品理由・返金額）';

CREATE TABLE returnItems (
    returnItemId       SERIAL PRIMARY KEY,
    returnId           INTEGER NOT NULL REFERENCES returns(returnId) ON DELETE CASCADE,
    orderItemId        INTEGER NOT NULL REFERENCES orderItems(orderItemId),
    quantity           INTEGER NOT NULL CHECK (quantity > 0),
    refundAmount       NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (refundAmount >= 0),
    itemCondition      VARCHAR(30),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (returnId, orderItemId)
);

COMMENT ON TABLE returnItems IS '返品明細（注文明細・返金額）';

-- 05_schema_customer.sql で先行定義された loyaltyTransactions.orderId への FK
ALTER TABLE loyaltyTransactions
    ADD CONSTRAINT fk_loyaltyTransactions_orderId
    FOREIGN KEY (orderId) REFERENCES orders(orderId);
