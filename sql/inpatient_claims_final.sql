-- ============================================================
-- COMPREHENSIVE DATA CLEANING PASS #2 -- Inpatient Claims
-- ============================================================
-- Builds on inpatient_claims_clean (created in script 15b) by:
--  1. Fixing a type inconsistency (icd9_prcdr_cd_1 was numeric-typed
--     while its sibling columns were text -- now all consistent)
--  2. Trimming whitespace and standardizing casing (uppercase) on every
--     code/ID column, since inconsistent casing would break future joins
--     or GROUP BY comparisons even if it looks "clean" visually
--  3. Fully separating the 68 incomplete records into their own table
--     (inpatient_claims_excluded) with a documented reason, rather than
--     just flagging them -- so the main clean table has zero known issues
-- ============================================================

DROP TABLE IF EXISTS inpatient_claims_excluded;
DROP TABLE IF EXISTS inpatient_claims_final;

-- Step 1: Split out the incomplete records into their own excluded table,
-- with a reason column documenting WHY they were excluded (this is what
-- makes an exclusion defensible/auditable rather than silent data loss).
CREATE TABLE inpatient_claims_excluded AS
SELECT *,
    'Missing CLM_FROM_DT and primary diagnosis code; root cause investigation pending' AS exclusion_reason
FROM inpatient_claims_clean
WHERE is_incomplete_record = TRUE;

-- Step 2: Build the final clean table from the remaining good records,
-- with full column-level standardization applied.
CREATE TABLE inpatient_claims_final AS
SELECT
    UPPER(TRIM(desynpuf_id))            AS desynpuf_id,
    clm_id,
    segment,
    clm_from_dt,
    clm_thru_dt,
    UPPER(TRIM(prvdr_num))              AS prvdr_num,
    clm_pmt_amt,
    nch_prmry_pyr_clm_pd_amt,
    at_physn_npi,
    op_physn_npi,
    ot_physn_npi,
    clm_admsn_dt,
    UPPER(TRIM(admtng_icd9_dgns_cd))    AS admtng_icd9_dgns_cd,
    clm_pass_thru_per_diem_amt,
    nch_bene_ip_ddctbl_amt,
    nch_bene_pta_coinsrnc_lblty_am,
    nch_bene_blood_ddctbl_lblty_am,
    clm_utlztn_day_cnt,
    nch_bene_dschrg_dt,
    UPPER(TRIM(clm_drg_cd))             AS clm_drg_cd,
    UPPER(TRIM(icd9_dgns_cd_1))         AS icd9_dgns_cd_1,
    UPPER(TRIM(icd9_dgns_cd_2))         AS icd9_dgns_cd_2,
    UPPER(TRIM(icd9_dgns_cd_3))         AS icd9_dgns_cd_3,
    UPPER(TRIM(icd9_dgns_cd_4))         AS icd9_dgns_cd_4,
    UPPER(TRIM(icd9_dgns_cd_5))         AS icd9_dgns_cd_5,
    UPPER(TRIM(icd9_dgns_cd_6))         AS icd9_dgns_cd_6,
    UPPER(TRIM(icd9_dgns_cd_7))         AS icd9_dgns_cd_7,
    UPPER(TRIM(icd9_dgns_cd_8))         AS icd9_dgns_cd_8,
    UPPER(TRIM(icd9_dgns_cd_9))         AS icd9_dgns_cd_9,
    UPPER(TRIM(icd9_dgns_cd_10))        AS icd9_dgns_cd_10,
    -- icd9_prcdr_cd_1 fix: cast to text explicitly so it matches its
    -- siblings (_2 through _6), which were already text. ::VARCHAR handles
    -- the case where the source column ended up numeric-typed.
    UPPER(TRIM(icd9_prcdr_cd_1::VARCHAR)) AS icd9_prcdr_cd_1,
    UPPER(TRIM(icd9_prcdr_cd_2))        AS icd9_prcdr_cd_2,
    UPPER(TRIM(icd9_prcdr_cd_3))        AS icd9_prcdr_cd_3,
    UPPER(TRIM(icd9_prcdr_cd_4))        AS icd9_prcdr_cd_4,
    UPPER(TRIM(icd9_prcdr_cd_5))        AS icd9_prcdr_cd_5,
    UPPER(TRIM(icd9_prcdr_cd_6))        AS icd9_prcdr_cd_6
FROM inpatient_claims_clean
WHERE is_incomplete_record = FALSE;

-- Step 3: Verify nothing was lost -- excluded + final should sum back to
-- the original total of 66,773
SELECT
    (SELECT COUNT(*) FROM inpatient_claims_final)    AS final_clean_rows,
    (SELECT COUNT(*) FROM inpatient_claims_excluded) AS excluded_rows,
    (SELECT COUNT(*) FROM inpatient_claims_final) + (SELECT COUNT(*) FROM inpatient_claims_excluded) AS total_check,
    (SELECT COUNT(*) FROM inpatient_claims) AS original_total;