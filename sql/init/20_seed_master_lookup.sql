-- ============================================================
-- マスター / 参照データ（35 テーブル）
-- 02_schema_master.sql の全マスターテーブルを投入
-- ============================================================

-- ------------------------------------------------------------
-- 地理・地域
-- ------------------------------------------------------------

INSERT INTO countries (countryCode, countryNameJa, countryNameEn, phoneCountryCode) VALUES
    ('JP', '日本', 'Japan', '+81'),
    ('US', 'アメリカ合衆国', 'United States', '+1'),
    ('CN', '中国', 'China', '+86'),
    ('KR', '大韓民国', 'South Korea', '+82'),
    ('GB', 'イギリス', 'United Kingdom', '+44'),
    ('DE', 'ドイツ', 'Germany', '+49'),
    ('FR', 'フランス', 'France', '+33'),
    ('AU', 'オーストラリア', 'Australia', '+61'),
    ('TW', '台湾', 'Taiwan', '+886'),
    ('SG', 'シンガポール', 'Singapore', '+65')
ON CONFLICT (countryCode) DO NOTHING;

INSERT INTO prefectures (countryId, prefectureCode, prefectureName, regionName, sortOrder)
SELECT c.countryId, v.prefectureCode, v.prefectureName, v.regionName, v.sortOrder
FROM countries c
CROSS JOIN (VALUES
    ('01', '北海道', '北海道', 1),
    ('02', '青森県', '東北', 2),
    ('03', '岩手県', '東北', 3),
    ('04', '宮城県', '東北', 4),
    ('05', '秋田県', '東北', 5),
    ('06', '山形県', '東北', 6),
    ('07', '福島県', '東北', 7),
    ('08', '茨城県', '関東', 8),
    ('09', '栃木県', '関東', 9),
    ('10', '群馬県', '関東', 10),
    ('11', '埼玉県', '関東', 11),
    ('12', '千葉県', '関東', 12),
    ('13', '東京都', '関東', 13),
    ('14', '神奈川県', '関東', 14),
    ('15', '新潟県', '中部', 15),
    ('16', '富山県', '中部', 16),
    ('17', '石川県', '中部', 17),
    ('18', '福井県', '中部', 18),
    ('19', '山梨県', '中部', 19),
    ('20', '長野県', '中部', 20),
    ('21', '岐阜県', '中部', 21),
    ('22', '静岡県', '中部', 22),
    ('23', '愛知県', '中部', 23),
    ('24', '三重県', '近畿', 24),
    ('25', '滋賀県', '近畿', 25),
    ('26', '京都府', '近畿', 26),
    ('27', '大阪府', '近畿', 27),
    ('28', '兵庫県', '近畿', 28),
    ('29', '奈良県', '近畿', 29),
    ('30', '和歌山県', '近畿', 30),
    ('31', '鳥取県', '中国', 31),
    ('32', '島根県', '中国', 32),
    ('33', '岡山県', '中国', 33),
    ('34', '広島県', '中国', 34),
    ('35', '山口県', '中国', 35),
    ('36', '徳島県', '四国', 36),
    ('37', '香川県', '四国', 37),
    ('38', '愛媛県', '四国', 38),
    ('39', '高知県', '四国', 39),
    ('40', '福岡県', '九州', 40),
    ('41', '佐賀県', '九州', 41),
    ('42', '長崎県', '九州', 42),
    ('43', '熊本県', '九州', 43),
    ('44', '大分県', '九州', 44),
    ('45', '宮崎県', '九州', 45),
    ('46', '鹿児島県', '九州', 46),
    ('47', '沖縄県', '九州', 47)
) AS v(prefectureCode, prefectureName, regionName, sortOrder)
WHERE c.countryCode = 'JP'
ON CONFLICT (countryId, prefectureCode) DO NOTHING;

-- 主要市区町村（実在地名）
INSERT INTO cities (prefectureId, cityName, cityNameKana, postalCodePrefix)
SELECT p.prefectureId, v.cityName, v.cityNameKana, v.postalCodePrefix
FROM prefectures p
JOIN countries c ON c.countryId = p.countryId AND c.countryCode = 'JP'
JOIN (VALUES
    ('13', '千代田区', 'チヨダク', '100'),
    ('13', '渋谷区', 'シブヤク', '150'),
    ('13', '新宿区', 'シンジュクク', '160'),
    ('13', '港区', 'ミナトク', '105'),
    ('13', '世田谷区', 'セタガヤク', '154'),
    ('14', '横浜市', 'ヨコハマシ', '220'),
    ('14', '川崎市', 'カワサキシ', '210'),
    ('14', '相模原市', 'サガミハラシ', '252'),
    ('11', 'さいたま市', 'サイタマシ', '330'),
    ('12', '千葉市', 'チバシ', '260'),
    ('27', '大阪市', 'オオサカシ', '530'),
    ('27', '堺市', 'サカイシ', '590'),
    ('27', '東大阪市', 'ヒガシオオサカシ', '578'),
    ('26', '京都市', 'キョウトシ', '600'),
    ('23', '名古屋市', 'ナゴヤシ', '460'),
    ('28', '神戸市', 'コウベシ', '650'),
    ('28', '姫路市', 'ヒメジシ', '670'),
    ('40', '福岡市', 'フクオカシ', '810'),
    ('40', '北九州市', 'キタキュウシュウシ', '800'),
    ('01', '札幌市', 'サッポロシ', '060'),
    ('04', '仙台市', 'センダイシ', '980'),
    ('34', '広島市', 'ヒロシマシ', '730'),
    ('22', '静岡市', 'シズオカシ', '420'),
    ('22', '浜松市', 'ハママツシ', '430'),
    ('47', '那覇市', 'ナハシ', '900'),
    ('47', '沖縄市', 'オキナワシ', '904'),
    ('33', '岡山市', 'オカヤマシ', '700'),
    ('43', '熊本市', 'クマモトシ', '860'),
    ('20', '長野市', 'ナガノシ', '380'),
    ('08', '水戸市', 'ミトシ', '310')
) AS v(prefectureCode, cityName, cityNameKana, postalCodePrefix)
    ON p.prefectureCode = v.prefectureCode
