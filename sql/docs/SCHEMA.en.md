# Schema Design (Business-Grade, 105 Tables)

**English** | [日本語](SCHEMA.ja.md)

## Overview

Integrated e-commerce, HR, logistics, finance, and system tables for practical SQL practice.

| Layer | Tables |
|-------|--------|
| Master / Reference | 35 |
| Transaction | 70 |
| **Total** | **105** |

## Domains

| Domain | File | Key tables |
|--------|------|------------|
| Master | `02_schema_master.sql` | countries, prefectures, paymentMethods, brands, ... |
| HR | `03_schema_hr.sql` | departments, employees, payrollRuns, ... |
| Catalog | `04_schema_catalog.sql` | products, stockLevels, priceHistory, ... |
| Customer | `05_schema_customer.sql` | customers, loyaltyAccounts, ... |
| Order | `06_schema_order.sql` | orders, invoices, payments, coupons, ... |
| Logistics | `07_schema_logistics.sql` | shipments, pickingLists, ... |
| Finance | `08_schema_finance.sql` | journalEntries, expenseReports, ... |
| Marketing | `09_schema_marketing.sql` | campaigns, productReviews, ... |
| System | `10_schema_system.sql` | userAccounts, roles, auditLogs, ... |

## Views (6)

`v_orderSummary`, `v_customerOrderStats`, `v_productSalesRank`, `v_employeeOrgChart`, `v_inventoryAlert`, `v_monthlyRevenue`

## Functions & Procedures

**Functions:** `fn_calcOrderTotal`, `fn_getCustomerTierDiscount`, `fn_getEmployeeTenureMonths`, `fn_isBusinessDay`, `fn_getProductStock`

**Procedures:** `sp_confirmOrder`, `sp_cancelOrder`, `sp_applyCoupon`, `sp_recordPayment`, `sp_generatePayroll`, `sp_restockProduct`

```sql
SELECT fn_calcOrderTotal(1);
CALL sp_confirmOrder(10);
```

## Triggers (5)

Audit logging, stock deduction, `updatedAt` maintenance, salary validation, order status history.

## Row counts (after bulk load)

| Table | Rows |
|-------|------|
| customers | 10,000 |
| orders | 50,000 |
| orderItems | ~150,000 |
| products | 2,000 |
| employees | 500 |

## Load order

```
01_extensions → 02_schema_master → 03–10_schema → 11–13 → 20–23_seed → indexes → 99_analyze
```

Exercise-compatible core data is preserved in `22_seed_core.sql`.
