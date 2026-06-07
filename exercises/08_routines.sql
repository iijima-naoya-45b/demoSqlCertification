-- ============================================================
-- 演習08: ストアドプロシージャ・関数・トリガー
-- 難易度: ★★★
-- ============================================================

-- Q1: fn_calcOrderTotal を使って、注文ID=1 の合計金額を取得してください。

-- Q2: fn_getCustomerTierDiscount を使って、顧客ID=1（gold会員）の割引率を取得してください。

-- Q3: fn_getEmployeeTenureMonths を使って、従業員ID=1 の勤続月数を取得してください。

-- Q4: sp_confirmOrder プロシージャで注文ID=10（pending）を確定してください。
--     実行前後で orders.status と orderStatusHistory の変化を確認してください。
--     CALL sp_confirmOrder(10);

-- Q5: sp_applyCoupon で注文ID=5 に有効なクーポンコードを適用してください。
--     coupons テーブルから isActive=TRUE のコードを1件確認してから実行してください。

-- Q6: auditLogs テーブルを確認し、orders 更新時にトリガーでログが記録されることを検証してください。
--     テスト用に orders の shippingFee を UPDATE し、auditLogs に記録があるか確認してください。