ON CONFLICT (prefectureId, cityName) DO NOTHING;

-- 追加市区町村（都道府県あたり 2 件、計 94 件以上）
INSERT INTO cities (prefectureId, cityName, postalCodePrefix)
SELECT p.prefectureId, p.prefectureName || '中央市' || n, lpad((p.sortOrder * 10 + n)::text, 3, '0')
FROM prefectures p
JOIN countries c ON c.countryId = p.countryId AND c.countryCode = 'JP'
CROSS JOIN generate_series(1, 2) AS n
ON CONFLICT (prefectureId, cityName) DO NOTHING;

-- ------------------------------------------------------------
-- 会計・税務
-- ------------------------------------------------------------

INSERT INTO currencies (currencyCode, currencyName, currencySymbol, decimalPlaces) VALUES
    ('JPY', '日本円', '¥', 0),
    ('USD', '米ドル', '$', 2),
    ('EUR', 'ユーロ', '€', 2),
    ('GBP', '英ポンド', '£', 2),
    ('CNY', '中国元', '元', 2),
    ('KRW', '韓国ウォン', '₩', 0)
ON CONFLICT (currencyCode) DO NOTHING;

INSERT INTO taxRates (countryId, taxType, ratePercent, effectiveFrom, effectiveTo, description)
SELECT c.countryId, v.taxType, v.ratePercent, v.effectiveFrom::date, v.effectiveTo::date, v.description
FROM countries c
CROSS JOIN (VALUES
    ('consumption_standard', 10.00, '2019-10-01', NULL, '標準税率 10%'),
    ('consumption_reduced', 8.00, '2019-10-01', NULL, '軽減税率 8%'),
    ('consumption_standard', 8.00, '2014-04-01', '2019-09-30', '旧標準税率 8%')
) AS v(taxType, ratePercent, effectiveFrom, effectiveTo, description)
WHERE c.countryCode = 'JP';

INSERT INTO fiscalYears (fiscalYearCode, startDate, endDate, isClosed) VALUES
    ('FY2022', '2022-04-01', '2023-03-31', TRUE),
    ('FY2023', '2023-04-01', '2024-03-31', TRUE),
    ('FY2024', '2024-04-01', '2025-03-31', FALSE),
    ('FY2025', '2025-04-01', '2026-03-31', FALSE)
ON CONFLICT (fiscalYearCode) DO NOTHING;

INSERT INTO holidays (countryId, prefectureId, holidayDate, holidayName, holidayType, isSubstitute)
SELECT c.countryId, NULL, v.holidayDate::date, v.holidayName, v.holidayType, v.isSubstitute
FROM countries c
CROSS JOIN (VALUES
    ('2024-01-01', '元日', 'national', FALSE),
    ('2024-01-08', '成人の日', 'national', FALSE),
    ('2024-02-11', '建国記念の日', 'national', FALSE),
    ('2024-02-23', '天皇誕生日', 'national', FALSE),
    ('2024-03-20', '春分の日', 'national', FALSE),
    ('2024-04-29', '昭和の日', 'national', FALSE),
    ('2024-05-03', '憲法記念日', 'national', FALSE),
    ('2024-05-04', 'みどりの日', 'national', FALSE),
    ('2024-05-05', 'こどもの日', 'national', FALSE),
    ('2024-07-15', '海の日', 'national', FALSE),
    ('2024-08-11', '山の日', 'national', FALSE),
    ('2024-09-16', '敬老の日', 'national', FALSE),
    ('2024-09-22', '秋分の日', 'national', FALSE),
    ('2024-10-14', 'スポーツの日', 'national', FALSE),
    ('2024-11-03', '文化の日', 'national', FALSE),
    ('2024-11-23', '勤労感謝の日', 'national', FALSE),
    ('2025-01-01', '元日', 'national', FALSE),
    ('2025-01-13', '成人の日', 'national', FALSE)
) AS v(holidayDate, holidayName, holidayType, isSubstitute)
WHERE c.countryCode = 'JP';

