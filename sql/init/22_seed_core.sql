-- ============================================================
-- コアデータ（演習問題互換）
-- ID 1〜N のレコードは演習・解答との互換性のため維持する
-- ============================================================

-- 部署
INSERT INTO departments (departmentName, location, budgetAmount) VALUES
    ('営業部', '東京', 50000000),
    ('開発部', '大阪', 80000000),
    ('人事部', '東京', 30000000),
    ('マーケティング部', '名古屋', 45000000),
    ('カスタマーサポート部', '福岡', 35000000)
ON CONFLICT (departmentName) DO NOTHING;

-- 従業員（managerId は後で更新）
INSERT INTO employees (departmentId, employeeName, email, jobTitle, salary, hireDate, isActive) VALUES
    (1, '田中 太郎', 'tanaka@example.com', '営業部長', 850000, '2018-04-01', TRUE),
    (1, '佐藤 花子', 'sato@example.com', '営業マネージャー', 650000, '2019-06-15', TRUE),
    (1, '鈴木 一郎', 'suzuki@example.com', '営業担当', 450000, '2021-03-01', TRUE),
    (1, '高橋 美咲', 'takahashi@example.com', '営業担当', 420000, '2022-01-10', TRUE),
    (2, '伊藤 健太', 'ito@example.com', '開発部長', 900000, '2017-08-01', TRUE),
    (2, '渡辺 直樹', 'watanabe@example.com', 'シニアエンジニア', 750000, '2019-02-20', TRUE),
    (2, '中村 さくら', 'nakamura@example.com', 'エンジニア', 550000, '2020-11-01', TRUE),
    (2, '小林 大輔', 'kobayashi@example.com', 'エンジニア', 520000, '2021-07-15', TRUE),
    (3, '加藤 由美', 'kato@example.com', '人事部長', 700000, '2018-10-01', TRUE),
    (3, '吉田 誠', 'yoshida@example.com', '人事担当', 480000, '2020-04-01', TRUE),
    (4, '山本 あかり', 'yamamoto@example.com', 'マーケ部長', 720000, '2019-01-15', TRUE),
    (4, '松本 翔', 'matsumoto@example.com', 'マーケター', 500000, '2021-09-01', TRUE),
    (5, '井上 真理', 'inoue@example.com', 'CS部長', 680000, '2018-12-01', TRUE),
    (5, '木村 拓也', 'kimura@example.com', 'CS担当', 400000, '2022-06-01', TRUE),
    (2, '林 優子', 'hayashi@example.com', 'エンジニア', 530000, '2023-02-01', FALSE)
ON CONFLICT (email) DO NOTHING;

UPDATE employees SET managerId = 1 WHERE employeeId IN (2, 3, 4);
UPDATE employees SET managerId = 5 WHERE employeeId IN (6, 7, 8, 15);
UPDATE employees SET managerId = 9 WHERE employeeId = 10;
UPDATE employees SET managerId = 11 WHERE employeeId = 12;
UPDATE employees SET managerId = 13 WHERE employeeId = 14;

-- カテゴリ
INSERT INTO categories (categoryName, parentCategoryId, sortOrder) VALUES
    ('電子機器', NULL, 1),
    ('書籍', NULL, 2),
    ('衣類', NULL, 3),
    ('食品', NULL, 4),
    ('スマートフォン', 1, 10),
    ('ノートPC', 1, 11),
    ('プログラミング', 2, 20),
    ('ビジネス書', 2, 21),
    ('メンズ', 3, 30),
    ('レディース', 3, 31)
ON CONFLICT (categoryName) DO NOTHING;

