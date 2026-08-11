-- QA RULE #5: Duplicate Claim ID Check
-- Purpose: CLM_ID should be a unique identifier for each claim. If the same
-- CLM_ID appears more than once, that could mean a claim was submitted or
-- loaded twice (duplicate billing), a system error during data entry, or an
-- ETL/import bug. Duplicate claim IDs are one of the most classic and
-- serious issues in claims/RCM data, since duplicate billing directly
-- affects revenue accuracy.

-- Step 1: Count how many claim IDs appear more than once
SELECT COUNT(*) AS duplicate_claim_id_count
FROM (
    SELECT clm_id
    FROM inpatient_claims
    GROUP BY clm_id
    HAVING COUNT(*) > 1
) dup;

-- Step 2: See the actual duplicate claim IDs and how many times each appears
SELECT clm_id, COUNT(*) AS occurrences
FROM inpatient_claims
GROUP BY clm_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 50;

-- Step 3: Look at the full rows for one duplicate example, to see if the
-- duplicate rows are identical (likely a load error) or different (likely a
-- genuine separate claim that reused an ID, which would be more concerning)
-- Replace 'PUT_A_CLM_ID_HERE' with an actual clm_id from Step 2's results.
-- SELECT * FROM inpatient_claims WHERE clm_id = PUT_A_CLM_ID_HERE;

-- Step 4: Summary with percentage
SELECT
    (SELECT COUNT(*) FROM inpatient_claims) AS total_claims,
    (SELECT COUNT(*) FROM (
        SELECT clm_id FROM inpatient_claims GROUP BY clm_id HAVING COUNT(*) > 1
    ) dup) AS duplicate_claim_ids,
    ROUND(
        100.0 * (SELECT COUNT(*) FROM (
            SELECT clm_id FROM inpatient_claims GROUP BY clm_id HAVING COUNT(*) > 1
        ) dup) / (SELECT COUNT(*) FROM inpatient_claims), 2
    ) AS duplicate_pct;
-- Follow-up to QA Rule #5: pick one duplicated CLM_ID and view both rows side
-- by side, to determine whether the duplication is an exact copy (likely a
-- data load/ETL issue) or contains differing details (likely a genuine
-- duplicate claim submission -- more serious).

SELECT desynpuf_id, clm_id, clm_from_dt, clm_thru_dt, clm_pmt_amt, prvdr_num, clm_drg_cd
FROM inpatient_claims
WHERE clm_id = 196851176990818
ORDER BY clm_id;

-- If you want to check a few more duplicate pairs at once, run this instead:
-- it shows every duplicated clm_id with both of its rows next to each other.
SELECT desynpuf_id, clm_id, clm_from_dt, clm_thru_dt, clm_pmt_amt, prvdr_num, clm_drg_cd
FROM inpatient_claims
WHERE clm_id IN (
    SELECT clm_id FROM inpatient_claims GROUP BY clm_id HAVING COUNT(*) > 1
)
ORDER BY clm_id
LIMIT 20;

-- Follow-up: does the SEGMENT column explain the duplicate CLM_IDs?
-- If every duplicated CLM_ID has one row with SEGMENT = 1 and one with
-- SEGMENT = 2 (or similar), this isn't a data error at all -- it's the
-- standard CMS convention for splitting long inpatient stays into multiple
-- billing segments (e.g. interim vs. final claim).

SELECT desynpuf_id, clm_id, segment, clm_from_dt, clm_thru_dt, clm_pmt_amt
FROM inpatient_claims
WHERE clm_id IN (
    SELECT clm_id FROM inpatient_claims GROUP BY clm_id HAVING COUNT(*) > 1
)
ORDER BY clm_id
LIMIT 20;

-- Also check: does every duplicate pair have DIFFERENT segment values?
SELECT clm_id, COUNT(DISTINCT segment) AS distinct_segment_values, COUNT(*) AS row_count
FROM inpatient_claims
WHERE clm_id IN (
    SELECT clm_id FROM inpatient_claims GROUP BY clm_id HAVING COUNT(*) > 1
)
GROUP BY clm_id
LIMIT 20;
