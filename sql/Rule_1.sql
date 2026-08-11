 QA RULE #1: Orphaned Claims Check
-- Purpose: Every claim should belong to a real, known beneficiary.
-- A claim whose DESYNPUF_ID does not exist in the beneficiary table is an
-- "orphaned" record -- it suggests a broken link between systems, a data
-- entry error, or a beneficiary record that failed to load correctly.
-- This is one of the most fundamental data integrity checks in any claims
-- system, and mirrors real RCM QA work: you can't trust downstream billing
-- or reporting if the underlying claim isn't tied to a valid patient.
 
-- Step 1: Count how many orphaned claims exist
SELECT COUNT(*) AS orphaned_claim_count
FROM inpatient_claims ic
LEFT JOIN beneficiary_summary_2008 bs
    ON ic.desynpuf_id = bs.desynpuf_id
WHERE bs.desynpuf_id IS NULL;
 
-- Step 2: See the actual orphaned rows (for spot-checking / documentation)
SELECT ic.desynpuf_id, ic.clm_id, ic.clm_from_dt, ic.clm_thru_dt, ic.clm_pmt_amt
FROM inpatient_claims ic
LEFT JOIN beneficiary_summary_2008 bs
    ON ic.desynpuf_id = bs.desynpuf_id
WHERE bs.desynpuf_id IS NULL
LIMIT 50;
 
-- Step 3: Express it as a percentage of total claims (useful for your report)
SELECT
    (SELECT COUNT(*) FROM inpatient_claims) AS total_claims,
    (SELECT COUNT(*)
     FROM inpatient_claims ic
     LEFT JOIN beneficiary_summary_2008 bs ON ic.desynpuf_id = bs.desynpuf_id
     WHERE bs.desynpuf_id IS NULL) AS orphaned_claims,
    ROUND(
        100.0 * (SELECT COUNT(*)
                  FROM inpatient_claims ic
                  LEFT JOIN beneficiary_summary_2008 bs ON ic.desynpuf_id = bs.desynpuf_id
                  WHERE bs.desynpuf_id IS NULL)
        / (SELECT COUNT(*) FROM inpatient_claims), 2
    ) AS orphaned_pct;