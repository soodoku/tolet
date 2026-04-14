# Replication Analysis: Chaturvedi, Das & Mahajan (2023)

## Executive Summary

This repository documents a comprehensive replication and critique of "When Do Gender Quotas Change Policy? Evidence from Household Toilet Provision in India" (Chaturvedi, Das & Mahajan, 2023). Our analyses reveal three critical concerns: (1) the heterogeneous RD specification produces significant effects on pre-treatment outcomes (FY 2014-15), indicating a failure of the parallel trends assumption; (2) the mechanism fails in UP specifically—the state where the RD is identified—while MP drives the pooled latrine preference results; and (3) NREGA sanitation spending shows *negative* interaction effects in post-treatment years, opposite to the predicted mechanism.

## Paper Context

**Paper:** Chaturvedi, Das & Mahajan (2023), "When Do Gender Quotas Change Policy? Evidence from Household Toilet Provision in India"

**Design:** Regression discontinuity using 2015 Uttar Pradesh gram panchayat elections (October 2015) with female reservation for sarpanch positions based on Muslim population share thresholds.

**Main Claims:**
1. Female reservation increases household toilet provision
2. Effects are heterogeneous by Muslim share (larger effects in high-Muslim-share areas)
3. The mechanism operates through increased female voice and preferences for sanitation

## Key Variables

- **Toilet coverage**: % of households in a GP with toilets (from SBM administrative data)
- **Latrine preference**: Survey response on whether respondent prefers a toilet (from SQUAT 2014 survey)
- **Female reservation**: Whether GP sarpanch seat is reserved for women
- **Muslim share**: Proportion of Muslim population in GP

## Timeline

```
FY 2013-14: Apr 2013 - Mar 2014  → Pre-treatment
FY 2014-15: Apr 2014 - Mar 2015  → Pre-treatment
Elections:  October 2015          → Treatment (four phases: Oct 9, 13, 17, 29)
FY 2015-16: Apr 2015 - Mar 2016  → Partially post (Oct 2015 - Mar 2016)
FY 2016-17: Apr 2016 - Mar 2017  → Post-treatment
```

## Key Findings

### 1. Placebo Test Failure (Critical)

**Source:** `code/table_3_placebo.R`, `output/table3_placebo.csv`

The heterogeneous RD specification (Female × Muslim Share × RD) shows significant effects on FY 2014-15 outcomes—a period entirely *before* the October 2015 elections:

| Fiscal Year | BW=0.10 | BW=0.075 | BW=0.05 |
|-------------|---------|----------|---------|
| 2013-14 (PRE) | 0.18 | 0.16 | 0.74 |
| **2014-15 (PRE)** | **2.64\*\*\*** | **3.35\*\*\*** | **3.36\*\*** |
| 2015-16 (POST) | 0.40 | 0.03 | -1.57 |

The triple interaction coefficient for FY 2014-15 is significant at conventional levels across all bandwidths, yet this fiscal year ended in March 2015—seven months before any elections occurred.

**Implication:** The parallel trends assumption is violated. Pre-existing differential trends in high-Muslim-share GPs may explain the heterogeneous effects attributed to female reservation.

### 2. State-Level Heterogeneity: Mechanism Fails in UP

**Source:** `code/table_2_by_state.R`, `output/table2_by_state.csv`

The paper's mechanism story relies on female sarpanches increasing sanitation because women prefer toilets more. But examining the Female × Muslim interaction for latrine preferences by state reveals a critical problem:

| State | N | m3 (pref1) | m4 (pref2) | m5 (pref3) |
|-------|---|-----------|-----------|-----------|
| **UP** | 385 | **-0.30** (0.42) | **-0.60** (0.39) | +0.26 (0.33) |
| MP | 382 | +0.99*** (0.27) | +1.07*** (0.23) | +0.60** (0.27) |
| Bihar | 408 | +0.43 (0.43) | +0.44 (0.38) | +0.29 (0.33) |
| Rajasthan | 193 | -0.84 (0.81) | -0.15 (1.08) | -0.91 (0.96) |
| Haryana | 104 | -5.02 (6.43) | -0.50 (3.90) | -2.10 (3.19) |

**Critical Issue:**
- Table 3's RD is identified from **UP** gram panchayat elections (October 2015)
- But UP shows **negative** (non-significant) preference interaction across most models
- Only **Madhya Pradesh** shows the expected positive significant interaction
- The pooled Table 2 result is driven by MP, not UP

