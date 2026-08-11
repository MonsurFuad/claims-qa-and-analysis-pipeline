-- QA RULE #7: Admission Date Logic Check
-- Purpose: CLM_ADMSN_DT (hospital admission date) should logically be on or
-- before CLM_FROM_DT (the claim's start date) for inpatient claims -- a
-- patient can't be admitted to the hospital after their claim period has
-- already begun. A violation here suggests a data entry or system error in
-- how admission vs. billing dates were recorded.

-- Step 1: Count claims where admission date is AFTER the claim's from date
SELECT COUNT(*) AS invalid_admission_date_count
FROM inpatient_claims
WHERE clm_admsn_dt IS NOT NULL
  AND TRIM(clm_admsn_dt) <> ''
  AND TO_DATE(clm_admsn_dt, 'YYYYMMDD') > TO_DATE(clm_from_dt, 'YYYYMMDD');

-- Step 2: See the actual problem rows
SELECT desynpuf_id, clm_id, clm_admsn_dt, clm_from_dt, clm_thru_dt
FROM inpatient_claims
WHERE clm_admsn_dt IS NOT NULL
  AND TRIM(clm_admsn_dt) <> ''
  AND TO_DATE(clm_admsn_dt, 'YYYYMMDD') > TO_DATE(clm_from_dt, 'YYYYMMDD')
LIMIT 50;

-- Step 3: Percentage of total claims affected
SELECT
    (SELECT COUNT(*) FROM inpatient_claims) AS total_claims,
    (SELECT COUNT(*) FROM inpatient_claims
     WHERE clm_admsn_dt IS NOT NULL AND TRIM(clm_admsn_dt) <> ''
       AND TO_DATE(clm_admsn_dt, 'YYYYMMDD') > TO_DATE(clm_from_dt, 'YYYYMMDD')) AS invalid_admission_claims,
    ROUND(
        100.0 * (SELECT COUNT(*) FROM inpatient_claims
                  WHERE clm_admsn_dt IS NOT NULL AND TRIM(clm_admsn_dt) <> ''
                    AND TO_DATE(clm_admsn_dt, 'YYYYMMDD') > TO_DATE(clm_from_dt, 'YYYYMMDD'))
        / (SELECT COUNT(*) FROM inpatient_claims), 2
    ) AS invalid_pct;
-- Follow-up investigation: are Rule #4 (before birth), Rule #6 (missing
-- primary diagnosis), and Rule #7 (admission date logic) flagging the SAME
-- underlying cluster of incomplete records, rather than separate issues?
-- This matters a lot for your report -- "68 unrelated errors" is a very
-- different finding than "68 claims share a single root cause: a missing
-- CLM_FROM_DT field."

-- Step 1: How many claims have a blank/missing clm_from_dt?
SELECT COUNT(*) AS missing_from_dt_count
FROM inpatient_claims
WHERE clm_from_dt IS NULL OR TRIM(clm_from_dt) = '';

-- Step 2: Do the claims missing clm_from_dt overlap with the Rule #6 (missing
-- primary diagnosis) and Rule #7 (admission date) flagged claims?
SELECT
    COUNT(*) AS missing_from_dt_total,
    COUNT(*) FILTER (WHERE icd9_dgns_cd_1 IS NULL OR TRIM(icd9_dgns_cd_1) = '') AS also_missing_primary_dgns,
    COUNT(*) FILTER (WHERE clm_drg_cd = 'OTH') AS also_drg_oth
FROM inpatient_claims
WHERE clm_from_dt IS NULL OR TRIM(clm_from_dt) = '';