-- ------------------------------------------------------------
-- 決済・支払
-- ------------------------------------------------------------

INSERT INTO paymentMethods (paymentMethodCode, paymentMethodName, requiresCardInfo, settlementDays) VALUES
    ('credit_card', 'クレジットカード', TRUE, 3),
    ('debit_card', 'デビットカード', TRUE, 1),
    ('bank_transfer', '銀行振込', FALSE, 2),
    ('convenience_store', 'コンビニ決済', FALSE, 3),
    ('cod', '代金引換', FALSE, 0),
    ('paypay', 'PayPay', FALSE, 1),
    ('apple_pay', 'Apple Pay', TRUE, 3),
    ('invoice', '請求書払い', FALSE, 30)
ON CONFLICT (paymentMethodCode) DO NOTHING;

INSERT INTO paymentTerms (paymentTermCode, paymentTermName, dueDays, discountDays, discountPercent) VALUES
    ('net30', '月末締め翌月末払い', 30, NULL, NULL),
    ('net60', '月末締め翌々月末払い', 60, NULL, NULL),
    ('2_10_net30', '2/10 Net 30', 30, 10, 2.00),
    ('cod', '代金引換（即時）', 0, NULL, NULL),
    ('prepaid', '前払い', 0, NULL, NULL),
    ('end_of_month', '月末締め当月末払い', 0, NULL, NULL)
ON CONFLICT (paymentTermCode) DO NOTHING;

-- ------------------------------------------------------------
-- 配送・物流
-- ------------------------------------------------------------

INSERT INTO shippingCarriers (carrierCode, carrierName, trackingUrlTemplate) VALUES
    ('yamato', 'ヤマト運輸', 'https://toi.kuronekoyamato.co.jp/cgi-bin/tneko?number=%s'),
    ('sagawa', '佐川急便', 'https://k2k.sagawa-exp.co.jp/p/sagawa/web/okurijoinput/okurijoinput.jsp?okurijoNo=%s'),
    ('japan_post', '日本郵便', 'https://trackings.post.japanpost.jp/services/srv/search?requestNo1=%s'),
    ('seino', '西濃運輸', NULL),
    ('fukuyama', '福山通運', NULL)
ON CONFLICT (carrierCode) DO NOTHING;

INSERT INTO shippingMethods (shippingCarrierId, methodCode, methodName, baseFee, estimatedDaysMin, estimatedDaysMax)
SELECT sc.shippingCarrierId, v.methodCode, v.methodName, v.baseFee, v.estimatedDaysMin, v.estimatedDaysMax
FROM shippingCarriers sc
JOIN (VALUES
    ('yamato', 'taqbin', '宅急便', 880, 1, 2),
    ('yamato', 'compact', '宅急便コンパクト', 450, 1, 2),
    ('yamato', 'cool', 'クール宅急便', 1200, 1, 2),
    ('sagawa', 'hikyaku', '飛脚宅配便', 850, 1, 3),
    ('sagawa', 'hikyaku_large', '飛脚ラージサイズ', 1500, 2, 4),
    ('japan_post', 'yu_pack', 'ゆうパック', 750, 2, 4),
    ('japan_post', 'yu_packet', 'ゆうパケット', 390, 2, 5),
    ('seino', 'super', 'スーパーセイノー', 900, 2, 4),
    ('fukuyama', 'standard', '福山通運 通常便', 800, 2, 5)
) AS v(carrierCode, methodCode, methodName, baseFee, estimatedDaysMin, estimatedDaysMax)
    ON sc.carrierCode = v.carrierCode
ON CONFLICT (shippingCarrierId, methodCode) DO NOTHING;

INSERT INTO deliveryTimeSlots (slotCode, slotName, startTime, endTime, sortOrder) VALUES
    ('morning', '午前中', '08:00', '12:00', 1),
    ('12_14', '12時〜14時', '12:00', '14:00', 2),
    ('14_16', '14時〜16時', '14:00', '16:00', 3),
    ('16_18', '16時〜18時', '16:00', '18:00', 4),
    ('18_20', '18時〜20時', '18:00', '20:00', 5),
    ('19_21', '19時〜21時', '19:00', '21:00', 6),
    ('unspecified', '時間指定なし', '00:00', '23:59', 99)
ON CONFLICT (slotCode) DO NOTHING;

-- ------------------------------------------------------------
-- EC 業務ステータス・区分
-- ------------------------------------------------------------

INSERT INTO orderStatusMaster (statusCode, statusName, statusCategory, sortOrder, isTerminal) VALUES
    ('pending', '受付待ち', 'order', 1, FALSE),
    ('confirmed', '受注確定', 'order', 2, FALSE),
    ('shipped', '出荷済み', 'fulfillment', 3, FALSE),
    ('delivered', '配送完了', 'fulfillment', 4, TRUE),
    ('cancelled', 'キャンセル', 'order', 5, TRUE)
ON CONFLICT (statusCode) DO NOTHING;

