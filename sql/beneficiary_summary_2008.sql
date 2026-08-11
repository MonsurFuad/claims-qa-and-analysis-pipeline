-- Run this in DBeaver while connected to the claims_qa_project database
-- Right-click claims_qa_project -> SQL Editor -> New SQL Script -> paste this in -> run (Ctrl+Enter, or the play button)

DROP TABLE IF EXISTS beneficiary_summary_2008;

CREATE TABLE beneficiary_summary_2008 (
    desynpuf_id                  VARCHAR(50),
    bene_birth_dt                VARCHAR(10),   -- format YYYYMMDD, convert to DATE later
    bene_death_dt                VARCHAR(10),   -- blank if beneficiary is alive
    bene_sex_ident_cd            VARCHAR(5),
    bene_race_cd                 VARCHAR(5),
    bene_esrd_ind                VARCHAR(5),
    sp_state_code                VARCHAR(5),
    bene_county_cd                VARCHAR(10),
    bene_hi_cvrage_tot_mons      INTEGER,
    bene_smi_cvrage_tot_mons     INTEGER,
    bene_hmo_cvrage_tot_mons     INTEGER,
    plan_cvrg_mos_num            INTEGER,
    sp_alzhdmta                  VARCHAR(5),
    sp_chf                       VARCHAR(5),
    sp_chrnkidn                  VARCHAR(5),
    sp_cncr                      VARCHAR(5),
    sp_copd                      VARCHAR(5),
    sp_depressn                  VARCHAR(5),
    sp_diabetes                  VARCHAR(5),
    sp_ischmcht                  VARCHAR(5),
    sp_osteoprs                  VARCHAR(5),
    sp_ra_oa                     VARCHAR(5),
    sp_strketia                  VARCHAR(5),
    medreimb_ip                  NUMERIC(12,2),
    benres_ip                    NUMERIC(12,2),
    pppymt_ip                    NUMERIC(12,2),
    medreimb_op                  NUMERIC(12,2),
    benres_op                    NUMERIC(12,2),
    pppymt_op                    NUMERIC(12,2),
    medreimb_car                 NUMERIC(12,2),
    benres_car                   NUMERIC(12,2),
    pppymt_car                   NUMERIC(12,2)
);

-- Notes:
-- BENE_BIRTH_DT and BENE_DEATH_DT are loaded as VARCHAR (format YYYYMMDD) to
-- guarantee a smooth import. We'll convert them to proper DATE columns afterward.
-- The SP_* columns are chronic condition flags: '1' = has condition, '2' = does not.
-- BENE_ESRD_IND: '0' = no, 'Y' = yes (End-Stage Renal Disease indicator).