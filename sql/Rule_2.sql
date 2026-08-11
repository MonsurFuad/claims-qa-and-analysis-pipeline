-- QA RULE #2: Claim Date Logic Check
-- Purpose: A claim's end date (CLM_THRU_DT) should never be earlier than its
-- start date (CLM_FROM_DT). A claim that "ends" before it "starts" is a
-- logical impossibility and signals a data entry error or system bug.
-- Dates are stored as VARCHAR in the format YYYYMMDD (e.g. '20100312'), so we
-- cast them to real DATE values here using TO_DATE().

-- Step 1: Count how many claims have this problem
SELECT COUNT(*) AS invalid_date_range_count
FROM inpatient_claims
WHERE TO_DATE(clm_thru_dt, 'YYYYMMDD') < TO_DATE(clm_from_dt, 'YYYYMMDD');

-- Step 2: See the actual problem rows
SELECT desynpuf_id, clm_id, clm_from_dt, clm_thru_dt
FROM inpatient_claims
WHERE TO_DATE(clm_thru_dt, 'YYYYMMDD') < TO_DATE(clm_from_dt, 'YYYYMMDD')
LIMIT 50;

-- Step 3: Percentage of total claims affected
SELECT
    (SELECT COUNT(*) FROM inpatient_claims) AS total_claims,
    (SELECT COUNT(*) FROM inpatient_claims
     WHERE TO_DATE(clm_thru_dt, 'YYYYMMDD') < TO_DATE(clm_from_dt, 'YYYYMMDD')) AS invalid_date_claims,
    ROUND(
        100.0 * (SELECT COUNT(*) FROM inpatient_claims
                  WHERE TO_DATE(clm_thru_dt, 'YYYYMMDD') < TO_DATE(clm_from_dt, 'YYYYMMDD'))
        / (SELECT COUNT(*) FROM inpatient_claims), 2
    ) AS invalid_pct;