INSERT INTO membershipTierMaster (tierCode, tierName, minAnnualSpend, discountPercent, pointMultiplier, sortOrder) VALUES
    ('standard', 'スタンダード', 0, 0, 1.00, 1),
    ('silver', 'シルバー', 50000, 3, 1.25, 2),
    ('gold', 'ゴールド', 150000, 5, 1.50, 3),
    ('platinum', 'プラチナ', 500000, 10, 2.00, 4)
ON CONFLICT (tierCode) DO NOTHING;

INSERT INTO productStatusMaster (statusCode, statusName, allowsSale, sortOrder) VALUES
    ('active', '販売中', TRUE, 1),
    ('preorder', '予約受付中', TRUE, 2),
    ('backorder', '入荷待ち', FALSE, 3),
    ('discontinued', '販売終了', FALSE, 4),
    ('draft', '下書き', FALSE, 5)
ON CONFLICT (statusCode) DO NOTHING;

INSERT INTO returnReasonMaster (reasonCode, reasonName, requiresInspection, sortOrder) VALUES
    ('defective', '不良品・破損', TRUE, 1),
    ('wrong_item', '誤配送', TRUE, 2),
    ('not_as_described', '商品説明と相違', TRUE, 3),
    ('customer_change', 'お客様都合', FALSE, 4),
    ('size_mismatch', 'サイズ不一致', FALSE, 5),
    ('duplicate_order', '重複注文', FALSE, 6)
ON CONFLICT (reasonCode) DO NOTHING;

INSERT INTO discountTypeMaster (discountTypeCode, discountTypeName, calculationMethod, isStackable) VALUES
    ('percentage', '率割引', 'percentage', FALSE),
    ('fixed_amount', '定額割引', 'fixed_amount', TRUE),
    ('member_tier', '会員ランク割引', 'percentage', TRUE),
    ('campaign', 'キャンペーン割引', 'percentage', FALSE),
    ('coupon', 'クーポン割引', 'fixed_amount', TRUE),
    ('bundle', 'セット割引', 'fixed_amount', FALSE)
ON CONFLICT (discountTypeCode) DO NOTHING;

INSERT INTO unitsOfMeasure (unitCode, unitName, unitSymbol, isBaseUnit) VALUES
    ('ea', '個', '個', TRUE),
    ('box', '箱', '箱', FALSE),
    ('kg', 'キログラム', 'kg', TRUE),
    ('g', 'グラム', 'g', FALSE),
    ('l', 'リットル', 'L', TRUE),
    ('ml', 'ミリリットル', 'mL', FALSE),
    ('m', 'メートル', 'm', TRUE),
    ('set', 'セット', '式', FALSE),
    ('pair', '足', '足', FALSE),
    ('pack', 'パック', 'pk', FALSE)
ON CONFLICT (unitCode) DO NOTHING;

-- ------------------------------------------------------------
-- 商品・調達
-- ------------------------------------------------------------

INSERT INTO brands (brandCode, brandName, brandNameKana, countryId)
SELECT v.brandCode, v.brandName, v.brandNameKana, c.countryId
FROM (VALUES
    ('sony', 'ソニー', 'ソニー', 'JP'),
    ('panasonic', 'パナソニック', 'パナソニック', 'JP'),
    ('sharp', 'シャープ', 'シャープ', 'JP'),
    ('apple', 'Apple', 'アップル', 'US'),
    ('samsung', 'Samsung', 'サムスン', 'KR'),
    ('nike', 'Nike', 'ナイキ', 'US'),
    ('uniqlo', 'ユニクロ', 'ユニクロ', 'JP'),
    ('muji', '無印良品', 'ムジルシリョウヒン', 'JP'),
    ('dyson', 'Dyson', 'ダイソン', 'GB'),
    ('bosch', 'Bosch', 'ボッシュ', 'DE'),
    ('canon', 'キヤノン', 'キヤノン', 'JP'),
    ('nikon', 'ニコン', 'ニコン', 'JP'),
    ('asahi', 'アサヒ', 'アサヒ', 'JP'),
    ('kirin', 'キリン', 'キリン', 'JP'),
    ('suntory', 'サントリー', 'サントリー', 'JP'),
    ('shiseido', '資生堂', 'シセイドウ', 'JP'),
    ('kose', 'コーセー', 'コーセー', 'JP'),
    ('toyota', 'トヨタ', 'トヨタ', 'JP'),
    ('honda', 'ホンダ', 'ホンダ', 'JP'),
    ('nintendo', '任天堂', 'ニンテンドウ', 'JP')
) AS v(brandCode, brandName, brandNameKana, countryCode)
LEFT JOIN countries c ON c.countryCode = v.countryCode
ON CONFLICT (brandCode) DO NOTHING;

