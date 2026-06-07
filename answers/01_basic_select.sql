-- ============================================================
-- 演習01 解答
-- ============================================================

-- Q1
SELECT productId, productName, unitPrice
FROM products
ORDER BY unitPrice DESC;

-- Q2
SELECT productName, stockQuantity
FROM products
WHERE stockQuantity < 100;

-- Q3
SELECT customerName, email, city
FROM customers
WHERE prefecture = '東京都';

-- Q4
SELECT employeeName, jobTitle, salary
FROM employees
WHERE salary >= 500000
ORDER BY salary DESC;

-- Q5
SELECT *
FROM products
WHERE isDiscontinued = TRUE;
