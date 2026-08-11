-- QA RULE #3: Claim Payment Amount Sanity Check
-- Purpose: CLM_PMT_AMT (the amount Medicare paid for the claim) should never
-- be negative under normal circumstances, and extremely large values may
-- indicate data entry errors or genuine outliers worth flagging for review.
-- This rule has two parts: (a) negative values, which are almost always
-- invalid, and (b) statistical outliers, which aren't necessarily wrong but
-- are worth a closer look -- exactly the kind of judgment call a QA analyst
-- makes day to day.

-- Step 1: Any negative payment amounts?
SELECT COUNT(*) AS negative_payment_count
FROM inpatient_claims
WHERE clm_pmt_amt < 0;

-- Step 2: Basic distribution stats to understand what's "normal" here
SELECT
    MIN(clm_pmt_amt) AS min_amt,
    MAX(clm_pmt_amt) AS max_amt,
    ROUND(AVG(clm_pmt_amt), 2) AS avg_amt,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY clm_pmt_amt) AS median_amt,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY clm_pmt_amt) AS p99_amt
FROM inpatient_claims;

-- Step 3: Flag claims above the 99th percentile as outliers worth reviewing
-- (Not necessarily errors -- but worth listing in your report as "flagged for review")
WITH threshold AS (
    SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY clm_pmt_amt) AS p99
    FROM inpatient_claims
)
SELECT ic.desynpuf_id, ic.clm_id, ic.clm_pmt_amt
FROM inpatient_claims ic, threshold
WHERE ic.clm_pmt_amt > threshold.p99
ORDER BY ic.clm_pmt_amt DESC
LIMIT 50;

-- Step 4: Count and percentage of outlier claims
WITH threshold AS (
    SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY clm_pmt_amt) AS p99
    FROM inpatient_claims
)
SELECT
    (SELECT COUNT(*) FROM inpatient_claims) AS total_claims,
    COUNT(*) AS outlier_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM inpatient_claims), 2) AS outlier_pct
FROM inpatient_claims ic, threshold
WHERE ic.clm_pmt_amt > threshold.p99;

-- Follow-up to QA Rule #3: inspect the actual negative-payment claims
-- so we can describe what they look like in the final report.

SELECT desynpuf_id, clm_id, clm_from_dt, clm_thru_dt, clm_pmt_amt, clm_drg_cd
FROM inpatient_claims
WHERE clm_pmt_amt < 0
ORDER BY clm_pmt_amt ASC
LIMIT 20;