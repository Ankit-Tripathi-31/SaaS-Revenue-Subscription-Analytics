# Dataset Inventory

## Project Information

**Project Name:** SaaS Revenue & Subscription Analytics  
**Project Type:** Individual Data Analytics Project  
**Dataset Source:** Prime Levels — Global SaaS Subscription & Revenue Retention Dataset  
**Source URL:** https://prime-levels.com/data-hub/global-saas-subscription-revenue-2024-2026  
**Dataset Type:** Synthetic data generated for analytics practice  
**Data Period:** 2024–2026  
**Currency:** USD

## 1. Dataset Overview

This project uses five related CSV files to analyze SaaS subscription revenue, customer activity, monthly recurring revenue (MRR), churn, and retention.

The source dataset is synthetic and does not represent actual customers, organizations, or financial transactions.

## 2. Dataset File Inventory

| File Name               |       Rows | Columns | Description                                                   |
| ----------------------- | ---------: | ------: | ------------------------------------------------------------- |
| plans.csv               |         10 |      11 | SaaS subscription plan details and pricing                    |
| customers.csv           |      1,200 |      12 | Customer profiles and subscription cohort information         |
| subscriptions.csv       |      1,381 |      12 | Subscription records and lifecycle information                |
| subscription_months.csv |     19,015 |      15 | Monthly subscription activity and recurring revenue movements |
| invoices.csv            |     11,257 |      17 | Invoice amounts, billing information, and payment records     |
| **Total**               | **32,863** |       — | Five related source tables                                    |

**Raw Data Location:** `data/raw/`

## 3. Dataset Relationships

The source documentation identifies the following relationships:

- `plans.plan_id` → `subscriptions.plan_id`
- `plans.plan_id` → `subscription_months.plan_id`
- `customers.customer_id` → `subscriptions.customer_id`
- `customers.customer_id` → `subscription_months.customer_id`
- `customers.customer_id` → `invoices.customer_id`
- `subscriptions.subscription_id` → `subscription_months.subscription_id`
- `subscriptions.subscription_id` → `invoices.subscription_id`

The `subscription_months` table is the primary source for monthly recurring revenue analysis.

These relationships will be validated during data-quality checks.

## 4. Planned Business Analysis

The dataset will be evaluated for the following analyses:

- Monthly recurring revenue (MRR)
- New, expansion, contraction, and churned MRR
- Reactivation revenue
- Customer churn and retention
- Monthly revenue trends
- Customer cohort retention
- Subscription plan performance
- Revenue reporting and dashboard development

Metric definitions and calculation logic will be documented and validated before final reporting.

## 5. Data Handling Rules

- Original CSV files will be preserved in `data/raw/`.
- Cleaned intermediate datasets will be stored in `data/interim/`.
- Final analysis-ready datasets will be stored in `data/processed/`.
- Raw source files will not be edited directly.
- All cleaning decisions and assumptions will be documented.

## 6. Dataset Limitations

1. The dataset is synthetic, so findings do not represent actual business performance.
2. Customer acquisition costs are not explicitly established; CAC analysis requires additional validated data.
3. Data quality and relationships must be independently verified.
4. Public redistribution permissions for the source CSV files have not yet been confirmed.
5. Dataset metrics and revenue movement definitions must be validated before use in final dashboards.

## 7. Source Attribution

**Publisher:** Prime Levels  
**Dataset:** Global SaaS Subscription & Revenue Retention Dataset — 2024–2026  
**URL:** https://prime-levels.com/data-hub/global-saas-subscription-revenue-2024-2026

**Note:** Source attribution does not automatically grant redistribution rights. The source license must be verified before publishing raw CSV files to a public GitHub repository.
