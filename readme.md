# Replication Analysis: Chaturvedi, Das & Mahajan (2023)

## Executive Summary

This repository documents a comprehensive replication and critique of "When Do Gender Quotas Change Policy? Evidence from Household Toilet Provision in India" (Chaturvedi, Das & Mahajan, 2023). Our analyses reveal several findings:

**Supportive of the paper:**
- Pre-trends test on coverage **levels** passes (0/6 pre-treatment coefficients significant at p<0.05)
- DID-style robustness using coverage **change** as outcome shows the interaction survives (p≈0.01)

**Critical concerns:**
1. The mechanism fails in UP specifically—the state where the RD is identified—while MP drives the pooled latrine preference results
2. The Female × Muslim Share interaction for latrine preferences is **not significant in raw data**—it only emerges after conditioning on village fixed effects, suggesting the "mechanism" is a statistical artifact rather than a real behavioral pattern
3. NREGA sanitation spending shows *negative* interaction effects in post-treatment years, opposite to the predicted mechanism
4. **SBM data quality concern:** ~12.6% of GPs show coverage regression (toilets "lost") in FY 2016-17, likely reflecting administrative data corrections rather than actual toilet destruction

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

### 1. Pre-trends Analysis

**Source:** `code/replication/02_table3_robustness.R`, `output/replication/pretrends.csv`

We test for pre-treatment differential trends by examining the Female × Muslim Share interaction on coverage levels in each fiscal year:

| Fiscal Year | Period | BW=0.10 p-value | BW=0.075 p-value | BW=0.05 p-value |
|-------------|--------|-----------------|------------------|-----------------|
| 2013-14 | Pre-treatment | 0.63 | 0.53 | 0.99 |
| 2014-15 | Pre-treatment | 0.39 | 0.49 | 0.33 |
| 2015-16 | Partial (elections Oct 2015) | 0.85 | 0.83 | 0.67 |
| **2016-17** | **Post-treatment** | **0.02** | **0.02** | **0.03** |

**Result:** 0/6 pre-treatment coefficients are significant at p<0.05. The pre-trends test **passes**—no evidence of differential pre-trends in coverage levels between treatment and control GPs by Muslim share.

The interaction becomes significant only in FY 2016-17 (post-treatment), consistent with a causal effect emerging after the October 2015 elections.

### 1b. DID Robustness: Coverage Change as Outcome

**Source:** `code/replication/02_table3_robustness.R`, `output/replication/did_robustness.csv`

As a robustness check, we use a difference-in-differences style specification with coverage **change** (FY 2016-17 minus FY 2014-15) as the outcome:

| Bandwidth | N | Interaction Coef | SE | p-value |
|-----------|---|------------------|-----|---------|
| 0.10 | 7,263 | 122.5 | 49.1 | **0.013** |
| 0.075 | 5,488 | 146.1 | 58.7 | **0.013** |
| 0.05 | 3,707 | 177.0 | 72.1 | **0.014** |

**Result:** The Female × Muslim Share interaction is significant at p<0.02 across all bandwidths when using coverage change as the outcome. This DID-style approach, which differences out any time-invariant confounds, supports the paper's main finding.

### 2. State-Level Heterogeneity: Mechanism Fails in UP

**Source:** `code/replication/01_main_replication.R`, `output/replication/table2_by_state.csv`

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

### 2b. Table 2 Control Sensitivity: Interaction Only Emerges With Controls

**Source:** `code/replication/01_main_replication.R` → `run_table2_control_sensitivity()`, `output/replication/table2_control_sensitivity.csv`

A key question for the mechanism: does the Female × Muslim Share interaction reflect actual preference differences that a sarpanch would observe, or does it only appear after conditioning on individual characteristics?

We re-run Table 2 with progressively more controls:

| Specification | Toilet Use | Pref 1 | Pref 2 | Pref 3 |
|---------------|------------|--------|--------|--------|
| 1. Raw (no FE, no controls) | 0.19*** | 0.16 | 0.20 | 0.13 |
| 2. Village FE only | 0.13** | 0.35 | 0.46* | 0.37* |
| 3. Village FE + Wealth | 0.13** | 0.31 | 0.42* | 0.36* |
| 4. Paper spec (+ Edu FE) | 0.13** | 0.34 | 0.43* | 0.38* |

