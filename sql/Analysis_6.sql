-- ============================================================
-- DATA ANALYSIS #6 -- Readmission Pattern Analysis
-- ============================================================
-- Purpose: Identify beneficiaries with multiple inpatient claims within the
-- dataset window, as a rough proxy for hospital readmissions. Readmission
-- rate is a well-known cost driver and quality metric in real healthcare
-- analytics -- frequent readmissions often signal either complex chronic
-- patients or potential gaps in care coordination.

-- Step 1: How many beneficiaries have 2+ inpatient claims?
SELECT
    claim_count_bucket,
    COUNT(*) AS beneficiary_count
FROM (
    SELECT
        desynpuf_id,
        COUNT(*) AS total_claims,
        CASE
            WHEN COUNT(*) = 1 THEN '1 claim'
            WHEN COUNT(*) = 2 THEN '2 claims'
            WHEN COUNT(*) BETWEEN 3 AND 4 THEN '3-4 claims'
            ELSE '5+ claims'
        END AS claim_count_bucket
    FROM inpatient_claims_final
    GROUP BY desynpuf_id
) sub
GROUP BY claim_count_bucket
ORDER BY MIN(sub.total_claims);

-- Step 2: Total spend comparison -- single-claim vs. multi-claim beneficiaries
SELECT
    CASE WHEN claim_count = 1 THEN 'Single claim' ELSE 'Multiple claims (2+)' END AS group_type,
    COUNT(*) AS beneficiary_count,
    ROUND(AVG(total_paid), 2) AS avg_total_paid_per_beneficiary
FROM (
    SELECT
        desynpuf_id,
        COUNT(*) AS claim_count,
        SUM(clm_pmt_amt) AS total_paid
    FROM inpatient_claims_final
    GROUP BY desynpuf_id
) sub
GROUP BY CASE WHEN claim_count = 1 THEN 'Single claim' ELSE 'Multiple claims (2+)' END;

-- Step 3: Beneficiaries with the highest number of inpatient claims (top 15)
-- -- these are the most extreme "frequent flyer" cases in the dataset
SELECT
    desynpuf_id,
    COUNT(*) AS total_claims,
    ROUND(SUM(clm_pmt_amt), 2) AS total_paid
FROM inpatient_claims_final
GROUP BY desynpuf_id
ORDER BY total_claims DESC
LIMIT 15;