-- 商品（brandId / manufacturerId を先頭レコードに紐付け）
INSERT INTO products (categoryId, brandId, manufacturerId, skuCode, productName, description, unitPrice, stockQuantity, isDiscontinued)
SELECT v.categoryId, b.brandId, m.manufacturerId, v.skuCode, v.productName, v.description, v.unitPrice, v.stockQuantity, v.isDiscontinued
FROM (VALUES
    (5, 'apple', 'foxconn', 'SP-X-001', 'スマートフォンX', '高性能スマートフォン', 89800, 50, FALSE),
    (5, 'samsung', 'lg_electronics', 'SP-Y-001', 'スマートフォンY', 'ミドルレンジスマートフォン', 49800, 120, FALSE),
    (5, 'samsung', 'lg_electronics', 'SP-Z-001', 'スマートフォンZ', '旧モデル', 29800, 10, TRUE),
    (6, 'apple', 'foxconn', 'NB-PRO-001', 'ノートPC Pro', '開発者向け高性能ノートPC', 198000, 30, FALSE),
    (6, 'apple', 'dell', 'NB-AIR-001', 'ノートPC Air', '軽量ノートPC', 128000, 45, FALSE),
    (6, 'panasonic', 'lenovo', 'NB-BAS-001', 'ノートPC Basic', 'エントリーモデル', 68000, 80, FALSE),
    (7, NULL, NULL, 'BK-SQL-001', 'SQL完全攻略', 'SQL資格対策の決定版', 3200, 200, FALSE),
    (7, NULL, NULL, 'BK-PG-001', 'PostgreSQL実践', 'PostgreSQL入門から実践まで', 3800, 150, FALSE),
    (7, NULL, NULL, 'BK-PY-001', 'Python入門', 'プログラミング初心者向け', 2800, 300, FALSE),
    (8, NULL, NULL, 'BK-LD-001', 'リーダーシップ入門', 'マネジメントの基礎', 2500, 100, FALSE),
    (8, NULL, NULL, 'BK-DA-001', 'データ分析の教科書', 'ビジネスデータ分析', 3500, 80, FALSE),
    (9, 'uniqlo', NULL, 'MN-TS-001', 'メンズTシャツ', 'コットン100%', 2980, 500, FALSE),
    (9, 'nike', NULL, 'MN-JN-001', 'メンズジーンズ', 'ストレッチデニム', 5980, 200, FALSE),
    (10, 'uniqlo', NULL, 'LD-WP-001', 'レディースワンピース', '春夏向け', 7980, 150, FALSE),
    (10, 'muji', NULL, 'LD-CD-001', 'レディースカーディガン', 'ウール混紡', 4980, 180, FALSE),
    (4, 'asahi', 'asahi_breweries', 'FD-CF-001', 'オーガニックコーヒー', '200g', 1280, 400, FALSE),
    (4, 'kirin', 'kirin_hd', 'FD-TE-001', 'プレミアム緑茶', '100g', 980, 350, FALSE),
    (4, 'suntory', 'asahi_breweries', 'FD-DF-001', 'ドライフルーツミックス', '300g', 1580, 250, FALSE)
) AS v(categoryId, brandCode, manufacturerCode, skuCode, productName, description, unitPrice, stockQuantity, isDiscontinued)
LEFT JOIN brands b ON b.brandCode = v.brandCode
LEFT JOIN manufacturers m ON m.manufacturerCode = v.manufacturerCode;

