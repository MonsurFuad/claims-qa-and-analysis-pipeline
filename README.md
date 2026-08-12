# Claims QA and Analysis Pipeline

A SQL-based quality assurance audit and analysis of synthetic Medicare inpatient claims data, modeled on the kind of data QA and RCM (Revenue Cycle Management) work done in healthcare operations.

## Project Overview

This project simulates a real-world claims QA workflow: auditing a raw dataset for data integrity issues, investigating and explaining anomalies, cleaning the data with a full audit trail, and analyzing it for business-relevant insights.

**Dataset:** [CMS DE-SynPUF](https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-claims-synthetic-public-use-files) (synthetic Medicare claims data) — Inpatient Claims Sample 1 (2008–2010) and 2008 Beneficiary Summary File, 66,773 claims total.

**Tools used:** PostgreSQL, DBeaver, SQL

## What This Project Covers

1. **QA Audit** — 7 data quality rules checking referential integrity, date logic, payment sanity, and record completeness, plus a root-cause investigation connecting multiple flagged issues to a single underlying cause.
2. **Data Cleaning** — Converts raw text fields to proper types, standardizes formatting, and separates problem records into a documented exclusion table — without ever modifying or deleting the original raw data.
3. **Data Analysis** — 8 analyses covering cost trends, high-cost diagnosis groups, chronic conditions, provider billing patterns, and readmission behavior.

## Key Findings

- **Referential integrity is strong:** 0% orphaned claims, 0% invalid date ranges.
- **Root cause identified:** 68 claims (0.1%) flagged by three separate QA rules were traced to a single shared issue — a small cluster of incomplete claim records missing multiple fields at once, rather than three unrelated problems.
- **False positive caught and corrected:** An initial "duplicate claim ID" flag (68 claims) was investigated and found to be a legitimate CMS billing convention (multi-segment claims for long hospital stays), not a data error — the QA rule was refined accordingly.
- **Cost is concentrated, not evenly spread:** A small set of high-cost diagnosis groups (DRG codes) average 5x the overall claim cost, and beneficiaries with 2+ claims (40% of all beneficiaries) account for nearly 3x the average spend of single-claim beneficiaries.
- **Chronic condition status has minimal cost impact** on individual inpatient claims — cost is driven far more by the specific procedure/DRG than by a patient's general health status.

Full findings, with methodology and numbers, are in [`/docs`](./docs).

## Repository Structure

```
├── README.md
├── SOP.md                                    # Step-by-step guide to reproduce this project
├── sql/                                       # All SQL scripts
│   ├── inpatient_claims.sql                   # Create raw inpatient claims table
│   ├── beneficiary_summary_2008.sql           # Create raw beneficiary summary table
│   ├── Rule_1.sql ... Rule_7.sql              # QA audit rules 1–7
│   ├── inpatient_claims_clean.sql             # Initial cleaning pass (type conversion, flagging)
│   ├── inpatient_claims_final.sql             # Final cleaned + excluded tables
│   ├── beneficiary_summary_2008_clean.sql     # Cleaned beneficiary table
│   └── Analysis_1.sql ... Analysis_8.sql      # Data analyses 1–8
├── docs/                                      # Findings write-ups
│   ├── QA_findings_summary.md
│   ├── data_cleaning_process.md
│   └── data_analysis_findings.md
└── results/                                   # Raw query output (CSV) for key findings
    ├── rule1_orphaned_claims_summary.csv
    ├── rule2_date_logic_summary.csv
    ├── rule3_payment_distribution_stats.csv
    ├── rule4_beneficiary_lifetime_summary.csv
    ├── rule5_duplicate_claim_ids.csv
    ├── rule6_missing_diagnosis_summary.csv
    ├── rule7_root_cause_incomplete_cluster.csv
    ├── analysis1_claims_by_year.csv
    ├── analysis2_top_drg_codes.csv
    ├── analysis3_chronic_conditions_vs_cost.csv
    ├── analysis4_length_of_stay_vs_cost.csv
    ├── analysis5_top_providers.csv
    ├── analysis6_readmission_cost_comparison.csv
    ├── analysis7_geographic_breakdown.csv
    └── analysis8_demographic_sex.csv
```

## How to Reproduce This Project

See [`SOP.md`](./SOP.md) for full step-by-step setup and execution instructions, including a quick checklist and a detailed walkthrough for first-time setup.

## About This Project

This project was built to practice and demonstrate the kind of SQL-based data QA, documentation, and analysis work involved in healthcare revenue cycle management — including not just running queries, but investigating anomalies, distinguishing real issues from false positives, and documenting findings clearly for both technical and non-technical audiences.
