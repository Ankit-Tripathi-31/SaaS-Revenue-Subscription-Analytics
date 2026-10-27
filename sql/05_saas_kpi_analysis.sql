-- ====================================================
-- SaaS Revenue & Subscription Analytics
-- Step 5.5: SQL KPI Analysis
-- ====================================================

-- Step 5.5.1: Monthly MRR Calculation

SELECT
    period_month,
    COUNT(*) AS total_subscription_records,
    COUNT(DISTINCT subscription_id) AS unique_subscriptions,
    ROUND(SUM(mrr_usd), 2) AS total_mrr_usd
FROM subscription_months
GROUP BY period_month
ORDER BY period_month;


-- ====================================================
-- Step 5.5.2: Monthly MRR Growth Analysis
-- ====================================================

WITH monthly_mrr AS (
    SELECT
        period_month,
        ROUND(SUM(mrr_usd), 2) AS total_mrr_usd
    FROM subscription_months
    GROUP BY period_month
),

mrr_with_previous AS (
    SELECT
        period_month,
        total_mrr_usd,

        LAG(total_mrr_usd) OVER (
            ORDER BY period_month
        ) AS previous_month_mrr

    FROM monthly_mrr
)

SELECT
    period_month,
    total_mrr_usd,
    previous_month_mrr,

    ROUND(
        total_mrr_usd - previous_month_mrr,
        2
    ) AS mrr_growth_usd,

    ROUND(
        (
            (total_mrr_usd - previous_month_mrr)
            / NULLIF(previous_month_mrr, 0)
        ) * 100,
        2
    ) AS mrr_growth_percentage

FROM mrr_with_previous
ORDER BY period_month;



-- ====================================================
-- Step 5.5.3: Monthly Revenue Movement Analysis
-- ====================================================

SELECT
    period_month,

    ROUND(SUM(
        CASE
            WHEN movement_type = 'New'
            THEN mrr_delta_usd ELSE 0
        END
    ), 2) AS new_mrr,

    ROUND(SUM(
        CASE
            WHEN movement_type = 'Expansion'
            THEN mrr_delta_usd ELSE 0
        END
    ), 2) AS expansion_mrr,

    ROUND(SUM(
        CASE
            WHEN movement_type = 'Contraction'
            THEN mrr_delta_usd ELSE 0
        END
    ), 2) AS contraction_mrr,

    ROUND(SUM(
        CASE
            WHEN movement_type = 'Churn'
            THEN mrr_delta_usd ELSE 0
        END
    ), 2) AS churn_mrr,

    ROUND(SUM(
        CASE
            WHEN movement_type = 'Reactivation'
            THEN mrr_delta_usd ELSE 0
        END
    ), 2) AS reactivation_mrr,

    ROUND(SUM(
        mrr_delta_usd
    ), 2) AS net_mrr_change

FROM subscription_months

GROUP BY period_month
ORDER BY period_month;


-- Step 5.5.3: Movement Reconciliation

WITH monthly_movements AS (
    SELECT
        period_month,

        SUM(CASE WHEN movement_type = 'New'
            THEN mrr_delta_usd ELSE 0 END) AS new_mrr,

        SUM(CASE WHEN movement_type = 'Expansion'
            THEN mrr_delta_usd ELSE 0 END) AS expansion_mrr,

        SUM(CASE WHEN movement_type = 'Contraction'
            THEN mrr_delta_usd ELSE 0 END) AS contraction_mrr,

        SUM(CASE WHEN movement_type = 'Churn'
            THEN mrr_delta_usd ELSE 0 END) AS churn_mrr,

        SUM(CASE WHEN movement_type = 'Reactivation'
            THEN mrr_delta_usd ELSE 0 END) AS reactivation_mrr,

        SUM(mrr_delta_usd) AS actual_net_change

    FROM subscription_months
    GROUP BY period_month
)

SELECT
    period_month,

    ROUND(
        new_mrr + expansion_mrr + contraction_mrr
        + churn_mrr + reactivation_mrr, 2
    ) AS calculated_net_change,

    ROUND(actual_net_change, 2) AS actual_net_change,

    CASE
        WHEN ABS(
            (new_mrr + expansion_mrr + contraction_mrr
             + churn_mrr + reactivation_mrr)
            - actual_net_change
        ) <= 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status

FROM monthly_movements
ORDER BY period_month;


-- ====================================================
-- Step 5.5.4: Monthly Subscription Churn Rate
-- ====================================================

WITH monthly_subscription_metrics AS (
    SELECT
        period_month,

        COUNT(DISTINCT subscription_id) FILTER (
            WHERE previous_mrr_usd > 0
        ) AS beginning_active_subscriptions,

        COUNT(DISTINCT subscription_id) FILTER (
            WHERE movement_type = 'Churn'
        ) AS churned_subscriptions

    FROM subscription_months
    GROUP BY period_month
)

SELECT
    period_month,
    beginning_active_subscriptions,
    churned_subscriptions,

    ROUND(
        churned_subscriptions::NUMERIC
        / NULLIF(beginning_active_subscriptions, 0)
        * 100,
        2
    ) AS subscription_churn_rate_pct

FROM monthly_subscription_metrics
ORDER BY period_month;



-- ====================================================
-- Step 5.5.5: Customer & Subscription Retention
-- ====================================================

WITH subscription_metrics AS (
    SELECT
        period_month,

        COUNT(DISTINCT subscription_id) FILTER (
            WHERE previous_mrr_usd > 0
        ) AS beginning_active_subscriptions,

        COUNT(DISTINCT subscription_id) FILTER (
            WHERE previous_mrr_usd > 0
              AND mrr_usd > 0
        ) AS retained_subscriptions

    FROM subscription_months
    GROUP BY period_month
),

