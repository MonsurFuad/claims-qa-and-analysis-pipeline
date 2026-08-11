-- ============================================================
-- DATA ANALYSIS #4 -- Length of Stay vs. Payment Amount
-- ============================================================
-- Purpose: Does a longer hospital stay correlate with higher payment
-- amounts, as you'd expect? This is a good "sanity check" style insight --
-- confirming the data behaves the way real healthcare billing should.

-- Step 1: Calculate length of stay (in days) and bucket claims into groups
SELECT
    CASE
        WHEN (clm_thru_dt - clm_from_dt) <= 2 THEN '0-2 days'
        WHEN (clm_thru_dt - clm_from_dt) <= 5 THEN '3-5 days'
        WHEN (clm_thru_dt - clm_from_dt) <= 10 THEN '6-10 days'
        WHEN (clm_thru_dt - clm_from_dt) <= 20 THEN '11-20 days'
        ELSE '20+ days'
    END AS stay_length_bucket,
    COUNT(*) AS claim_count,
    ROUND(AVG(clm_pmt_amt), 2) AS avg_paid
FROM inpatient_claims_final
WHERE clm_from_dt IS NOT NULL AND clm_thru_dt IS NOT NULL
GROUP BY stay_length_bucket
ORDER BY MIN(clm_thru_dt - clm_from_dt);