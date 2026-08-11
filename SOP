# Standard Operating Procedure — Inpatient Claims QA & Analysis Audit

**Purpose:** This document is a step-by-step guide for reproducing this project from scratch —
from raw CMS SynPUF data to the final QA findings, cleaned dataset, and analysis. It is written
so that another analyst, unfamiliar with this specific project, could follow it and arrive at
the same results.

Two versions are provided: a **Quick Checklist** for someone already familiar with the tools,
and a **Detailed Walkthrough** for someone setting this up for the first time.

---

## Quick Checklist

1. Install PostgreSQL and DBeaver.
2. Download the CMS DE-SynPUF Sample 1 files (Inpatient Claims, 2008 Beneficiary Summary).
3. Create a database called `claims_qa_project`.
4. Run scripts `01` and `02` to create the raw table structures.
5. Import both CSVs into their matching tables using DBeaver's Import Data wizard.
6. Run QA scripts `03` through `13` in order; record each result.
7. Run cleaning scripts `15b`, `16`, and `17` in order to produce the clean, analysis-ready tables.
8. Run analysis scripts `19` through `27` in order; record each result.
9. Compile findings into the summary documents (`14`, `18`, `23`, `28`).

---

## Detailed Walkthrough

### Step 1 — Install Required Tools

- **PostgreSQL** (database engine): download from postgresql.org/download, install with default
  settings, and set (and record) a password for the `postgres` superuser during setup.
- **DBeaver Community** (database GUI client): download from dbeaver.io/download, install with
  default components.

### Step 2 — Obtain the Source Data

Download the CMS DE-SynPUF Sample 1 files (publicly available synthetic Medicare claims data):
- `DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv`
- `DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv`

Save both files to a consistent local folder (e.g. `~/claims-qa-project/data/`).

### Step 3 — Connect DBeaver to PostgreSQL

1. Open DBeaver → Database → New Database Connection → select PostgreSQL.
2. Enter: Host = `localhost`, Port = `5432`, Username = `postgres`, Password = (set in Step 1).
3. Click "Test Connection" to confirm, then Finish.
4. In connection settings, enable "Show all databases" (PostgreSQL tab) if it is not already on —
   this is required to create new databases from within DBeaver.

### Step 4 — Create the Project Database

Right-click the connection → Create New Database → name it `claims_qa_project`.

### Step 5 — Create the Raw Table Structures

Open a new SQL editor connected to `claims_qa_project`. Run the following scripts, in order,
using "Execute SQL Script" (runs the full script, not just one statement):

- `01_create_inpatient_claims_table.sql`
- `02_create_beneficiary_summary_2008_table.sql`

These create empty tables with pre-defined, correct column types — this avoids the column
type-detection errors that occur if you let DBeaver auto-create tables directly from a CSV import
(several columns in this dataset, such as diagnosis and DRG codes, mix letters and numbers and
will fail to import if a type is guessed as purely numeric).

### Step 6 — Import the CSV Data

For each table:
1. Right-click the table itself (e.g. `inpatient_claims`) in the DBeaver sidebar → Import Data.
2. Choose CSV as the source, select the matching CSV file.
3. Confirm the target is the existing table (all columns should map as "existing", not "new").
4. Proceed through the wizard and run the import.

Verify success by running `SELECT COUNT(*) FROM inpatient_claims;` — expected result: 66,773 rows.
Similarly verify the beneficiary table — expected result: 116,352 rows.

### Step 7 — Run the QA Audit

Run each QA script in order, recording the result of each `SELECT COUNT(*)` step:

| Script | Rule |
|---|---|
| `03_qa_rule1_orphaned_claims.sql` | Orphaned claims (no matching beneficiary) |
| `04_qa_rule2_claim_date_logic.sql` | Claim end date before start date |
| `05_qa_rule3_payment_amount_check.sql` | Negative / outlier payment amounts |
| `06_rule3_followup_negative_claims_detail.sql` | Inspect negative-payment claims |
| `07_qa_rule4_claim_vs_beneficiary_lifetime.sql` | Claims outside beneficiary birth/death window |
| `08_qa_rule5_duplicate_claim_ids.sql` | Duplicate claim IDs |
| `09_rule5_followup_duplicate_detail.sql` | Inspect duplicate claim ID pairs |
| `10_rule5_check_segment_column.sql` | Confirm SEGMENT explains duplicates |
| `11_qa_rule6_missing_primary_diagnosis.sql` | Missing primary diagnosis code |
| `12_qa_rule7_admission_date_logic.sql` | Admission date after claim start date |
| `13_investigate_incomplete_claims_cluster.sql` | Root cause: shared incomplete-record cluster |

Compile results into `14_QA_findings_summary.md` (template already provided).

### Step 8 — Clean the Data

Run, in order, using "Execute SQL Script":

- `15b_create_inpatient_claims_clean_fixed.sql` — converts date columns to proper `DATE` type,
  flags the 68 incomplete records identified in Step 7.
- `16_full_cleaning_pass_inpatient.sql` — separates incomplete records into
  `inpatient_claims_excluded` (with a documented reason), builds the final clean table
  `inpatient_claims_final`, standardizes text formatting, and fixes a data type inconsistency
  in `ICD9_PRCDR_CD_1`.
- `17_clean_beneficiary_summary.sql` — applies the same date conversion and text standardization
  to the beneficiary table, producing `beneficiary_summary_2008_clean`.

Verify: `inpatient_claims_final` (66,705 rows) + `inpatient_claims_excluded` (68 rows) should
equal the original raw total of 66,773 rows. Document the process in `18_data_cleaning_process.md`.

### Step 9 — Run the Data Analysis

Run each analysis script in order, using the clean tables (`inpatient_claims_final`,
`beneficiary_summary_2008_clean`):

| Script | Analysis |
|---|---|
| `19_analysis1_claim_volume_trends.sql` | Claim volume and spend by year/month |
| `20_analysis2_cost_by_drg.sql` | Cost by diagnosis-related group |
| `21_analysis3_chronic_conditions_vs_cost.sql` | Chronic conditions vs. claim cost |
| `22_analysis4_length_of_stay_vs_cost.sql` | Length of stay vs. claim cost |
| `24_analysis5_provider_billing_patterns.sql` | Provider-level billing patterns |
| `25_analysis6_readmission_patterns.sql` | Readmission / repeat-utilization patterns |
| `26_analysis7_geographic_breakdown.sql` | Claim volume/cost by state |
| `27_analysis8_demographic_breakdown_sex.sql` | Claim volume/cost by sex |

Compile results into `23_data_analysis_findings.md` and `28_extended_analysis_findings.md`.

### Step 10 — Final Review

Before considering the audit complete, confirm:
- [ ] Every QA rule has a recorded result and interpretation (not just a raw number)
- [ ] Every flagged finding has been investigated for root cause where possible, not just reported
- [ ] All cleaning steps are documented with before/after row counts
- [ ] No raw source table was modified or deleted — only new tables were created
- [ ] All findings are written in plain language a non-technical stakeholder could understand

---

## Notes on Reproducibility

- All scripts use `DROP TABLE IF EXISTS` before creating tables, so the full pipeline can be
  re-run from scratch at any time without manual cleanup.
- Raw tables (`inpatient_claims`, `beneficiary_summary_2008`) are never modified after import —
  every downstream transformation happens in a new table, preserving a full audit trail back to
  the original source data.
- If additional CMS SynPUF files are added later (e.g. Outpatient Claims, additional beneficiary
  years), follow the same pattern: create a typed table first (Step 5 pattern), then import
  (Step 6 pattern), before writing any QA or analysis queries against it.