INSERT INTO manufacturers (manufacturerCode, manufacturerName, countryId, websiteUrl)
SELECT v.manufacturerCode, v.manufacturerName, c.countryId, v.websiteUrl
FROM (VALUES
    ('sony_corp', 'ソニーグループ株式会社', 'JP', 'https://www.sony.com'),
    ('panasonic_hd', 'パナソニックホールディングス株式会社', 'JP', 'https://www.panasonic.com'),
    ('foxconn', 'Foxconn Technology Group', 'CN', 'https://www.foxconn.com'),
    ('tsmc', '台湾セミコンダクター製造会社', 'TW', 'https://www.tsmc.com'),
    ('lg_electronics', 'LG Electronics', 'KR', 'https://www.lg.com'),
    ('dell', 'Dell Technologies', 'US', 'https://www.dell.com'),
    ('hp_inc', 'HP Inc.', 'US', 'https://www.hp.com'),
    ('lenovo', 'Lenovo Group', 'CN', 'https://www.lenovo.com'),
    ('asahi_breweries', 'アサヒビール株式会社', 'JP', 'https://www.asahibeer.co.jp'),
    ('kirin_hd', 'キリンホールディングス株式会社', 'JP', 'https://www.kirinholdings.com'),
    ('shiseido_co', '株式会社資生堂', 'JP', 'https://www.shiseido.co.jp'),
    ('toyota_motor', 'トヨタ自動車株式会社', 'JP', 'https://www.toyota.co.jp'),
    ('honda_motor', '本田技研工業株式会社', 'JP', 'https://www.honda.co.jp'),
    ('nintendo_co', '任天堂株式会社', 'JP', 'https://www.nintendo.co.jp'),
    ('canon_inc', 'キヤノン株式会社', 'JP', 'https://www.canon.co.jp')
) AS v(manufacturerCode, manufacturerName, countryCode, websiteUrl)
LEFT JOIN countries c ON c.countryCode = v.countryCode
ON CONFLICT (manufacturerCode) DO NOTHING;

INSERT INTO supplierMaster (supplierCode, supplierName, supplierNameKana, countryId, currencyId, paymentTermId, contactEmail, contactPhone)
SELECT v.supplierCode, v.supplierName, v.supplierNameKana, co.countryId, cu.currencyId, pt.paymentTermId, v.contactEmail, v.contactPhone
FROM (VALUES
    ('sup_tech', 'テックサプライ株式会社', 'テックサプライ', 'JP', 'JPY', 'net30', 'sales@techsupply.example.jp', '03-1234-0001'),
    ('sup_book', '出版流通センター', 'シュッパンリュウツウセンター', 'JP', 'JPY', 'net30', 'order@bookdist.example.jp', '03-1234-0002'),
    ('sup_fashion', 'アパレル卸売センター', 'アパレルオロシウリセンター', 'JP', 'JPY', 'net60', 'wholesale@fashion.example.jp', '06-1234-0003'),
    ('sup_food', 'フードリンクス株式会社', 'フードリンクス', 'JP', 'JPY', 'net30', 'info@foodlinks.example.jp', '052-123-0004'),
    ('sup_electronics', 'エレクトロパーツ商事', 'エレクトロパーツショウジ', 'JP', 'JPY', '2_10_net30', 'parts@electro.example.jp', '045-123-0005'),
    ('sup_global', 'Global Parts Inc.', NULL, 'US', 'USD', 'net60', 'export@globalparts.example.com', '+1-555-0100'),
    ('sup_asia', 'Asia Trade Co., Ltd.', NULL, 'CN', 'CNY', 'prepaid', 'trade@asiatrade.example.cn', '+86-21-1234-0007'),
    ('sup_korea', 'Korea Electronics Supply', NULL, 'KR', 'KRW', 'net30', 'sales@kes.example.kr', '+82-2-1234-0008'),
    ('sup_logistics', 'ロジスティクスパートナー', 'ロジスティクスパートナー', 'JP', 'JPY', 'end_of_month', 'logistics@partner.example.jp', '03-1234-0009'),
    ('sup_premium', 'プレミアム仕入株式会社', 'プレミアムシイレ', 'JP', 'JPY', 'cod', 'premium@supplier.example.jp', '03-1234-0010')
) AS v(supplierCode, supplierName, supplierNameKana, countryCode, currencyCode, paymentTermCode, contactEmail, contactPhone)
JOIN countries co ON co.countryCode = v.countryCode
JOIN currencies cu ON cu.currencyCode = v.currencyCode
LEFT JOIN paymentTerms pt ON pt.paymentTermCode = v.paymentTermCode
ON CONFLICT (supplierCode) DO NOTHING;

INSERT INTO warehouseMaster (warehouseCode, warehouseName, prefectureId, postalCode, addressLine1, addressLine2)
SELECT v.warehouseCode, v.warehouseName, p.prefectureId, v.postalCode, v.addressLine1, v.addressLine2
FROM (VALUES
    ('WH_TOKYO', '東京物流センター', '13', '136-0082', '東京都江東区新木場1-1-1', '第1倉庫'),
    ('WH_OSAKA', '大阪物流センター', '27', '554-0041', '大阪府大阪市此花区北港白津1-1-1', NULL),
    ('WH_NAGOYA', '名古屋物流センター', '23', '455-0841', '愛知県名古屋市港区金城町1-1', NULL),
    ('WH_FUKUOKA', '福岡物流センター', '40', '811-2301', '福岡県糟屋郡粕屋町大字仲原1-1', NULL),
    ('WH_SAPPORO', '札幌物流センター', '01', '003-0001', '北海道札幌市白石区中央1-1-1', NULL)
) AS v(warehouseCode, warehouseName, prefectureCode, postalCode, addressLine1, addressLine2)
JOIN prefectures p ON p.prefectureCode = v.prefectureCode
JOIN countries c ON c.countryId = p.countryId AND c.countryCode = 'JP'
ON CONFLICT (warehouseCode) DO NOTHING;

