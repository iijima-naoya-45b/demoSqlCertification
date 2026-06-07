-- ============================================================
-- ビュー（参照用・分析用）
-- ============================================================

CREATE VIEW v_orderSummary AS
SELECT
    o.orderId,
    c.customerName,
    e.employeeName AS salesRepName,
    o.orderDate,
    o.status,
    COUNT(oi.orderItemId) AS itemCount,
    SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) AS subtotal,
    o.shippingFee,
    SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) + o.shippingFee AS totalAmount
FROM orders o
JOIN customers c ON c.customerId = o.customerId
LEFT JOIN employees e ON e.employeeId = o.employeeId
JOIN orderItems oi ON oi.orderId = o.orderId
GROUP BY o.orderId, c.customerName, e.employeeName, o.orderDate, o.status, o.shippingFee;

COMMENT ON VIEW v_orderSummary IS '注文サマリービュー（顧客・担当者・明細集計を結合した参照用）';

CREATE VIEW v_customerOrderStats AS
SELECT
    c.customerId,
    c.customerName,
    c.email,
    c.membershipTier,
    COUNT(o.orderId) AS orderCount,
    COALESCE(SUM(
        o.shippingFee + COALESCE(lineTotals.lineSubtotal, 0)
    ), 0) AS totalSpent,
    MIN(o.orderDate) AS firstOrderDate,
    MAX(o.orderDate) AS lastOrderDate
FROM customers c
LEFT JOIN orders o ON o.customerId = c.customerId
    AND o.status NOT IN ('cancelled')
LEFT JOIN LATERAL (
    SELECT SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) AS lineSubtotal
    FROM orderItems oi
    WHERE oi.orderId = o.orderId
) lineTotals ON TRUE
GROUP BY c.customerId, c.customerName, c.email, c.membershipTier;

COMMENT ON VIEW v_customerOrderStats IS '顧客別注文統計ビュー（注文件数・累計購入金額・初回/最終注文日）';

CREATE VIEW v_productSalesRank AS
SELECT
    p.productId,
    p.productName,
    cat.categoryName,
    COALESCE(SUM(oi.quantity), 0) AS totalQuantitySold,
    COALESCE(SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)), 0) AS totalRevenue,
    RANK() OVER (
        ORDER BY COALESCE(SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)), 0) DESC
    ) AS salesRank
FROM products p
JOIN categories cat ON cat.categoryId = p.categoryId
LEFT JOIN orderItems oi ON oi.productId = p.productId
LEFT JOIN orders o ON o.orderId = oi.orderId
    AND o.status IN ('confirmed', 'shipped', 'delivered')
GROUP BY p.productId, p.productName, cat.categoryName;

COMMENT ON VIEW v_productSalesRank IS '商品売上ランキングビュー（販売数量・売上金額・順位）';

CREATE VIEW v_employeeOrgChart AS
SELECT
    e.employeeId,
    e.employeeName,
    e.email,
    e.jobTitle,
    d.departmentId,
    d.departmentName,
    mgr.employeeId AS managerId,
    mgr.employeeName AS managerName,
    e.hireDate,
    e.salary,
    e.isActive
FROM employees e
JOIN departments d ON d.departmentId = e.departmentId
LEFT JOIN employees mgr ON mgr.employeeId = e.managerId;

COMMENT ON VIEW v_employeeOrgChart IS '従業員組織図ビュー（部署・上長名を含む人事参照用）';

CREATE VIEW v_inventoryAlert AS
SELECT
    p.productId,
    p.productName,
    cat.categoryName,
    p.stockQuantity,
    COALESCE(sl.reorderPoint, 10) AS reorderPoint,
    p.stockQuantity - COALESCE(sl.reorderPoint, 10) AS stockGap,
    CASE
        WHEN p.stockQuantity = 0 THEN 'out_of_stock'
        WHEN p.stockQuantity <= COALESCE(sl.reorderPoint, 10) THEN 'low_stock'
        ELSE 'adequate'
    END AS alertLevel
FROM products p
JOIN categories cat ON cat.categoryId = p.categoryId
LEFT JOIN LATERAL (
    SELECT MIN(sl_inner.reorderPoint) AS reorderPoint
    FROM stockLevels sl_inner
    WHERE sl_inner.productId = p.productId
) sl ON TRUE
WHERE p.isDiscontinued = FALSE
  AND (
      p.stockQuantity = 0
      OR p.stockQuantity <= COALESCE(sl.reorderPoint, 10)
  );

COMMENT ON VIEW v_inventoryAlert IS '在庫アラートビュー（発注点以下・在庫切れの商品を抽出）';

CREATE VIEW v_monthlyRevenue AS
SELECT
    DATE_TRUNC('month', o.orderDate)::DATE AS revenueMonth,
    TO_CHAR(o.orderDate, 'YYYY-MM') AS revenueYearMonth,
    COUNT(DISTINCT o.orderId) AS orderCount,
    COUNT(DISTINCT o.customerId) AS uniqueCustomers,
    SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) AS merchandiseRevenue,
    SUM(o.shippingFee) AS shippingRevenue,
    SUM(oi.quantity * oi.unitPrice * (1 - oi.discountRate)) + SUM(o.shippingFee) AS totalRevenue
FROM orders o
JOIN orderItems oi ON oi.orderId = o.orderId
WHERE o.status IN ('confirmed', 'shipped', 'delivered')
GROUP BY DATE_TRUNC('month', o.orderDate)::DATE, TO_CHAR(o.orderDate, 'YYYY-MM')
ORDER BY revenueMonth;

COMMENT ON VIEW v_monthlyRevenue IS '月次売上集計ビュー（商品売上・送料・注文件数の月別サマリー）';
