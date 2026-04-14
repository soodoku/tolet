# Table 3 Placebo Test: Heterogeneous RD on Pre-Treatment Outcomes
# This replicates Table C11 Panel B from the paper using R
# Testing whether the Muslim share heterogeneity specification shows effects on pre-treatment outcomes

library(haven)
library(dplyr)
library(ivreg)
library(sandwich)

# Load GP-level data
panel <- read_dta("data/SBM_panel.dta")
gp_data <- read_dta("data/final election caste sbm.dta")

# Prepare the data similar to Stata code in table_c11_covariates_balance_interaction.do
# Extract muslim_share from panel data (post==1 version)
muslim_share_data <- panel %>%
  filter(post == 1) %>%
  group_by(eleid) %>%
  summarise(muslim_share = first(muslim_share), .groups = "drop")

# Get femalereservation from panel data (post==1 version)
femres_data <- panel %>%
  filter(post == 1) %>%
  group_by(eleid) %>%
  summarise(femalereservation = first(femalereservation), .groups = "drop")

# Merge with GP data
df <- gp_data %>%
  left_join(muslim_share_data, by = "eleid") %>%
  left_join(femres_data, by = "eleid")

# Create interaction variables for 2SLS
df <- df %>%
  mutate(
    female_x_muslim = femalereservation * muslim_share,
    inst_x_muslim = femaleinstrument * muslim_share,
    running_x_inst = runningvar2_norm_std * femaleinstrument,
    running_x_muslim = runningvar2_norm_std * muslim_share,
    running_x_inst_x_muslim = runningvar2_norm_std * femaleinstrument * muslim_share
  )

# Run placebo tests on pre-treatment outcomes
outcomes <- c("covered_13_14_to_uncovered", "covered_14_15_to_uncovered", "covered_15_16_to_uncovered")
bandwidths <- c(0.10, 0.075, 0.05)

# Store results
results_list <- vector("list", length(outcomes) * length(bandwidths))
idx <- 0

for (outcome in outcomes) {
  for (bw in bandwidths) {
    idx <- idx + 1

    # Filter data for this bandwidth and outcome
    sample_data <- df %>%
      filter(abs(runningvar2_norm_std) <= bw) %>%
      filter(!is.na(.data[[outcome]])) %>%
      filter(!is.na(muslim_share)) %>%
      filter(!is.na(femalereservation))

    # Create triangular kernel weights
    sample_data <- sample_data %>%
      mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)

    n_obs <- nrow(sample_data)

    # 2SLS specification matching Stata
    formula_str <- sprintf(
      "%s ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim",
      outcome
    )

    result <- tryCatch({
      model <- ivreg(as.formula(formula_str), data = sample_data, weights = weight)
      vcov_robust <- vcovHC(model, type = "HC1")
      coef_est <- coef(model)
      se_robust <- sqrt(diag(vcov_robust))

      list(
        bandwidth = bw,
        outcome = outcome,
        n = n_obs,
        coef_female_res = coef_est["femalereservation"],
        se_female_res = se_robust["femalereservation"],
        coef_interaction = coef_est["female_x_muslim"],
        se_interaction = se_robust["female_x_muslim"],
        coef_triple = coef_est["running_x_inst_x_muslim"],
        se_triple = se_robust["running_x_inst_x_muslim"],
        error = NA
      )
    }, error = function(e) {
      list(
        bandwidth = bw,
        outcome = outcome,
        n = n_obs,
        coef_female_res = NA,
        se_female_res = NA,
        coef_interaction = NA,
        se_interaction = NA,
        coef_triple = NA,
        se_triple = NA,
        error = e$message
      )
    })

    results_list[[idx]] <- result
  }
}

# Convert to data frame
results_df <- do.call(rbind, lapply(results_list, function(x) {
  data.frame(
    Outcome = x$outcome,
    Bandwidth = x$bandwidth,
    N = x$n,
    Coef_FemaleRes = round(as.numeric(x$coef_female_res), 4),
    SE_FemaleRes = round(as.numeric(x$se_female_res), 4),
    Coef_Interaction = round(as.numeric(x$coef_interaction), 4),
    SE_Interaction = round(as.numeric(x$se_interaction), 4),
    Coef_Triple = round(as.numeric(x$coef_triple), 4),
    SE_Triple = round(as.numeric(x$se_triple), 4),
    stringsAsFactors = FALSE
  )
}))

