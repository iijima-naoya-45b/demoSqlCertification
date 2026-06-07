-- ============================================================
-- 演習06 解答
-- ============================================================

-- Q1
WITH categorySales AS (
    SELECT c.categoryName,
           SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) AS totalSales
    FROM categories c
    INNER JOIN products p ON p.categoryId = c.categoryId
    INNER JOIN orderItems oi ON oi.productId = p.productId
    GROUP BY c.categoryId, c.categoryName
)
SELECT categoryName, totalSales
FROM categorySales
ORDER BY totalSales DESC
LIMIT 3;

-- Q2
SELECT employeeName, hireDate,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, hireDate)) AS yearsOfService,
       CASE
           WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, hireDate)) < 5 THEN '5年未満'
           WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, hireDate)) < 10 THEN '5年以上10年未満'
           ELSE '10年以上'
       END AS serviceCategory
FROM employees;

-- Q3
SELECT
    CASE EXTRACT(MONTH FROM orderDate)
        WHEN 1 THEN 'Q1' WHEN 2 THEN 'Q1' WHEN 3 THEN 'Q1'
        WHEN 4 THEN 'Q2' WHEN 5 THEN 'Q2' WHEN 6 THEN 'Q2'
        WHEN 7 THEN 'Q3' WHEN 8 THEN 'Q3' WHEN 9 THEN 'Q3'
        ELSE 'Q4'
    END AS quarter,
    COUNT(DISTINCT o.orderId) AS orderCount,
    SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) AS totalSales
FROM orders o
INNER JOIN orderItems oi ON oi.orderId = o.orderId
WHERE EXTRACT(YEAR FROM o.orderDate) = 2024
GROUP BY quarter
ORDER BY quarter;

-- Q4
SELECT sh.employeeId, e.employeeName, sh.oldSalary, sh.newSalary, sh.changedAt, sh.reason
FROM salaryHistory sh
INNER JOIN employees e ON e.employeeId = sh.employeeId
WHERE sh.changedAt = (
    SELECT MAX(sh2.changedAt)
    FROM salaryHistory sh2
    WHERE sh2.employeeId = sh.employeeId
);

-- Q5
SELECT productName, stockQuantity,
       CASE
           WHEN stockQuantity = 0 THEN '在庫切れ'
           WHEN stockQuantity <= 50 THEN '残りわずか'
           ELSE '十分'
       END AS stockStatus
FROM products;
