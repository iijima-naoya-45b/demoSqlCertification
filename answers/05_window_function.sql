-- ============================================================
-- 演習05 解答
-- ============================================================

-- Q1
SELECT employeeName, salary,
       RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS salaryRank
FROM employees;

-- Q2
SELECT productName, unitPrice,
       ROW_NUMBER() OVER (PARTITION BY categoryId ORDER BY unitPrice DESC) AS priceRank
FROM products;

-- Q3
SELECT TO_CHAR(orderDate, 'YYYY-MM') AS orderMonth,
       COUNT(*) AS monthlyOrders,
       SUM(COUNT(*)) OVER (ORDER BY TO_CHAR(orderDate, 'YYYY-MM')) AS cumulativeOrders
FROM orders
GROUP BY TO_CHAR(orderDate, 'YYYY-MM')
ORDER BY orderMonth;

-- Q4
SELECT c.customerName, o.orderId, o.orderDate,
       SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) AS orderAmount,
       SUM(SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)))
           OVER (PARTITION BY c.customerId ORDER BY o.orderDate) AS cumulativeAmount
FROM customers c
INNER JOIN orders o ON o.customerId = c.customerId
INNER JOIN orderItems oi ON oi.orderId = o.orderId
GROUP BY c.customerId, c.customerName, o.orderId, o.orderDate;

-- Q5
SELECT employeeName, salary, deptAvgSalary,
       salary - deptAvgSalary AS salaryDiff
FROM (
    SELECT employeeName, salary,
           ROUND(AVG(salary) OVER (PARTITION BY departmentId), 2) AS deptAvgSalary
    FROM employees
) AS employeeWithAvg
WHERE salary > deptAvgSalary;