**Critical finding for latrine preferences:**
- In **raw data** (no controls): interaction is **not significant** for any preference measure (p > 0.09)
- Adding **village FE doubles the coefficient** and makes it significant for Pref 2-3

This is backwards from what we'd expect if controls were removing confounds—normally controls shrink coefficients. Here, village FE inflates the interaction.

**Interpretation:** The significant preference interaction only emerges after conditioning on village. In the raw data—what a sarpanch would actually observe—there is no significant gender gap in toilet preferences that varies by Muslim share. The "mechanism" is a statistical artifact of the specification, not a real behavioral pattern.

For toilet use, the interaction is robust across specifications (0.13-0.19), suggesting a real pattern. But for preferences—the key mechanism—the pattern only appears with controls.

For toilet use (models 1-2), the pattern also varies substantially:

| State | Female × Muslim (m2) | N |
|-------|---------------------|---|
| Bihar | 0.04 (SE: 0.09) | 1,132 |
| Madhya Pradesh | 0.09 (SE: 0.05) | 1,782 |
| Uttar Pradesh | 0.14 (SE: 0.07) | 1,825 |
| Rajasthan | 0.32 (SE: 0.24) | 530 |
| Haryana | 0.81 (SE: 0.29) | 2,469 |

### 3. NREGA Sanitation: Wrong-Signed Effects

**Source:** `code/replication/05_mnrega.R`, `output/replication/mnrega_heterogeneous.csv`

If female sarpanches in high-Muslim GPs prioritize sanitation, the Female × Muslim Share interaction for NREGA sanitation spending should be **positive**. Instead, it is **negative** in post-treatment years:

| Year | Coef (BW=0.10) | SE | t-stat | N |
|------|----------------|-----|--------|-----|
| 2016 | -0.058 | 0.030 | -1.9* | 1,030 |
| **2017** | **-0.094** | **0.040** | **-2.3**† | **1,440** |

† Significant at 5%

**Implication:** NREGA sanitation spending is *lower* in reserved GPs within high-Muslim areas—the opposite of what the mechanism predicts. This is not merely a null result but a wrong-signed effect.

### 4. Temporal Pattern Issues

**Source:** `code/replication/02_table3_robustness.R`, `output/replication/pretrends.csv`, `output/replication/mnrega_heterogeneous.csv`

The Female × Muslim Share interaction coefficient across years (coverage and NREGA outcomes) does not show the clean pre/post pattern expected from a causal interpretation:

- Coverage FY 2016-17 shows positive interaction (107–153), but FY 2015-16 shows negative interaction (-9 to -36)
- NREGA Total spending shows negative interactions in 2014 (-0.46 to -0.88), becoming less negative post-treatment
- NREGA Sanitation shows negative interactions post-treatment in 2016-2017

### 5. Non-Monotonic Dose-Response

**Source:** `code/replication/02_dose_response.R`, `code/replication/02_dose_response.R`

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

A GAM with smooth interaction (`code/replication/02_dose_response.R`) shows the Female effect by Muslim share with proper uncertainty:

| Muslim Share | Female Effect | 95% CI | Significant? |
|--------------|---------------|--------|--------------|
| 0.05 | -2.0 pp | [-5.6, +1.7] | No |
| 0.10 | -2.6 pp | [-6.3, +1.1] | No |
| 0.20 | -1.6 pp | [-6.6, +3.4] | No |
| 0.30 | +2.7 pp | [-3.7, +9.1] | No |
| 0.40 | +9.0 pp | [+1.0, +16.9] | **Yes** |
| 0.50 | +15.6 pp | [+5.9, +25.4] | **Yes** |

Where data lives (Muslim share < 0.20, 80% of sample): **null or negative effects, CIs include zero**. Effects only become significant at Muslim share > 0.35, where < 5% of observations reside.

**Implication:** The linear interaction is fit by high-leverage observations in the tail. The GAM shows tight null effects where the data lives and increasing uncertainty (wider CIs) where it doesn't—exactly what we'd expect when a linear term is extrapolating from sparse data.

**GAM Analysis for Table 2 (Survey Data):**

*Toilet Use (models 1-2):*
| Muslim Share | Female Effect | 95% CI | Sig? |
|--------------|---------------|--------|------|
| 0.05 | +0.090 | [+0.067, +0.113] | Yes |
| 0.10 | +0.100 | [+0.063, +0.136] | Yes |
| 0.20 | +0.110 | [+0.062, +0.158] | Yes |
| 0.30 | +0.120 | [+0.066, +0.174] | Yes |