**Implication:** The mechanism (female preferences → female sarpanch → more toilets) has no empirical support in UP, the state where the main treatment effect is identified.

For toilet use (models 1-2), the pattern also varies substantially:

| State | Female × Muslim (m2) | N |
|-------|---------------------|---|
| Bihar | 0.04 (SE: 0.09) | 1,132 |
| Madhya Pradesh | 0.09 (SE: 0.05) | 1,782 |
| Uttar Pradesh | 0.14 (SE: 0.07) | 1,825 |
| Rajasthan | 0.32 (SE: 0.24) | 530 |
| Haryana | 0.81 (SE: 0.29) | 2,469 |

### 3. NREGA Sanitation: Wrong-Signed Effects

**Source:** `code/mnrega_main.R`, `output/table3_lagged.csv`

If female sarpanches in high-Muslim GPs prioritize sanitation, the Female × Muslim Share interaction for NREGA sanitation spending should be **positive**. Instead, it is **negative** in post-treatment years:

| Year | Coef (BW=0.10) | SE | t-stat | N |
|------|----------------|-----|--------|-----|
| 2016 | -0.058 | 0.030 | -1.9* | 1,030 |
| **2017** | **-0.094** | **0.040** | **-2.3**† | **1,440** |

† Significant at 5%

**Implication:** NREGA sanitation spending is *lower* in reserved GPs within high-Muslim areas—the opposite of what the mechanism predicts. This is not merely a null result but a wrong-signed effect.

### 4. Temporal Pattern Issues

**Source:** `code/table_3_lagged.R`, `output/table3_lagged.csv`

The Female × Muslim Share interaction coefficient across years (coverage and NREGA outcomes) does not show the clean pre/post pattern expected from a causal interpretation:

- Coverage FY 2016-17 shows positive interaction (107–153), but FY 2015-16 shows negative interaction (-9 to -36)
- NREGA Total spending shows negative interactions in 2014 (-0.46 to -0.88), becoming less negative post-treatment
- NREGA Sanitation shows negative interactions post-treatment in 2016-2017

### 5. Non-Monotonic Dose-Response

**Source:** `code/dose_response_coverage.R`, `code/dose_response_preferences.R`

If the Female × Muslim Share interaction reflects a real moderating effect, we would expect a monotonic dose-response: larger effects at higher Muslim share. Instead, the relationship is erratic.

**Toilet Coverage (Table 3):**

| Muslim Share | Female Effect (pp) |
|--------------|-------------------|
| 0.00–0.05 | -0.6 |
| 0.05–0.10 | -2.9 |
| 0.10–0.15 | -4.1 |
| 0.15–0.20 | -4.8 |
| 0.20–0.25 | **-18.8** |
| 0.25–0.30 | +6.0 |
| 0.30–0.35 | **+32.4** |
| 0.35–0.40 | -9.8 |
| 0.40–0.45 | +1.2 |

The effect of female reservation on toilet coverage is **negative** for Muslim share 0–25%, then spikes at 30–35%, then erratic. This is not a smooth dose-response.

**Latrine Preferences in UP (Table 2):**

| Muslim Share | Female - Male Diff | N |
|--------------|--------------------|----|
| 0.0–0.1 | +0.01 | 1,716 |
| 0.1–0.2 | +0.01 | 356 |
| 0.2–0.3 | **-0.05** | 57 |
| 0.3–0.4 | **-0.12** | 135 |
| 0.4–0.5 | **-0.08** | 62 |
| 0.5–0.6 | +0.16 | 31 |
| 0.9–1.0 | 0.00 | 11 |

In UP (where the RD is identified), the bulk of the data (Muslim share 0–0.5) shows women prefer toilets the same or **less** than men. The 0.3–0.4 bin shows a -0.12 gap. Only at very high Muslim share (0.5–0.6, N=31) does a positive gap appear. The mechanism predicts a monotonically increasing positive relationship; the data show no such pattern.

**Data Distribution Problem (Table 3):**

The interaction coefficient (107.4) appears large, but consider the data distribution:

| Muslim Share | Implied Effect | Cumulative % of Data |
|--------------|----------------|----------------------|
| < 0.10 | +10.7 pp | 60.7% |
| < 0.20 | +21.5 pp | 80.4% |
| < 0.30 | +32.2 pp | 88.5% |

