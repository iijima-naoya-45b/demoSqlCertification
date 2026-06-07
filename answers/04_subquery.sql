-- ============================================================
-- 演習04 解答
-- ============================================================

-- Q1
SELECT employeeName, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Q2
SELECT o.orderId,
       SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) + o.shippingFee AS totalAmount
FROM orders o
INNER JOIN orderItems oi ON oi.orderId = o.orderId
GROUP BY o.orderId, o.shippingFee
ORDER BY totalAmount DESC
LIMIT 1;

-- Q3
SELECT productName
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM productReviews pr WHERE pr.productId = p.productId
);

-- Q4
SELECT e.employeeName, d.departmentName, e.salary
FROM employees e
INNER JOIN departments d ON d.departmentId = e.departmentId
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.departmentId = e.departmentId
);

-- Q5
SELECT DISTINCT p.productName
FROM products p
INNER JOIN orderItems oi ON oi.productId = p.productId
INNER JOIN orders o ON o.orderId = oi.orderId
INNER JOIN customers c ON c.customerId = o.customerId
WHERE c.membershipTier = 'platinum';
