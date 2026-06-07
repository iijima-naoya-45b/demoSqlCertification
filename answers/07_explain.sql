-- ============================================================
-- 演習07 解答（実行計画確認用クエリ）
-- 環境により計画は異なる場合があります。ノード種別の読み方を確認してください。
-- ============================================================

-- Q1
EXPLAIN ANALYZE
SELECT * FROM customers WHERE prefecture = '東京都';

-- Q2
EXPLAIN ANALYZE
SELECT orderId, customerId, orderDate
FROM orders
WHERE status = 'delivered'
  AND orderDate >= '2024-01-01';

-- Q3
EXPLAIN ANALYZE
SELECT employeeName, salary
FROM employees
WHERE isActive = TRUE AND departmentId = 2
ORDER BY salary DESC;

-- Q4
EXPLAIN ANALYZE
SELECT c.membershipTier, COUNT(o.orderId)
FROM customers c
JOIN orders o ON o.customerId = c.customerId
GROUP BY c.membershipTier;

-- Q5（比較用・実行後は削除推奨）
-- CREATE INDEX idx_orders_delivered_date_test ON orders(orderDate) WHERE status = 'delivered';
-- EXPLAIN ANALYZE ...（Q2 と同じクエリ）
-- DROP INDEX idx_orders_delivered_date_test;
