-- ============================================================
-- DATA ANALYSIS #5 -- Provider-Level Billing Patterns
-- ============================================================
-- Purpose: Identify providers (PRVDR_NUM) with unusually high claim volume
-- or total billing. In real RCM work, providers with billing patterns far
-- outside the norm are a routine focus area -- not necessarily fraud, but
-- worth a closer look to confirm legitimacy.

-- Step 1: Top 15 providers by total claims billed
SELECT
    prvdr_num,
    COUNT(*) AS claim_count,
    ROUND(SUM(clm_pmt_amt), 2) AS total_paid,
    ROUND(AVG(clm_pmt_amt), 2) AS avg_paid_per_claim
FROM inpatient_claims_final
WHERE prvdr_num IS NOT NULL
GROUP BY prvdr_num
ORDER BY total_paid DESC
LIMIT 15;

-- Step 2: Providers with unusually high claim volume (statistical outliers)
-- Uses the average + 3 standard deviations as a rough outlier threshold --
-- a common, simple approach for flagging "far outside the norm" providers.
WITH provider_stats AS (
    SELECT
        prvdr_num,
        COUNT(*) AS claim_count,
        ROUND(SUM(clm_pmt_amt), 2) AS total_paid
    FROM inpatient_claims_final
    WHERE prvdr_num IS NOT NULL
    GROUP BY prvdr_num
),
threshold AS (
    SELECT
        AVG(claim_count) + 3 * STDDEV(claim_count) AS volume_threshold
    FROM provider_stats
)
SELECT ps.*
FROM provider_stats ps, threshold t
WHERE ps.claim_count > t.volume_threshold
ORDER BY ps.claim_count DESC;

-- Step 3: Overall provider volume distribution, for context
SELECT
    ROUND(AVG(claim_count), 2) AS avg_claims_per_provider,
    ROUND(STDDEV(claim_count), 2) AS stddev_claims_per_provider,
    MAX(claim_count) AS max_claims_by_single_provider,
    COUNT(*) AS total_distinct_providers
FROM (
    SELECT prvdr_num, COUNT(*) AS claim_count
    FROM inpatient_claims_final
    WHERE prvdr_num IS NOT NULL
    GROUP BY prvdr_num
) sub;