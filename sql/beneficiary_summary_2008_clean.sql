-- ============================================================
-- DATA CLEANING -- Beneficiary Summary 2008
-- ============================================================
-- Applies the same treatment as the claims table: convert text dates to
-- real DATE type, trim/standardize text fields, and keep this as a NEW
-- table so the original raw beneficiary_summary_2008 stays untouched.
-- ============================================================

DROP TABLE IF EXISTS beneficiary_summary_2008_clean;

CREATE TABLE beneficiary_summary_2008_clean AS
SELECT
    UPPER(TRIM(desynpuf_id))                              AS desynpuf_id,
    TO_DATE(NULLIF(TRIM(bene_birth_dt), ''), 'YYYYMMDD')  AS bene_birth_dt,
    TO_DATE(NULLIF(TRIM(bene_death_dt), ''), 'YYYYMMDD')  AS bene_death_dt,
    UPPER(TRIM(bene_sex_ident_cd))                        AS bene_sex_ident_cd,
    UPPER(TRIM(bene_race_cd))                             AS bene_race_cd,
    UPPER(TRIM(bene_esrd_ind))                            AS bene_esrd_ind,
    UPPER(TRIM(sp_state_code))                            AS sp_state_code,
    UPPER(TRIM(bene_county_cd))                           AS bene_county_cd,
    bene_hi_cvrage_tot_mons,
    bene_smi_cvrage_tot_mons,
    bene_hmo_cvrage_tot_mons,
    plan_cvrg_mos_num,
    UPPER(TRIM(sp_alzhdmta))   AS sp_alzhdmta,
    UPPER(TRIM(sp_chf))        AS sp_chf,
    UPPER(TRIM(sp_chrnkidn))   AS sp_chrnkidn,
    UPPER(TRIM(sp_cncr))       AS sp_cncr,
    UPPER(TRIM(sp_copd))       AS sp_copd,
    UPPER(TRIM(sp_depressn))   AS sp_depressn,
    UPPER(TRIM(sp_diabetes))   AS sp_diabetes,
    UPPER(TRIM(sp_ischmcht))   AS sp_ischmcht,
    UPPER(TRIM(sp_osteoprs))   AS sp_osteoprs,
    UPPER(TRIM(sp_ra_oa))      AS sp_ra_oa,
    UPPER(TRIM(sp_strketia))   AS sp_strketia,
    medreimb_ip, benres_ip, pppymt_ip,
    medreimb_op, benres_op, pppymt_op,
    medreimb_car, benres_car, pppymt_car
FROM beneficiary_summary_2008;

-- Verify row count matches the original (should be unchanged -- we are
-- only reformatting values here, not removing any beneficiaries)
SELECT
    (SELECT COUNT(*) FROM beneficiary_summary_2008)       AS original_rows,
    (SELECT COUNT(*) FROM beneficiary_summary_2008_clean) AS clean_rows;