# Add significance stars
add_stars <- function(coef, se) {
  if (is.na(coef) || is.na(se)) return(NA)
  pval <- 2 * (1 - pnorm(abs(coef / se)))
  stars <- ""
  if (pval < 0.01) stars <- "***"
  else if (pval < 0.05) stars <- "**"
  else if (pval < 0.1) stars <- "*"
  sprintf("%.4f%s", coef, stars)
}

results_df$Triple_Formatted <- mapply(add_stars, results_df$Coef_Triple, results_df$SE_Triple)

# Print results
cat("\n============================================\n")
cat("Table 3 Placebo Test: Pre-Treatment Outcomes\n")
cat("============================================\n\n")

cat("Triple Interaction Coefficient (femaleinstrument x running x muslim_share):\n")
cat("This is the reduced-form coefficient that should be zero for pre-treatment outcomes.\n\n")

for (outcome in outcomes) {
  cat(sprintf("Outcome: %s\n", outcome))
  subset_res <- results_df[results_df$Outcome == outcome, ]
  for (i in 1:nrow(subset_res)) {
    cat(sprintf("  BW=%.3f: Triple=%-12s  (SE=%.4f)  N=%d\n",
                subset_res$Bandwidth[i],
                subset_res$Triple_Formatted[i],
                subset_res$SE_Triple[i],
                subset_res$N[i]))
  }
  cat("\n")
}

cat("============================================\n")
cat("Comparison with Stata results (pretreatmentoutcome_het.txt):\n")
cat("  Stata covered_14_15: BW=0.10: 1.726***, BW=0.075: 2.957***, BW=0.05: 5.215***\n")
cat("============================================\n\n")

cat("Key Finding:\n")
cat("- covered_13_14: No significant triple interaction (as expected for pre-treatment)\n")
cat("- covered_14_15: SIGNIFICANT triple interaction - THIS IS PROBLEMATIC\n")
cat("  FY 2014-15 runs April 2014 - March 2015\n")
cat("  UP GP elections were held in October 2015\n")
cat("  So 2014-15 should be pre-treatment, yet shows significant effects\n")
cat("- covered_15_16: Not significant (post-treatment period)\n")
cat("============================================\n")

# Save CSV
write.csv(results_df, "output/table3_placebo.csv", row.names = FALSE)
cat("\nSaved results to output/table3_placebo.csv\n")

# Generate LaTeX table
latex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Placebo Test: Heterogeneous RD on Pre-Treatment Outcomes (Table C11 Panel B)}",
  "\\label{tab:placebo_het}",
  "\\small",
  "\\begin{tabular}{lccc}",
  "\\hline\\hline",
  " & BW=0.10 & BW=0.075 & BW=0.05 \\\\",
  "\\hline",
  "\\multicolumn{4}{l}{\\textbf{Panel A: FY 2013-14 (Pre-treatment)}} \\\\"
)

