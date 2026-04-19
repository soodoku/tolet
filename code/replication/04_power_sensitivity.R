# Power and Sensitivity Analyses
# Power analysis (Type M errors), E-values/sensitivity

library(ivreg)
library(sandwich)

source("code/replication/00_utils.R")

# =============================================================================
# SECTION 1: POWER ANALYSIS (Type M Errors)
# =============================================================================

run_power_analysis <- function() {
  df <- load_gp_data(bw = 0.10) %>%
    filter(!is.na(coverage16_17), !is.na(muslim_share), !is.na(femalereservation))

  formula_str <- "coverage16_17 ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim"

  model <- ivreg(as.formula(formula_str), data = df, weights = weight)
  vcov_robust <- vcovHC(model, type = "HC1")

  coef_obs <- coef(model)["female_x_muslim"]
  se_obs <- sqrt(vcov_robust["female_x_muslim", "female_x_muslim"])
  z_obs <- coef_obs / se_obs
  pval_obs <- 2 * (1 - pnorm(abs(z_obs)))

  cat("============================================================\n")
  cat("Power Analysis: Type M and Type S Errors\n")
  cat("============================================================\n\n")

  cat("Observed Results:\n")
  cat(sprintf("  Coefficient: %.1f\n", coef_obs))
  cat(sprintf("  Standard Error: %.1f\n", se_obs))
  cat(sprintf("  z-statistic: %.2f\n", z_obs))
  cat(sprintf("  p-value: %.4f\n\n", pval_obs))

  alpha <- 0.05
  z_crit <- qnorm(1 - alpha / 2)
  z_power <- qnorm(0.80)

  mde_80 <- (z_crit + z_power) * se_obs
  power_at_obs <- pnorm(abs(coef_obs) / se_obs - z_crit) + pnorm(-abs(coef_obs) / se_obs - z_crit)

  cat(sprintf("Minimum Detectable Effect (80%% power): %.1f\n", mde_80))
  cat(sprintf("Observed effect / MDE: %.2f\n", coef_obs / mde_80))
  cat(sprintf("Power at observed effect size: %.0f%%\n\n", 100 * power_at_obs))

  calc_type_m <- function(true_effect, se, alpha = 0.05) {
    z_crit <- qnorm(1 - alpha / 2)
    n_sim <- 100000
    estimates <- rnorm(n_sim, mean = true_effect, sd = se)
    significant <- abs(estimates) > z_crit * se

    if (sum(significant) == 0) return(list(power = 0, type_m = NA, type_s = NA))

    sig_estimates <- estimates[significant]
    list(
      power = mean(significant),
      type_m = mean(abs(sig_estimates)) / abs(true_effect),
      type_s = mean(sig_estimates * sign(true_effect) < 0)
    )
  }

  cat("============================================================\n")
  cat("Type M Error Analysis by Hypothetical True Effect\n")
  cat("============================================================\n\n")

  cat("True Effect | Power  | Type M (Exaggeration) | Type S (Sign Error)\n")
  cat(paste(rep("-", 65), collapse = ""), "\n")

  results <- data.frame()
  true_effects <- c(100, 75, 50, 35, 25, 15, 10, 5)

  for (true_eff in true_effects) {
    res <- calc_type_m(true_eff, se_obs)
    cat(sprintf("    %3d     | %5.1f%% |         %.2f          |       %.1f%%\n",
                true_eff, 100 * res$power, res$type_m, 100 * res$type_s))

    results <- rbind(results, data.frame(
      true_effect = true_eff, se = se_obs, power = res$power,
      type_m = res$type_m, type_s = res$type_s, stringsAsFactors = FALSE
    ))
  }

  results <- rbind(
    data.frame(
      true_effect = NA, se = se_obs, power = NA, type_m = NA, type_s = NA,
      observed_coef = coef_obs, observed_se = se_obs, observed_pval = pval_obs,
      mde_80 = mde_80, power_at_observed = power_at_obs, stringsAsFactors = FALSE
    ),
    data.frame(
      true_effect = results$true_effect, se = results$se, power = results$power,
      type_m = results$type_m, type_s = results$type_s,
      observed_coef = NA, observed_se = NA, observed_pval = NA,
      mde_80 = NA, power_at_observed = NA, stringsAsFactors = FALSE
    )
  )

  write.csv(results, "output/replication/power_analysis.csv", row.names = FALSE)
  cat("\nSaved: output/replication/power_analysis.csv\n")
  results
}

# =============================================================================
# SECTION 2: SENSITIVITY ANALYSIS (E-values)
# =============================================================================

