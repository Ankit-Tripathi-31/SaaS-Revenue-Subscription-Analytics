-- ====================================================
-- SaaS Revenue & Subscription Analytics
-- Step 5.4.1: Date Consistency Validation
-- ====================================================

-- Check 1: Customer churn date before signup date

SELECT
    COUNT(*) AS invalid_customer_dates
FROM customers
WHERE churn_date < signup_date;


-- Check 2: Subscription end date before start date

SELECT
    COUNT(*) AS invalid_subscription_dates
FROM subscriptions
WHERE end_date < start_date;


-- Check 3: Invoice billing period end before start

SELECT
    COUNT(*) AS invalid_billing_periods
FROM invoices
WHERE billing_period_end < billing_period_start;


-- Check 4: Invoice date missing

SELECT
    COUNT(*) AS missing_invoice_dates
FROM invoices
WHERE invoice_date IS NULL;


-- Check 5: Subscription start date missing

SELECT
    COUNT(*) AS missing_subscription_start_dates
FROM subscriptions
WHERE start_date IS NULL;


-- Check 6: Customer signup date missing

SELECT
    COUNT(*) AS missing_customer_signup_dates
FROM customers
WHERE signup_date IS NULL;


-- ====================================================
-- Step 5.4.2: Revenue & Invoice Amount Validation
-- ====================================================

-- Check 1: Negative monthly revenue
SELECT
    COUNT(*) AS negative_mrr_records
FROM subscription_months
WHERE mrr_usd < 0;


-- Check 2: Negative previous monthly revenue
SELECT
    COUNT(*) AS negative_previous_mrr_records
FROM subscription_months
WHERE previous_mrr_usd < 0;


-- Check 3: Monthly revenue delta consistency
SELECT
    COUNT(*) AS invalid_mrr_delta_records
FROM subscription_months
WHERE mrr_usd IS NULL
   OR previous_mrr_usd IS NULL
   OR mrr_delta_usd IS NULL
   OR ABS(
       mrr_delta_usd - (mrr_usd - previous_mrr_usd)
   ) > 0.01;


-- Check 4: Negative invoice totals
SELECT
    COUNT(*) AS negative_invoice_totals
FROM invoices
WHERE total_usd < 0;


-- Check 5: Missing invoice totals
SELECT
    COUNT(*) AS missing_invoice_totals
FROM invoices
WHERE total_usd IS NULL;


-- Check 6: Invoice total calculation consistency
-- Assumed formula: total = subtotal + tax
SELECT
    COUNT(*) AS invalid_invoice_total_calculations
FROM invoices
WHERE subtotal_usd IS NULL
   OR tax_usd IS NULL
   OR total_usd IS NULL
   OR ABS(
       total_usd - (subtotal_usd + tax_usd)
   ) > 0.01;


-- Check 7: Negative invoice amount components
SELECT
    COUNT(*) AS negative_invoice_components
FROM invoices
WHERE amount_usd < 0
   OR discount_usd < 0
   OR subtotal_usd < 0
   OR tax_usd < 0;

-- ====================================================
-- Step 5.4.3: Subscription Relationship Consistency
-- ====================================================

-- Check 1: Subscription months customer mismatch

SELECT
    COUNT(*) AS mismatched_monthly_customers
FROM subscription_months sm
JOIN subscriptions s
    ON sm.subscription_id = s.subscription_id
WHERE sm.customer_id IS DISTINCT FROM s.customer_id;


-- Check 2: Subscription months plan mismatch

SELECT
    COUNT(*) AS mismatched_monthly_plans
FROM subscription_months sm
JOIN subscriptions s
    ON sm.subscription_id = s.subscription_id
WHERE sm.plan_id IS DISTINCT FROM s.plan_id;


-- Check 3: Invoice customer mismatch

SELECT
    COUNT(*) AS mismatched_invoice_customers
FROM invoices i
JOIN subscriptions s
    ON i.subscription_id = s.subscription_id
WHERE i.customer_id IS DISTINCT FROM s.customer_id;


-- Check 4: Subscriptions without monthly records

SELECT
    COUNT(*) AS subscriptions_without_monthly_records
