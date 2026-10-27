# SQL Data Quality Validation Report

## Project

SaaS Revenue & Subscription Analytics

## Objective

Validate the integrity, consistency, and business-rule compliance of the cleaned SaaS dataset after importing it into PostgreSQL.

## Database Overview

- Database: `saas_revenue_analytics`
- Database System: PostgreSQL
- Total Tables: 5
- Total Records: 32,863

| Table               |    Records |
| ------------------- | ---------: |
| plans               |         10 |
| customers           |      1,200 |
| subscriptions       |      1,381 |
| subscription_months |     19,015 |
| invoices            |     11,257 |
| **Total**           | **32,863** |

## 1. Import and Structural Validation

- All five tables imported successfully.
- No duplicate primary keys identified.
- All seven foreign key relationships validated.
- Column names and ordering verified against the cleaned CSV files.

**Result: PASS**

## 2. Missing Value Validation

| Column                   | NULL Records |
| ------------------------ | -----------: |
| customers.churn_date     |          855 |
| subscriptions.end_date   |          855 |
| invoices.days_to_payment |          309 |

These missing values were retained because they are explainable in the source data and should not automatically be replaced with zero.

**Result: PASS**

## 3. Date Consistency Validation

Six checks were performed covering customer signup/churn dates, subscription start/end dates, invoice billing periods, and required dates.

All six queries returned zero invalid records.

**Result: PASS**

## 4. Revenue and Invoice Consistency

Seven SQL checks validated negative MRR, previous MRR, MRR delta calculations, invoice totals, missing invoice totals, invoice calculations, and negative invoice components.

All seven checks returned zero invalid records.

**Result: PASS**

## 5. Relationship Consistency

Six checks validated subscription-to-customer relationships, monthly plan relationships, invoice customer relationships, and missing associated records.

All six checks returned zero mismatches or missing associations.

**Result: PASS**

## 6. Monthly MRR Movement Validation

| Movement Type |    Records | Invalid Records |
| ------------- | ---------: | --------------: |
| Retained      |     16,143 |               0 |
| New           |      1,200 |               0 |
| Expansion     |      1,023 |               0 |
| Churn         |        368 |               0 |
| Contraction   |        258 |               0 |
| Reactivation  |         23 |               0 |
| **Total**     | **19,015** |           **0** |

The movement distribution matches the Python analysis. All six movement types passed the applicable MRR consistency checks.

**Result: PASS**

## 7. Overall Conclusion

All executed PostgreSQL data quality validations passed.

The imported dataset is structurally consistent and satisfies the tested date, revenue, relationship, and monthly MRR movement rules.

This validation supports the next phase of SQL-based SaaS KPI analysis. It does not independently establish the accuracy of the original source data or all possible business rules.

## SQL Files

- `sql/01_database_setup.sql`
- `sql/02_create_tables.sql`
- `sql/03_import_validation.sql`
- `sql/04_data_quality_validation.sql`