run_sensitivity_analysis <- function() {
  df <- load_gp_data(bw = 0.10) %>%
    filter(!is.na(coverage16_17), !is.na(muslim_share), !is.na(femalereservation))

  formula_str <- "coverage16_17 ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim"

  model <- ivreg(as.formula(formula_str), data = df, weights = weight)
  vcov_robust <- vcovHC(model, type = "HC1")

  coef_obs <- coef(model)["female_x_muslim"]
  se_obs <- sqrt(vcov_robust["female_x_muslim", "female_x_muslim"])
  ci_lo <- coef_obs - 1.96 * se_obs
  ci_hi <- coef_obs + 1.96 * se_obs

  outcome_sd <- sd(df$coverage16_17, na.rm = TRUE)

  d_obs <- coef_obs / outcome_sd
  d_ci_lo <- ci_lo / outcome_sd

  convert_d_to_rr <- function(d) exp(0.91 * d)

  rr_obs <- convert_d_to_rr(d_obs)
  rr_ci_lo <- convert_d_to_rr(d_ci_lo)

  calc_evalue <- function(rr) {
    if (rr < 1) rr <- 1 / rr
    rr + sqrt(rr * (rr - 1))
  }

  evalue_point <- calc_evalue(rr_obs)
  evalue_ci <- if (rr_ci_lo > 1) calc_evalue(rr_ci_lo) else 1.0

  cat("============================================================\n")
  cat("Sensitivity Analysis: E-values for Unmeasured Confounding\n")
  cat("============================================================\n\n")

  cat("Observed Results:\n")
  cat(sprintf("  Coefficient: %.1f pp\n", coef_obs))
  cat(sprintf("  95%% CI: [%.1f, %.1f]\n", ci_lo, ci_hi))
  cat(sprintf("  Standard Error: %.1f\n", se_obs))
  cat(sprintf("  Outcome SD: %.1f\n\n", outcome_sd))

  cat("Effect Size Conversion:\n")
  cat(sprintf("  Cohen's d (point): %.2f\n", d_obs))
  cat(sprintf("  Cohen's d (CI lower): %.2f\n", d_ci_lo))
  cat(sprintf("  Approximate RR (point): %.2f\n", rr_obs))
  cat(sprintf("  Approximate RR (CI lower): %.2f\n\n", rr_ci_lo))

  cat("============================================================\n")
  cat("E-values\n")
  cat("============================================================\n\n")
  cat(sprintf("E-value (point estimate): %.2f\n", evalue_point))
  cat(sprintf("E-value (95%% CI lower bound): %.2f\n\n", evalue_ci))

  cat("Interpretation:\n")
  cat(sprintf("To explain away the POINT ESTIMATE, an unmeasured confounder\n"))
  cat(sprintf("would need to be associated with BOTH the treatment AND outcome\n"))
  cat(sprintf("by a risk ratio of at least %.2f each.\n\n", evalue_point))

  m_reduced <- lm(coverage16_17 ~ runningvar2_norm_std + muslim_share, data = df, weights = weight)
  m_full <- lm(coverage16_17 ~ femalereservation + muslim_share + femalereservation:muslim_share +
                 runningvar2_norm_std, data = df, weights = weight)

  r2_full <- summary(m_full)$r.squared
  r2_reduced <- summary(m_reduced)$r.squared
  partial_r2 <- (r2_full - r2_reduced) / (1 - r2_reduced)

  cat("============================================================\n")
  cat("Robustness Assessment via Partial R-squared\n")
  cat("============================================================\n\n")
  cat(sprintf("R-squared (full model): %.4f\n", r2_full))
  cat(sprintf("R-squared (reduced, no treatment): %.4f\n", r2_reduced))
  cat(sprintf("Partial R-squared of treatment: %.4f (%.2f%%)\n\n", partial_r2, 100 * partial_r2))

  results <- data.frame(
    metric = c("Coefficient", "SE", "CI_lower", "CI_upper", "Outcome_SD",
               "Cohens_d", "Approximate_RR", "E_value_point", "E_value_CI", "Partial_R2_treatment"),
    value = c(coef_obs, se_obs, ci_lo, ci_hi, outcome_sd,
              d_obs, rr_obs, evalue_point, evalue_ci, partial_r2),
    stringsAsFactors = FALSE
  )

  write.csv(results, "output/replication/sensitivity_analysis.csv", row.names = FALSE)
  cat("Saved: output/replication/sensitivity_analysis.csv\n")
  results
}

# =============================================================================
# RUN ALL
# =============================================================================

if (sys.nframe() == 0) {
  cat("=== Running Power and Sensitivity Analyses ===\n\n")

  cat("--- Power Analysis ---\n")
  run_power_analysis()

  cat("\n--- Sensitivity Analysis ---\n")
  run_sensitivity_analysis()

  cat("\n=== All power and sensitivity analyses complete ===\n")
}