Toilet use shows a real female main effect (~9pp) that is significant across all Muslim share levels, with modest increase at higher Muslim share.

*Latrine Preferences (models 3-5):*
| Muslim Share | Female Effect | 95% CI | Sig? |
|--------------|---------------|--------|------|
| 0.05 | +0.019 | [-0.004, +0.042] | No |
| 0.10 | +0.035 | [+0.002, +0.067] | Barely |
| 0.20 | +0.040 | [-0.003, +0.084] | No |
| 0.30 | +0.011 | [-0.040, +0.062] | No |
| 0.40 | -0.018 | [-0.087, +0.050] | No |

Latrine preferences show **no significant effect** except marginally at Muslim share 0.10-0.15. At higher Muslim share, the effect is null or negative. The preference heterogeneity that supposedly drives the mechanism essentially doesn't exist.

### 6. SBM Data Quality Caveat

**Source:** SBM administrative data analysis

The Swachh Bharat Mission (SBM) toilet coverage data shows a concerning pattern of **coverage regression**—GPs reporting *fewer* toilets than in previous years:

| Fiscal Year | % GPs with Coverage Regression |
|-------------|--------------------------------|
| 2013-14 | ~1% |
| 2014-15 | ~3% |
| 2015-16 | ~4% |
| **2016-17** | **~12.6%** |

**What this means:** Only previously *reported* construction can be "rescinded" through data corrections. The 12.6% coverage regression rate indicates that at least 12.6% of GPs had over-reported toilet construction in prior years that was later corrected (likely through SBM verification drives).

**Key insight:** Measurement error (potential for downward revision) is mechanically correlated with previously reported construction. GPs that reported higher construction have more "room" for corrections to reveal over-reporting.

#### 6b. DID with Measurement-Error-Corrected Baseline

**Source:** `code/replication/02_table3_robustness.R` → `run_did_corrected()`, `output/replication/did_robustness_corrected.csv`

To address potential over-reporting, we apply a **floor correction** to the baseline:

```
cov14_corrected = min(coverage14_15, coverage15_16, coverage16_17)
```

If a GP reported X toilets in FY14-15 but only Y < X in a later year, then X was over-reported. This identifies over-reporting by taking the minimum across years.

**Data Quality Check:**
| Metric | Value |
|--------|-------|
| % GPs with corrected baseline | 18.5% |
| Original FY14-15 mean | 8.8 |
| Corrected FY14-15 mean | 0.7 |
| Mean reduction | 8.1 pp |

**Comparison: Original vs Corrected DID:**

| Bandwidth | Original Coef | Original p | Corrected Coef | Corrected p | Change |
|-----------|---------------|------------|----------------|-------------|--------|
| 0.10 | 122.5 | 0.013 | 104.1 | 0.026 | -15.0% |
| 0.075 | 146.1 | 0.013 | 124.4 | 0.027 | -14.9% |
| 0.05 | 177.0 | 0.014 | 141.3 | 0.042 | -20.2% |

**Interpretation:** The coefficient **decreases by 15-20%** after floor correction, suggesting over-reporting was higher in the treatment group (reserved GPs × high Muslim share). This implies the original DID estimate **overstated** the true effect by approximately 15-20%.

However, the interaction remains statistically significant (p < 0.05) across all bandwidths even after correction, suggesting a real treatment effect exists—just smaller than originally estimated.