Median Muslim share is **0.074**. The huge coefficient is extrapolated from ~12% of observations at Muslim share > 0.30, where the dose-response shows erratic positive effects. Where the data actually lives (0–0.25, 85% of sample), effects are **negative**.

**GAM Analysis Confirms Leverage Problem:**

A GAM with smooth interaction (`code/gam_interaction.R`) shows the Female effect by Muslim share with proper uncertainty:

| Muslim Share | Female Effect | 95% CI | Significant? |
|--------------|---------------|--------|--------------|
| 0.05 | -2.0 pp | [-5.6, +1.7] | No |
| 0.10 | -2.6 pp | [-6.3, +1.1] | No |
| 0.20 | -1.6 pp | [-6.6, +3.4] | No |
| 0.30 | +2.7 pp | [-3.7, +9.1] | No |
| 0.40 | +9.0 pp | [+1.0, +16.9] | **Yes** |
| 0.50 | +15.6 pp | [+5.9, +25.4] | **Yes** |

Where data lives (Muslim share < 0.20, 80% of sample): **null or negative effects, CIs include zero**. Effects only become significant at Muslim share > 0.35, where < 5% of observations reside.

**Implication:** The linear interaction is fit by high-leverage observations in the tail. The GAM shows tight null effects where the data lives and increasing uncertainty (wider CIs) where it doesn't — exactly what we'd expect when a linear term is extrapolating from sparse data.

## Implications for Causal Interpretation

1. **Identification Failure:** The significant placebo effects on FY 2014-15 outcomes indicate that the heterogeneous RD specification captures pre-existing differential trends rather than (or in addition to) causal effects of female reservation.

2. **Mechanism Disconnect:** The mechanism (women's preferences → female sarpanch → sanitation) fails in UP—the state providing treatment variation—while only MP shows supporting evidence.

3. **Wrong-Signed Spending Effects:** NREGA sanitation spending shows *negative* interaction effects post-treatment, contradicting the claim that female sarpanches channel resources toward sanitation in high-Muslim areas.

4. **Non-Monotonic Dose-Response:** The Female × Muslim Share interaction does not reflect a smooth moderating relationship. Effects are negative at low Muslim share, spike erratically at specific bins, and show no monotonic pattern. This suggests the linear interaction term is fitting noise rather than a substantive moderating effect.

5. **Alternative Explanations:** The pattern of results is consistent with Muslim population share being correlated with other time-varying factors (economic development, government program targeting, Swachh Bharat Mission rollout) that differentially affected toilet provision.

## Replication Files

### Code
- `code/00_utils.R` - Utility functions
- `code/table_2_by_state.R` - State heterogeneity analysis of Table 2
- `code/table_3_placebo.R` - Placebo test replication
- `code/table_3_lagged.R` - Temporal pattern analysis
- `code/mnrega_main.R` - NREGA spending analysis
- `code/dose_response_coverage.R` - Dose-response analysis for toilet coverage
- `code/dose_response_preferences.R` - Dose-response analysis for latrine preferences
- `code/gam_interaction.R` - GAM analysis showing leverage point problem

### Output
- `output/table2_by_state.csv` - State-level Table 2 results
- `output/table3_placebo.csv` - Placebo test coefficients
- `output/table3_lagged.csv` - Year-by-year coefficients
- `output/mnrega_main.csv` - NREGA main results
- `output/mnrega_main_bw*.tex` - LaTeX tables by bandwidth
- `output/dose_response_coverage.csv` - Toilet coverage by Muslim share bin
- `output/dose_response_coverage.pdf` - Toilet coverage dose-response plot
- `output/dose_response_preferences.csv` - Latrine preferences by Muslim share bin
- `output/gam_interaction.csv` - GAM predicted effects by Muslim share
- `output/gam_interaction.pdf` - GAM interaction plot with confidence intervals

## Sources

Election timing documentation:
- [Aaj Tak - UP Panchayat Election 2015](https://www.aajtak.in/india/uttar-pradesh/story/uttar-pradesh-announces-panchayat-elections-in-four-phase--313437-2015-09-21)
- [State Election Commission UP](https://sec.up.nic.in/site/)
- [Ministry of Panchayati Raj](https://panchayat.gov.in/en/status-of-panchayat-elections-in-pris/)
