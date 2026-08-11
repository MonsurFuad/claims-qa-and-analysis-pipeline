-- Data Cleaning: build inpatient_claims_clean from inpatient_claims
-- This step happens AFTER the QA audit (see files 03-13), not instead of it.
-- The original inpatient_claims table is left untouched as the raw source of
-- record / evidence for the QA findings. This cleaned table is a separate,
-- ready-to-analyze version with proper data types and documented exclusions.

DROP TABLE IF EXISTS inpatient_claims_clean;

CREATE TABLE inpatient_claims_clean AS
SELECT
    desynpuf_id,
    clm_id,
    segment,
    -- Convert date columns from text (YYYYMMDD) to real DATE type.
    -- NULLIF handles blank strings so TO_DATE doesn't error on empty values.
    TO_DATE(NULLIF(TRIM(clm_from_dt), ''), 'YYYYMMDD')  AS clm_from_dt,
    TO_DATE(NULLIF(TRIM(clm_thru_dt), ''), 'YYYYMMDD')  AS clm_thru_dt,
    prvdr_num,
    clm_pmt_amt,
    nch_prmry_pyr_clm_pd_amt,
    at_physn_npi,
    op_physn_npi,
    ot_physn_npi,
    TO_DATE(NULLIF(TRIM(clm_admsn_dt), ''), 'YYYYMMDD') AS clm_admsn_dt,
    NULLIF(TRIM(admtng_icd9_dgns_cd), '')                AS admtng_icd9_dgns_cd,
    clm_pass_thru_per_diem_amt,
    nch_bene_ip_ddctbl_amt,
    nch_bene_pta_coinsrnc_lblty_am,
    nch_bene_blood_ddctbl_lblty_am,
    clm_utlztn_day_cnt,
    TO_DATE(NULLIF(TRIM(nch_bene_dschrg_dt), ''), 'YYYYMMDD') AS nch_bene_dschrg_dt,
    NULLIF(TRIM(clm_drg_cd), '')                          AS clm_drg_cd,
    NULLIF(TRIM(icd9_dgns_cd_1), '')  AS icd9_dgns_cd_1,
    NULLIF(TRIM(icd9_dgns_cd_2), '')  AS icd9_dgns_cd_2,
    NULLIF(TRIM(icd9_dgns_cd_3), '')  AS icd9_dgns_cd_3,
    NULLIF(TRIM(icd9_dgns_cd_4), '')  AS icd9_dgns_cd_4,
    NULLIF(TRIM(icd9_dgns_cd_5), '')  AS icd9_dgns_cd_5,
    -- (columns 6-10 omitted here for brevity in this excerpt logic, but
    --  included below in the actual SELECT list)
    icd9_dgns_cd_6, icd9_dgns_cd_7, icd9_dgns_cd_8, icd9_dgns_cd_9, icd9_dgns_cd_10,
    icd9_prcdr_cd_1, icd9_prcdr_cd_2, icd9_prcdr_cd_3, icd9_prcdr_cd_4, icd9_prcdr_cd_5, icd9_prcdr_cd_6,

    -- Flag: is this one of the 68 "incomplete cluster" records identified in
    -- the root cause analysis (missing CLM_FROM_DT)? Kept in the clean table
    -- but flagged, rather than silently deleted, so downstream analysis can
    -- choose to include/exclude them with full transparency.
    CASE WHEN clm_from_dt IS NULL OR TRIM(clm_from_dt) = ''
         THEN TRUE ELSE FALSE END AS is_incomplete_record

FROM inpatient_claims;

-- Quick sanity check after running the above: row count should match the
-- original table (66,773) since we are flagging, not deleting, records.
SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE is_incomplete_record) AS flagged_incomplete
FROM inpatient_claims_clean;