# FY 2013-14 results
subset_1314 <- results_df[results_df$Outcome == "covered_13_14_to_uncovered", ]
latex_lines <- c(latex_lines,
  sprintf("Female Reservation & %.3f & %.3f & %.3f \\\\",
          subset_1314$Coef_FemaleRes[1], subset_1314$Coef_FemaleRes[2], subset_1314$Coef_FemaleRes[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1314$SE_FemaleRes[1], subset_1314$SE_FemaleRes[2], subset_1314$SE_FemaleRes[3]),
  sprintf("Female Res $\\times$ Muslim Share & %.3f & %.3f & %.3f \\\\",
          subset_1314$Coef_Interaction[1], subset_1314$Coef_Interaction[2], subset_1314$Coef_Interaction[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1314$SE_Interaction[1], subset_1314$SE_Interaction[2], subset_1314$SE_Interaction[3]),
  sprintf("Triple Interaction (RF) & %s & %s & %s \\\\",
          subset_1314$Triple_Formatted[1], subset_1314$Triple_Formatted[2], subset_1314$Triple_Formatted[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1314$SE_Triple[1], subset_1314$SE_Triple[2], subset_1314$SE_Triple[3]),
  sprintf("N & %s & %s & %s \\\\",
          format(subset_1314$N[1], big.mark = ","),
          format(subset_1314$N[2], big.mark = ","),
          format(subset_1314$N[3], big.mark = ",")),
  "\\hline",
  "\\multicolumn{4}{l}{\\textbf{Panel B: FY 2014-15 (Should be Pre-treatment)}} \\\\"
)

# FY 2014-15 results
subset_1415 <- results_df[results_df$Outcome == "covered_14_15_to_uncovered", ]
latex_lines <- c(latex_lines,
  sprintf("Female Reservation & %.3f & %.3f & %.3f \\\\",
          subset_1415$Coef_FemaleRes[1], subset_1415$Coef_FemaleRes[2], subset_1415$Coef_FemaleRes[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1415$SE_FemaleRes[1], subset_1415$SE_FemaleRes[2], subset_1415$SE_FemaleRes[3]),
  sprintf("Female Res $\\times$ Muslim Share & %.3f & %.3f & %.3f \\\\",
          subset_1415$Coef_Interaction[1], subset_1415$Coef_Interaction[2], subset_1415$Coef_Interaction[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1415$SE_Interaction[1], subset_1415$SE_Interaction[2], subset_1415$SE_Interaction[3]),
  sprintf("Triple Interaction (RF) & %s & %s & %s \\\\",
          subset_1415$Triple_Formatted[1], subset_1415$Triple_Formatted[2], subset_1415$Triple_Formatted[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1415$SE_Triple[1], subset_1415$SE_Triple[2], subset_1415$SE_Triple[3]),
  sprintf("N & %s & %s & %s \\\\",
          format(subset_1415$N[1], big.mark = ","),
          format(subset_1415$N[2], big.mark = ","),
          format(subset_1415$N[3], big.mark = ",")),
  "\\hline",
  "\\multicolumn{4}{l}{\\textbf{Panel C: FY 2015-16 (Post-treatment)}} \\\\"
)

# FY 2015-16 results
subset_1516 <- results_df[results_df$Outcome == "covered_15_16_to_uncovered", ]
latex_lines <- c(latex_lines,
  sprintf("Female Reservation & %.3f & %.3f & %.3f \\\\",
          subset_1516$Coef_FemaleRes[1], subset_1516$Coef_FemaleRes[2], subset_1516$Coef_FemaleRes[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1516$SE_FemaleRes[1], subset_1516$SE_FemaleRes[2], subset_1516$SE_FemaleRes[3]),
  sprintf("Female Res $\\times$ Muslim Share & %.3f & %.3f & %.3f \\\\",
          subset_1516$Coef_Interaction[1], subset_1516$Coef_Interaction[2], subset_1516$Coef_Interaction[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1516$SE_Interaction[1], subset_1516$SE_Interaction[2], subset_1516$SE_Interaction[3]),
  sprintf("Triple Interaction (RF) & %s & %s & %s \\\\",
          subset_1516$Triple_Formatted[1], subset_1516$Triple_Formatted[2], subset_1516$Triple_Formatted[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          subset_1516$SE_Triple[1], subset_1516$SE_Triple[2], subset_1516$SE_Triple[3]),
  sprintf("N & %s & %s & %s \\\\",
          format(subset_1516$N[1], big.mark = ","),
          format(subset_1516$N[2], big.mark = ","),
          format(subset_1516$N[3], big.mark = ",")),
  "\\hline\\hline",
  "\\multicolumn{4}{l}{\\footnotesize Robust standard errors in parentheses. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\",
  "\\multicolumn{4}{l}{\\footnotesize Triple Interaction = Reduced-form coefficient on instrument $\\times$ running $\\times$ muslim share.} \\\\",
  "\\multicolumn{4}{l}{\\footnotesize FY 2014-15 covers April 2014 - March 2015. UP GP elections held October 2015.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(latex_lines, "output/table3_placebo.tex")
cat("Saved LaTeX table to output/table3_placebo.tex\n")
