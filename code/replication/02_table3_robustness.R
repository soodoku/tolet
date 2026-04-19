# Table 3 Robustness Analyses
# Pre-trends test, leave-one-out, specification curve

library(ivreg)
library(sandwich)
library(ggplot2)

source("code/replication/00_utils.R")

# =============================================================================
# SECTION 1: PRE-TRENDS TEST
# Purpose: Check if Female × Muslim interaction exists in pre-treatment years
# If significant pre-treatment, the RD identification is compromised.
#
# Timeline:
#   coverage13_14: Apr 2013 - Mar 2014 (PRE)
#   coverage14_15: Apr 2014 - Mar 2015 (PRE)
#   coverage15_16: Apr 2015 - Mar 2016 (PARTIAL - elections Oct 2015)
#   coverage16_17: Apr 2016 - Mar 2017 (POST)
#   coverage17_18: Apr 2017 - Mar 2018 (POST)
#   coverage18_19: Apr 2018 - Mar 2019 (POST)
# =============================================================================

run_pretrends <- function() {
  df <- load_gp_data()

  run_het_2sls <- function(data, outcome_var, bw) {
    sample_data <- data %>%
      filter(abs(runningvar2_norm_std) <= bw) %>%
      filter(!is.na(.data[[outcome_var]]), !is.na(muslim_share), !is.na(femalereservation)) %>%
      filter(is.finite(.data[[outcome_var]])) %>%
      mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)

    if (nrow(sample_data) < 100) return(list(n = nrow(sample_data), coefs = NULL, ses = NULL))

    formula_str <- sprintf(
      "%s ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim",
      outcome_var
    )

    tryCatch({
      model <- ivreg(as.formula(formula_str), data = sample_data, weights = weight)
      vcov_robust <- vcovHC(model, type = "HC1")
      list(n = nrow(sample_data), coefs = coef(model), ses = sqrt(diag(vcov_robust)))
    }, error = function(e) {
      list(n = nrow(sample_data), coefs = NULL, ses = NULL)
    })
  }

  outcomes <- c("coverage13_14", "coverage14_15", "coverage15_16", "coverage16_17", "coverage17_18", "coverage18_19")
  periods <- c("Pre-treatment", "Pre-treatment", "Partial (elections Oct 2015)", "Post-treatment", "Post-treatment", "Post-treatment")
  bandwidths <- c(0.10, 0.075, 0.05)

  cat("============================================================\n")
  cat("Pre-Trends Test: Female × Muslim Interaction by Fiscal Year\n")
  cat("============================================================\n\n")
  cat("If interaction is significant PRE-TREATMENT, the RD is compromised.\n\n")

  csv_rows <- list()
  for (i in seq_along(outcomes)) {
    outcome <- outcomes[i]
    period <- periods[i]

    for (bw in bandwidths) {
      r <- run_het_2sls(df, outcome, bw)
      if (!is.null(r$coefs)) {
        coef_int <- r$coefs["female_x_muslim"]
        se_int <- r$ses["female_x_muslim"]
        t_stat <- coef_int / se_int
        pval <- 2 * (1 - pnorm(abs(t_stat)))

        csv_rows[[length(csv_rows) + 1]] <- data.frame(
          Outcome = outcome, Period = period, Bandwidth = bw, N = r$n,
          FemaleRes_Coef = round(as.numeric(r$coefs["femalereservation"]), 4),
          FemaleRes_SE = round(as.numeric(r$ses["femalereservation"]), 4),
          Interaction_Coef = round(as.numeric(coef_int), 4),
          Interaction_SE = round(as.numeric(se_int), 4),
          Interaction_pval = round(pval, 4),
          stringsAsFactors = FALSE
        )
      }
    }
  }

  csv_df <- do.call(rbind, csv_rows)

  cat("Fiscal Year    | Period          | BW=0.10        | BW=0.075       | BW=0.05\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")

  for (outcome in outcomes) {
    period <- periods[which(outcomes == outcome)]
    row_10 <- csv_df[csv_df$Outcome == outcome & csv_df$Bandwidth == 0.10, ]
    row_075 <- csv_df[csv_df$Outcome == outcome & csv_df$Bandwidth == 0.075, ]
    row_05 <- csv_df[csv_df$Outcome == outcome & csv_df$Bandwidth == 0.05, ]

    if (nrow(row_10) > 0 && nrow(row_075) > 0 && nrow(row_05) > 0) {
      sig_10 <- ifelse(row_10$Interaction_pval < 0.05, "*", "")
      sig_075 <- ifelse(row_075$Interaction_pval < 0.05, "*", "")
      sig_05 <- ifelse(row_05$Interaction_pval < 0.05, "*", "")

      cat(sprintf("%-14s | %-15s | %+6.1f (%4.1f)%s | %+6.1f (%4.1f)%s | %+6.1f (%4.1f)%s\n",
                  outcome, substr(period, 1, 15),
                  row_10$Interaction_Coef, row_10$Interaction_SE, sig_10,
                  row_075$Interaction_Coef, row_075$Interaction_SE, sig_075,
                  row_05$Interaction_Coef, row_05$Interaction_SE, sig_05))
    }
  }

  pre_rows <- csv_df[csv_df$Period == "Pre-treatment", ]
  sig_pre <- sum(pre_rows$Interaction_pval < 0.05)
  cat(sprintf("\n* = p < 0.05\n"))
  cat(sprintf("Pre-treatment coefficients significant at p<0.05: %d/%d\n", sig_pre, nrow(pre_rows)))

  if (sig_pre > 0) {
    cat("\nPROBLEM: Significant pre-treatment effects suggest the interaction\n")
    cat("existed before elections, compromising the RD identification.\n")
  }

  write.csv(csv_df, "output/replication/pretrends.csv", row.names = FALSE)
  cat("\nSaved: output/replication/pretrends.csv\n")
  csv_df
}

