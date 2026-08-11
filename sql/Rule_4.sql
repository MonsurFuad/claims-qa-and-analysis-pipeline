-- QA RULE #4: Claim Dates vs. Beneficiary Lifetime Check
-- Purpose: A claim cannot logically occur before a beneficiary was born, or
-- after they died. Claims outside this window point to either a data entry
-- error in the claim, an incorrect birth/death date on the beneficiary
-- record, or a beneficiary ID mismatch. This check joins the two tables
-- you've loaded so far and mirrors the kind of cross-table validation a
-- real RCM QA analyst does daily.

-- Step 1: Claims that occur BEFORE the beneficiary's birth date
SELECT COUNT(*) AS claims_before_birth
FROM inpatient_claims ic
JOIN beneficiary_summary_2008 bs ON ic.desynpuf_id = bs.desynpuf_id
WHERE TO_DATE(ic.clm_from_dt, 'YYYYMMDD') < TO_DATE(bs.bene_birth_dt, 'YYYYMMDD');

-- Step 2: Claims that occur AFTER the beneficiary's death date
-- (only applies to beneficiaries who have a death date on record)
SELECT COUNT(*) AS claims_after_death
FROM inpatient_claims ic
JOIN beneficiary_summary_2008 bs ON ic.desynpuf_id = bs.desynpuf_id
WHERE bs.bene_death_dt IS NOT NULL
  AND TO_DATE(ic.clm_from_dt, 'YYYYMMDD') > TO_DATE(bs.bene_death_dt, 'YYYYMMDD');

-- Step 3: See the actual problem rows for claims after death (likely more
-- interesting than before-birth, since it can reveal billing-after-death issues)
SELECT ic.desynpuf_id, ic.clm_id, ic.clm_from_dt, bs.bene_death_dt, ic.clm_pmt_amt
FROM inpatient_claims ic
JOIN beneficiary_summary_2008 bs ON ic.desynpuf_id = bs.desynpuf_id
WHERE bs.bene_death_dt IS NOT NULL
  AND TO_DATE(ic.clm_from_dt, 'YYYYMMDD') > TO_DATE(bs.bene_death_dt, 'YYYYMMDD')
ORDER BY ic.clm_from_dt DESC
LIMIT 50;

-- Step 4: Summary with percentages
SELECT
    (SELECT COUNT(*) FROM inpatient_claims) AS total_claims,
    (SELECT COUNT(*) FROM inpatient_claims ic
     JOIN beneficiary_summary_2008 bs ON ic.desynpuf_id = bs.desynpuf_id
     WHERE TO_DATE(ic.clm_from_dt, 'YYYYMMDD') < TO_DATE(bs.bene_birth_dt, 'YYYYMMDD')) AS before_birth_count,
    (SELECT COUNT(*) FROM inpatient_claims ic
     JOIN beneficiary_summary_2008 bs ON ic.desynpuf_id = bs.desynpuf_id
     WHERE bs.bene_death_dt IS NOT NULL
       AND TO_DATE(ic.clm_from_dt, 'YYYYMMDD') > TO_DATE(bs.bene_death_dt, 'YYYYMMDD')) AS after_death_count;