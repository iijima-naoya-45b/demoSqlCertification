-- ============================================================
-- マスター / 参照テーブル (Master / Reference)
-- 日本向け EC + 人事 演習用の共通マスター定義
-- テーブル数: 35
-- ============================================================

-- ------------------------------------------------------------
-- 地理・地域
-- ------------------------------------------------------------

CREATE TABLE countries (
    countryId          SERIAL PRIMARY KEY,
    countryCode        CHAR(2) NOT NULL UNIQUE,
    countryNameJa      VARCHAR(100) NOT NULL,
    countryNameEn      VARCHAR(100) NOT NULL,
    phoneCountryCode   VARCHAR(5),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE countries IS '国マスタ（ISO 3166-1 alpha-2 コード管理）';

CREATE TABLE prefectures (
    prefectureId       SERIAL PRIMARY KEY,
    countryId          INTEGER NOT NULL REFERENCES countries(countryId),
    prefectureCode     CHAR(2) NOT NULL,
    prefectureName     VARCHAR(20) NOT NULL,
    regionName         VARCHAR(20),
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (countryId, prefectureCode)
);

COMMENT ON TABLE prefectures IS '都道府県マスタ（国マスタへの外部キー）';

CREATE TABLE cities (
    cityId             SERIAL PRIMARY KEY,
    prefectureId       INTEGER NOT NULL REFERENCES prefectures(prefectureId),
    cityName           VARCHAR(100) NOT NULL,
    cityNameKana       VARCHAR(200),
    postalCodePrefix   VARCHAR(3),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (prefectureId, cityName)
);

COMMENT ON TABLE cities IS '市区町村マスタ（都道府県マスタへの外部キー）';

-- ------------------------------------------------------------
-- 会計・税務
-- ------------------------------------------------------------

CREATE TABLE currencies (
    currencyId         SERIAL PRIMARY KEY,
    currencyCode       CHAR(3) NOT NULL UNIQUE,
    currencyName       VARCHAR(50) NOT NULL,
    currencySymbol     VARCHAR(5),
    decimalPlaces      SMALLINT NOT NULL DEFAULT 0 CHECK (decimalPlaces >= 0 AND decimalPlaces <= 4),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE currencies IS '通貨マスタ（ISO 4217 コード管理）';

CREATE TABLE taxRates (
    taxRateId          SERIAL PRIMARY KEY,
    countryId          INTEGER NOT NULL REFERENCES countries(countryId),
    taxType            VARCHAR(30) NOT NULL,
    ratePercent        NUMERIC(5, 2) NOT NULL CHECK (ratePercent >= 0 AND ratePercent <= 100),
    effectiveFrom      DATE NOT NULL,
    effectiveTo        DATE,
    description        VARCHAR(200),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (effectiveTo IS NULL OR effectiveTo >= effectiveFrom)
);

COMMENT ON TABLE taxRates IS '税率マスタ（適用期間・国別の消費税・軽減税率など）';

CREATE TABLE fiscalYears (
    fiscalYearId       SERIAL PRIMARY KEY,
    fiscalYearCode     VARCHAR(10) NOT NULL UNIQUE,
    startDate          DATE NOT NULL,
    endDate            DATE NOT NULL,
    isClosed           BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (endDate > startDate)
);

COMMENT ON TABLE fiscalYears IS '会計年度マスタ（決算期間の参照用）';

CREATE TABLE holidays (
    holidayId          SERIAL PRIMARY KEY,
    countryId          INTEGER NOT NULL REFERENCES countries(countryId),
    prefectureId       INTEGER REFERENCES prefectures(prefectureId),
    holidayDate        DATE NOT NULL,
    holidayName        VARCHAR(100) NOT NULL,
    holidayType        VARCHAR(30) NOT NULL DEFAULT 'national',
    isSubstitute       BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE holidays IS '祝日・休業日マスタ（全国祝日・地域限定休業日）';

-- ------------------------------------------------------------
-- 決済・支払
-- ------------------------------------------------------------

CREATE TABLE paymentMethods (
    paymentMethodId    SERIAL PRIMARY KEY,
    paymentMethodCode  VARCHAR(20) NOT NULL UNIQUE,
    paymentMethodName  VARCHAR(100) NOT NULL,
    requiresCardInfo   BOOLEAN NOT NULL DEFAULT FALSE,
    settlementDays     SMALLINT NOT NULL DEFAULT 0 CHECK (settlementDays >= 0),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE paymentMethods IS '決済手段マスタ（クレジット・銀行振込・代引きなど）';

CREATE TABLE paymentTerms (
    paymentTermId      SERIAL PRIMARY KEY,
    paymentTermCode    VARCHAR(20) NOT NULL UNIQUE,
    paymentTermName    VARCHAR(100) NOT NULL,
    dueDays            SMALLINT NOT NULL DEFAULT 30 CHECK (dueDays >= 0),
    discountDays       SMALLINT CHECK (discountDays >= 0),
    discountPercent    NUMERIC(5, 2) CHECK (discountPercent >= 0 AND discountPercent <= 100),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE paymentTerms IS '支払条件マスタ（締日・支払サイト・早期割引）';

-- ------------------------------------------------------------
-- 配送・物流
-- ------------------------------------------------------------

CREATE TABLE shippingCarriers (
    shippingCarrierId  SERIAL PRIMARY KEY,
    carrierCode        VARCHAR(20) NOT NULL UNIQUE,
    carrierName        VARCHAR(100) NOT NULL,
    trackingUrlTemplate VARCHAR(500),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE shippingCarriers IS '配送業者マスタ（ヤマト・佐川・日本郵便など）';

CREATE TABLE shippingMethods (
    shippingMethodId   SERIAL PRIMARY KEY,
    shippingCarrierId  INTEGER NOT NULL REFERENCES shippingCarriers(shippingCarrierId),
    methodCode         VARCHAR(20) NOT NULL,
    methodName         VARCHAR(100) NOT NULL,
    baseFee            NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (baseFee >= 0),
    estimatedDaysMin   SMALLINT NOT NULL DEFAULT 1 CHECK (estimatedDaysMin >= 0),
    estimatedDaysMax   SMALLINT NOT NULL DEFAULT 3 CHECK (estimatedDaysMax >= estimatedDaysMin),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (shippingCarrierId, methodCode)
);

COMMENT ON TABLE shippingMethods IS '配送方法マスタ（配送業者・料金・リードタイム）';

CREATE TABLE deliveryTimeSlots (
    deliveryTimeSlotId SERIAL PRIMARY KEY,
    slotCode           VARCHAR(20) NOT NULL UNIQUE,
    slotName           VARCHAR(50) NOT NULL,
    startTime          TIME NOT NULL,
    endTime            TIME NOT NULL,
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (endTime > startTime)
);

COMMENT ON TABLE deliveryTimeSlots IS '配送時間帯マスタ（午前・14-16時・18-20時など）';

-- ------------------------------------------------------------
-- EC 業務ステータス・区分
-- ------------------------------------------------------------

CREATE TABLE orderStatusMaster (
    orderStatusId      SERIAL PRIMARY KEY,
    statusCode         VARCHAR(20) NOT NULL UNIQUE,
    statusName         VARCHAR(50) NOT NULL,
    statusCategory     VARCHAR(30) NOT NULL,
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isTerminal         BOOLEAN NOT NULL DEFAULT FALSE,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE orderStatusMaster IS '注文ステータスマスタ（受付・出荷・完了・キャンセルなど）';

CREATE TABLE membershipTierMaster (
    membershipTierId   SERIAL PRIMARY KEY,
    tierCode           VARCHAR(20) NOT NULL UNIQUE,
    tierName           VARCHAR(50) NOT NULL,
    minAnnualSpend     NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (minAnnualSpend >= 0),
    discountPercent    NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (discountPercent >= 0 AND discountPercent <= 100),
    pointMultiplier    NUMERIC(4, 2) NOT NULL DEFAULT 1.00 CHECK (pointMultiplier >= 0),
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE membershipTierMaster IS '会員ランクマスタ（standard / silver / gold / platinum 等）';

CREATE TABLE productStatusMaster (
    productStatusId    SERIAL PRIMARY KEY,
    statusCode         VARCHAR(20) NOT NULL UNIQUE,
    statusName         VARCHAR(50) NOT NULL,
    allowsSale         BOOLEAN NOT NULL DEFAULT TRUE,
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE productStatusMaster IS '商品ステータスマスタ（販売中・入荷待ち・廃番など）';

CREATE TABLE returnReasonMaster (
    returnReasonId     SERIAL PRIMARY KEY,
    reasonCode         VARCHAR(20) NOT NULL UNIQUE,
    reasonName         VARCHAR(100) NOT NULL,
    requiresInspection BOOLEAN NOT NULL DEFAULT FALSE,
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE returnReasonMaster IS '返品理由マスタ（不良品・誤配送・お客様都合など）';

CREATE TABLE discountTypeMaster (
    discountTypeId     SERIAL PRIMARY KEY,
    discountTypeCode   VARCHAR(20) NOT NULL UNIQUE,
    discountTypeName   VARCHAR(100) NOT NULL,
    calculationMethod  VARCHAR(30) NOT NULL,
    isStackable        BOOLEAN NOT NULL DEFAULT FALSE,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE discountTypeMaster IS '値引種別マスタ（クーポン・会員割引・キャンペーンなど）';

CREATE TABLE unitsOfMeasure (
    unitId             SERIAL PRIMARY KEY,
    unitCode           VARCHAR(10) NOT NULL UNIQUE,
    unitName           VARCHAR(50) NOT NULL,
    unitSymbol         VARCHAR(10),
    isBaseUnit         BOOLEAN NOT NULL DEFAULT FALSE,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE unitsOfMeasure IS '数量単位マスタ（個・箱・kg・L など）';

-- ------------------------------------------------------------
-- 商品・調達
-- ------------------------------------------------------------

CREATE TABLE brands (
    brandId            SERIAL PRIMARY KEY,
    brandCode          VARCHAR(20) NOT NULL UNIQUE,
    brandName          VARCHAR(100) NOT NULL,
    brandNameKana      VARCHAR(200),
    countryId          INTEGER REFERENCES countries(countryId),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE brands IS 'ブランドマスタ（商品ブランドの参照用）';

CREATE TABLE manufacturers (
    manufacturerId     SERIAL PRIMARY KEY,
    manufacturerCode   VARCHAR(20) NOT NULL UNIQUE,
    manufacturerName   VARCHAR(200) NOT NULL,
    countryId          INTEGER REFERENCES countries(countryId),
    websiteUrl         VARCHAR(500),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE manufacturers IS '製造元マスタ（メーカー情報の参照用）';

CREATE TABLE supplierMaster (
    supplierId         SERIAL PRIMARY KEY,
    supplierCode       VARCHAR(20) NOT NULL UNIQUE,
    supplierName       VARCHAR(200) NOT NULL,
    supplierNameKana   VARCHAR(200),
    countryId          INTEGER NOT NULL REFERENCES countries(countryId),
    currencyId         INTEGER NOT NULL REFERENCES currencies(currencyId),
    paymentTermId      INTEGER REFERENCES paymentTerms(paymentTermId),
    contactEmail       VARCHAR(255),
    contactPhone       VARCHAR(20),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE supplierMaster IS '仕入先マスタ（国・通貨・支払条件の参照）';

CREATE TABLE warehouseMaster (
    warehouseId        SERIAL PRIMARY KEY,
    warehouseCode      VARCHAR(20) NOT NULL UNIQUE,
    warehouseName      VARCHAR(100) NOT NULL,
    prefectureId         INTEGER NOT NULL REFERENCES prefectures(prefectureId),
    postalCode         VARCHAR(8) NOT NULL,
    addressLine1       VARCHAR(200) NOT NULL,
    addressLine2       VARCHAR(200),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE warehouseMaster IS '倉庫マスタ（物流拠点・所在地）';

CREATE TABLE locationMaster (
    locationId         SERIAL PRIMARY KEY,
    warehouseId        INTEGER NOT NULL REFERENCES warehouseMaster(warehouseId),
    locationCode       VARCHAR(30) NOT NULL,
    locationType       VARCHAR(30) NOT NULL DEFAULT 'shelf',
    aisle              VARCHAR(10),
    rack               VARCHAR(10),
    shelf              VARCHAR(10),
    capacityUnits      INTEGER CHECK (capacityUnits IS NULL OR capacityUnits > 0),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (warehouseId, locationCode)
);

COMMENT ON TABLE locationMaster IS 'ロケーションマスタ（倉庫内の棚・ピッキングエリア）';

-- ------------------------------------------------------------
-- 人事
-- ------------------------------------------------------------

CREATE TABLE jobGradeMaster (
    jobGradeId         SERIAL PRIMARY KEY,
    gradeCode          VARCHAR(20) NOT NULL UNIQUE,
    gradeName          VARCHAR(50) NOT NULL,
    minSalary          NUMERIC(10, 2) CHECK (minSalary IS NULL OR minSalary >= 0),
    maxSalary          NUMERIC(10, 2) CHECK (maxSalary IS NULL OR maxSalary >= 0),
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (minSalary IS NULL OR maxSalary IS NULL OR maxSalary >= minSalary)
);

COMMENT ON TABLE jobGradeMaster IS '職級マスタ（等級・想定給与レンジ）';

CREATE TABLE employmentTypeMaster (
    employmentTypeId   SERIAL PRIMARY KEY,
    typeCode           VARCHAR(20) NOT NULL UNIQUE,
    typeName           VARCHAR(50) NOT NULL,
    isFullTime         BOOLEAN NOT NULL DEFAULT TRUE,
    contractMonths     SMALLINT CHECK (contractMonths IS NULL OR contractMonths > 0),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE employmentTypeMaster IS '雇用形態マスタ（正社員・契約・派遣・パートなど）';

CREATE TABLE leaveTypeMaster (
    leaveTypeId        SERIAL PRIMARY KEY,
    leaveTypeCode      VARCHAR(20) NOT NULL UNIQUE,
    leaveTypeName      VARCHAR(50) NOT NULL,
    isPaid             BOOLEAN NOT NULL DEFAULT TRUE,
    maxDaysPerYear     SMALLINT CHECK (maxDaysPerYear IS NULL OR maxDaysPerYear >= 0),
    requiresApproval   BOOLEAN NOT NULL DEFAULT TRUE,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE leaveTypeMaster IS '休暇種別マスタ（年次有給・特別休暇・育児休業など）';

CREATE TABLE positionMaster (
    positionId         SERIAL PRIMARY KEY,
    positionCode       VARCHAR(20) NOT NULL UNIQUE,
    positionName       VARCHAR(100) NOT NULL,
    jobGradeId         INTEGER REFERENCES jobGradeMaster(jobGradeId),
    departmentCategory VARCHAR(50),
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE positionMaster IS '役職マスタ（職級との紐付け）';

CREATE TABLE skillMaster (
    skillId            SERIAL PRIMARY KEY,
    skillCode          VARCHAR(20) NOT NULL UNIQUE,
    skillName          VARCHAR(100) NOT NULL,
    skillCategory      VARCHAR(50),
    proficiencyLevels  SMALLINT NOT NULL DEFAULT 5 CHECK (proficiencyLevels >= 1 AND proficiencyLevels <= 10),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE skillMaster IS 'スキルマスタ（技術・語学・資格カテゴリ）';

CREATE TABLE educationLevelMaster (
    educationLevelId   SERIAL PRIMARY KEY,
    levelCode          VARCHAR(20) NOT NULL UNIQUE,
    levelName          VARCHAR(50) NOT NULL,
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE educationLevelMaster IS '学歴マスタ（高校・短大・大学・大学院など）';

-- ------------------------------------------------------------
-- 経理・マーケティング・業種
-- ------------------------------------------------------------

CREATE TABLE accountTypeMaster (
    accountTypeId      SERIAL PRIMARY KEY,
    accountTypeCode    VARCHAR(20) NOT NULL UNIQUE,
    accountTypeName    VARCHAR(100) NOT NULL,
    normalBalance      VARCHAR(10) NOT NULL CHECK (normalBalance IN ('debit', 'credit')),
    statementSection   VARCHAR(30) NOT NULL,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE accountTypeMaster IS '勘定科目区分マスタ（資産・負債・収益・費用）';

CREATE TABLE expenseCategoryMaster (
    expenseCategoryId  SERIAL PRIMARY KEY,
    categoryCode       VARCHAR(20) NOT NULL UNIQUE,
    categoryName       VARCHAR(100) NOT NULL,
    parentCategoryId   INTEGER REFERENCES expenseCategoryMaster(expenseCategoryId),
    accountTypeId      INTEGER REFERENCES accountTypeMaster(accountTypeId),
    isReimbursable     BOOLEAN NOT NULL DEFAULT TRUE,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE expenseCategoryMaster IS '経費カテゴリマスタ（階層構造・勘定科目区分への参照）';

CREATE TABLE campaignTypeMaster (
    campaignTypeId     SERIAL PRIMARY KEY,
    campaignTypeCode   VARCHAR(20) NOT NULL UNIQUE,
    campaignTypeName   VARCHAR(100) NOT NULL,
    defaultDurationDays SMALLINT NOT NULL DEFAULT 30 CHECK (defaultDurationDays > 0),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE campaignTypeMaster IS 'キャンペーン種別マスタ（セール・新規会員・ポイント還元など）';

CREATE TABLE industryTypeMaster (
    industryTypeId     SERIAL PRIMARY KEY,
    industryCode       VARCHAR(10) NOT NULL UNIQUE,
    industryName       VARCHAR(100) NOT NULL,
    industryCategory   VARCHAR(50),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE industryTypeMaster IS '業種マスタ（日本標準産業分類ベースの参照用）';

CREATE TABLE transactionTypeMaster (
    transactionTypeId  SERIAL PRIMARY KEY,
    transactionTypeCode VARCHAR(20) NOT NULL UNIQUE,
    transactionTypeName VARCHAR(100) NOT NULL,
    debitCreditIndicator CHAR(1) NOT NULL CHECK (debitCreditIndicator IN ('D', 'C')),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE transactionTypeMaster IS '取引種別マスタ（売上・返金・入金・出金など）';

CREATE TABLE bankMaster (
    bankId             SERIAL PRIMARY KEY,
    bankCode           VARCHAR(4) NOT NULL,
    bankName           VARCHAR(100) NOT NULL,
    bankNameKana       VARCHAR(200),
    branchRequired     BOOLEAN NOT NULL DEFAULT TRUE,
    countryId          INTEGER NOT NULL REFERENCES countries(countryId),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (countryId, bankCode)
);

COMMENT ON TABLE bankMaster IS '金融機関マスタ（銀行コード・国別管理）';
