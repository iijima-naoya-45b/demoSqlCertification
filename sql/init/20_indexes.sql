-- ============================================================
-- インデックス（基本 + 複合）
-- 実行計画演習: Index Scan / Bitmap Scan / Seq Scan の比較用
-- ============================================================

-- HR
CREATE INDEX idx_employees_departmentId ON employees(departmentId);
CREATE INDEX idx_employees_managerId ON employees(managerId);
CREATE INDEX idx_employees_hireDate ON employees(hireDate);
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_employees_dept_salary ON employees(departmentId, salary DESC);

-- Catalog
CREATE INDEX idx_products_categoryId ON products(categoryId);
CREATE INDEX idx_products_unitPrice ON products(unitPrice);
CREATE INDEX idx_products_category_price ON products(categoryId, unitPrice);
CREATE INDEX idx_categories_parentCategoryId ON categories(parentCategoryId);

-- Customer
CREATE INDEX idx_customers_membershipTier ON customers(membershipTier);
CREATE INDEX idx_customers_prefecture ON customers(prefecture);
CREATE INDEX idx_customers_registeredAt ON customers(registeredAt);
CREATE INDEX idx_customers_tier_prefecture ON customers(membershipTier, prefecture);

-- Order
CREATE INDEX idx_orders_customerId ON orders(customerId);
CREATE INDEX idx_orders_employeeId ON orders(employeeId);
CREATE INDEX idx_orders_orderDate ON orders(orderDate);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_customer_date ON orders(customerId, orderDate DESC);
CREATE INDEX idx_orders_status_date ON orders(status, orderDate);

CREATE INDEX idx_orderItems_orderId ON orderItems(orderId);
CREATE INDEX idx_orderItems_productId ON orderItems(productId);
CREATE INDEX idx_orderItems_order_product ON orderItems(orderId, productId);

-- Review
CREATE INDEX idx_productReviews_productId ON productReviews(productId);
CREATE INDEX idx_productReviews_customerId ON productReviews(customerId);
CREATE INDEX idx_productReviews_rating ON productReviews(rating);
CREATE INDEX idx_productReviews_reviewedAt ON productReviews(reviewedAt);

-- Salary History
CREATE INDEX idx_salaryHistory_employeeId ON salaryHistory(employeeId);
CREATE INDEX idx_salaryHistory_changedAt ON salaryHistory(changedAt);
