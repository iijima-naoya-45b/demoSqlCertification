-- ============================================================
-- 演習08 解答
-- ============================================================

-- Q1
SELECT fn_calcOrderTotal(1) AS orderTotal;

-- Q2
SELECT fn_getCustomerTierDiscount(1) AS discountPercent;

-- Q3
SELECT fn_getEmployeeTenureMonths(1) AS tenureMonths;

-- Q4
-- 実行前確認
SELECT orderId, status FROM orders WHERE orderId = 10;
SELECT * FROM orderStatusHistory WHERE orderId = 10 ORDER BY changedAt;

CALL sp_confirmOrder(10);

-- 実行後確認
SELECT orderId, status FROM orders WHERE orderId = 10;
SELECT * FROM orderStatusHistory WHERE orderId = 10 ORDER BY changedAt;

-- Q5
SELECT couponCode, discountAmount, isActive FROM coupons WHERE isActive = TRUE LIMIT 5;

-- 例: 先頭のクーポンコードを使用（環境によりコードは異なる場合あり）
-- CALL sp_applyCoupon(5, 'WELCOME10');

-- Q6
UPDATE orders SET shippingFee = shippingFee + 100 WHERE orderId = 1;

SELECT auditLogId, tableName, recordId, actionType, occurredAt
FROM auditLogs
WHERE tableName = 'orders' AND recordId = 1
ORDER BY occurredAt DESC
LIMIT 5;
