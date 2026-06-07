-- ============================================================
-- バルクデータ（実行計画・大量集計演習用）
-- generate_series による自動生成
-- ============================================================

-- 追加部署（計 20 部署）
INSERT INTO departments (departmentName, location, budgetAmount)
SELECT
    '事業部門 ' || i,
    (ARRAY['東京', '大阪', '名古屋', '福岡', '札幌'])[1 + (i % 5)],
    20000000 + (i * 3500000)
FROM generate_series(6, 20) AS i
ON CONFLICT (departmentName) DO NOTHING;

-- 追加カテゴリ（計 50 カテゴリ）
INSERT INTO categories (categoryName, parentCategoryId, sortOrder)
SELECT
    'サブカテゴリ ' || i,
    1 + (i % 4),
    100 + i
FROM generate_series(11, 50) AS i
ON CONFLICT (categoryName) DO NOTHING;

-- 追加従業員（計 500 名）
INSERT INTO employees (departmentId, employeeName, email, jobTitle, salary, hireDate, isActive, managerId)
SELECT
    1 + (i % 20),
    '従業員 ' || i,
    'employee' || i || '@example.com',
    (ARRAY['担当', 'リーダー', 'マネージャー', 'スペシャリスト'])[1 + (i % 4)],
    350000 + ((i % 50) * 8000),
    DATE '2015-01-01' + ((i % 3000) * INTERVAL '1 day'),
    (i % 17) <> 0,
    1 + (i % 15)
FROM generate_series(16, 500) AS i
ON CONFLICT (email) DO NOTHING;

-- 追加商品（計 2000 商品）
INSERT INTO products (categoryId, brandId, manufacturerId, skuCode, productName, description, unitPrice, stockQuantity, isDiscontinued)
SELECT
    1 + (i % 50),
    (SELECT brandId FROM brands WHERE brandId = 1 + (i % 20) LIMIT 1),
    (SELECT manufacturerId FROM manufacturers WHERE manufacturerId = 1 + (i % 15) LIMIT 1),
    'SKU-' || lpad(i::text, 6, '0'),
    '商品 ' || i,
    'バルク生成商品 ' || i,
    500 + ((i % 200) * 450),
    (i % 500),
    (i % 47) = 0
FROM generate_series(19, 2000) AS i;

-- 追加顧客（計 10000 名）
INSERT INTO customers (customerName, email, phone, prefecture, city, registeredAt, membershipTier, prefectureId, membershipTierId)
SELECT
    '顧客 ' || i,
    'customer' || i || '@example.com',
    '090-' || lpad((i % 10000)::text, 4, '0') || '-' || lpad(i::text, 4, '0'),
    p.prefectureName,
    '市区町村 ' || (i % 80),
    DATE '2020-01-01' + ((i % 1800) * INTERVAL '1 day'),
    (ARRAY['standard', 'silver', 'gold', 'platinum'])[1 + (i % 4)],
    p.prefectureId,
    mt.membershipTierId
FROM generate_series(16, 10000) AS i
JOIN prefectures p ON p.prefectureId = 1 + (i % 47)
JOIN membershipTierMaster mt ON mt.tierCode = (ARRAY['standard', 'silver', 'gold', 'platinum'])[1 + (i % 4)]
ON CONFLICT (email) DO NOTHING;

-- 追加注文（計 50000 件）
INSERT INTO orders (customerId, employeeId, orderDate, status, shippingFee, orderStatusId)
SELECT
    1 + (i % 10000),
    1 + (i % 500),
    TIMESTAMP '2022-01-01 00:00:00' + ((i % 1000) * INTERVAL '1 day') + ((i % 24) * INTERVAL '1 hour'),
    (ARRAY['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'])[1 + (i % 5)],
    CASE WHEN (i % 3) = 0 THEN 0 ELSE 500 END,
    1 + (i % 5)
FROM generate_series(21, 50000) AS i;

