# SaaS Revenue & Subscription Analytics

## KPI Definitions & Business Logic

### 1. Monthly Recurring Revenue (MRR)

**Definition:** Total recurring subscription revenue for a given month.

**Formula:** `SUM(mrr_usd)`

**Source:** `subscription_months`

**Business use:** Tracks the monthly recurring revenue base.

### 2. Month-over-Month MRR Growth

**Formula:**

`((Current Month MRR - Previous Month MRR) / Previous Month MRR) × 100`

**Business use:** Measures monthly recurring revenue growth or decline.

**Limitation:** Undefined when previous-month MRR is zero or unavailable.

### 3. MRR Movement Metrics

| Metric           | Definition                                                               |
| ---------------- | ------------------------------------------------------------------------ |
| New MRR          | Positive MRR change classified as New                                    |
| Expansion MRR    | Additional recurring revenue from existing subscriptions                 |
| Contraction MRR  | Recurring revenue reduction, reported as a positive loss magnitude       |
| Churn MRR        | Lost recurring revenue from churn, reported as a positive loss magnitude |
| Reactivation MRR | Recurring revenue restored through reactivation                          |

**Source:** `subscription_months.movement_type` and `mrr_delta_usd`

**Revenue reconciliation:**

`Closing MRR = Opening MRR + New MRR + Expansion MRR + Reactivation MRR - Contraction MRR - Churn MRR`

Retained movement delta is also included in the implemented reconciliation and was validated to be approximately zero.

### 4. Subscription Churn Rate

**Formula:**

`Churn Events / Opening Paid Subscriptions × 100`

**Opening paid subscription definition:** Distinct subscriptions with `previous_mrr_usd > 0` represented in the reporting month.

**Business use:** Measures subscription loss relative to the observed opening paid subscription base.

**Limitation:** Subscription churn events are not equivalent to unique customers who have fully churned.

### 5. Subscription Retention Rate

**Formula:**

`Subscriptions Paid at Both Start and End / Opening Paid Subscriptions × 100`

**Business use:** Measures how much of the opening paid subscription base remains paid at month-end.

### 6. Customer Retention Rate

**Formula:**

`Customers Paid at Both Start and End / Opening Paid Customers × 100`

Customers are deduplicated by customer ID within each month.

**Business use:** Measures continued paying-customer presence, regardless of whether the same subscription remains active.

### 7. Gross Revenue Retention (GRR)

**Formula:**

`(Opening MRR - Contraction MRR - Churn MRR) / Opening MRR × 100`

**Business use:** Measures revenue retained from the existing paid base without expansion.

### 8. Net Revenue Retention (NRR)

**Formula:**

`(Opening MRR + Expansion MRR - Contraction MRR - Churn MRR) / Opening MRR × 100`

**Business use:** Measures revenue retained from the existing paid base including expansion.

New MRR and reactivation MRR are excluded from this project's NRR definition.

### 9. Data Sources

- `data/interim/subscription_months_cleaned.csv`
- `data/processed/SaaS_Monthly_KPI_Summary.csv`

### 10. Data Quality & Calculation Rules

- Monetary values are denominated in USD.
- MRR is already normalized to a monthly amount.
- Churn and contraction losses are displayed as positive magnitudes in reporting.
- Zero opening denominators produce undefined rates rather than artificial zero percentages.
- Revenue movement totals are reconciled against source MRR deltas.
- Opening MRR and closing MRR are validated through the monthly revenue bridge.
- Customer and subscription metrics are reported separately.

### 11. Analysis Limitations

- The dataset is synthetic and does not represent actual company performance.
- Subscription-month records are not necessarily equivalent to complete historical account snapshots.
- Retention metrics are based on observed previous/current monthly MRR values.
- Monthly retention rates are not cohort retention rates.
- Summing monthly MRR balances does not produce recognized annual revenue.
- Previous calendar-month closing MRR and source-derived opening MRR are separate fields and should not be confused.