-- 顧客
INSERT INTO customers (customerName, email, phone, prefecture, city, registeredAt, membershipTier) VALUES
    ('山田 一郎', 'yamada1@mail.com', '090-1111-0001', '東京都', '渋谷区', '2022-01-15', 'gold'),
    ('佐々木 恵', 'sasaki@mail.com', '090-1111-0002', '大阪府', '大阪市', '2022-03-20', 'silver'),
    ('森 健一', 'mori@mail.com', '090-1111-0003', '愛知県', '名古屋市', '2022-05-10', 'standard'),
    ('石川 美穂', 'ishikawa@mail.com', '090-1111-0004', '福岡県', '福岡市', '2022-07-01', 'platinum'),
    ('阿部 隆', 'abe@mail.com', '090-1111-0005', '北海道', '札幌市', '2022-09-15', 'standard'),
    ('福田 彩', 'fukuda@mail.com', '090-1111-0006', '神奈川県', '横浜市', '2023-01-10', 'gold'),
    ('西村 浩二', 'nishimura@mail.com', '090-1111-0007', '京都府', '京都市', '2023-03-05', 'silver'),
    ('岡田 真由', 'okada@mail.com', '090-1111-0008', '広島県', '広島市', '2023-05-20', 'standard'),
    ('藤田 修', 'fujita@mail.com', '090-1111-0009', '宮城県', '仙台市', '2023-07-15', 'gold'),
    ('村上 里奈', 'murakami@mail.com', '090-1111-0010', '沖縄県', '那覇市', '2023-09-01', 'platinum'),
    ('清水 拓海', 'shimizu@mail.com', '090-1111-0011', '東京都', '新宿区', '2024-01-20', 'standard'),
    ('原田 奈々', 'harada@mail.com', '090-1111-0012', '大阪府', '堺市', '2024-03-10', 'silver'),
    ('三浦 誠', 'miura@mail.com', '090-1111-0013', '千葉県', '千葉市', '2024-05-05', 'standard'),
    ('大野 愛', 'ono@mail.com', '090-1111-0014', '兵庫県', '神戸市', '2024-07-01', 'gold'),
    ('菊地 翔太', 'kikuchi@mail.com', '090-1111-0015', '静岡県', '静岡市', '2024-09-15', 'standard')
ON CONFLICT (email) DO NOTHING;

-- FK 紐付け: 都道府県・市区町村・会員ランク
UPDATE customers c
SET prefectureId = p.prefectureId
FROM prefectures p
WHERE c.prefecture = p.prefectureName
  AND c.prefectureId IS NULL;

UPDATE customers c
SET membershipTierId = mt.membershipTierId
FROM membershipTierMaster mt
WHERE c.membershipTier = mt.tierCode
  AND c.membershipTierId IS NULL;

UPDATE customers c
SET cityId = ci.cityId
FROM cities ci
JOIN prefectures p ON p.prefectureId = ci.prefectureId
WHERE c.prefecture = p.prefectureName
  AND c.city = ci.cityName
  AND c.cityId IS NULL;

-- 注文
INSERT INTO orders (customerId, employeeId, orderDate, status, shippingFee) VALUES
    (1, 3, '2024-01-10 10:30:00', 'delivered', 500),
    (1, 3, '2024-02-15 14:20:00', 'delivered', 0),
    (2, 4, '2024-01-20 09:00:00', 'delivered', 500),
    (3, 3, '2024-02-01 11:45:00', 'delivered', 500),
    (4, 2, '2024-02-10 16:00:00', 'delivered', 0),
    (4, 2, '2024-03-05 10:15:00', 'delivered', 0),
    (4, 2, '2024-04-20 13:30:00', 'shipped', 500),
    (5, 4, '2024-03-01 08:30:00', 'delivered', 500),
    (6, 3, '2024-03-15 15:00:00', 'delivered', 500),
    (7, 4, '2024-04-01 12:00:00', 'confirmed', 500),
    (8, 3, '2024-04-10 09:30:00', 'pending', 500),
    (9, 2, '2024-05-01 17:45:00', 'delivered', 0),
    (10, 2, '2024-05-15 10:00:00', 'delivered', 0),
    (10, 2, '2024-06-01 14:30:00', 'cancelled', 0),
    (11, 4, '2024-06-10 11:00:00', 'delivered', 500),
    (12, 3, '2024-07-01 13:15:00', 'shipped', 500),
    (13, 4, '2024-07-15 16:30:00', 'pending', 500),
    (14, 2, '2024-08-01 10:45:00', 'delivered', 0),
    (15, 3, '2024-08-15 09:00:00', 'confirmed', 500),
    (1, 3, '2024-09-01 12:30:00', 'delivered', 500);

UPDATE orders o
SET orderStatusId = osm.orderStatusId
FROM orderStatusMaster osm
WHERE o.status = osm.statusCode
  AND o.orderStatusId IS NULL;

-- 注文明細（在庫トリガーはシード時に一時無効化）
ALTER TABLE orderItems DISABLE TRIGGER trg_orderItems_stock;