-- 追加注文明細（約 150000 件、注文あたり 3 明細）
ALTER TABLE orderItems DISABLE TRIGGER trg_orderItems_stock;

INSERT INTO orderItems (orderId, productId, quantity, unitPrice, discountRate)
SELECT
    o.orderId,
    1 + ((o.orderId * 7 + line.lineNo * 13) % 2000),
    1 + (line.lineNo % 4),
    500 + (((o.orderId * 7 + line.lineNo * 13) % 2000) * 45),
    CASE WHEN (o.orderId % 10) = 0 THEN 0.1 ELSE 0 END
FROM generate_series(21, 50000) AS o(orderId)
CROSS JOIN generate_series(1, 3) AS line(lineNo)
ON CONFLICT (orderId, productId) DO NOTHING;

ALTER TABLE orderItems ENABLE TRIGGER trg_orderItems_stock;

-- 衝突で減った明細を補完
ALTER TABLE orderItems DISABLE TRIGGER trg_orderItems_stock;

INSERT INTO orderItems (orderId, productId, quantity, unitPrice, discountRate)
SELECT
    o.orderId,
    1 + ((o.orderId + s.i) % 2000),
    1,
    1000,
    0
FROM orders o
CROSS JOIN generate_series(1, 2) AS s(i)
WHERE o.orderId >= 21
  AND (SELECT COUNT(*) FROM orderItems oi WHERE oi.orderId = o.orderId) < 2
ON CONFLICT (orderId, productId) DO NOTHING;

ALTER TABLE orderItems ENABLE TRIGGER trg_orderItems_stock;

-- 追加レビュー（計 20000 件、productId × customerId の一意組み合わせ）
INSERT INTO productReviews (productId, customerId, rating, comment, reviewedAt)
SELECT
    1 + ((i - 14) % 2000),
    1 + ((i - 14) / 2000),
    1 + (i % 5),
    'バルクレビュー ' || i,
    TIMESTAMP '2023-01-01 00:00:00' + (i * INTERVAL '2 hours')
FROM generate_series(14, 20000) AS i
ON CONFLICT (productId, customerId) DO NOTHING;

-- 追加給与履歴（計 2000 件）
INSERT INTO salaryHistory (employeeId, oldSalary, newSalary, changedAt, reason)
SELECT
    1 + (i % 500),
    350000 + ((i % 30) * 5000),
    360000 + ((i % 30) * 5000),
    TIMESTAMP '2020-01-01 00:00:00' + (i * INTERVAL '15 days'),
    (ARRAY['定期昇給', '昇格', '業績評価', '役職変更'])[1 + (i % 4)]
FROM generate_series(9, 2000) AS i;

-- 在庫残高（商品 × 倉庫のサンプル）
INSERT INTO stockLevels (productId, warehouseId, locationId, quantityOnHand, quantityReserved, reorderPoint)
SELECT
    p.productId,
    w.warehouseId,
    (SELECT locationId FROM locationMaster lm WHERE lm.warehouseId = w.warehouseId ORDER BY lm.locationId LIMIT 1),
    (p.productId % 300) + 10,
    (p.productId % 20),
    20
FROM products p
CROSS JOIN warehouseMaster w
WHERE p.productId <= 500
ON CONFLICT (productId, warehouseId, locationId) DO NOTHING;

-- 在庫移動履歴（5000 件）
INSERT INTO stockMovements (productId, warehouseId, movementType, quantityChange, referenceType, referenceId, movementDate, employeeId)
SELECT
    1 + (i % 2000),
    1 + (i % 5),
    (ARRAY['receipt', 'shipment', 'adjustment', 'transfer', 'return'])[1 + (i % 5)],
    CASE WHEN (i % 2) = 0 THEN (i % 50) + 1 ELSE -((i % 30) + 1) END,
    'bulk_seed',
    i,
    TIMESTAMP '2023-01-01 00:00:00' + (i * INTERVAL '3 hours'),
    1 + (i % 500)
