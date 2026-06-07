-- ============================================================
-- 部分インデックス（実行計画演習用）
-- WHERE 句との組み合わせで Index Scan が選択されるケース
-- ============================================================

CREATE INDEX idx_employees_active_dept
    ON employees(departmentId, salary)
    WHERE isActive = TRUE;

CREATE INDEX idx_products_available
    ON products(categoryId, unitPrice)
    WHERE isDiscontinued = FALSE;

CREATE INDEX idx_orders_delivered_date
    ON orders(orderDate, customerId)
    WHERE status = 'delivered';

CREATE INDEX idx_orders_pending
    ON orders(orderDate)
    WHERE status IN ('pending', 'confirmed');

CREATE INDEX idx_customers_gold_platinum
    ON customers(prefecture, registeredAt)
    WHERE membershipTier IN ('gold', 'platinum');

CREATE INDEX idx_productReviews_high_rating
    ON productReviews(productId, rating)
    WHERE rating >= 4;
