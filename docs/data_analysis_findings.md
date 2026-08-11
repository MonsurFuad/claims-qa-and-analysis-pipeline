# Inpatient Claims Data Analysis — Findings Summary

**Dataset used:** `inpatient_claims_final` (66,705 rows, cleaned) joined with `beneficiary_summary_2008_clean` where noted.
**Purpose:** Beyond the QA audit, this analysis explores patterns in the data to surface business-relevant insights, covering spending trends, cost drivers, provider behavior, and utilization patterns.

---

## Analysis #1 — Claim Volume & Spending Trends by Year

| Year | Claims | Total Paid | Avg per Claim |
|---|---|---|---|
| 2007 | 224 | $2,770,000 | $12,366 |
| 2008 | 27,678 | $257,732,880 | $9,312 |
| 2009 | 25,231 | $244,810,270 | $9,703 |
| 2010 | 13,572 | $132,669,330 | $9,775 |

**Findings:**
- A small number of claims (224) are dated in 2007, despite the source file covering 2008–2010. These likely represent claims that began in late 2007 and were recorded in the following year's file.
- 2010 shows roughly half the claim volume of 2008/2009. This is most likely due to the sample file containing only a partial year of 2010 data, rather than a genuine drop in healthcare utilization.
- Average payment per claim increased steadily year over year ($9,312 → $9,703 → $9,775), a mild upward cost trend across the sample period.

---

## Analysis #2 — Cost by Diagnosis Related Group (DRG)

The five most expensive DRG codes by average payment per claim (minimum 20 claims):

| DRG Code | Claims | Avg Paid per Claim |
|---|---|---|
| 009 | 23 | $54,217 |
| 002 | 24 | $54,042 |
| 013 | 20 | $52,450 |
| 003 | 21 | $52,095 |
| 008 | 29 | $51,483 |

**Findings:** These top DRG codes average $50,000–$54,000 per claim — roughly 5x the overall dataset average of ~$9,500. This highlights a small set of diagnosis groups that disproportionately drive high-cost claims, which would be a natural starting point for cost-review or negotiation prioritization in a real RCM context.

---

## Analysis #3 — Chronic Conditions vs. Claim Cost

| Condition | Has Condition | Claims | Avg Paid |
|---|---|---|---|
| Cancer | Yes | 11,143 | $9,705 |
| Cancer | No | 55,562 | $9,536 |
| Congestive Heart Failure | Yes | 43,202 | $9,598 |
| Congestive Heart Failure | No | 23,503 | $9,503 |
| Diabetes | Yes | 48,417 | $9,553 |
| Diabetes | No | 18,288 | $9,594 |

**Findings:** Contrary to expectation, average claim cost barely differs between beneficiaries with and without these chronic conditions (differences of ~1-2%). This suggests that for inpatient claims specifically, the cost is driven far more by the nature of the specific procedure/DRG (see Analysis #2) than by a patient's general chronic condition status. This is a useful nuance: chronic conditions may better predict claim *frequency* or *long-term cost* rather than the cost of any single inpatient encounter.

---

## Analysis #4 — Length of Stay vs. Claim Cost

| Stay Length | Claims | Avg Paid |
|---|---|---|
| 0-2 days | 18,551 | $6,780 |
| 3-5 days | 25,502 | $8,159 |
| 6-10 days | 14,276 | $11,350 |
| 11-20 days | 6,207 | $15,617 |
| 20+ days | 2,169 | $20,825 |

**Findings:** A clear, consistent relationship — average payment roughly triples from the shortest stays (0-2 days) to the longest (20+ days). This confirms the data behaves as expected for real healthcare billing, and serves as a useful sanity check that the underlying claim and payment data is internally consistent, reinforcing confidence in the QA findings from the earlier audit.

---

## Analysis #5 — Provider-Level Billing Patterns

**Top provider by volume:** Provider `23006G` billed 772 claims totaling $7,280,500 — nearly double the second-highest provider (`1000AH`, 633 claims, $6,109,900).

**Distribution stats:**
- Average: ~25 claims per provider across 2,675 distinct providers
- Standard deviation: 47.8 — very high relative to the average
- Maximum: 772 claims (a single provider)

**Findings:** A statistical outlier check (providers exceeding average + 3 standard deviations) flagged a large number of providers rather than a small handful. This indicates provider claim volume is **heavily right-skewed** rather than normally distributed — a small number of high-volume providers (likely larger hospital systems) handle a disproportionate share of claims, while most providers handle far fewer. This is a useful methodological note: a simple z-score threshold isn't the ideal outlier detection method for this kind of skewed, real-world billing data; a percentile-based cutoff (e.g., top 1% by volume) would likely be more informative in a production setting, since raw high volume mostly reflects provider size rather than anomalous behavior.

**Recommendation:** For genuine anomaly detection (as opposed to simply identifying large providers), a more targeted approach — such as flagging providers whose *average cost per claim* is unusually high relative to peers billing similar DRG codes — would better surface true billing concerns.

---

## Analysis #6 — Readmission Pattern Analysis

**Beneficiary claim distribution:**

| Group | Beneficiaries | % of Total |
|---|---|---|
| 1 claim | 22,640 | 60% |
| 2 claims | 8,216 | 22% |
| 3-4 claims | 5,151 | 14% |
| 5+ claims | 1,773 | 5% |

**Cost comparison:**

| Group | Avg Total Paid per Beneficiary |
|---|---|
| Single claim | $9,512 |
| Multiple claims (2+) | $27,915 |

**Findings:** 40% of beneficiaries have 2 or more inpatient claims, and this group accounts for nearly **3x the average total spend** of single-claim beneficiaries ($27,915 vs. $9,512). This is a significant and actionable insight: a relatively small subset of high-utilization patients drives a disproportionate share of total inpatient spending — a pattern consistent with real-world healthcare cost concentration, where repeat/high-need patients account for the majority of costs. In a production RCM or care management context, this group would be a natural target for care coordination programs aimed at reducing avoidable readmissions.

---

## Analysis #7 — Geographic Breakdown by State

Claim volume and average cost per claim were examined across CMS's coded state values (`SP_STATE_CODE`). Average cost per claim was fairly consistent across the top 15 states by volume, ranging from roughly $9,250 to $9,975 — no state stood out as a significant cost outlier. Claim volume varied more, with the top state accounting for 5,324 claims versus ~1,550 for the 15th-ranked state.

**Note:** CMS state codes are numeric (SSA state codes), not standard two-letter abbreviations. A lookup table would be needed to convert these into readable state names for a client-facing report.

---

## Analysis #8 — Demographic Breakdown by Sex

| Sex | Claims | Avg Paid |
|---|---|---|
| Male | 28,983 | $9,618 |
| Female | 37,722 | $9,523 |

**Findings:** Female beneficiaries account for more claims overall, but average cost per claim is nearly identical between the two groups (within 1%). Sex does not appear to be a meaningful driver of individual claim cost in this dataset.

---

## Overall Takeaway

Combining all analyses, the dataset is structurally sound (per the QA findings) and behaves in economically sensible ways — cost rises steadily with stay length, and certain DRGs are consistently far more expensive than others. The clearest actionable finding across this dataset is **utilization concentration**: a minority of high-utilization beneficiaries (40%, with 2+ claims) and a minority of high-cost DRG codes together account for a disproportionate share of total spend, while broad demographic factors (chronic condition status, sex, state) show only modest cost differences. In a real RCM setting, this points toward prioritizing care coordination for repeat inpatient utilizers and targeted review of high-cost DRG categories as the most impactful levers for cost management — rather than broad demographic-based interventions.