customer_monthly_status AS (
    SELECT
        period_month,
        customer_id,

        BOOL_OR(previous_mrr_usd > 0)
            AS active_at_beginning,

        BOOL_OR(mrr_usd > 0)
            AS active_at_end

    FROM subscription_months
    GROUP BY period_month, customer_id
),

customer_metrics AS (
    SELECT
        period_month,

        COUNT(*) FILTER (
            WHERE active_at_beginning
        ) AS beginning_active_customers,

        COUNT(*) FILTER (
            WHERE active_at_beginning
              AND active_at_end
        ) AS retained_customers

    FROM customer_monthly_status
    GROUP BY period_month
)

SELECT
    s.period_month,

    c.beginning_active_customers,
    c.retained_customers,

    ROUND(
        c.retained_customers::NUMERIC
        / NULLIF(c.beginning_active_customers, 0)
        * 100,
        2
    ) AS customer_retention_rate_pct,

    s.beginning_active_subscriptions,
    s.retained_subscriptions,

    ROUND(
        s.retained_subscriptions::NUMERIC
        / NULLIF(s.beginning_active_subscriptions, 0)
        * 100,
        2
    ) AS subscription_retention_rate_pct

FROM subscription_metrics s
JOIN customer_metrics c
    ON s.period_month = c.period_month

ORDER BY s.period_month;



-- ====================================================
-- Step 5.5.6: Gross & Net Revenue Retention
-- ====================================================

WITH monthly_revenue AS (
    SELECT
        period_month,

        SUM(previous_mrr_usd) AS beginning_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Expansion'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS expansion_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Contraction'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS contraction_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Churn'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS churn_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Reactivation'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS reactivation_mrr

    FROM subscription_months
    GROUP BY period_month
)

SELECT
    period_month,

    ROUND(beginning_mrr, 2) AS beginning_mrr,

    ROUND(
        (
            beginning_mrr
            + contraction_mrr
            + churn_mrr
        ) / NULLIF(beginning_mrr, 0) * 100,
        2
    ) AS grr_pct,

    ROUND(
        (
            beginning_mrr
            + expansion_mrr
            + contraction_mrr
            + churn_mrr
            + reactivation_mrr
        ) / NULLIF(beginning_mrr, 0) * 100,
        2
    ) AS nrr_pct

FROM monthly_revenue
ORDER BY period_month;



-- ====================================================
-- Step 5.5.7: Monthly Revenue Bridge Reconciliation
-- ====================================================

WITH monthly_revenue_bridge AS (
    SELECT
        period_month,

        SUM(previous_mrr_usd) AS beginning_mrr,

        SUM(
            CASE
                WHEN movement_type = 'New'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS new_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Expansion'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS expansion_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Reactivation'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS reactivation_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Contraction'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS contraction_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Churn'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS churn_mrr,

        SUM(mrr_usd) AS actual_ending_mrr

    FROM subscription_months
    GROUP BY period_month
),

reconciliation AS (
    SELECT
        *,

        beginning_mrr
        + new_mrr
        + expansion_mrr
        + reactivation_mrr
        + contraction_mrr
        + churn_mrr
        AS calculated_ending_mrr

    FROM monthly_revenue_bridge
)

SELECT
    period_month,

    ROUND(beginning_mrr, 2) AS beginning_mrr,
    ROUND(new_mrr, 2) AS new_mrr,
    ROUND(expansion_mrr, 2) AS expansion_mrr,
    ROUND(reactivation_mrr, 2) AS reactivation_mrr,
    ROUND(contraction_mrr, 2) AS contraction_mrr,
    ROUND(churn_mrr, 2) AS churn_mrr,

    ROUND(calculated_ending_mrr, 2)
        AS calculated_ending_mrr,

    ROUND(actual_ending_mrr, 2)
        AS actual_ending_mrr,

    ROUND(
        calculated_ending_mrr - actual_ending_mrr,
        2
    ) AS reconciliation_difference,

    CASE
        WHEN ABS(
            calculated_ending_mrr - actual_ending_mrr
        ) <= 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status

FROM reconciliation
ORDER BY period_month;



-- ====================================================
-- Step 5.5.8: Final SQL KPI Consistency Verification
-- ====================================================

WITH monthly_kpis AS (
    SELECT
        period_month,

        COUNT(*) AS total_records,

        SUM(mrr_usd) AS ending_mrr,

        SUM(previous_mrr_usd) AS beginning_mrr,

        SUM(mrr_delta_usd) AS net_mrr_change,

        SUM(
            CASE
                WHEN movement_type = 'New'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS new_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Expansion'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS expansion_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Contraction'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS contraction_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Churn'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS churn_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Reactivation'
                THEN mrr_delta_usd ELSE 0
            END
        ) AS reactivation_mrr

    FROM subscription_months
    GROUP BY period_month
)

SELECT
    period_month,

    total_records,

    ROUND(beginning_mrr, 2) AS beginning_mrr,

    ROUND(ending_mrr, 2) AS ending_mrr,

    ROUND(net_mrr_change, 2) AS net_mrr_change,

    CASE
        WHEN ABS(
            beginning_mrr + net_mrr_change - ending_mrr
        ) <= 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS mrr_delta_check,

    CASE
        WHEN ABS(
            new_mrr
            + expansion_mrr
            + contraction_mrr
            + churn_mrr
            + reactivation_mrr
            - net_mrr_change
        ) <= 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS movement_check

FROM monthly_kpis
ORDER BY period_month;
