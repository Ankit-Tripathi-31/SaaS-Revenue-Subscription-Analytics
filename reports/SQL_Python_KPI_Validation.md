# SQL vs Python KPI Validation Report

## Project

SaaS Revenue & Subscription Analytics

## Objective

Verify consistency between SaaS KPI calculations implemented in PostgreSQL and Python.

## Data Source

- Database: `saas_revenue_analytics`
- Primary KPI table: `subscription_months`
- Subscription-month records: 19,015
- Total records across all five imported tables: 32,863

## KPI Reconciliation Summary

| KPI                                                     | SQL vs Python Result |
| ------------------------------------------------------- | -------------------- |
| Monthly MRR                                             | PASS                 |
| Monthly MRR Growth                                      | PASS                 |
| New, Expansion, Contraction, Churn and Reactivation MRR | PASS                 |
| Net MRR Change                                          | PASS                 |
| Monthly Subscription Churn Rate                         | PASS                 |
| Customer Retention Rate                                 | PASS                 |
| Subscription Retention Rate                             | PASS                 |
| Gross Revenue Retention (GRR)                           | PASS                 |
| Net Revenue Retention (NRR)                             | PASS                 |
| Monthly Revenue Bridge                                  | PASS                 |

## Validation Methodology

1. Calculated SaaS KPIs using PostgreSQL queries.
2. Compared reporting periods and calculated values against the existing Python KPI notebook.
3. Confirmed that SQL and Python use consistent KPI definitions.
4. Validated monthly MRR movement reconciliation.
5. Verified that calculated ending MRR matches recorded ending MRR.

## Financial Reconciliation

The monthly revenue bridge follows:

Ending MRR = Beginning MRR + New MRR + Expansion MRR + Reactivation MRR + Contraction MRR + Churn MRR

Contraction and Churn are represented as negative revenue movements.

All previously executed monthly revenue bridge reconciliation checks passed.

## KPI Definition Notes

- Monthly MRR is calculated from subscription-month recurring revenue.
- Monthly churn rate uses beginning active subscriptions as the denominator.
- Customer retention considers whether customers remain active across the reporting month.
- GRR excludes Expansion MRR.
- The project's NRR calculation includes Reactivation MRR, consistent with the validated Python implementation.

## Conclusion

The PostgreSQL SaaS KPI calculations match the corresponding Python analysis based on the completed comparisons.

The revenue movement and reconciliation checks support the consistency of the project's KPI calculations.

## Supporting Files

- `sql/05_saas_kpi_analysis.sql`
- `notebooks/04_SaaS_Revenue_KPI_Analysis.ipynb`
- `docs/SaaS_KPI_Definitions.md`
- `reports/SaaS_KPI_Business_Findings.md`
- `reports/SQL_Data_Quality_Validation.md`
