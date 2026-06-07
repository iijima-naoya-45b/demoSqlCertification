-- ============================================================
-- 演習03 解答
-- ============================================================

-- Q1
SELECT d.departmentName, COUNT(e.employeeId) AS employeeCount, ROUND(AVG(e.salary), 2) AS avgSalary
FROM departments d
INNER JOIN employees e ON e.departmentId = d.departmentId
GROUP BY d.departmentId, d.departmentName;

-- Q2
SELECT membershipTier, COUNT(*) AS customerCount
FROM customers
GROUP BY membershipTier;

-- Q3
SELECT p.productName,
       ROUND(AVG(pr.rating), 2) AS avgRating,
       COUNT(pr.reviewId) AS reviewCount
FROM products p
LEFT JOIN productReviews pr ON pr.productId = p.productId
GROUP BY p.productId, p.productName;

-- Q4
SELECT o.orderId,
       SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) + o.shippingFee AS totalAmount
FROM orders o
INNER JOIN orderItems oi ON oi.orderId = o.orderId
GROUP BY o.orderId, o.shippingFee
HAVING SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) + o.shippingFee >= 100000;

-- Q5
SELECT c.customerName,
       COUNT(o.orderId) AS orderCount,
       SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate) + o.shippingFee / (
           SELECT COUNT(*) FROM orderItems WHERE orderId = o.orderId
       )) AS totalPurchase
FROM customers c
INNER JOIN orders o ON o.customerId = c.customerId
INNER JOIN orderItems oi ON oi.orderId = o.orderId
WHERE o.orderDate >= '2024-01-01' AND o.orderDate < '2025-01-01'
GROUP BY c.customerId, c.customerName
ORDER BY orderCount DESC;

-- Q6
SELECT p.productName, ROUND(AVG(pr.rating), 2) AS avgRating
FROM products p
INNER JOIN productReviews pr ON pr.productId = p.productId
GROUP BY p.productId, p.productName
HAVING AVG(pr.rating) >= 4.0;