INSERT INTO orderItems (orderId, productId, quantity, unitPrice, discountRate) VALUES
    (1, 1, 1, 89800, 0),
    (1, 7, 2, 3200, 0),
    (2, 7, 1, 3200, 0),
    (2, 8, 1, 3800, 0.1),
    (3, 2, 1, 49800, 0),
    (3, 16, 3, 1280, 0),
    (4, 6, 1, 68000, 0.05),
    (4, 9, 2, 2800, 0),
    (5, 4, 1, 198000, 0),
    (5, 7, 3, 3200, 0),
    (5, 8, 2, 3800, 0),
    (6, 1, 2, 89800, 0.1),
    (6, 5, 1, 128000, 0),
    (7, 4, 1, 198000, 0.05),
    (8, 12, 5, 2980, 0),
    (8, 13, 2, 5980, 0),
    (9, 14, 1, 7980, 0),
    (9, 15, 2, 4980, 0.1),
    (10, 3, 1, 29800, 0.2),
    (11, 9, 1, 2800, 0),
    (12, 10, 2, 2500, 0),
    (12, 11, 1, 3500, 0),
    (13, 1, 1, 89800, 0),
    (13, 16, 5, 1280, 0),
    (13, 17, 3, 980, 0),
    (14, 5, 1, 128000, 0),
    (15, 7, 1, 3200, 0),
    (15, 8, 1, 3800, 0),
    (15, 9, 1, 2800, 0),
    (16, 2, 1, 49800, 0),
    (17, 18, 2, 1580, 0),
    (18, 4, 1, 198000, 0.1),
    (18, 6, 1, 68000, 0),
    (19, 1, 1, 89800, 0.05),
    (20, 7, 2, 3200, 0),
    (20, 8, 1, 3800, 0)
ON CONFLICT (orderId, productId) DO NOTHING;

ALTER TABLE orderItems ENABLE TRIGGER trg_orderItems_stock;

-- 商品レビュー
INSERT INTO productReviews (productId, customerId, rating, comment, reviewedAt) VALUES
    (1, 1, 5, 'とても使いやすいです', '2024-01-20 10:00:00'),
    (1, 4, 4, 'カメラの性能が良い', '2024-02-15 14:00:00'),
    (1, 9, 5, 'バッテリー持ちが素晴らしい', '2024-05-10 09:00:00'),
    (4, 4, 5, '開発作業に最適', '2024-02-20 11:00:00'),
    (4, 14, 4, '少し重いが性能は抜群', '2024-08-10 16:00:00'),
    (7, 1, 5, 'SQL学習に最適な一冊', '2024-02-20 10:00:00'),
    (7, 2, 4, 'わかりやすい解説', '2024-01-25 15:00:00'),
    (7, 5, 3, 'もう少し実践的な内容が欲しい', '2024-03-10 12:00:00'),
    (8, 1, 5, 'PostgreSQLの理解が深まった', '2024-02-25 09:00:00'),
    (2, 3, 4, 'コスパが良い', '2024-02-10 13:00:00'),
    (6, 4, 3, '普通のノートPC', '2024-04-25 10:00:00'),
    (16, 3, 5, '香りが良い', '2024-02-05 08:00:00'),
    (12, 5, 4, '着心地が良い', '2024-03-05 14:00:00')
ON CONFLICT (productId, customerId) DO NOTHING;

-- 給与履歴
INSERT INTO salaryHistory (employeeId, oldSalary, newSalary, changedAt, reason) VALUES
    (3, 400000, 450000, '2023-04-01 00:00:00', '定期昇給'),
    (4, 380000, 420000, '2023-04-01 00:00:00', '定期昇給'),
    (6, 700000, 750000, '2023-10-01 00:00:00', '昇格'),
    (7, 500000, 550000, '2023-04-01 00:00:00', '定期昇給'),
    (8, 480000, 520000, '2023-04-01 00:00:00', '定期昇給'),
    (2, 600000, 650000, '2024-04-01 00:00:00', '昇格'),
    (11, 680000, 720000, '2024-01-01 00:00:00', '業績評価'),
    (3, 450000, 480000, '2024-04-01 00:00:00', '業績評価');
