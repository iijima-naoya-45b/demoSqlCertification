# スキーマ設計書（実務寄り・105テーブル）

[English](SCHEMA.en.md) | **日本語**

## 概要

EC + 人事 + 物流 + 会計 + システムを統合した、実務に近い検証用データベースです。

| 区分 | テーブル数 |
|------|-----------|
| マスタ / 参照 | 35 |
| トランザクション | 70 |
| **合計** | **105** |

## ドメイン構成

| ドメイン | ファイル | 主なテーブル |
|----------|----------|-------------|
| Master | `02_schema_master.sql` | countries, prefectures, cities, paymentMethods, brands, ... |
| HR | `03_schema_hr.sql` | departments, employees, leaveRequests, payrollRuns, ... |
| Catalog | `04_schema_catalog.sql` | categories, products, productVariants, stockLevels, ... |
| Customer | `05_schema_customer.sql` | customers, customerAddresses, loyaltyAccounts, ... |
| Order | `06_schema_order.sql` | orders, orderItems, invoices, payments, coupons, ... |
| Logistics | `07_schema_logistics.sql` | shipments, shipmentTracking, pickingLists, ... |
| Finance | `08_schema_finance.sql` | chartOfAccounts, journalEntries, expenseReports, ... |
| Marketing | `09_schema_marketing.sql` | productReviews, campaigns, newsletters, ... |
| System | `10_schema_system.sql` | userAccounts, roles, auditLogs, batchJobLogs, ... |

## マスタテーブル一覧（35）

地理: `countries`, `prefectures`, `cities`  
会計: `currencies`, `taxRates`, `fiscalYears`, `holidays`  
決済・物流: `paymentMethods`, `paymentTerms`, `shippingCarriers`, `shippingMethods`, `deliveryTimeSlots`  
業務コード: `orderStatusMaster`, `membershipTierMaster`, `productStatusMaster`, `returnReasonMaster`, `discountTypeMaster`  
商品: `unitsOfMeasure`, `brands`, `manufacturers`, `supplierMaster`, `warehouseMaster`, `locationMaster`  
人事: `jobGradeMaster`, `employmentTypeMaster`, `leaveTypeMaster`, `positionMaster`, `skillMaster`, `educationLevelMaster`  
その他: `expenseCategoryMaster`, `accountTypeMaster`, `campaignTypeMaster`, `industryTypeMaster`, `transactionTypeMaster`, `bankMaster`

## ビュー（6）

| ビュー | 用途 |
|--------|------|
| `v_orderSummary` | 注文サマリー（演習互換） |
| `v_customerOrderStats` | 顧客別購入統計 |
| `v_productSalesRank` | 商品売上ランキング |
| `v_employeeOrgChart` | 組織図（上長付き） |
| `v_inventoryAlert` | 在庫アラート |
| `v_monthlyRevenue` | 月次売上 |

## 関数・プロシージャ

### 関数（5）

| 名前 | 説明 |
|------|------|
| `fn_calcOrderTotal` | 注文合計金額算出 |
| `fn_getCustomerTierDiscount` | 会員ランク割引率 |
| `fn_getEmployeeTenureMonths` | 勤続月数 |
| `fn_isBusinessDay` | 営業日判定（祝日マスタ参照） |
| `fn_getProductStock` | 商品在庫数 |

### プロシージャ（6）

| 名前 | 説明 |
|------|------|
| `sp_confirmOrder` | 注文確定 |
| `sp_cancelOrder` | 注文キャンセル |
| `sp_applyCoupon` | クーポン適用 |
| `sp_recordPayment` | 入金記録 |
| `sp_generatePayroll` | 給与計算バッチ |
| `sp_restockProduct` | 在庫補充 |

```sql
-- 使用例
SELECT fn_calcOrderTotal(1);
CALL sp_confirmOrder(10);
CALL sp_restockProduct(1, 100, 1);
```

## トリガー（5）

| トリガー | 動作 |
|----------|------|
| `trg_orders_audit` | orders 変更を auditLogs に記録 |
| `trg_orderItems_stock` | 確定注文の明細追加時に在庫減算 |
| `trg_customers_updated` | customers.updatedAt 自動更新 |
| `trg_salaryHistory_validate` | 給与改定の妥当性検証 |
| `trg_orders_status_history` | ステータス変更履歴の自動挿入 |

## データ件数（バルク投入後）

| テーブル | 件数 |
|----------|------|
| customers | 10,000 |
| orders | 50,000 |
| orderItems | 約 150,000 |
| products | 2,000 |
| employees | 500 |
| productReviews | 約 20,000 |
| auditLogs | 60,000+ |

## 投入順序

```
01_extensions
→ 02_schema_master
→ 03〜10_schema_*
→ 11_schema_views
→ 12_schema_routines
→ 13_schema_triggers
→ 20〜23_seed_*
→ 20_indexes / 21_indexes_partial
→ 99_analyze
```

## 演習互換性

演習01〜07が参照する **固定マスターデータ（ID 1〜20 付近）** は `22_seed_core.sql` で維持しています。  
レガシー列（`customers.prefecture`, `orders.status` 等）も残してあり、マスタFK列と併存します。
