-- ============================================================
-- 統計情報更新 + 主要シーケンス調整
-- 実行計画 (EXPLAIN) の精度向上に必須
-- ============================================================

DO $analyze$
DECLARE
    tableRecord RECORD;
BEGIN
    FOR tableRecord IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    LOOP
        EXECUTE 'ANALYZE public.' || quote_ident(tableRecord.tablename);
    END LOOP;
END $analyze$;

-- 主要テーブルのシーケンスを最大IDに合わせる
SELECT setval(pg_get_serial_sequence('departments', 'departmentid'), GREATEST(COALESCE((SELECT MAX(departmentId) FROM departments), 1), 1));
SELECT setval(pg_get_serial_sequence('employees', 'employeeid'), GREATEST(COALESCE((SELECT MAX(employeeId) FROM employees), 1), 1));
SELECT setval(pg_get_serial_sequence('categories', 'categoryid'), GREATEST(COALESCE((SELECT MAX(categoryId) FROM categories), 1), 1));
SELECT setval(pg_get_serial_sequence('products', 'productid'), GREATEST(COALESCE((SELECT MAX(productId) FROM products), 1), 1));
SELECT setval(pg_get_serial_sequence('customers', 'customerid'), GREATEST(COALESCE((SELECT MAX(customerId) FROM customers), 1), 1));
SELECT setval(pg_get_serial_sequence('orders', 'orderid'), GREATEST(COALESCE((SELECT MAX(orderId) FROM orders), 1), 1));
SELECT setval(pg_get_serial_sequence('orderitems', 'orderitemid'), GREATEST(COALESCE((SELECT MAX(orderItemId) FROM orderItems), 1), 1));
SELECT setval(pg_get_serial_sequence('productreviews', 'reviewid'), GREATEST(COALESCE((SELECT MAX(reviewId) FROM productReviews), 1), 1));
SELECT setval(pg_get_serial_sequence('salaryhistory', 'historyid'), GREATEST(COALESCE((SELECT MAX(historyId) FROM salaryHistory), 1), 1));
