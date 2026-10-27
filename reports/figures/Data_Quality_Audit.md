# Data Quality Audit Report

## Project

SaaS Revenue & Subscription Analytics

## 1. Dataset Overview

| Dataset             |    Records |
| ------------------- | ---------: |
| Plans               |         10 |
| Customers           |      1,200 |
| Subscriptions       |      1,381 |
| Subscription Months |     19,015 |
| Invoices            |     11,257 |
| **Total**           | **32,863** |

Total columns across datasets: **67**

## 2. Data Quality Findings

| Validation                   | Result                              |
| ---------------------------- | ----------------------------------- |
| Exact duplicate records      | PASS — 0 found                      |
| Duplicate primary keys       | PASS — 0 found                      |
| Foreign-key references       | PASS — 0 orphan records             |
| Invalid date formats         | PASS — 0 after correct date parsing |
| Date-order consistency       | PASS                                |
| Monthly reporting dates      | PASS                                |
| MRR calculation consistency  | PASS                                |
| Invoice revenue calculations | PASS                                |
| Cross-table consistency      | PASS                                |
| Subscription business rules  | PASS                                |
| Missing-value business rules | PASS                                |

## 3. Missing Value Analysis

Total missing cells: **2,019**

| Dataset       | Column          | Missing | Business interpretation                        |
| ------------- | --------------- | ------: | ---------------------------------------------- |
| Customers     | churn_date      |     855 | Active customers have not churned              |
| Subscriptions | end_date        |     855 | Active subscriptions have not ended            |
| Invoices      | days_to_payment |     309 | Missing values associated with Failed invoices |

All observed missing-value combinations were consistent with their respective statuses.

**Decision:** Retain these missing values rather than automatically replacing or deleting them.

## 4. Revenue Validation

- MRR records validated: 19,015
- Negative current and previous MRR values: 0
- MRR delta calculation mismatches: 0
- Invoice records validated: 11,257
- Invoice subtotal calculation mismatches: 0
- Invoice total calculation mismatches: 0
- Excessive discounts: 0

## 5. Business Rule Validation

Seven subscription business-rule checks passed with zero violations.

Cross-table customer and plan consistency checks also passed.

## 6. Data Quality Decisions

- Preserve original raw datasets.
- Use explicit DD-MM-YYYY parsing for the four identified customer and subscription date columns.
- Retain legitimate missing values.
- Preserve negative MRR changes associated with revenue contraction and churn.
- Create cleaned analytical datasets separately from the raw source files.

## 7. Conclusion

The completed validation checks found no violations of the tested data-quality and business rules.

The dataset is suitable for proceeding to the cleaning and transformation stage, subject to any additional checks required during KPI development.
