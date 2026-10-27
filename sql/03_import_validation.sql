
-- =====================================================
-- SaaS Revenue & Subscription Analytics
-- Step 5.3.9: Final PostgreSQL Import Validation
-- =====================================================

-- 1. ROW COUNT VALIDATION

WITH actual_counts AS (
    SELECT 'plans' AS table_name, COUNT(*) AS actual_rows FROM plans
    UNION ALL
    SELECT 'customers', COUNT(*) FROM customers
    UNION ALL
    SELECT 'subscriptions', COUNT(*) FROM subscriptions
    UNION ALL
    SELECT 'subscription_months', COUNT(*) FROM subscription_months
    UNION ALL
    SELECT 'invoices', COUNT(*) FROM invoices
),
expected_counts AS (
    SELECT 'plans' AS table_name, 10 AS expected_rows
    UNION ALL SELECT 'customers', 1200
    UNION ALL SELECT 'subscriptions', 1381
    UNION ALL SELECT 'subscription_months', 19015
    UNION ALL SELECT 'invoices', 11257
)
SELECT
    a.table_name,
    e.expected_rows,
    a.actual_rows,
    CASE
        WHEN a.actual_rows = e.expected_rows THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM actual_counts a
JOIN expected_counts e USING (table_name)
ORDER BY a.table_name;


-- 2. TOTAL IMPORTED RECORDS

SELECT
    (SELECT COUNT(*) FROM plans)
    + (SELECT COUNT(*) FROM customers)
    + (SELECT COUNT(*) FROM subscriptions)
    + (SELECT COUNT(*) FROM subscription_months)
    + (SELECT COUNT(*) FROM invoices)
    AS total_imported_records;


-- 3. PRIMARY KEY UNIQUENESS

SELECT
    'plans' AS table_name,
    COUNT(*) - COUNT(DISTINCT plan_id) AS duplicate_keys
FROM plans

UNION ALL

SELECT
    'customers',
    COUNT(*) - COUNT(DISTINCT customer_id)
FROM customers

UNION ALL

SELECT
    'subscriptions',
    COUNT(*) - COUNT(DISTINCT subscription_id)
FROM subscriptions

UNION ALL

SELECT
    'subscription_months',
    COUNT(*) - COUNT(DISTINCT record_id)
FROM subscription_months

UNION ALL

SELECT
    'invoices',
    COUNT(*) - COUNT(DISTINCT invoice_id)
FROM invoices;


-- 4. MISSING VALUE VALIDATION

SELECT
    'customers.churn_date' AS column_name,
    855 AS expected_nulls,
    COUNT(*) FILTER (WHERE churn_date IS NULL) AS actual_nulls
FROM customers

UNION ALL

SELECT
    'subscriptions.end_date',
    855,
    COUNT(*) FILTER (WHERE end_date IS NULL)
FROM subscriptions

UNION ALL

SELECT
    'invoices.days_to_payment',
    309,
    COUNT(*) FILTER (WHERE days_to_payment IS NULL)
FROM invoices;


-- 5. FOREIGN KEY VALIDATION

SELECT
    'subscriptions.customer_id' AS relationship,
    COUNT(*) AS invalid_references
FROM subscriptions s
LEFT JOIN customers c
    ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'subscriptions.plan_id',
    COUNT(*)
FROM subscriptions s
LEFT JOIN plans p
    ON s.plan_id = p.plan_id
WHERE p.plan_id IS NULL

UNION ALL

SELECT
    'subscription_months.customer_id',
    COUNT(*)
FROM subscription_months sm
LEFT JOIN customers c
    ON sm.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'subscription_months.subscription_id',
    COUNT(*)
FROM subscription_months sm
LEFT JOIN subscriptions s
    ON sm.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL

UNION ALL

SELECT
    'subscription_months.plan_id',
    COUNT(*)
FROM subscription_months sm
LEFT JOIN plans p
    ON sm.plan_id = p.plan_id
WHERE p.plan_id IS NULL

UNION ALL

SELECT
    'invoices.customer_id',
    COUNT(*)
FROM invoices i
LEFT JOIN customers c
    ON i.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'invoices.subscription_id',
    COUNT(*)
FROM invoices i
LEFT JOIN subscriptions s
    ON i.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;


-- 6. NEGATIVE REVENUE VALIDATION

SELECT
    COUNT(*) FILTER (
        WHERE mrr_usd < 0
    ) AS negative_mrr_records
FROM subscription_months;


-- 7. MOVEMENT DISTRIBUTION

SELECT
    movement_type,
    COUNT(*) AS total_records
FROM subscription_months
GROUP BY movement_type
ORDER BY total_records DESC;