# =============================================================================
# SECTION 2: DID-STYLE ROBUSTNESS (Change as outcome)
# Purpose: Test if result holds when using coverage CHANGE (post - pre)
# instead of coverage levels
# =============================================================================

run_did_robustness <- function() {
  df <- load_gp_data()

  df <- df %>%
    mutate(coverage_change = coverage16_17 - coverage14_15)

  run_het_2sls <- function(data, outcome_var, bw) {
    sample_data <- data %>%
      filter(abs(runningvar2_norm_std) <= bw) %>%
      filter(!is.na(.data[[outcome_var]]), !is.na(muslim_share), !is.na(femalereservation)) %>%
      filter(is.finite(.data[[outcome_var]])) %>%
      mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)

    if (nrow(sample_data) < 100) return(NULL)

    formula_str <- sprintf(
      "%s ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim",
      outcome_var
    )

    tryCatch({
      model <- ivreg(as.formula(formula_str), data = sample_data, weights = weight)
      vcov_robust <- vcovHC(model, type = "HC1")
      coef_int <- coef(model)["female_x_muslim"]
      se_int <- sqrt(vcov_robust["female_x_muslim", "female_x_muslim"])
      list(
        n = nrow(sample_data),
        coef = coef_int,
        se = se_int,
        pval = 2 * (1 - pnorm(abs(coef_int / se_int)))
      )
    }, error = function(e) NULL)
  }

  cat("============================================================\n")
  cat("DID-Style Robustness: Coverage CHANGE as Outcome\n")
  cat("============================================================\n\n")
  cat("Outcome: coverage16_17 - coverage14_15 (post minus pre)\n")
  cat("This tests whether the interaction affects coverage GAINS,\n")
  cat("not just post-treatment levels.\n\n")

  bandwidths <- c(0.10, 0.075, 0.05)
  results <- list()

  cat("Bandwidth | N     | Female × Muslim | SE    | p-value\n")
  cat(paste(rep("-", 55), collapse = ""), "\n")

  for (bw in bandwidths) {
    r <- run_het_2sls(df, "coverage_change", bw)
    if (!is.null(r)) {
      sig <- ifelse(r$pval < 0.05, "*", "")
      cat(sprintf("  %.3f   | %5d | %+10.2f      | %5.2f | %.4f%s\n",
                  bw, r$n, r$coef, r$se, r$pval, sig))
      results[[length(results) + 1]] <- data.frame(
        Outcome = "coverage_change", Bandwidth = bw, N = r$n,
        Interaction_Coef = round(r$coef, 4),
        Interaction_SE = round(r$se, 4),
        Interaction_pval = round(r$pval, 4),
        stringsAsFactors = FALSE
      )
    }
  }

  results_df <- do.call(rbind, results)

  cat("\n* = p < 0.05\n")
  if (any(results_df$Interaction_pval < 0.05)) {
    cat("\nResult: Interaction SURVIVES with change outcome.\n")
  } else {
    cat("\nResult: Interaction does NOT survive with change outcome.\n")
  }

  write.csv(results_df, "output/replication/did_robustness.csv", row.names = FALSE)
  cat("Saved: output/replication/did_robustness.csv\n")
  results_df
}