INSERT INTO locationMaster (warehouseId, locationCode, locationType, aisle, rack, shelf, capacityUnits)
SELECT w.warehouseId, v.locationCode, v.locationType, v.aisle, v.rack, v.shelf, v.capacityUnits
FROM warehouseMaster w
JOIN (VALUES
    ('WH_TOKYO', 'A-01-01', 'shelf', 'A', '01', '01', 100),
    ('WH_TOKYO', 'A-01-02', 'shelf', 'A', '01', '02', 100),
    ('WH_TOKYO', 'A-02-01', 'shelf', 'A', '02', '01', 120),
    ('WH_TOKYO', 'B-01-01', 'picking', 'B', '01', '01', 80),
    ('WH_TOKYO', 'B-02-01', 'picking', 'B', '02', '01', 80),
    ('WH_OSAKA', 'A-01-01', 'shelf', 'A', '01', '01', 100),
    ('WH_OSAKA', 'A-01-02', 'shelf', 'A', '01', '02', 100),
    ('WH_OSAKA', 'B-01-01', 'picking', 'B', '01', '01', 90),
    ('WH_NAGOYA', 'A-01-01', 'shelf', 'A', '01', '01', 100),
    ('WH_NAGOYA', 'A-02-01', 'shelf', 'A', '02', '01', 100),
    ('WH_FUKUOKA', 'A-01-01', 'shelf', 'A', '01', '01', 80),
    ('WH_FUKUOKA', 'B-01-01', 'picking', 'B', '01', '01', 70),
    ('WH_SAPPORO', 'A-01-01', 'shelf', 'A', '01', '01', 80),
    ('WH_SAPPORO', 'A-01-02', 'shelf', 'A', '01', '02', 80),
    ('WH_SAPPORO', 'COLD-01', 'cold_storage', 'C', '01', '01', 50)
) AS v(warehouseCode, locationCode, locationType, aisle, rack, shelf, capacityUnits)
    ON w.warehouseCode = v.warehouseCode
ON CONFLICT (warehouseId, locationCode) DO NOTHING;

-- ------------------------------------------------------------
-- 人事
-- ------------------------------------------------------------

INSERT INTO jobGradeMaster (gradeCode, gradeName, minSalary, maxSalary, sortOrder) VALUES
    ('G1', '一般職 G1', 250000, 350000, 1),
    ('G2', '一般職 G2', 300000, 450000, 2),
    ('G3', '一般職 G3', 400000, 550000, 3),
    ('G4', '主任級 G4', 450000, 650000, 4),
    ('G5', '係長級 G5', 550000, 750000, 5),
    ('G6', '課長級 G6', 650000, 900000, 6),
    ('G7', '部長級 G7', 800000, 1200000, 7),
    ('G8', '役員級 G8', 1000000, 2000000, 8)
ON CONFLICT (gradeCode) DO NOTHING;

INSERT INTO employmentTypeMaster (typeCode, typeName, isFullTime, contractMonths) VALUES
    ('full_time', '正社員', TRUE, NULL),
    ('contract', '契約社員', FALSE, 12),
    ('part_time', 'パート・アルバイト', FALSE, NULL),
    ('dispatch', '派遣社員', FALSE, 6),
    ('executive', '役員', TRUE, NULL),
    ('intern', 'インターン', FALSE, 3)
ON CONFLICT (typeCode) DO NOTHING;

INSERT INTO leaveTypeMaster (leaveTypeCode, leaveTypeName, isPaid, maxDaysPerYear, requiresApproval) VALUES
    ('annual', '年次有給休暇', TRUE, 20, TRUE),
    ('special', '特別休暇', TRUE, 5, TRUE),
    ('sick', '病気休暇', TRUE, NULL, TRUE),
    ('childcare', '育児休業', FALSE, NULL, TRUE),
    ('nursing', '介護休業', FALSE, NULL, TRUE),
    ('maternity', '産前産後休暇', FALSE, NULL, TRUE),
    ('unpaid', '無給休暇', FALSE, NULL, TRUE)
ON CONFLICT (leaveTypeCode) DO NOTHING;

