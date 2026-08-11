-- QA RULE #6: Missing Primary Diagnosis Code
-- Purpose: ICD9_DGNS_CD_1 is the primary diagnosis code for a claim -- the
-- main medical reason for the encounter. A claim without a primary diagnosis
-- is a significant data quality issue, since diagnosis codes drive medical
-- necessity determinations, reimbursement calculations, and reporting.
-- Missing primary diagnoses are a common real-world RCM red flag, distinct
-- from missing secondary/tertiary codes (ICD9_DGNS_CD_2 onward), which are
-- much more commonly and legitimately blank.

-- Step 1: Count claims missing a primary diagnosis code
SELECT COUNT(*) AS missing_primary_dgns_count
FROM inpatient_claims
WHERE icd9_dgns_cd_1 IS NULL OR TRIM(icd9_dgns_cd_1) = '';

-- Step 2: See the actual rows missing a primary diagnosis
SELECT desynpuf_id, clm_id, clm_from_dt, clm_drg_cd, admtng_icd9_dgns_cd
FROM inpatient_claims
WHERE icd9_dgns_cd_1 IS NULL OR TRIM(icd9_dgns_cd_1) = ''
LIMIT 50;

-- Step 3: Percentage of total claims affected
SELECT
    (SELECT COUNT(*) FROM inpatient_claims) AS total_claims,
    (SELECT COUNT(*) FROM inpatient_claims
     WHERE icd9_dgns_cd_1 IS NULL OR TRIM(icd9_dgns_cd_1) = '') AS missing_primary_dgns,
    ROUND(
        100.0 * (SELECT COUNT(*) FROM inpatient_claims
                  WHERE icd9_dgns_cd_1 IS NULL OR TRIM(icd9_dgns_cd_1) = '')
        / (SELECT COUNT(*) FROM inpatient_claims), 2
    ) AS missing_pct;