# =============================================================================
# SECTION 2b: DID WITH MEASUREMENT-ERROR-CORRECTED BASELINE
# Purpose: Address over-reporting in SBM data by using floor correction.
# For pre-treatment years, take minimum of (that year, all later years up to 16-17)
# coverage14_15_corrected = min(coverage14_15, coverage15_16, coverage16_17)
# This identifies over-reporting: if a GP reported X toilets in 14-15 but only
# Y < X in 16-17, then X was over-reported.
# =============================================================================

run_did_corrected <- function() {
  df <- load_gp_data()

  df <- df %>%
    mutate(
      coverage_change = coverage16_17 - coverage14_15,
      cov14_corrected = pmin(coverage14_15, coverage15_16, coverage16_17, na.rm = TRUE),
      coverage_change_corrected = coverage16_17 - cov14_corrected
    )

  n_corrected <- sum(df$cov14_corrected < df$coverage14_15, na.rm = TRUE)
  n_total <- sum(!is.na(df$coverage14_15) & !is.na(df$cov14_corrected))
  pct_corrected <- 100 * n_corrected / n_total

  orig_mean <- mean(df$coverage14_15, na.rm = TRUE)
  corr_mean <- mean(df$cov14_corrected, na.rm = TRUE)

  run_het_2sls <- function(data, outcome_var, bw) {
    sample_data <- data %>%
      filter(abs(runningvar2_norm_std) <= bw) %>%
      filter(!is.na(.data[[outcome_var]]), !is.na(muslim_share), !is.na(femalereservation)) %>%
      filter(is.finite(.data[[outcome_var]])) %>%
      mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)

    if (nrow(sample_data) < 100) return(NULL)

    formula_str <- sprintf(
      "%s ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim",
      outcome_var
    )

    tryCatch({
      model <- ivreg(as.formula(formula_str), data = sample_data, weights = weight)
      vcov_robust <- vcovHC(model, type = "HC1")
      coef_int <- coef(model)["female_x_muslim"]
      se_int <- sqrt(vcov_robust["female_x_muslim", "female_x_muslim"])
      list(
        n = nrow(sample_data),
        coef = coef_int,
        se = se_int,
        pval = 2 * (1 - pnorm(abs(coef_int / se_int)))
      )
    }, error = function(e) NULL)
  }

  cat("============================================================\n")
  cat("DID with Measurement-Error-Corrected Baseline\n")
  cat("============================================================\n\n")
  cat("Floor correction: cov14_corrected = min(cov14_15, cov15_16, cov16_17)\n")
  cat("This identifies over-reporting by taking minimum across years.\n\n")
  cat(sprintf("Data Quality Check:\n"))
  cat(sprintf("  GPs with corrected baseline: %d / %d (%.1f%%)\n", n_corrected, n_total, pct_corrected))
  cat(sprintf("  Original FY14-15 mean: %.1f\n", orig_mean))
  cat(sprintf("  Corrected FY14-15 mean: %.1f\n", corr_mean))
  cat(sprintf("  Mean reduction: %.1f pp\n\n", orig_mean - corr_mean))

  bandwidths <- c(0.10, 0.075, 0.05)
  results_orig <- list()
  results_corr <- list()

  cat("Comparison: Original vs Corrected Baseline\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("            |      Original DID      |      Corrected DID      | Change\n")
  cat("Bandwidth   | Coef     SE     p-val  | Coef     SE     p-val   | in Coef\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")

  for (bw in bandwidths) {
    r_orig <- run_het_2sls(df, "coverage_change", bw)
    r_corr <- run_het_2sls(df, "coverage_change_corrected", bw)

    if (!is.null(r_orig) && !is.null(r_corr)) {
      sig_orig <- ifelse(r_orig$pval < 0.05, "*", "")
      sig_corr <- ifelse(r_corr$pval < 0.05, "*", "")
      change_pct <- 100 * (r_corr$coef - r_orig$coef) / abs(r_orig$coef)

      cat(sprintf("  %.3f     | %+6.1f  %5.1f  %.4f%s | %+6.1f  %5.1f  %.4f%s  | %+.1f%%\n",
                  bw, r_orig$coef, r_orig$se, r_orig$pval, sig_orig,
                  r_corr$coef, r_corr$se, r_corr$pval, sig_corr, change_pct))

      results_orig[[length(results_orig) + 1]] <- data.frame(
        Outcome = "coverage_change", Bandwidth = bw, N = r_orig$n,
        Interaction_Coef = round(r_orig$coef, 4),
        Interaction_SE = round(r_orig$se, 4),
        Interaction_pval = round(r_orig$pval, 4),
        stringsAsFactors = FALSE
      )

      results_corr[[length(results_corr) + 1]] <- data.frame(
        Outcome = "coverage_change_corrected", Bandwidth = bw, N = r_corr$n,
        Interaction_Coef = round(r_corr$coef, 4),
        Interaction_SE = round(r_corr$se, 4),
        Interaction_pval = round(r_corr$pval, 4),
        stringsAsFactors = FALSE
      )
    }
  }

  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("* = p < 0.05\n\n")

  results_corr_df <- do.call(rbind, results_corr)
  results_orig_df <- do.call(rbind, results_orig)

  cat("Interpretation:\n")
  if (nrow(results_corr_df) > 0 && nrow(results_orig_df) > 0) {
    coef_change <- results_corr_df$Interaction_Coef[1] - results_orig_df$Interaction_Coef[1]
    if (coef_change > 10) {
      cat("  Coefficient INCREASES: Over-reporting was higher in control group\n")
      cat("  (treatment effect was UNDERSTATED in original analysis)\n")
    } else if (coef_change < -10) {
      cat("  Coefficient DECREASES: Over-reporting was higher in treatment group\n")
      cat("  (treatment effect was OVERSTATED in original analysis)\n")
    } else {
      cat("  Coefficient is SIMILAR: Over-reporting was orthogonal to treatment\n")
      cat("  (measurement error did not bias the interaction estimate)\n")
    }
  }

  write.csv(results_corr_df, "output/replication/did_robustness_corrected.csv", row.names = FALSE)
  cat("\nSaved: output/replication/did_robustness_corrected.csv\n")

  results_corr_df
}

