-- ============================================================
-- 商品カタログドメイン (Catalog)
-- テーブル数: 12
-- ============================================================

CREATE TABLE categories (
    categoryId         SERIAL PRIMARY KEY,
    categoryName       VARCHAR(100) NOT NULL UNIQUE,
    parentCategoryId   INTEGER REFERENCES categories(categoryId),
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE categories IS '商品カテゴリ（階層構造）';

CREATE TABLE products (
    productId          SERIAL PRIMARY KEY,
    categoryId         INTEGER NOT NULL REFERENCES categories(categoryId),
    brandId            INTEGER REFERENCES brands(brandId),
    manufacturerId     INTEGER REFERENCES manufacturers(manufacturerId),
    skuCode            VARCHAR(50),
    productName        VARCHAR(200) NOT NULL,
    description        TEXT,
    unitPrice          NUMERIC(10, 2) NOT NULL CHECK (unitPrice >= 0),
    stockQuantity      INTEGER NOT NULL DEFAULT 0 CHECK (stockQuantity >= 0),
    isDiscontinued     BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE products IS '商品マスタ（価格帯・在庫フィルタ演習用）';

CREATE TABLE productVariants (
    productVariantId   SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId) ON DELETE CASCADE,
    variantSku         VARCHAR(50) NOT NULL UNIQUE,
    variantName        VARCHAR(200) NOT NULL,
    colorName          VARCHAR(50),
    sizeName           VARCHAR(20),
    unitPrice          NUMERIC(10, 2) CHECK (unitPrice IS NULL OR unitPrice >= 0),
    stockQuantity      INTEGER NOT NULL DEFAULT 0 CHECK (stockQuantity >= 0),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE productVariants IS '商品バリエーション（色・サイズ別 SKU）';

CREATE TABLE attributeDefinitions (
    attributeDefinitionId SERIAL PRIMARY KEY,
    attributeCode      VARCHAR(30) NOT NULL UNIQUE,
    attributeName      VARCHAR(100) NOT NULL,
    dataType           VARCHAR(20) NOT NULL DEFAULT 'text'
        CHECK (dataType IN ('text', 'number', 'boolean', 'date')),
    unitId             INTEGER REFERENCES unitsOfMeasure(unitId),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE attributeDefinitions IS '商品属性定義（仕様・スペック項目）';

CREATE TABLE productAttributes (
    productAttributeId SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId) ON DELETE CASCADE,
    attributeDefinitionId INTEGER NOT NULL REFERENCES attributeDefinitions(attributeDefinitionId),
    attributeValue     TEXT NOT NULL,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (productId, attributeDefinitionId)
);

COMMENT ON TABLE productAttributes IS '商品属性値（属性定義との紐付け）';

CREATE TABLE productImages (
    productImageId     SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId) ON DELETE CASCADE,
    imageUrl           VARCHAR(500) NOT NULL,
    altText            VARCHAR(200),
    sortOrder          INTEGER NOT NULL DEFAULT 0,
    isPrimary          BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE productImages IS '商品画像（表示順・メイン画像フラグ）';

CREATE TABLE productTags (
    productTagId       SERIAL PRIMARY KEY,
    tagName            VARCHAR(50) NOT NULL UNIQUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE productTags IS '商品タグマスタ（検索・分類用）';

CREATE TABLE productTagMappings (
    productTagMappingId SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId) ON DELETE CASCADE,
    productTagId       INTEGER NOT NULL REFERENCES productTags(productTagId) ON DELETE CASCADE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (productId, productTagId)
);

COMMENT ON TABLE productTagMappings IS '商品とタグの中間テーブル';

CREATE TABLE supplierProducts (
    supplierProductId  SERIAL PRIMARY KEY,
    supplierId         INTEGER NOT NULL REFERENCES supplierMaster(supplierId),
    productId          INTEGER NOT NULL REFERENCES products(productId),
    supplierSku        VARCHAR(50),
    unitCost           NUMERIC(10, 2) NOT NULL CHECK (unitCost >= 0),
    leadTimeDays       SMALLINT NOT NULL DEFAULT 7 CHECK (leadTimeDays >= 0),
    isPreferred        BOOLEAN NOT NULL DEFAULT FALSE,
    currencyId         INTEGER NOT NULL REFERENCES currencies(currencyId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (supplierId, productId)
);

COMMENT ON TABLE supplierProducts IS '仕入先別商品情報（原価・リードタイム）';

CREATE TABLE priceHistory (
    priceHistoryId     SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId),
    oldUnitPrice       NUMERIC(10, 2) NOT NULL CHECK (oldUnitPrice >= 0),
    newUnitPrice       NUMERIC(10, 2) NOT NULL CHECK (newUnitPrice >= 0),
    effectiveFrom      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changedByEmployeeId INTEGER REFERENCES employees(employeeId),
    reason             VARCHAR(200),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE priceHistory IS '商品価格改定履歴';

CREATE TABLE stockLevels (
    stockLevelId       SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId),
    warehouseId        INTEGER NOT NULL REFERENCES warehouseMaster(warehouseId),
    locationId         INTEGER REFERENCES locationMaster(locationId),
    quantityOnHand     INTEGER NOT NULL DEFAULT 0 CHECK (quantityOnHand >= 0),
    quantityReserved   INTEGER NOT NULL DEFAULT 0 CHECK (quantityReserved >= 0),
    reorderPoint       INTEGER NOT NULL DEFAULT 0 CHECK (reorderPoint >= 0),
    lastCountedAt      TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE NULLS NOT DISTINCT (productId, warehouseId, locationId)
);

COMMENT ON TABLE stockLevels IS '倉庫別在庫残高（ロケーション単位）';

CREATE TABLE stockMovements (
    stockMovementId    SERIAL PRIMARY KEY,
    productId          INTEGER NOT NULL REFERENCES products(productId),
    warehouseId        INTEGER NOT NULL REFERENCES warehouseMaster(warehouseId),
    movementType       VARCHAR(20) NOT NULL
        CHECK (movementType IN ('receipt', 'shipment', 'adjustment', 'transfer', 'return')),
    quantityChange     INTEGER NOT NULL CHECK (quantityChange <> 0),
    referenceType      VARCHAR(30),
    referenceId        INTEGER,
    movementDate       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId         INTEGER REFERENCES employees(employeeId),
    notes              VARCHAR(200),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE stockMovements IS '在庫移動履歴（入庫・出庫・調整・振替）';
