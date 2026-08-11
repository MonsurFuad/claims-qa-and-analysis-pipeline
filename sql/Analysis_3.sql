-- ============================================================
-- DATA ANALYSIS #3 -- Chronic Conditions vs. Claim Cost
-- ============================================================
-- Purpose: Using the beneficiary table's chronic condition flags (diabetes,
-- cancer, heart failure, etc.), see whether beneficiaries with certain
-- conditions tend to have higher-cost inpatient claims. This connects your
-- two tables together in a business-relevant way, not just a QA check.
-- Note: In this dataset, '1' = has condition, '2' = does not.

-- Step 1: Average claim payment for beneficiaries WITH vs WITHOUT diabetes
SELECT
    b.sp_diabetes,
    COUNT(*) AS claim_count,
    ROUND(AVG(c.clm_pmt_amt), 2) AS avg_paid
FROM inpatient_claims_final c
JOIN beneficiary_summary_2008_clean b ON c.desynpuf_id = b.desynpuf_id
GROUP BY b.sp_diabetes;

-- Step 2: Same comparison across all major chronic conditions at once
SELECT
    'Diabetes' AS condition, b.sp_diabetes AS has_condition,
    COUNT(*) AS claim_count, ROUND(AVG(c.clm_pmt_amt), 2) AS avg_paid
FROM inpatient_claims_final c
JOIN beneficiary_summary_2008_clean b ON c.desynpuf_id = b.desynpuf_id
GROUP BY b.sp_diabetes

UNION ALL

SELECT
    'Cancer', b.sp_cncr,
    COUNT(*), ROUND(AVG(c.clm_pmt_amt), 2)
FROM inpatient_claims_final c
JOIN beneficiary_summary_2008_clean b ON c.desynpuf_id = b.desynpuf_id
GROUP BY b.sp_cncr

UNION ALL

SELECT
    'Congestive Heart Failure', b.sp_chf,
    COUNT(*), ROUND(AVG(c.clm_pmt_amt), 2)
FROM inpatient_claims_final c
JOIN beneficiary_summary_2008_clean b ON c.desynpuf_id = b.desynpuf_id
GROUP BY b.sp_chf

ORDER BY condition, has_condition;