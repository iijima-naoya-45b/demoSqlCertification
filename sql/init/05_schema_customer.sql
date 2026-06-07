-- ============================================================
-- 顧客ドメイン (Customer)
-- テーブル数: 9
-- ============================================================

CREATE TABLE customers (
    customerId         SERIAL PRIMARY KEY,
    customerName       VARCHAR(100) NOT NULL,
    email              VARCHAR(255) NOT NULL UNIQUE,
    phone              VARCHAR(20),
    prefecture         VARCHAR(20),
    city               VARCHAR(50),
    registeredAt       DATE NOT NULL DEFAULT CURRENT_DATE,
    membershipTier     VARCHAR(20) NOT NULL DEFAULT 'standard'
        CHECK (membershipTier IN ('standard', 'silver', 'gold', 'platinum')),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    prefectureId       INTEGER REFERENCES prefectures(prefectureId),
    cityId             INTEGER REFERENCES cities(cityId),
    membershipTierId   INTEGER REFERENCES membershipTierMaster(membershipTierId)
);

COMMENT ON TABLE customers IS '顧客マスタ（会員ランク・地域分布演習用）';

CREATE TABLE customerAddresses (
    customerAddressId  SERIAL PRIMARY KEY,
    customerId         INTEGER NOT NULL REFERENCES customers(customerId) ON DELETE CASCADE,
    addressType        VARCHAR(20) NOT NULL DEFAULT 'shipping'
        CHECK (addressType IN ('shipping', 'billing', 'home', 'office')),
    prefectureId       INTEGER REFERENCES prefectures(prefectureId),
    cityId             INTEGER REFERENCES cities(cityId),
    postalCode         VARCHAR(8) NOT NULL,
    addressLine1       VARCHAR(200) NOT NULL,
    addressLine2       VARCHAR(200),
    recipientName      VARCHAR(100),
    phone              VARCHAR(20),
    isDefault          BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customerAddresses IS '顧客住所（配送先・請求先・複数登録）';

CREATE TABLE customerSegments (
    customerSegmentId  SERIAL PRIMARY KEY,
    segmentCode        VARCHAR(20) NOT NULL UNIQUE,
    segmentName        VARCHAR(100) NOT NULL,
    description        TEXT,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customerSegments IS '顧客セグメント定義（RFM・属性別グループ）';

CREATE TABLE customerSegmentMembers (
    customerSegmentMemberId SERIAL PRIMARY KEY,
    customerSegmentId  INTEGER NOT NULL REFERENCES customerSegments(customerSegmentId) ON DELETE CASCADE,
    customerId         INTEGER NOT NULL REFERENCES customers(customerId) ON DELETE CASCADE,
    joinedAt           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (customerSegmentId, customerId)
);

COMMENT ON TABLE customerSegmentMembers IS '顧客セグメント所属（多対多）';

CREATE TABLE customerContacts (
    customerContactId  SERIAL PRIMARY KEY,
    customerId         INTEGER NOT NULL REFERENCES customers(customerId) ON DELETE CASCADE,
    contactName        VARCHAR(100) NOT NULL,
    email              VARCHAR(255),
    phone              VARCHAR(20),
    contactRole        VARCHAR(50),
    isPrimary          BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customerContacts IS '顧客担当者連絡先（法人顧客向け）';

CREATE TABLE loyaltyAccounts (
    loyaltyAccountId   SERIAL PRIMARY KEY,
    customerId         INTEGER NOT NULL REFERENCES customers(customerId) ON DELETE CASCADE UNIQUE,
    pointBalance       INTEGER NOT NULL DEFAULT 0 CHECK (pointBalance >= 0),
    lifetimePointsEarned INTEGER NOT NULL DEFAULT 0 CHECK (lifetimePointsEarned >= 0),
    tierOverrideCode   VARCHAR(20),
    lastActivityAt     TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE loyaltyAccounts IS 'ロイヤルティアカウント（ポイント残高）';

CREATE TABLE loyaltyTransactions (
    loyaltyTransactionId SERIAL PRIMARY KEY,
    loyaltyAccountId   INTEGER NOT NULL REFERENCES loyaltyAccounts(loyaltyAccountId),
    transactionType    VARCHAR(20) NOT NULL
        CHECK (transactionType IN ('earn', 'redeem', 'expire', 'adjustment')),
    pointAmount        INTEGER NOT NULL CHECK (pointAmount <> 0),
    orderId            INTEGER,
    description        VARCHAR(200),
    transactionAt      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE loyaltyTransactions IS 'ポイント取引履歴（付与・利用・失効）';

CREATE TABLE wishlists (
    wishlistId         SERIAL PRIMARY KEY,
    customerId         INTEGER NOT NULL REFERENCES customers(customerId) ON DELETE CASCADE,
    wishlistName       VARCHAR(100) NOT NULL DEFAULT 'マイリスト',
    isPublic           BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE wishlists IS '顧客ウィッシュリスト';

CREATE TABLE wishlistItems (
    wishlistItemId     SERIAL PRIMARY KEY,
    wishlistId         INTEGER NOT NULL REFERENCES wishlists(wishlistId) ON DELETE CASCADE,
    productId          INTEGER NOT NULL REFERENCES products(productId),
    quantity           INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    addedAt            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (wishlistId, productId)
);

COMMENT ON TABLE wishlistItems IS 'ウィッシュリスト明細（商品・数量）';