FROM generate_series(1, 5000) AS i;

-- 顧客住所（10000 件）
INSERT INTO customerAddresses (customerId, addressType, prefectureId, postalCode, addressLine1, recipientName, isDefault)
SELECT
    c.customerId,
    (ARRAY['shipping', 'billing', 'home', 'office'])[1 + (c.customerId % 4)],
    c.prefectureId,
    lpad((100 + (c.customerId % 899))::text, 3, '0') || '-' || lpad((c.customerId % 9999)::text, 4, '0'),
    '住所 ' || c.customerId || ' 番地',
    c.customerName,
    TRUE
FROM customers c
WHERE c.prefectureId IS NOT NULL;

-- 出荷（20000 件、出荷済み注文のみ）
INSERT INTO shipments (orderId, shippingCarrierId, shippingMethodId, trackingNumber, shipmentStatus, shippedAt, deliveredAt)
SELECT
    o.orderId,
    1 + (o.orderId % 5),
    1 + (o.orderId % 9),
    'TRK-' || lpad(o.orderId::text, 10, '0'),
    CASE o.status
        WHEN 'delivered' THEN 'delivered'
        WHEN 'shipped' THEN 'in_transit'
        WHEN 'cancelled' THEN 'cancelled'
        ELSE 'pending'
    END,
    CASE WHEN o.status IN ('shipped', 'delivered') THEN o.orderDate + INTERVAL '1 day' ELSE NULL END,
    CASE WHEN o.status = 'delivered' THEN o.orderDate + INTERVAL '3 days' ELSE NULL END
FROM orders o
WHERE o.orderId >= 21
  AND o.status IN ('shipped', 'delivered')
  AND o.orderId <= 20020;

-- 請求書（30000 件）
INSERT INTO invoices (orderId, invoiceNumber, invoiceDate, dueDate, subtotalAmount, taxAmount, totalAmount, invoiceStatus, currencyId)
SELECT
    o.orderId,
    'INV-' || lpad(o.orderId::text, 8, '0'),
    o.orderDate::date,
    o.orderDate::date + 30,
    5000 + (o.orderId % 100000),
    (5000 + (o.orderId % 100000)) * 0.1,
    (5000 + (o.orderId % 100000)) * 1.1,
    (ARRAY['draft', 'issued', 'paid', 'void'])[1 + (o.orderId % 4)],
    (SELECT currencyId FROM currencies WHERE currencyCode = 'JPY' LIMIT 1)
FROM orders o
WHERE o.orderId >= 21
  AND o.orderId <= 30020
ON CONFLICT (invoiceNumber) DO NOTHING;

-- 入金（25000 件）
INSERT INTO payments (orderId, customerId, paymentMethodId, paymentAmount, paymentDate, paymentStatus, transactionReference, currencyId)
SELECT
    o.orderId,
    o.customerId,
    1 + (o.orderId % 8),
    5500 + (o.orderId % 100000),
    o.orderDate + INTERVAL '1 hour',
    (ARRAY['pending', 'completed', 'failed', 'refunded'])[1 + (o.orderId % 4)],
    'TXN-' || lpad(o.orderId::text, 10, '0'),
    (SELECT currencyId FROM currencies WHERE currencyCode = 'JPY' LIMIT 1)
FROM orders o
WHERE o.orderId >= 21
  AND o.orderId <= 25020;

-- ロイヤルティアカウント（顧客全員）
INSERT INTO loyaltyAccounts (customerId, pointBalance, lifetimePointsEarned, lastActivityAt)
SELECT
    c.customerId,
    (c.customerId % 5000),
    (c.customerId % 20000) + 100,
    TIMESTAMP '2024-01-01 00:00:00' + (c.customerId * INTERVAL '1 hour')
FROM customers c
ON CONFLICT (customerId) DO NOTHING;