# =============================================================================
# SECTION 3: LEAVE-ONE-OUT (Jackknife Analysis)
# =============================================================================

run_leave_one_out <- function() {
  df <- load_gp_data(bw = 0.10) %>%
    filter(!is.na(coverage16_17), !is.na(muslim_share), !is.na(femalereservation)) %>%
    mutate(muslim_bin = cut(muslim_share,
                            breaks = seq(0, 1.01, by = 0.05),
                            include.lowest = TRUE, right = FALSE,
                            labels = sprintf("[%.2f, %.2f)", seq(0, 0.96, by = 0.05), seq(0.05, 1.01, by = 0.05))))

  run_2sls <- function(data) {
    formula_str <- "coverage16_17 ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim"

    tryCatch({
      model <- ivreg(as.formula(formula_str), data = data, weights = weight)
      vcov_robust <- vcovHC(model, type = "HC1")
      list(coef = coef(model)["female_x_muslim"],
           se = sqrt(vcov_robust["female_x_muslim", "female_x_muslim"]),
           n = nrow(data))
    }, error = function(e) list(coef = NA, se = NA, n = nrow(data)))
  }

  cat("============================================================\n")
  cat("Leave-One-Out Analysis: Female × Muslim Share Interaction\n")
  cat("============================================================\n\n")

  full_result <- run_2sls(df)
  cat(sprintf("Full sample: Coef = %.1f (SE = %.1f), N = %d\n\n",
              full_result$coef, full_result$se, full_result$n))

  bins <- sort(unique(df$muslim_bin[!is.na(df$muslim_bin)]))
  bin_counts <- table(df$muslim_bin)

  results <- data.frame(
    bin = "Full Sample", dropped_n = 0, remaining_n = full_result$n,
    coef = full_result$coef, se = full_result$se,
    change_from_full = 0, pct_change = 0, stringsAsFactors = FALSE
  )

  cat("Dropped Bin        | Dropped N | Remaining N | Coef    | SE     | Change  | % Change\n")
  cat(paste(rep("-", 85), collapse = ""), "\n")

  for (b in bins) {
    if (bin_counts[b] >= 10) {
      df_loo <- df %>% filter(muslim_bin != b)
      loo_result <- run_2sls(df_loo)

      if (!is.na(loo_result$coef)) {
        change <- loo_result$coef - full_result$coef
        pct_change <- 100 * change / full_result$coef

        cat(sprintf("%-18s | %9d | %11d | %7.1f | %6.1f | %+7.1f | %+6.1f%%\n",
                    as.character(b), as.numeric(bin_counts[b]), loo_result$n,
                    loo_result$coef, loo_result$se, change, pct_change))

        results <- rbind(results, data.frame(
          bin = as.character(b), dropped_n = as.numeric(bin_counts[b]),
          remaining_n = loo_result$n, coef = loo_result$coef, se = loo_result$se,
          change_from_full = change, pct_change = pct_change, stringsAsFactors = FALSE
        ))
      }
    }
  }

  write.csv(results, "output/replication/leave_one_out.csv", row.names = FALSE)
  cat("\nSaved: output/replication/leave_one_out.csv\n")
  results
}

