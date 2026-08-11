-- ============================================================
-- DATA ANALYSIS #7 -- Geographic Breakdown by State
-- ============================================================
-- Purpose: See how claim volume and average cost vary by beneficiary state
-- (SP_STATE_CODE). Useful as a demographic cut and easy to visualize later
-- (e.g. bar chart or map) if you want to add a chart to your final report.

SELECT
    b.sp_state_code,
    COUNT(*) AS claim_count,
    ROUND(SUM(c.clm_pmt_amt), 2) AS total_paid,
    ROUND(AVG(c.clm_pmt_amt), 2) AS avg_paid
FROM inpatient_claims_final c
JOIN beneficiary_summary_2008_clean b ON c.desynpuf_id = b.desynpuf_id
WHERE b.sp_state_code IS NOT NULL
GROUP BY b.sp_state_code
ORDER BY claim_count DESC
LIMIT 15;