INSERT INTO positionMaster (positionCode, positionName, jobGradeId, departmentCategory, sortOrder)
SELECT v.positionCode, v.positionName, jg.jobGradeId, v.departmentCategory, v.sortOrder
FROM (VALUES
    ('ceo', '代表取締役社長', 'G8', '経営', 1),
    ('cfo', '最高財務責任者', 'G8', '経営', 2),
    ('cto', '最高技術責任者', 'G8', '経営', 3),
    ('sales_director', '営業本部長', 'G7', '営業', 10),
    ('sales_manager', '営業部長', 'G6', '営業', 11),
    ('sales_lead', '営業リーダー', 'G5', '営業', 12),
    ('sales_rep', '営業担当', 'G3', '営業', 13),
    ('dev_director', '開発本部長', 'G7', '開発', 20),
    ('dev_manager', '開発部長', 'G6', '開発', 21),
    ('senior_engineer', 'シニアエンジニア', 'G5', '開発', 22),
    ('engineer', 'エンジニア', 'G3', '開発', 23),
    ('hr_director', '人事本部長', 'G7', '人事', 30),
    ('hr_manager', '人事部長', 'G6', '人事', 31),
    ('hr_specialist', '人事担当', 'G3', '人事', 32),
    ('marketing_director', 'マーケティング本部長', 'G7', 'マーケティング', 40),
    ('marketing_manager', 'マーケティング部長', 'G6', 'マーケティング', 41),
    ('marketer', 'マーケター', 'G3', 'マーケティング', 42),
    ('cs_director', 'CS本部長', 'G7', 'カスタマーサポート', 50),
    ('cs_manager', 'CS部長', 'G6', 'カスタマーサポート', 51),
    ('cs_agent', 'CS担当', 'G2', 'カスタマーサポート', 52)
) AS v(positionCode, positionName, gradeCode, departmentCategory, sortOrder)
LEFT JOIN jobGradeMaster jg ON jg.gradeCode = v.gradeCode
ON CONFLICT (positionCode) DO NOTHING;

INSERT INTO skillMaster (skillCode, skillName, skillCategory, proficiencyLevels) VALUES
    ('sql', 'SQL', 'データベース', 5),
    ('postgresql', 'PostgreSQL', 'データベース', 5),
    ('python', 'Python', 'プログラミング', 5),
    ('java', 'Java', 'プログラミング', 5),
    ('javascript', 'JavaScript', 'プログラミング', 5),
    ('typescript', 'TypeScript', 'プログラミング', 5),
    ('react', 'React', 'フロントエンド', 5),
    ('vue', 'Vue.js', 'フロントエンド', 5),
    ('aws', 'Amazon Web Services', 'クラウド', 5),
    ('gcp', 'Google Cloud Platform', 'クラウド', 5),
    ('azure', 'Microsoft Azure', 'クラウド', 5),
    ('docker', 'Docker', 'インフラ', 5),
    ('kubernetes', 'Kubernetes', 'インフラ', 5),
    ('linux', 'Linux', 'インフラ', 5),
    ('git', 'Git', '開発ツール', 5),
    ('agile', 'アジャイル開発', 'プロジェクト管理', 5),
    ('scrum', 'スクラム', 'プロジェクト管理', 5),
    ('sales_negotiation', '営業交渉', '営業', 5),
    ('customer_support', 'カスタマーサポート', '営業', 5),
    ('marketing_analytics', 'マーケティング分析', 'マーケティング', 5),
    ('seo', 'SEO', 'マーケティング', 5),
    ('english', '英語', '語学', 5),
    ('chinese', '中国語', '語学', 5),
    ('presentation', 'プレゼンテーション', 'ビジネススキル', 5),
    ('leadership', 'リーダーシップ', 'ビジネススキル', 5),
    ('excel', 'Microsoft Excel', 'オフィス', 5),
    ('powerpoint', 'Microsoft PowerPoint', 'オフィス', 5),
    ('tableau', 'Tableau', 'データ分析', 5),
    ('power_bi', 'Power BI', 'データ分析', 5),
    ('project_management', 'プロジェクト管理', 'プロジェクト管理', 5)
ON CONFLICT (skillCode) DO NOTHING;

INSERT INTO educationLevelMaster (levelCode, levelName, sortOrder) VALUES
    ('high_school', '高等学校', 1),
    ('vocational', '専門学校', 2),
    ('associate', '短期大学', 3),
    ('bachelor', '大学（学士）', 4),
    ('master', '大学院（修士）', 5),
    ('doctorate', '大学院（博士）', 6),
    ('other', 'その他', 99)
ON CONFLICT (levelCode) DO NOTHING;

-- ------------------------------------------------------------
-- 経理・マーケティング・業種
-- ------------------------------------------------------------

INSERT INTO accountTypeMaster (accountTypeCode, accountTypeName, normalBalance, statementSection) VALUES
    ('asset', '資産', 'debit', 'balance_sheet'),
    ('liability', '負債', 'credit', 'balance_sheet'),
    ('equity', '純資産', 'credit', 'balance_sheet'),
    ('revenue', '収益', 'credit', 'income_statement'),
    ('expense', '費用', 'debit', 'income_statement'),
    ('contra_asset', '資産控除', 'credit', 'balance_sheet'),
    ('contra_revenue', '収益控除', 'debit', 'income_statement')
ON CONFLICT (accountTypeCode) DO NOTHING;

