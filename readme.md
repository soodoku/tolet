# Replication Analysis: When Do Gender Quotas Change Policy?

This documents findings from our replication and investigation of Chaturvedi, Das & Mahajan (2023) "When Do Gender Quotas Change Policy? Evidence from Household Toilet Provision in India."

## Key Concerns

### 1. Table 3 Placebo Test Failure

**Table C11 Panel B** from the paper runs the heterogeneous RD specification (Muslim share × female reservation) on pre-treatment toilet coverage outcomes. The results reveal a serious concern:

| Fiscal Year | BW=0.10 | BW=0.075 | BW=0.05 | Expected |
|-------------|---------|----------|---------|----------|
| **2013-14** | 0.470 | 0.675 | 0.803 | ✓ No effect (pre-treatment) |
| **2014-15** | **1.726***| **2.957***| **5.215***| ✗ Significant effect |
| **2015-16** | 0.600 | -0.480 | -1.235 | Mixed (post-treatment) |

**The Problem:** FY 2014-15 (April 2014 - March 2015) is *before* the UP gram panchayat elections, yet shows highly significant effects.

### 2. Election Timing

Based on web searches:
- UP gram panchayat elections were held in **October 2015** (four phases: October 9, 13, 17, and 29)
- Vote counting occurred around November 1, 2015

**Timeline:**
```
FY 2013-14: Apr 2013 - Mar 2014  → Pre-treatment ✓
FY 2014-15: Apr 2014 - Mar 2015  → Pre-treatment ✓
Elections:  October 2015          → Treatment
FY 2015-16: Apr 2015 - Mar 2016  → Partially post-treatment
FY 2016-17: Apr 2016 - Mar 2017  → Post-treatment ✓
```

The significant effect on FY 2014-15 toilet coverage cannot be explained by the treatment (female reservation), since the elections had not yet occurred.

### 3. Possible Explanations

1. **Pre-existing differential trends**: High-Muslim-share GPs may have been on different trajectories even before female reservation was implemented

2. **Omitted variable bias**: Muslim share may be correlated with other time-varying factors affecting toilet provision

3. **Measurement/coding issues**: The coverage variables may not cleanly correspond to fiscal years

### 4. Our R Replication Results

We replicated the Table C11 Panel B analysis in R (`code/table_3_placebo.R`):

| Fiscal Year | BW=0.10 | BW=0.075 | BW=0.05 |
|-------------|---------|----------|---------|
| 2013-14 | 0.18 | 0.16 | 0.74 |
| 2014-15 | **2.64***| **3.35***| **3.36**|
| 2015-16 | 0.40 | 0.03 | -1.57 |

The R results confirm the Stata findings: significant effects on FY 2014-15 but not on FY 2013-14.

### 5. Table 2 State Heterogeneity Issues

The pooled survey results in Table 2 mask substantial state-level heterogeneity:

- **Toilet use** (Models 1-2): Female effect consistent across states, but Muslim share × Female interaction varies (near-zero in Bihar, marginally significant in UP)
- **Latrine preferences** (Models 3-5): Results driven primarily by Madhya Pradesh; UP and Bihar show different patterns

See `output/table2_by_state.csv` for full state-level results.

## Implications

The placebo test failure for FY 2014-15 raises questions about the causal interpretation of Table 3's Muslim share heterogeneity results. If the heterogeneous RD specification detects "effects" in pre-treatment periods, then the post-treatment effects may also reflect pre-existing differential trends rather than the causal impact of female reservation.

## Files

- `code/table_3_placebo.R`: R replication of Table C11 Panel B
- `output/table3_placebo.csv`: Placebo test results
- `output/table3_placebo.tex`: LaTeX table
- `code/table_2_by_state.R`: Table 2 state heterogeneity analysis
- `output/table2_by_state.csv`: State-level results

## Sources

Election timing information:
- [Aaj Tak - UP Panchayat Election 2015](https://www.aajtak.in/india/uttar-pradesh/story/uttar-pradesh-announces-panchayat-elections-in-four-phase--313437-2015-09-21)
- [State Election Commission UP](https://sec.up.nic.in/site/)
- [Ministry of Panchayati Raj - Status of Elections](https://panchayat.gov.in/en/status-of-panchayat-elections-in-pris/)
