-- ============================================================
-- 地理マスター補足（郵便番号プレフィックス・政令指定都市など）
-- 20_seed_master_lookup.sql の cities を拡充
-- ============================================================

-- 政令指定都市・主要都市の追加
INSERT INTO cities (prefectureId, cityName, cityNameKana, postalCodePrefix)
SELECT p.prefectureId, v.cityName, v.cityNameKana, v.postalCodePrefix
FROM prefectures p
JOIN countries c ON c.countryId = p.countryId AND c.countryCode = 'JP'
JOIN (VALUES
    ('13', '中央区', 'チュウオウク', '104'),
    ('13', '品川区', 'シナガワク', '140'),
    ('13', '目黒区', 'メグロク', '153'),
    ('13', '大田区', 'オオタク', '144'),
    ('13', '江東区', 'コウトウク', '135'),
    ('13', '板橋区', 'イタバシク', '173'),
    ('13', '練馬区', 'ネリマク', '176'),
    ('13', '足立区', 'アダチク', '120'),
    ('13', '八王子市', 'ハチオウジシ', '192'),
    ('13', '立川市', 'タチカワシ', '190'),
    ('27', '吹田市', 'スイタシ', '564'),
    ('27', '豊中市', 'トヨナカシ', '561'),
    ('27', '高槻市', 'タカツキシ', '569'),
    ('27', '枚方市', 'ヒラカタシ', '573'),
    ('23', '豊田市', 'トヨタシ', '471'),
    ('23', '一宮市', 'イチノミヤシ', '491'),
    ('28', '西宮市', 'ニシノミヤシ', '662'),
    ('28', '尼崎市', 'アマガサキシ', '660'),
    ('40', '久留米市', 'クルメシ', '830'),
    ('40', '飯塚市', 'イイヅカシ', '820'),
    ('01', '旭川市', 'アサヒカワシ', '070'),
    ('01', '函館市', 'ハコダテシ', '040'),
    ('04', '石巻市', 'イシノマキシ', '986'),
    ('34', '呉市', 'クレシ', '737'),
    ('34', '福山市', 'フクヤマシ', '720'),
    ('12', '船橋市', 'フナバシシ', '273'),
    ('12', '柏市', 'カシワシ', '277'),
    ('11', '川口市', 'カワグチシ', '332'),
    ('11', '所沢市', 'トコロザワシ', '359'),
    ('14', '藤沢市', 'フジサワシ', '251'),
    ('14', '厚木市', 'アツギシ', '243'),
    ('26', '宇治市', 'ウジシ', '611'),
    ('26', '長岡京市', 'ナガオカキョウシ', '617'),
    ('29', '奈良市', 'ナラシ', '630'),
    ('30', '和歌山市', 'ワカヤマシ', '640'),
    ('33', '倉敷市', 'クラシキシ', '710'),
    ('43', '八代市', 'ヤツシロシ', '866'),
    ('46', '鹿児島市', 'カゴシマシ', '890'),
    ('47', '宜野湾市', 'ギノワンシ', '901'),
    ('47', 'うるま市', 'ウルマシ', '904')
) AS v(prefectureCode, cityName, cityNameKana, postalCodePrefix)
    ON p.prefectureCode = v.prefectureCode
ON CONFLICT (prefectureId, cityName) DO NOTHING;

-- 地域限定休業日（例: 沖縄県）
INSERT INTO holidays (countryId, prefectureId, holidayDate, holidayName, holidayType, isSubstitute)
SELECT c.countryId, p.prefectureId, v.holidayDate::date, v.holidayName, 'regional', FALSE
FROM countries c
JOIN prefectures p ON p.countryId = c.countryId AND p.prefectureCode = '47'
CROSS JOIN (VALUES
    ('2024-06-23', '沖縄慰霊の日'),
    ('2025-06-23', '沖縄慰霊の日')
) AS v(holidayDate, holidayName)
WHERE c.countryCode = 'JP';