INSERT INTO expenseCategoryMaster (categoryCode, categoryName, parentCategoryId, accountTypeId, isReimbursable)
SELECT v.categoryCode, v.categoryName, parent.expenseCategoryId, at.accountTypeId, v.isReimbursable
FROM (VALUES
    ('travel', '旅費交通費', NULL, 'expense', TRUE),
    ('entertainment', '交際費', NULL, 'expense', TRUE),
    ('supplies', '消耗品費', NULL, 'expense', TRUE),
    ('communication', '通信費', NULL, 'expense', TRUE),
    ('training', '研修費', NULL, 'expense', TRUE),
    ('misc', '雑費', NULL, 'expense', TRUE)
) AS v(categoryCode, categoryName, parentCode, accountTypeCode, isReimbursable)
LEFT JOIN expenseCategoryMaster parent ON parent.categoryCode = v.parentCode
LEFT JOIN accountTypeMaster at ON at.accountTypeCode = v.accountTypeCode
ON CONFLICT (categoryCode) DO NOTHING;

INSERT INTO expenseCategoryMaster (categoryCode, categoryName, parentCategoryId, accountTypeId, isReimbursable)
SELECT v.categoryCode, v.categoryName, parent.expenseCategoryId, at.accountTypeId, v.isReimbursable
FROM (VALUES
    ('transport', '交通費', 'travel', 'expense', TRUE),
    ('lodging', '宿泊費', 'travel', 'expense', TRUE)
) AS v(categoryCode, categoryName, parentCode, accountTypeCode, isReimbursable)
JOIN expenseCategoryMaster parent ON parent.categoryCode = v.parentCode
JOIN accountTypeMaster at ON at.accountTypeCode = v.accountTypeCode
ON CONFLICT (categoryCode) DO NOTHING;

INSERT INTO campaignTypeMaster (campaignTypeCode, campaignTypeName, defaultDurationDays) VALUES
    ('seasonal_sale', '季節セール', 14),
    ('new_member', '新規会員キャンペーン', 30),
    ('point_back', 'ポイント還元', 7),
    ('flash_sale', 'フラッシュセール', 3),
    ('bundle', 'セット販売', 30),
    ('clearance', '在庫処分セール', 21)
ON CONFLICT (campaignTypeCode) DO NOTHING;

INSERT INTO industryTypeMaster (industryCode, industryName, industryCategory) VALUES
    ('G4711', '百貨店・総合スーパー', '卸売・小売'),
    ('G4719', 'その他の各種商品小売業', '卸売・小売'),
    ('G4791', '通信販売・インターネット販売', '卸売・小売'),
    ('C2611', '電子計算機製造業', '製造'),
    ('C2621', '電子部品製造業', '製造'),
    ('J6111', '固定電気通信業', '情報通信'),
    ('J6121', '移動電気通信業', '情報通信'),
    ('M7211', '学術・開発研究機関', '学術研究'),
    ('M7221', '自然科学研究所', '学術研究'),
    ('K6411', '銀行業', '金融・保険'),
    ('K6421', '協同組織金融業', '金融・保険'),
    ('L6811', '不動産売買業', '不動産'),
    ('H3011', '旅客鉄道業', '運輸'),
    ('I5611', '食堂・レストラン', '宿泊・飲食'),
    ('P8311', '学校教育', '教育')
ON CONFLICT (industryCode) DO NOTHING;

INSERT INTO transactionTypeMaster (transactionTypeCode, transactionTypeName, debitCreditIndicator) VALUES
    ('sales', '売上', 'C'),
    ('refund', '返金', 'D'),
    ('receipt', '入金', 'D'),
    ('payment', '出金', 'C'),
    ('adjustment', '調整', 'D'),
    ('transfer', '振替', 'D'),
    ('expense', '経費', 'D'),
    ('depreciation', '減価償却', 'D')
ON CONFLICT (transactionTypeCode) DO NOTHING;

INSERT INTO bankMaster (bankCode, bankName, bankNameKana, branchRequired, countryId)
SELECT v.bankCode, v.bankName, v.bankNameKana, v.branchRequired, c.countryId
FROM countries c
CROSS JOIN (VALUES
    ('0001', 'みずほ銀行', 'ミズホギンコウ', TRUE),
    ('0005', '三菱UFJ銀行', 'ミツビシユーエフジェイギンコウ', TRUE),
    ('0009', '三井住友銀行', 'ミツイスミトモギンコウ', TRUE),
    ('0010', 'りそな銀行', 'リソナギンコウ', TRUE),
    ('0017', '埼玉りそな銀行', 'サイタマリソナギンコウ', TRUE),
    ('0033', 'ジャパンネット銀行', 'ジャパンネットギンコウ', FALSE),
    ('0036', '楽天銀行', 'ラクテンギンコウ', FALSE),
    ('0038', '住信SBIネット銀行', 'スミシンエスビーアイネットギンコウ', FALSE),
    ('0116', '北海道銀行', 'ホッカイドウギンコウ', TRUE),
    ('0158', '京都銀行', 'キョウトギンコウ', TRUE)
) AS v(bankCode, bankName, bankNameKana, branchRequired)
WHERE c.countryCode = 'JP'
ON CONFLICT (countryId, bankCode) DO NOTHING;
