# Data Cleaning Process — Inpatient Claims QA Project

**Purpose:** After completing the QA audit (see `14_QA_findings_summary.md`), this document
describes how the raw, audited data was transformed into a clean, analysis-ready dataset.
Cleaning was performed *after* QA, not instead of it, so that every finding in the audit
remains traceable back to the original raw data.

---

## Guiding Principle

The original raw tables (`inpatient_claims`, `beneficiary_summary_2008`) were never modified
or deleted from. All cleaning was done by creating **new tables**, so the raw data always
remains available as evidence for the QA findings. Nothing was silently changed or removed —
every transformation is documented below, and every excluded record is preserved with a
reason rather than deleted.

---

## Step 1 — Convert Text Dates to Real Date Types

**Problem:** During the initial CSV import, several date columns (`CLM_FROM_DT`,
`CLM_THRU_DT`, `CLM_ADMSN_DT`, `NCH_BENE_DSCHRG_DT`, `BENE_BIRTH_DT`, `BENE_DEATH_DT`) were
loaded as plain text (e.g. `'20100312'`) rather than proper date values. This was a
deliberate choice during import to avoid failed loads, with the intent to convert them
properly afterward.

**Fix:** Used `TO_DATE(column, 'YYYYMMDD')` to convert each of these columns to PostgreSQL's
native `DATE` type. Used `NULLIF(TRIM(column), '')` first so that blank strings convert
cleanly to `NULL` instead of causing a conversion error.

**Result:** All date columns are now proper `DATE` type, enabling correct date arithmetic,
sorting, and comparisons in analysis.

---

## Step 2 — Standardize Text Formatting

**Problem:** Text/code columns (beneficiary IDs, provider numbers, diagnosis codes,
procedure codes, DRG codes, condition flags) could contain inconsistent casing or stray
whitespace from the original CSV, which would cause incorrect groupings or failed joins
even when values are logically the same (e.g. `' abc123 '` vs `'ABC123'`).

**Fix:** Applied `UPPER(TRIM(column))` to every text/code column across both tables.

**Result:** All code and ID values are now consistently uppercase with no leading/trailing
whitespace, ensuring reliable joins, groupings, and comparisons in later analysis.

---

## Step 3 — Fix a Data Type Inconsistency

**Problem:** During the original import, `ICD9_PRCDR_CD_1` was loaded as a numeric type,
while its sibling columns (`ICD9_PRCDR_CD_2` through `_6`) were correctly loaded as text.
Since these columns represent the same kind of value (procedure codes, which can contain
non-numeric values), this inconsistency would cause problems in any query comparing or
combining these columns.

**Fix:** Cast `ICD9_PRCDR_CD_1` to `VARCHAR` to match its sibling columns.

**Result:** All six procedure code columns now share a consistent data type.

---

## Step 4 — Separate Incomplete Records (Documented Exclusion, Not Deletion)

**Problem:** The QA audit (Rules #4, #6, #7 — see findings summary) identified 68 claims
sharing a cluster of missing fields: no `CLM_FROM_DT`, no primary diagnosis code, and in
about half of cases, a placeholder `'OTH'` DRG code. Root cause analysis confirmed these are
the same 68 records being flagged by multiple rules, not independent issues.

**Fix:** Rather than deleting these rows or silently leaving them mixed into the clean data,
they were moved into a separate table, `inpatient_claims_excluded`, with an explicit
`exclusion_reason` column documenting why each record was set aside.

**Result:**
- `inpatient_claims_final` — 66,705 rows, the clean, analysis-ready dataset
- `inpatient_claims_excluded` — 68 rows, preserved with a documented reason
- 66,705 + 68 = 66,773, matching the original raw row count exactly — confirming no data was
  lost during cleaning, only reorganized.

---

## Resulting Table Structure

| Table | Rows | Purpose |
|---|---|---|
| `inpatient_claims` | 66,773 | Raw source data (untouched) — evidence for QA audit |
| `beneficiary_summary_2008` | 116,352 | Raw source data (untouched) |
| `inpatient_claims_final` | 66,705 | Clean, standardized, analysis-ready claims data |
| `inpatient_claims_excluded` | 68 | Documented exclusions, preserved for transparency |
| `beneficiary_summary_2008_clean` | 116,352 | Clean, standardized beneficiary data |

---

## Why This Approach

A QA/RCM analyst's job is not just to fix data silently — it's to make every decision about
the data auditable. This process was designed so that at any point, someone could ask "why
was this record excluded?" or "what did the raw data originally look like?" and get a clear,
documented answer. This mirrors how a real production data pipeline should be built: raw →
audited → cleaned → excluded, with full traceability at every step.
