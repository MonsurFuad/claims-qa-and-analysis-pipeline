-- ============================================================
-- DATA ANALYSIS #2 -- Cost by Diagnosis Related Group (DRG)
-- ============================================================
-- Purpose: Which diagnosis groups are the most expensive, on average and in
-- total? This is a classic RCM/business question -- understanding where the
-- money goes helps prioritize review, negotiation, or cost-control efforts.

-- Step 1: Top 15 DRG codes by total amount paid
SELECT
    clm_drg_cd,
    COUNT(*) AS claim_count,
    ROUND(SUM(clm_pmt_amt), 2) AS total_paid,
    ROUND(AVG(clm_pmt_amt), 2) AS avg_paid_per_claim
FROM inpatient_claims_final
WHERE clm_drg_cd IS NOT NULL
GROUP BY clm_drg_cd
ORDER BY total_paid DESC
LIMIT 15;

-- Step 2: Top 15 DRG codes by average cost per claim (only DRGs with at
-- least 20 claims, so rare one-off codes don't skew the "most expensive" list)
SELECT
    clm_drg_cd,
    COUNT(*) AS claim_count,
    ROUND(AVG(clm_pmt_amt), 2) AS avg_paid_per_claim
FROM inpatient_claims_final
WHERE clm_drg_cd IS NOT NULL
GROUP BY clm_drg_cd
HAVING COUNT(*) >= 20
ORDER BY avg_paid_per_claim DESC
LIMIT 15;