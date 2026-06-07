-- ============================================================
-- マーケティングドメイン (Marketing)
-- テーブル数: 5
-- ============================================================

CREATE TABLE productReviews (
    reviewId           SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId),
    customerId         INTEGER NOT NULL REFERENCES customers(customerId),
    rating             INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment            TEXT,
    reviewedAt         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (productId, customerId)
);

COMMENT ON TABLE productReviews IS '商品レビュー（評価分布・相関サブクエリ演習用）';

CREATE TABLE campaigns (
    campaignId         SERIAL PRIMARY KEY,
    campaignTypeId     INTEGER NOT NULL REFERENCES campaignTypeMaster(campaignTypeId),
    campaignCode       VARCHAR(30) NOT NULL UNIQUE,
    campaignName       VARCHAR(200) NOT NULL,
    startDate          TIMESTAMP NOT NULL,
    endDate            TIMESTAMP NOT NULL,
    discountPercent    NUMERIC(5, 2) CHECK (discountPercent IS NULL OR (discountPercent >= 0 AND discountPercent <= 100)),
    campaignStatus     VARCHAR(20) NOT NULL DEFAULT 'planned'
        CHECK (campaignStatus IN ('planned', 'active', 'paused', 'completed', 'cancelled')),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (endDate > startDate)
);

COMMENT ON TABLE campaigns IS 'マーケティングキャンペーン（種別・期間・割引率）';

CREATE TABLE campaignProducts (
    campaignProductId  SERIAL PRIMARY KEY,
    campaignId         INTEGER NOT NULL REFERENCES campaigns(campaignId) ON DELETE CASCADE,
    productId          INTEGER NOT NULL REFERENCES products(productId),
    promotionalPrice   NUMERIC(10, 2) CHECK (promotionalPrice IS NULL OR promotionalPrice >= 0),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (campaignId, productId)
);

COMMENT ON TABLE campaignProducts IS 'キャンペーン対象商品（特価設定）';

CREATE TABLE newsletters (
    newsletterId       SERIAL PRIMARY KEY,
    subject            VARCHAR(200) NOT NULL,
    bodyHtml           TEXT NOT NULL,
    scheduledAt        TIMESTAMP,
    sentAt             TIMESTAMP,
    newsletterStatus   VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (newsletterStatus IN ('draft', 'scheduled', 'sent', 'cancelled')),
    createdByEmployeeId INTEGER REFERENCES employees(employeeId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE newsletters IS 'メールマガジン（配信スケジュール・送信状態）';

CREATE TABLE emailSubscriptions (
    emailSubscriptionId SERIAL PRIMARY KEY,
    customerId         INTEGER REFERENCES customers(customerId),
    email              VARCHAR(255) NOT NULL UNIQUE,
    subscriptionStatus VARCHAR(20) NOT NULL DEFAULT 'subscribed'
        CHECK (subscriptionStatus IN ('subscribed', 'unsubscribed', 'bounced')),
    subscribedAt       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unsubscribedAt     TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE emailSubscriptions IS 'メール購読管理（オプトイン・解除）';

-- 06_schema_order.sql で先行定義された orderPromotions.campaignId への FK
ALTER TABLE orderPromotions
    ADD CONSTRAINT fk_orderPromotions_campaignId
    FOREIGN KEY (campaignId) REFERENCES campaigns(campaignId);