-- キャンペーン（50 件）
INSERT INTO campaigns (campaignTypeId, campaignCode, campaignName, startDate, endDate, discountPercent, campaignStatus)
SELECT
    1 + (i % 6),
    'CAMP-' || lpad(i::text, 4, '0'),
    'キャンペーン ' || i,
    TIMESTAMP '2024-01-01 00:00:00' + (i * INTERVAL '7 days'),
    TIMESTAMP '2024-01-01 00:00:00' + (i * INTERVAL '7 days') + INTERVAL '14 days',
    5 + (i % 20),
    (ARRAY['planned', 'active', 'paused', 'completed', 'cancelled'])[1 + (i % 5)]
FROM generate_series(1, 50) AS i
ON CONFLICT (campaignCode) DO NOTHING;

-- 仕訳（5000 件）
INSERT INTO journalEntries (fiscalYearId, entryNumber, entryDate, description, entryStatus, createdByEmployeeId)
SELECT
    1 + (i % 4),
    'JE-' || lpad(i::text, 8, '0'),
    DATE '2024-01-01' + ((i % 365) * INTERVAL '1 day'),
    '自動仕訳 ' || i,
    (ARRAY['draft', 'posted', 'reversed'])[1 + (i % 3)],
    1 + (i % 500)
FROM generate_series(1, 5000) AS i
ON CONFLICT (entryNumber) DO NOTHING;

-- ロール（10 件）
INSERT INTO roles (roleCode, roleName, description) VALUES
    ('admin', 'システム管理者', '全機能へのアクセス'),
    ('manager', 'マネージャー', '部門管理権限'),
    ('sales', '営業担当', '注文・顧客管理'),
    ('engineer', 'エンジニア', '開発・システム管理'),
    ('hr', '人事担当', '人事データ管理'),
    ('finance', '経理担当', '財務データ管理'),
    ('support', 'サポート担当', 'カスタマーサポート'),
    ('viewer', '閲覧者', '読み取り専用'),
    ('marketing', 'マーケティング', 'キャンペーン管理'),
    ('warehouse', '倉庫担当', '在庫・出荷管理')
ON CONFLICT (roleCode) DO NOTHING;

-- ユーザーアカウント（500 件: 従業員 300 + 顧客 200）
INSERT INTO userAccounts (employeeId, customerId, username, email, passwordHash, isActive, lastLoginAt)
SELECT
    e.employeeId,
    NULL,
    'emp_' || e.employeeId,
    e.email,
    '$2a$10$dummyhashforexercises000000000000000000000',
    e.isActive,
    TIMESTAMP '2024-06-01 00:00:00' + (e.employeeId * INTERVAL '1 hour')
FROM employees e
WHERE e.employeeId <= 300
ON CONFLICT (username) DO NOTHING;

INSERT INTO userAccounts (employeeId, customerId, username, email, passwordHash, isActive, lastLoginAt)
SELECT
    NULL,
    c.customerId,
    'cust_' || c.customerId,
    c.email,
    '$2a$10$dummyhashforexercises000000000000000000000',
    TRUE,
    TIMESTAMP '2024-06-01 00:00:00' + (c.customerId * INTERVAL '30 minutes')
FROM customers c
WHERE c.customerId <= 200
ON CONFLICT (username) DO NOTHING;

-- 監査ログ（10000 件）
INSERT INTO auditLogs (userAccountId, tableName, recordId, actionType, oldValues, newValues, ipAddress, occurredAt)
SELECT
    1 + (i % 500),
    (ARRAY['orders', 'customers', 'products', 'employees', 'payments'])[1 + (i % 5)],
    1 + (i % 10000),
    (ARRAY['INSERT', 'UPDATE', 'DELETE', 'SELECT'])[1 + (i % 4)],
    NULL,
    jsonb_build_object('seed', i, 'bulk', TRUE),
    ('192.168.' || (i % 255) || '.' || ((i * 7) % 255))::inet,
    TIMESTAMP '2024-01-01 00:00:00' + (i * INTERVAL '30 minutes')
FROM generate_series(1, 10000) AS i;
