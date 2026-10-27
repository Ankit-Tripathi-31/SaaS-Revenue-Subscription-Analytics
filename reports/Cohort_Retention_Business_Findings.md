# Customer Cohort Retention — Business Findings

## Project

SaaS Revenue & Subscription Analytics

## Objective

Analyze signup-based customer cohorts to understand revenue-active customer retention over time.

## Methodology

- Customers grouped by their signup month.
- A customer is considered revenue-active in a month when their recorded MRR is greater than zero.
- Multiple subscriptions belonging to one customer are counted only once per month.
- Retention percentages use the original signup cohort size.
- Months outside the dataset observation window are excluded.
- Overall retention is weighted by eligible cohort size.

## Key Findings

### 1. Month 0 Customer Activation

- Overall Month 0 activation: **[Enter value]%**
- Interpretation: **[Describe the share of signup customers generating revenue in their signup month.]**

### 2. Month 1 Customer Retention

- Overall Month 1 retention: **[Enter value]%**
- Interpretation: **[Describe early customer retention.]**

### 3. Month 3 Customer Retention

- Overall Month 3 retention: **[Enter value]%**
- Interpretation: **[Describe medium-term retention.]**

### 4. Best and Worst Month 1 Cohorts

- Highest Month 1 retention cohort: **[Month and percentage]**
- Lowest Month 1 retention cohort: **[Month and percentage]**

### 5. Retention Change

- Month 0 activation for Month 3-eligible cohorts: **[Enter value]%**
- Month 3 retention for the same cohorts: **[Enter value]%**
- Change: **[Enter value] percentage points**

## Business Implications

- Investigate signup cohorts with comparatively low early retention.
- Examine onboarding and activation processes as potential improvement areas.
- Compare retention across acquisition periods to identify patterns.
- Monitor retention trends before making conclusions about long-term customer behavior.

## Limitations

- Dataset contains synthetic SaaS records.
- Revenue-active retention is not the same as login or product engagement retention.
- Recent cohorts have shorter observation windows.
- Cohort differences alone do not establish the causes of customer churn.

## Supporting Files

- `notebooks/05_Cohort_Retention_Analysis.ipynb`
- `reports/figures/customer_cohort_retention_heatmap.png`
