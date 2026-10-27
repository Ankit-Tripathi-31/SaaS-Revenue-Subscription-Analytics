# Data Dictionary

## SaaS Revenue & Subscription Analytics

**Dataset:** Global SaaS Subscription & Revenue Retention Dataset (2024–2026)  
**Source:** https://prime-levels.com/data-hub/global-saas-subscription-revenue-2024-2026  
**Dataset Type:** Synthetic  
**Currency:** USD  
**Total Tables:** 5  
**Total Columns:** 67

## 1. Overview

This data dictionary documents the five source tables used for subscription revenue, MRR movements, churn, and customer retention analysis.

Column names are taken from the original CSV files. Pandas-inferred data types, non-null counts, and missing-value counts are separately documented in `Dataset_Schema.csv`.

Date fields are initially imported from CSV and will be converted to appropriate date types during data preparation.

## 2. Plans Table

**Source:** `data/raw/plans.csv`  
**Rows:** 10  
**Columns:** 11  
**Grain:** One record per subscription plan.

| Column                 | Description                                   |
| ---------------------- | --------------------------------------------- |
| `plan_id`              | Unique plan identifier; primary key candidate |
| `plan_name`            | Subscription plan name                        |
| `tier`                 | Subscription plan tier                        |
| `billing_interval`     | Monthly or annual billing interval            |
| `list_price_usd`       | Listed plan price in USD                      |
| `monthly_price_usd`    | Monthly equivalent of listed price            |
| `billing_months`       | Number of months in the billing interval      |
| `seats_included`       | Seats included in the base plan               |
| `extra_seat_price_usd` | Additional price per extra seat               |
| `is_active`            | Whether the plan is active                    |
| `launched_date`        | Plan launch date                              |

## 3. Customers Table

**Source:** `data/raw/customers.csv`  
**Rows:** 1,200  
**Columns:** 12  
**Grain:** One record per customer.

| Column                | Description                                       |
| --------------------- | ------------------------------------------------- |
| `customer_id`         | Unique customer identifier; primary key candidate |
| `company_name`        | Customer organization name                        |
| `country`             | Customer country                                  |
| `region`              | Geographic region                                 |
| `industry`            | Customer industry                                 |
| `segment`             | Customer segment                                  |
| `employees_band`      | Company employee-size category                    |
| `signup_date`         | Customer signup date                              |
| `acquisition_channel` | Channel through which customer was acquired       |
| `cohort_month`        | Customer's first month with recorded MRR          |
| `customer_status`     | Customer's recorded lifecycle status              |
| `churn_date`          | Customer churn date, if applicable                |

## 4. Subscriptions Table

**Source:** `data/raw/subscriptions.csv`  
**Rows:** 1,381  
**Columns:** 12  
**Grain:** One record per subscription.

| Column                 | Description                                           |
| ---------------------- | ----------------------------------------------------- |
| `subscription_id`      | Unique subscription identifier; primary key candidate |
| `customer_id`          | Customer identifier; foreign key to customers         |
| `plan_id`              | Plan identifier; foreign key to plans                 |
| `start_date`           | Subscription start date                               |
| `end_date`             | Subscription end date, if applicable                  |
| `subscription_status`  | Recorded subscription status                          |
| `billing_interval`     | Subscription billing interval                         |
| `seats`                | Number of subscription seats                          |
| `discount_pct`         | Percentage discount applied                           |
| `mrr_usd`              | Recorded monthly recurring revenue in USD             |
| `contract_term_months` | Contract duration in months                           |
| `auto_renew`           | Whether automatic renewal is enabled                  |

## 5. Subscription Months Table

**Source:** `data/raw/subscription_months.csv`  
**Rows:** 19,015  
**Columns:** 15  
**Grain:** One monthly revenue-ledger record per customer-month, as specified by the source documentation.

| Column             | Description                                                   |
| ------------------ | ------------------------------------------------------------- |
| `record_id`        | Unique monthly ledger record identifier                       |
| `customer_id`      | Customer identifier                                           |
| `subscription_id`  | Associated subscription identifier                            |
| `plan_id`          | Associated subscription plan identifier                       |
| `period_month`     | Reporting month in YYYY-MM format                             |
| `month_start_date` | First calendar date of the reporting month                    |
| `is_active`        | Whether the customer has an active subscription in the period |
| `seats`            | Number of seats for the period                                |
| `mrr_usd`          | Monthly recurring revenue in USD                              |
| `previous_mrr_usd` | Customer's previous recorded MRR                              |
| `mrr_delta_usd`    | Difference between current and previous MRR                   |
| `movement_type`    | Revenue movement category                                     |
| `tenure_months`    | Customer tenure in months                                     |
| `cohort_month`     | Customer's first month with MRR                               |
| `currency`         | Revenue currency                                              |

