-- ============================================================
-- 演習07: 実行計画 (EXPLAIN / EXPLAIN ANALYZE)
-- 難易度: ★★★
-- 前提: ./scripts/seed.sh reset 済み（バルクデータ + ANALYZE 済み）
-- ============================================================

-- DBeaver / psql で EXPLAIN ANALYZE の結果を確認してください。

-- Q1: 都道府県で顧客を検索する。Seq Scan と Index Scan のどちらが選ばれるか確認してください。
--     EXPLAIN ANALYZE を付けて実行:
--     SELECT * FROM customers WHERE prefecture = '東京都';

-- Q2: 配達済み注文を日付範囲で検索する。部分インデックスが使われるか確認してください。
--     SELECT orderId, customerId, orderDate
--     FROM orders
--     WHERE status = 'delivered'
--       AND orderDate >= '2024-01-01';

-- Q3: 在籍中の従業員を部署・給与で検索する。部分インデックス idx_employees_active_dept の使用を確認してください。
--     SELECT employeeName, salary
--     FROM employees
--     WHERE isActive = TRUE AND departmentId = 2
--     ORDER BY salary DESC;

-- Q4: 顧客と注文を JOIN して集計する。Hash Join / Merge Join / Nested Loop のいずれが選ばれるか確認してください。
--     SELECT c.membershipTier, COUNT(o.orderId)
--     FROM customers c
--     JOIN orders o ON o.customerId = c.customerId
--     GROUP BY c.membershipTier;

-- Q5: Q2 に複合インデックスを追加した場合の計画変化を比較してください（任意）。
--     CREATE INDEX idx_orders_delivered_date_test ON orders(orderDate) WHERE status = 'delivered';
--     再度 EXPLAIN ANALYZE を実行し、追加前後を比較した後 DROP INDEX してください。
