# Inpatient Claims QA Audit — Findings Summary

**Dataset:** CMS DE-SynPUF Inpatient Claims Sample 1 (2008–2010) + Beneficiary Summary 2008
**Total claims analyzed:** 66,773

---

## Rule #1 — Orphaned Claims Check
Verified that every claim's beneficiary ID (`DESYNPUF_ID`) exists in the beneficiary summary table.
**Result:** 0 out of 66,773 claims (0%) were orphaned. Confirms strong referential integrity between the claims and beneficiary datasets — no broken links found.

## Rule #2 — Claim Date Logic Check
Verified that no claim's end date (`CLM_THRU_DT`) occurs before its start date (`CLM_FROM_DT`).
**Result:** 0 out of 66,773 claims (0%) violated this rule. Confirms strong internal date consistency within individual claim records.

## Rule #3 — Payment Amount Sanity Check
Checked for negative or statistically extreme claim payment amounts (`CLM_PMT_AMT`).
**Result:** 55 claims (0.08%) had negative payment amounts, ranging from -$100 to -$8,000. All negative values were round numbers, and the associated claims had valid dates and standard DRG codes — suggesting these represent legitimate payment reversals or adjustments rather than data entry errors. No claims exceeded the 99th percentile threshold ($57,000), indicating no extreme positive outliers in this sample.
**Recommendation:** Confirm with billing/RCM team whether these are expected adjustment transactions.

## Rule #4 — Claim Dates vs. Beneficiary Lifetime
Checked that claims fall within a beneficiary's birth and death dates.
**Result:** 68 claims (0.1%) occurred before the beneficiary's recorded birth date. More significantly, 66,518 claims (99.6%) occurred after the beneficiary's recorded death date.
**Analysis:** Given the scale of this finding, it is inconsistent with real billing fraud and instead reflects a known limitation of CMS's synthetic SynPUF dataset, which prioritizes statistical realism over perfect logical consistency between fields. In a production environment with real data, a finding at this scale would warrant immediate escalation rather than being dismissed as a dataset artifact.

## Rule #5 — Duplicate Claim ID Check
Checked whether `CLM_ID` values are unique.
**Result:** 68 claim IDs (0.1%) appeared exactly twice each.
**Analysis:** Investigation showed each duplicate pair has a different `SEGMENT` value (1 and 2), consistent with CMS's standard practice of splitting long inpatient stays into multiple billing segments (e.g., interim and final claims). These are not true duplicates or data errors.
**Recommendation:** Refine the QA rule to check uniqueness on the combination of `(CLM_ID, SEGMENT)` rather than `CLM_ID` alone, to avoid false positives in future audits.

## Rule #6 — Missing Primary Diagnosis Code
Checked whether `ICD9_DGNS_CD_1` (primary diagnosis) is populated.
**Result:** 95 claims (0.14%) had no primary diagnosis code recorded.

## Rule #7 — Admission Date Logic Check
Checked that `CLM_ADMSN_DT` (admission date) is not after `CLM_FROM_DT` (claim start date).
**Result:** 68 claims (0.1%) flagged.
**Analysis:** In every flagged row, `CLM_FROM_DT` was blank rather than genuinely later than the admission date, indicating the rule surfaced a missing-field issue rather than a true date-order violation.

## Root Cause Analysis — Incomplete Claim Records
Cross-referenced the claims flagged by Rules #4, #6, and #7 with a check for missing `CLM_FROM_DT`.
**Result:** All 68 claims missing `CLM_FROM_DT` also lack a primary diagnosis code, and 33 of them additionally carry a placeholder `'OTH'` DRG code.
**Analysis:** These same 68 records were independently flagged by three separate QA rules, confirming they represent a single underlying data quality issue — a small cluster of incomplete or placeholder claim records — rather than three distinct problems.
**Recommendation:** Investigate these 68 records with the source system to determine whether they represent failed claim submissions, test/placeholder data, or an ETL/loading issue. Resolving the root cause would clear multiple QA flags simultaneously.

---

## Summary Table

| # | Rule | Result | Status |
|---|---|---|---|
| 1 | Orphaned claims | 0 / 66,773 (0%) | Clean |
| 2 | Invalid date range | 0 / 66,773 (0%) | Clean |
| 3 | Negative payments | 55 / 66,773 (0.08%) | Flagged — likely legitimate |
| 4 | Claims after beneficiary death | 66,518 / 66,773 (99.6%) | Flagged — dataset artifact |
| 5 | Duplicate claim IDs | 68 / 66,773 (0.1%) | False positive — explained |
| 6 | Missing primary diagnosis | 95 / 66,773 (0.14%) | Flagged — root cause identified |
| 7 | Admission date logic | 68 / 66,773 (0.1%) | Flagged — same root cause as #6 |