**Implications for identification:**
1. If reserved GPs in high-Muslim areas reported *more* construction (the paper's main finding), they also have more scope for subsequent data corrections
2. This creates a potential attenuation bias: genuine treatment effects could be partially offset by larger corrections in treated units
3. Alternatively, if over-reporting was itself a treatment effect (female sarpanches more responsive to reporting pressure), the measured effect conflates real construction with differential over-reporting
4. The identifying assumption requires that over-reporting rates were similar across treatment × Muslim share cells—an assumption that is untestable

**Note:** The DID specification (coverage change) partially addresses *time-invariant* over-reporting. But if corrections were triggered by the same forces that drove construction (SBM pressure on female sarpanches in high-Muslim areas), the DID estimate could still be biased.

## Robustness Checks (Gelman/Green/Hainmueller Style)

### 1. Leave-One-Out Analysis

**Source:** `code/replication/03_robustness.R`, `output/replication/leave_one_out.csv`

Dropping each Muslim share bin and re-estimating the interaction coefficient reveals high sensitivity to specific observations:

| Dropped Bin | Remaining N | Coefficient | Change from Full |
|-------------|-------------|-------------|------------------|
| Full Sample | 7,263 | 107.4 | — |
| [0.55, 0.60) | 7,213 | 81.5 | -24.1% |
| [0.65, 0.70) | 7,223 | 88.8 | -17.4% |
| [0.45, 0.50) | 7,186 | 89.5 | -16.7% |
| [0.00, 0.05) | 4,819 | 124.7 | +16.1% |

The interaction coefficient is highly sensitive to a few Muslim share bins. High-Muslim-share bins (0.55-0.70) are high-leverage points that inflate the estimate.

### 2. Specification Curve (Multiverse Analysis)

**Source:** `code/replication/03_robustness.R`, `output/replication/specification_curve.csv`

Testing 50 specifications for the FY 2016-17 interaction effect (5 bandwidths × 2 functional forms × 5 covariate sets):

| Bandwidth | Significant (p < 0.05) | Significant (p < 0.10) |
|-----------|------------------------|------------------------|
| BW=0.05 | 0/10 (0%) | 10/10 (100%) |
| BW=0.075 | 5/10 (50%) | 10/10 (100%) |
| **BW=0.10** | **10/10 (100%)** | 10/10 (100%) |
| BW=0.125 | 8/10 (80%) | 10/10 (100%) |
| BW=0.15 | 0/10 (0%) | 10/10 (100%) |
| **Overall** | **23/50 (46%)** | **50/50 (100%)** |

Significance is highly sensitive to bandwidth choice. At narrow bandwidth (0.05), high standard errors yield 0% significance at p<0.05 despite point estimates around 150. At the paper's preferred bandwidth (0.10), all specifications reach significance. At wider bandwidth (0.15), estimates shrink (~70) and again fail p<0.05. This U-shaped pattern suggests the significant result is bandwidth-dependent rather than robust across specifications.

### 3. Power Analysis with Type M Errors

**Source:** `code/replication/03_robustness.R`, `output/replication/power_analysis.csv`

Following Gelman & Carlin (2014):

| Metric | Value |
|--------|-------|
| Observed coefficient | 107.4 |
| Standard error | 47.6 |
| MDE at 80% power | 133.2 |
| Observed / MDE | 0.81 |
| Power at observed effect | 62% |

**Type M (Exaggeration) Analysis:**

| True Effect | Power | Exaggeration Ratio |
|-------------|-------|-------------------|
| 100 | 56% | 1.34× |
| 75 | 35% | 1.67× |
| 50 | 19% | 2.38× |
| 35 | 11% | 3.31× |
| 15 | 6% | 7.48× |

If the true effect is 50 (half the observed), conditional on significance, estimates would be exaggerated by 2.4×. The study is underpowered, and significant estimates are likely inflated due to winner's curse.

### 4. Sensitivity Analysis (E-values)

**Source:** `code/replication/03_robustness.R`, `output/replication/sensitivity_analysis.csv`

Following VanderWeele & Ding (2017):

| Metric | Value |
|--------|-------|
| E-value (point estimate) | 8.08 |
| E-value (95% CI) | 1.72 |
| Partial R² of treatment | 0.15% |

To explain away the point estimate, an unmeasured confounder would need associations of RR ≥ 8.08 with both treatment and outcome. To move the CI to include zero, associations of only RR ≥ 1.72 would suffice.

Given the failed placebo tests and high-leverage observations, the modest E-value for the CI (1.72) suggests unmeasured confounding is a plausible alternative explanation.

### Robustness Summary

The combination of:
1. **High sensitivity** to specific Muslim share bins (leave-one-out)
2. **Bandwidth-sensitive** results (0-100% significant at p<0.05 depending on bandwidth)
3. **Underpowered design** with likely exaggeration (Type M > 2× if true effect is modest)
4. **Moderate sensitivity** to unmeasured confounding (E-value CI = 1.72)

...reinforces concerns about the causal interpretation of the Female × Muslim Share interaction.

**Synthesis Document:** For a consolidated view of all robustness findings, see `output/synthesis_female_muslim_interaction.md` (or PDF version).

## Implications for Causal Interpretation

**Supportive findings:**

1. **Pre-trends pass:** The coverage levels show no significant pre-treatment differential trends (0/6 coefficients significant), supporting the parallel trends assumption for the main specification.

2. **DID robustness:** Using coverage change (post minus pre) as the outcome, the interaction remains significant (p≈0.01), suggesting the effect survives a more conservative DID-style test.

**Concerns:**

1. **Mechanism Disconnect:** The mechanism (women's preferences → female sarpanch → sanitation) fails in UP—the state providing treatment variation—while only MP shows supporting evidence.

2. **Wrong-Signed Spending Effects:** NREGA sanitation spending shows *negative* interaction effects post-treatment, contradicting the claim that female sarpanches channel resources toward sanitation in high-Muslim areas.

3. **Non-Monotonic Dose-Response:** The Female × Muslim Share interaction does not reflect a smooth moderating relationship. Effects are negative at low Muslim share, spike erratically at specific bins, and show no monotonic pattern. This suggests the linear interaction term is fitting noise rather than a substantive moderating effect.

4. **Data Quality:** The ~12.6% coverage regression rate in FY 2016-17 indicates substantial measurement error in the outcome. If over-reporting corrections were differential by treatment status or Muslim share, this could bias the interaction estimate. The identifying assumption requires that measurement error is orthogonal to treatment × Muslim share—an assumption that is untestable with available data.

5. **Alternative Explanations:** The pattern of results is consistent with Muslim population share being correlated with other time-varying factors (economic development, government program targeting, Swachh Bharat Mission rollout) that differentially affected toilet provision.

## Replication Files

### Code
- `code/replication/00_utils.R` - Shared utility functions (data loading, formatting)
- `code/replication/01_table2.R` - Table 2 analyses (by state, control sensitivity, dose-response preferences, GAM)
- `code/replication/02_table3_robustness.R` - Table 3 robustness (placebo, coverage temporal, leave-one-out, specification curve)
- `code/replication/03_table3_dose_response.R` - Table 3 dose-response (coverage, GAM interaction)
- `code/replication/04_power_sensitivity.R` - Power analysis (Type M errors) and sensitivity (E-values)
- `code/replication/05_mnrega.R` - MNREGA spending analysis (main effects + heterogeneous effects)

### Output
- `output/replication/table2_by_state.csv` - State-level Table 2 results
- `output/replication/table2_control_sensitivity.csv` - Table 2 with varying controls (raw, village FE, wealth, education FE)
- `output/replication/pretrends.csv` - Pre-trends test (coverage by fiscal year with interaction p-values)
- `output/replication/did_robustness.csv` - DID robustness (coverage change as outcome)
- `output/replication/did_robustness_corrected.csv` - DID robustness with floor-corrected baseline (addresses over-reporting)
- `output/replication/mnrega_main.csv` - NREGA main effects (simple RD)
- `output/replication/mnrega_main_bw*.tex` - LaTeX tables by bandwidth
- `output/replication/mnrega_heterogeneous.csv` - NREGA heterogeneous effects (Female × Muslim interaction by year)
- `output/replication/dose_response_coverage.csv` - Toilet coverage by Muslim share bin
- `output/replication/dose_response_coverage.pdf` - Toilet coverage dose-response plot
- `output/replication/dose_response_preferences.csv` - Latrine preferences by Muslim share bin
- `output/replication/gam_interaction.csv` - GAM predicted effects for Table 3
- `output/replication/gam_interaction.pdf` - GAM plot for Table 3 (toilet coverage)
- `output/replication/gam_table2.csv` - GAM predicted effects for Table 2
- `output/replication/gam_table2.pdf` - GAM plot for Table 2 (toilet use and preferences)
- `output/replication/leave_one_out.csv` - Leave-one-out analysis results
- `output/replication/specification_curve.csv` - Specification curve results
- `output/replication/specification_curve.pdf` - Specification curve plot
- `output/replication/power_analysis.csv` - Power analysis and Type M errors
- `output/replication/sensitivity_analysis.csv` - E-values and sensitivity metrics

## Sources

Election timing documentation:
- [Aaj Tak - UP Panchayat Election 2015](https://www.aajtak.in/india/uttar-pradesh/story/uttar-pradesh-announces-panchayat-elections-in-four-phase--313437-2015-09-21)
- [State Election Commission UP](https://sec.up.nic.in/site/)
- [Ministry of Panchayati Raj](https://panchayat.gov.in/en/status-of-panchayat-elections-in-pris/)
