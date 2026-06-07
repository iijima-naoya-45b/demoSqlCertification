-- ============================================================
-- 全オブジェクト削除（動的・リセット用）
-- ============================================================

DROP VIEW IF EXISTS v_monthlyRevenue CASCADE;
DROP VIEW IF EXISTS v_inventoryAlert CASCADE;
DROP VIEW IF EXISTS v_employeeOrgChart CASCADE;
DROP VIEW IF EXISTS v_productSalesRank CASCADE;
DROP VIEW IF EXISTS v_customerOrderStats CASCADE;
DROP VIEW IF EXISTS v_orderSummary CASCADE;

DO $drop$
DECLARE
    routineRecord RECORD;
    tableRecord RECORD;
BEGIN
    FOR routineRecord IN
        SELECT p.oid::regprocedure AS routineSignature
        FROM pg_proc p
        WHERE p.pronamespace = 'public'::regnamespace
          AND p.prokind IN ('f', 'p')
          AND NOT EXISTS (
              SELECT 1
              FROM pg_depend d
              WHERE d.objid = p.oid
                AND d.deptype = 'e'
          )
    LOOP
        EXECUTE 'DROP ROUTINE IF EXISTS ' || routineRecord.routineSignature || ' CASCADE';
    END LOOP;

    FOR tableRecord IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(tableRecord.tablename) || ' CASCADE';
    END LOOP;
END $drop$;