# =============================================================================
# SECTION 4: SPECIFICATION CURVE (Multiverse Analysis)
# =============================================================================

run_specification_curve <- function() {
  df <- load_gp_data() %>%
    mutate(
      running_sq_x_inst = running_sq * femaleinstrument,
      running_sq_x_muslim = running_sq * muslim_share,
      district_factor = as.factor(district)
    )

  bandwidths <- c(0.05, 0.075, 0.10, 0.125, 0.15)
  functional_forms <- c("linear", "quadratic")
  covariate_sets <- c("none", "baseline", "demographics", "district_fe", "full")

  run_spec <- function(data, bw, form, cov_set) {
    sample_data <- data %>%
      filter(abs(runningvar2_norm_std) <= bw) %>%
      filter(!is.na(coverage16_17), !is.na(muslim_share), !is.na(femalereservation)) %>%
      filter(!is.na(district)) %>%
      mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)

    if (cov_set %in% c("baseline", "demographics", "full")) {
      sample_data <- sample_data %>% filter(!is.na(coverage14_15))
    }
    if (cov_set %in% c("demographics", "full")) {
      sample_data <- sample_data %>% filter(!is.na(tot_new), !is.na(sc_prop), !is.na(st_prop))
    }

    if (nrow(sample_data) < 50) return(NULL)

    n_clusters <- length(unique(sample_data$district))
    if (n_clusters < 10) return(NULL)

    base_exog <- "runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim"
    if (form == "quadratic") {
      base_exog <- paste0(base_exog, " + running_sq + running_sq_x_inst + running_sq_x_muslim")
    }

    cov_part <- switch(cov_set,
                       "none" = "",
                       "baseline" = " + coverage14_15",
                       "demographics" = " + coverage14_15 + tot_new + sc_prop + st_prop",
                       "district_fe" = " + district_factor",
                       "full" = " + coverage14_15 + tot_new + sc_prop + st_prop + district_factor")

    formula_str <- sprintf("coverage16_17 ~ femalereservation + female_x_muslim + %s%s | %s%s + femaleinstrument + inst_x_muslim",
                           base_exog, cov_part, base_exog, cov_part)

    tryCatch({
      model <- ivreg(as.formula(formula_str), data = sample_data, weights = weight)
      vcov_cl <- vcovCL(model, cluster = sample_data$district, type = "HC1")
      coef_int <- coef(model)["female_x_muslim"]
      se_cl <- sqrt(vcov_cl["female_x_muslim", "female_x_muslim"])
      t_stat <- coef_int / se_cl
      df <- n_clusters - 1
      pval <- 2 * (1 - pt(abs(t_stat), df = df))

      list(
        coef = coef_int, se = se_cl, pval = pval,
        ci_lower = coef_int - qt(0.975, df) * se_cl,
        ci_upper = coef_int + qt(0.975, df) * se_cl,
        n = nrow(sample_data), n_clusters = n_clusters,
        sig_05 = pval < 0.05, sig_10 = pval < 0.10
      )
    }, error = function(e) NULL)
  }

  cat("============================================================\n")
  cat("Specification Curve Analysis\n")
  cat("Outcome: coverage16_17 (post-treatment)\n")
  cat("Inference: Cluster-robust SEs (district-level)\n")
  cat("============================================================\n\n")

  results <- data.frame()
  spec_id <- 0
  total_specs <- length(bandwidths) * length(functional_forms) * length(covariate_sets)

  for (bw in bandwidths) {
    for (form in functional_forms) {
      for (cov_set in covariate_sets) {
        spec_id <- spec_id + 1
        cat(sprintf("\rRunning specification %d/%d...", spec_id, total_specs))
        flush.console()

        result <- run_spec(df, bw, form, cov_set)

        if (!is.null(result)) {
          results <- rbind(results, data.frame(
            spec_id = spec_id, bandwidth = bw, functional_form = form, covariate_set = cov_set,
            coef = result$coef, se = result$se, pval = result$pval,
            ci_lower = result$ci_lower, ci_upper = result$ci_upper,
            n = result$n, n_clusters = result$n_clusters,
            sig_05 = result$sig_05, sig_10 = result$sig_10, stringsAsFactors = FALSE
          ))
        }
      }
    }
  }
  cat("\n\n")

  results <- results[order(results$coef), ]
  results$rank <- 1:nrow(results)

  cat(sprintf("Total specifications: %d\n", nrow(results)))
  cat(sprintf("Significant at p < 0.05: %d (%.0f%%)\n", sum(results$sig_05), 100 * mean(results$sig_05)))
  cat(sprintf("Significant at p < 0.10: %d (%.0f%%)\n\n", sum(results$sig_10), 100 * mean(results$sig_10)))

  cat("By bandwidth (p < 0.05):\n")
  for (b in bandwidths) {
    subset <- results[results$bandwidth == b, ]
    if (nrow(subset) > 0) {
      cat(sprintf("  BW = %.3f: %d/%d significant (%.0f%%)\n",
                  b, sum(subset$sig_05), nrow(subset), 100 * mean(subset$sig_05)))
    }
  }

  write.csv(results, "output/replication/specification_curve.csv", row.names = FALSE)
  cat("\nSaved: output/replication/specification_curve.csv\n")

  p <- ggplot(results, aes(x = rank, y = coef)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper, color = sig_05), width = 0, alpha = 0.5) +
    geom_point(aes(color = sig_05, shape = covariate_set), size = 2) +
    scale_color_manual(values = c("FALSE" = "gray50", "TRUE" = "red"),
                       labels = c("FALSE" = "p >= 0.05", "TRUE" = "p < 0.05"), name = "Significance") +
    scale_shape_manual(values = c("none" = 16, "baseline" = 17, "demographics" = 15,
                                  "district_fe" = 18, "full" = 8), name = "Covariates") +
    labs(x = "Specification (ranked by coefficient)", y = "Female × Muslim Share Coefficient",
         title = "Specification Curve: Multiverse Analysis",
         subtitle = sprintf("%d specifications; %d (%.0f%%) significant at p < 0.05",
                            nrow(results), sum(results$sig_05), 100 * mean(results$sig_05))) +
    theme_minimal() +
    theme(legend.position = "bottom", legend.box = "horizontal")

  ggsave("output/replication/specification_curve.pdf", p, width = 10, height = 6)
  cat("Plot saved: output/replication/specification_curve.pdf\n")
  results
}

# =============================================================================
# RUN ALL
# =============================================================================

if (sys.nframe() == 0) {
  cat("=== Running Table 3 Robustness Analyses ===\n\n")

  cat("--- Pre-Trends Test ---\n")
  run_pretrends()

  cat("\n--- DID-Style Robustness ---\n")
  run_did_robustness()

  cat("\n--- DID with Corrected Baseline ---\n")
  run_did_corrected()

  cat("\n--- Leave-One-Out Analysis ---\n")
  run_leave_one_out()

  cat("\n--- Specification Curve ---\n")
  run_specification_curve()

  cat("\n=== All Table 3 robustness analyses complete ===\n")
}
