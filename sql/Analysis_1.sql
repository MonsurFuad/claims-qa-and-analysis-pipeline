-- ============================================================
-- DATA ANALYSIS #1 -- Claim Volume Trends Over Time
-- ============================================================
-- Purpose: Beyond QA, understand the shape of the data itself -- how claim
-- volume and spending changed month to month across 2008-2010. This kind
-- of trend view is exactly what a business stakeholder (e.g. Sales,
-- Account Management) would want summarized in plain terms.

-- Step 1: Claims per month
SELECT
    DATE_TRUNC('month', clm_from_dt) AS claim_month,
    COUNT(*) AS claim_count,
    ROUND(SUM(clm_pmt_amt), 2) AS total_paid,
    ROUND(AVG(clm_pmt_amt), 2) AS avg_paid
FROM inpatient_claims_final
WHERE clm_from_dt IS NOT NULL
GROUP BY DATE_TRUNC('month', clm_from_dt)
ORDER BY claim_month;

-- Step 2: Claims per year (simpler, higher-level view)
SELECT
    EXTRACT(YEAR FROM clm_from_dt) AS claim_year,
    COUNT(*) AS claim_count,
    ROUND(SUM(clm_pmt_amt), 2) AS total_paid,
    ROUND(AVG(clm_pmt_amt), 2) AS avg_paid
FROM inpatient_claims_final
WHERE clm_from_dt IS NOT NULL
GROUP BY EXTRACT(YEAR FROM clm_from_dt)
ORDER BY claim_year;