FROM subscriptions s
WHERE NOT EXISTS (
    SELECT 1
    FROM subscription_months sm
    WHERE sm.subscription_id = s.subscription_id
);


-- Check 5: Customers without subscriptions

SELECT
    COUNT(*) AS customers_without_subscriptions
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM subscriptions s
    WHERE s.customer_id = c.customer_id
);


-- Check 6: Invoices with subscriptions
-- that belong to different customers

SELECT
    i.invoice_id,
    i.customer_id AS invoice_customer,
    s.customer_id AS subscription_customer,
    i.subscription_id
FROM invoices i
JOIN subscriptions s
    ON i.subscription_id = s.subscription_id
WHERE i.customer_id IS DISTINCT FROM s.customer_id
LIMIT 10;

-- Step 5.4.4: Monthly MRR Movement Validation

-- Check 1: New movement consistency
SELECT
    COUNT(*) AS invalid_new_movements
FROM subscription_months
WHERE movement_type = 'New'
  AND (
      previous_mrr_usd <> 0
      OR mrr_usd <= 0
      OR mrr_delta_usd <= 0
  );


-- Check 2: Retained movement consistency

SELECT
    COUNT(*) AS invalid_retained_movements
FROM subscription_months
WHERE movement_type = 'Retained'
  AND (
      previous_mrr_usd IS NULL
      OR mrr_usd IS NULL
      OR mrr_delta_usd IS NULL
      OR previous_mrr_usd <= 0
      OR mrr_usd <= 0
      OR ABS(mrr_delta_usd) > 0.01
      OR ABS(mrr_usd - previous_mrr_usd) > 0.01
  );

-- Check 3: Expansion movement consistency

SELECT
    COUNT(*) AS invalid_expansion_movements
FROM subscription_months
WHERE movement_type = 'Expansion'
  AND (
      previous_mrr_usd IS NULL
      OR mrr_usd IS NULL
      OR mrr_delta_usd IS NULL
      OR previous_mrr_usd <= 0
      OR mrr_usd <= previous_mrr_usd
      OR mrr_delta_usd <= 0
  );

-- Check 4: Contraction movement consistency

SELECT
    COUNT(*) AS invalid_contraction_movements
FROM subscription_months
WHERE movement_type = 'Contraction'
  AND (
      previous_mrr_usd IS NULL
      OR mrr_usd IS NULL
      OR mrr_delta_usd IS NULL
      OR previous_mrr_usd <= 0
      OR mrr_usd <= 0
      OR mrr_usd >= previous_mrr_usd
      OR mrr_delta_usd >= 0
  );

-- Check 5: Churn movement consistency

SELECT
    COUNT(*) AS invalid_churn_movements
FROM subscription_months
WHERE movement_type = 'Churn'
  AND (
      previous_mrr_usd IS NULL
      OR mrr_usd IS NULL
      OR mrr_delta_usd IS NULL
      OR previous_mrr_usd <= 0
      OR mrr_usd <> 0
      OR mrr_delta_usd >= 0
      OR ABS(mrr_delta_usd + previous_mrr_usd) > 0.01
  );

-- Check 6: Reactivation movement consistency

SELECT
    COUNT(*) AS invalid_reactivation_movements
FROM subscription_months
WHERE movement_type = 'Reactivation'
  AND (
      previous_mrr_usd IS NULL
      OR mrr_usd IS NULL
      OR mrr_delta_usd IS NULL
      OR previous_mrr_usd <> 0
      OR mrr_usd <= 0
      OR mrr_delta_usd <= 0
      OR ABS(mrr_delta_usd - mrr_usd) > 0.01
  );

-- Step 5.4.4: Final Movement Distribution Validation

SELECT
    movement_type,
    COUNT(*) AS total_records,
    ROUND(SUM(mrr_usd), 2) AS total_current_mrr,
    ROUND(SUM(previous_mrr_usd), 2) AS total_previous_mrr,
    ROUND(SUM(mrr_delta_usd), 2) AS total_mrr_change
FROM subscription_months
GROUP BY movement_type
ORDER BY total_records DESC;