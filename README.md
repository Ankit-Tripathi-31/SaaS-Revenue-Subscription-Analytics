# SaaS Revenue & Subscription Analytics

## Project Overview

This project analyzes Software-as-a-Service (SaaS) subscription activity, recurring revenue, customer churn, and retention to identify business growth opportunities.

The project follows the Qveto Technologies Data Analyst Project 2 requirements and four-week implementation plan.

## Business Objectives

- Analyze Monthly Recurring Revenue (MRR).
- Track new subscriptions, upgrades, downgrades, reactivations, and cancellations.
- Calculate customer churn and revenue churn.
- Perform cohort-based customer retention analysis.
- Evaluate customer acquisition cost (CAC) and customer lifetime value (LTV) only when sufficient data is available.
- Build an interactive Power BI dashboard.
- Provide evidence-based revenue growth recommendations.

## Technology Stack

- Python
- Pandas and NumPy
- Matplotlib and Seaborn
- PostgreSQL and SQL
- Microsoft Excel
- Power BI
- Git and GitHub

## Project Structure

```text
SaaS-Revenue-Subscription-Analytics/
├── data/
│   ├── raw/
│   ├── interim/
│   └── processed/
├── notebooks/
├── src/
├── sql/
├── reports/
│   └── figures/
├── dashboards/
├── docs/
├── README.md
├── requirements.txt
└── .gitignore
```

## Four-Week Implementation Plan

### Week 1: Data Ingestion and Quality Audit
- Identify and obtain a suitable dataset.
- Inspect customer, subscription, and billing records.
- Validate identifiers, dates, statuses, prices, and missing values.
- Prepare data dictionary, data model, and cleaned interim datasets.
- Perform initial exploratory data analysis.

### Week 2: MRR, Subscription Movements and Churn
- Calculate recurring revenue and subscription movement KPIs.
- Analyze cancellations and reactivations.
- Calculate customer and revenue churn.
- Validate monthly KPI calculations.

### Week 3: Retention and Revenue Trends
- Perform cohort retention analysis.
- Compare customer segments and subscription plans.
- Analyze revenue trends.
- Evaluate CAC, LTV, and forecasting only when supported by available data.

### Week 4: Dashboard and Reporting
- Develop an interactive Power BI dashboard.
- Validate dashboard metrics against analytical results.
- Prepare a revenue analysis report.
- Document business insights and recommendations.
- Complete the final presentation.

## Dataset

Dataset selection is pending. The data source, license, coverage, limitations, and available fields will be documented after selection.

## Project Status

**Week 1 — Project environment setup in progress.**

## Reproducibility

Create and activate a Python virtual environment, then install dependencies:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

Raw source files will be preserved without modification. Data cleaning and KPI calculations will be documented and validated.

## Author

Ankit Tripathi

## Disclaimer

This project is developed for educational and analytical purposes. Findings will depend on the quality and limitations of the selected dataset.