### Revenue Movement Categories

The source dataset contains the following movement types:

- **New:** First recorded customer MRR
- **Retained:** Continuing revenue without a classified expansion or contraction
- **Expansion:** Increase in recurring revenue
- **Contraction:** Decrease in recurring revenue
- **Churn:** Recurring revenue lost when the customer becomes inactive
- **Reactivation:** Recurring revenue restored after churn

These classifications will be validated against monthly MRR values during KPI engineering.

### Source-Defined MRR Rules

The dataset documentation specifies:

`mrr_delta_usd = mrr_usd - previous_mrr_usd`

MRR is derived from the plan's monthly price, additional seats, and applicable discount.

The monthly revenue ledger is the primary source for MRR and revenue movement analysis.

## 6. Invoices Table

**Source:** `data/raw/invoices.csv`  
**Rows:** 11,257  
**Columns:** 17  
**Grain:** One record per invoice.

| Column                 | Description                                      |
| ---------------------- | ------------------------------------------------ |
| `invoice_id`           | Unique invoice identifier; primary key candidate |
| `customer_id`          | Customer identifier                              |
| `subscription_id`      | Associated subscription identifier               |
| `invoice_date`         | Date invoice was issued                          |
| `invoice_month`        | Invoice reporting month                          |
| `billing_period_start` | Billing coverage start date                      |
| `billing_period_end`   | Billing coverage end date                        |
| `months_covered`       | Number of months covered by invoice              |
| `amount_usd`           | Invoice amount before recorded discount          |
| `discount_usd`         | Invoice discount amount                          |
| `subtotal_usd`         | Invoice subtotal after discount                  |
| `tax_usd`              | Tax amount                                       |
| `total_usd`            | Invoice total including tax                      |
| `invoice_status`       | Recorded invoice status                          |
| `payment_method`       | Payment method                                   |
| `days_to_payment`      | Days taken to pay the invoice, where available   |
| `currency`             | Invoice currency                                 |

### Invoice Calculation Rules

According to the source documentation:

`subtotal_usd = amount_usd - discount_usd`

`total_usd = subtotal_usd + tax_usd`

Invoice amounts and subscription MRR must not be combined indiscriminately, because they represent different financial measures.

## 7. Table Relationships

| Parent Table  | Child Table         | Relationship Key  | Expected Cardinality |
| ------------- | ------------------- | ----------------- | -------------------- |
| plans         | subscriptions       | `plan_id`         | One-to-many          |
| plans         | subscription_months | `plan_id`         | One-to-many          |
| customers     | subscriptions       | `customer_id`     | One-to-many          |
| customers     | subscription_months | `customer_id`     | One-to-many          |
| customers     | invoices            | `customer_id`     | One-to-many          |
| subscriptions | subscription_months | `subscription_id` | One-to-many          |
| subscriptions | invoices            | `subscription_id` | One-to-many          |

Primary key uniqueness, foreign key validity, and relationship cardinalities will be checked during the data-quality audit.

## 8. Business Metrics Planned

| Metric                    | Primary Data Source                       |
| ------------------------- | ----------------------------------------- |
| Monthly Recurring Revenue | subscription_months                       |
| New MRR                   | subscription_months                       |
| Expansion MRR             | subscription_months                       |
| Contraction MRR           | subscription_months                       |
| Churned MRR               | subscription_months                       |
| Reactivation MRR          | subscription_months                       |
| Customer Churn Rate       | subscription_months, customers            |
| Customer Retention Rate   | subscription_months, customers            |
| Cohort Retention          | customers, subscription_months            |
| Plan Performance          | plans, subscriptions, subscription_months |
| Invoice Analysis          | invoices                                  |

Exact metric formulas, cohort definitions, and reconciliation rules will be documented during Week 2 KPI engineering.

## 9. Data Quality and Limitations

- Raw source data must remain unchanged.
- Missing dates and payment-duration values require business-rule validation.
- CSV-inferred data types are not necessarily the final analytical data types.
- The dataset is synthetic and does not represent real business transactions.
- Customer acquisition cost cannot be calculated without verified acquisition spending data.
- Source licensing and public redistribution permissions require confirmation before publishing raw CSV files to GitHub.

## 10. Documentation References

- `docs/Dataset_Inventory.md` — Source file inventory
- `docs/Dataset_Schema.csv` — Actual column names, inferred types, and completeness counts
- `notebooks/01_Data_Inspection.ipynb` — Reproducible schema inspection
- `data/raw/` — Original CSV datasets

**Documentation Status:** Initial data dictionary completed; business rules and key constraints pending validation.
