-- ============================================================
-- DATA ANALYSIS #8 -- Demographic Breakdown by Sex
-- ============================================================
-- Purpose: Compare claim volume and average cost between beneficiary sex
-- groups. A quick demographic cut to round out the analysis.
-- Note: BENE_SEX_IDENT_CD -- '1' = Male, '2' = Female per CMS documentation.

SELECT
    b.bene_sex_ident_cd,
    CASE WHEN b.bene_sex_ident_cd = '1' THEN 'Male'
         WHEN b.bene_sex_ident_cd = '2' THEN 'Female'
         ELSE 'Unknown' END AS sex_label,
    COUNT(*) AS claim_count,
    ROUND(AVG(c.clm_pmt_amt), 2) AS avg_paid
FROM inpatient_claims_final c
JOIN beneficiary_summary_2008_clean b ON c.desynpuf_id = b.desynpuf_id
GROUP BY b.bene_sex_ident_cd
ORDER BY b.bene_sex_ident_cd;