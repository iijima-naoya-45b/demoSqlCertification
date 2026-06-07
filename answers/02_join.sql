-- ============================================================
-- 演習02 解答
-- ============================================================

-- Q1
SELECT e.employeeName, d.departmentName, e.jobTitle
FROM employees e
INNER JOIN departments d ON d.departmentId = e.departmentId;

-- Q2
SELECT o.orderId, c.customerName, o.orderDate, o.status
FROM orders o
INNER JOIN customers c ON c.customerId = o.customerId;

-- Q3
SELECT oi.orderId, p.productName, oi.quantity, oi.unitPrice, oi.discountRate
FROM orderItems oi
INNER JOIN products p ON p.productId = oi.productId;

-- Q4
SELECT e.employeeName, m.employeeName AS managerName
FROM employees e
INNER JOIN employees m ON m.employeeId = e.managerId;

-- Q5
SELECT c.customerName, c.email
FROM customers c
LEFT JOIN orders o ON o.customerId = c.customerId
WHERE o.orderId IS NULL;

-- Q6
SELECT c.categoryName, COUNT(p.productId) AS productCount
FROM categories c
LEFT JOIN products p ON p.categoryId = c.categoryId
GROUP BY c.categoryId, c.categoryName;
