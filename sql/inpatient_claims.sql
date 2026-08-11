-- Run this in DBeaver while connected to the claims_qa_project database
-- Right-click claims_qa_project -> SQL Editor -> New SQL Script -> paste this in -> run (Ctrl+Enter, or the play button)

DROP TABLE IF EXISTS inpatient_claims;

CREATE TABLE inpatient_claims (
    desynpuf_id                      VARCHAR(50),
    clm_id                           BIGINT,
    segment                          VARCHAR(10),
    clm_from_dt                      VARCHAR(10),
    clm_thru_dt                      VARCHAR(10),
    prvdr_num                        VARCHAR(20),
    clm_pmt_amt                      NUMERIC(12,2),
    nch_prmry_pyr_clm_pd_amt         NUMERIC(12,2),
    at_physn_npi                     BIGINT,
    op_physn_npi                     BIGINT,
    ot_physn_npi                     BIGINT,
    clm_admsn_dt                     VARCHAR(10),
    admtng_icd9_dgns_cd               VARCHAR(20),
    clm_pass_thru_per_diem_amt       NUMERIC(12,2),
    nch_bene_ip_ddctbl_amt           NUMERIC(12,2),
    nch_bene_pta_coinsrnc_lblty_am   NUMERIC(12,2),
    nch_bene_blood_ddctbl_lblty_am   NUMERIC(12,2),
    clm_utlztn_day_cnt               INTEGER,
    nch_bene_dschrg_dt               VARCHAR(10),
    clm_drg_cd                       VARCHAR(20),
    icd9_dgns_cd_1  VARCHAR(20), icd9_dgns_cd_2  VARCHAR(20), icd9_dgns_cd_3  VARCHAR(20),
    icd9_dgns_cd_4  VARCHAR(20), icd9_dgns_cd_5  VARCHAR(20), icd9_dgns_cd_6  VARCHAR(20),
    icd9_dgns_cd_7  VARCHAR(20), icd9_dgns_cd_8  VARCHAR(20), icd9_dgns_cd_9  VARCHAR(20),
    icd9_dgns_cd_10 VARCHAR(20),
    icd9_prcdr_cd_1 VARCHAR(20), icd9_prcdr_cd_2 VARCHAR(20), icd9_prcdr_cd_3 VARCHAR(20),
    icd9_prcdr_cd_4 VARCHAR(20), icd9_prcdr_cd_5 VARCHAR(20), icd9_prcdr_cd_6 VARCHAR(20),
    hcpcs_cd_1  VARCHAR(20), hcpcs_cd_2  VARCHAR(20), hcpcs_cd_3  VARCHAR(20), hcpcs_cd_4  VARCHAR(20),
    hcpcs_cd_5  VARCHAR(20), hcpcs_cd_6  VARCHAR(20), hcpcs_cd_7  VARCHAR(20), hcpcs_cd_8  VARCHAR(20),
    hcpcs_cd_9  VARCHAR(20), hcpcs_cd_10 VARCHAR(20), hcpcs_cd_11 VARCHAR(20), hcpcs_cd_12 VARCHAR(20),
    hcpcs_cd_13 VARCHAR(20), hcpcs_cd_14 VARCHAR(20), hcpcs_cd_15 VARCHAR(20), hcpcs_cd_16 VARCHAR(20),
    hcpcs_cd_17 VARCHAR(20), hcpcs_cd_18 VARCHAR(20), hcpcs_cd_19 VARCHAR(20), hcpcs_cd_20 VARCHAR(20),
    hcpcs_cd_21 VARCHAR(20), hcpcs_cd_22 VARCHAR(20), hcpcs_cd_23 VARCHAR(20), hcpcs_cd_24 VARCHAR(20),
    hcpcs_cd_25 VARCHAR(20), hcpcs_cd_26 VARCHAR(20), hcpcs_cd_27 VARCHAR(20), hcpcs_cd_28 VARCHAR(20),
    hcpcs_cd_29 VARCHAR(20), hcpcs_cd_30 VARCHAR(20), hcpcs_cd_31 VARCHAR(20), hcpcs_cd_32 VARCHAR(20),
    hcpcs_cd_33 VARCHAR(20), hcpcs_cd_34 VARCHAR(20), hcpcs_cd_35 VARCHAR(20), hcpcs_cd_36 VARCHAR(20),
    hcpcs_cd_37 VARCHAR(20), hcpcs_cd_38 VARCHAR(20), hcpcs_cd_39 VARCHAR(20), hcpcs_cd_40 VARCHAR(20),
    hcpcs_cd_41 VARCHAR(20), hcpcs_cd_42 VARCHAR(20), hcpcs_cd_43 VARCHAR(20), hcpcs_cd_44 VARCHAR(20),
    hcpcs_cd_45 VARCHAR(20)
);

-- Note: CLM_FROM_DT, CLM_THRU_DT, CLM_ADMSN_DT, NCH_BENE_DSCHRG_DT are loaded as
-- VARCHAR here (format YYYYMMDD, e.g. 20100312) to guarantee the import succeeds.
-- We will convert them to proper DATE columns in a later script, once the data is loaded.