# Table 2 Analyses
# Table 2 by state, control sensitivity, dose-response preferences, GAM Table 2

library(fixest)
library(mgcv)
library(ggplot2)

source("code/replication/00_utils.R")

# =============================================================================
# SECTION 1: TABLE 2 BY STATE (State heterogeneity analysis)
# =============================================================================

run_table2_by_state <- function() {
  df <- load_survey_data()

  filter_toiletuse <- quote(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 1 & (is.na(b2_3_) | b2_3_ != 1))
  filter_latrinepref <- quote(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & (is.na(b2_3_) | b2_3_ != 1) & selected == 1)

  run_models <- function(data, state_label) {
    results <- list()
    sample1 <- data %>% filter(eval(filter_toiletuse))
    sample2 <- data %>% filter(eval(filter_latrinepref))

    tryCatch({
      m1 <- feols(
        toiletuse ~ female + female:muslim_share +
          e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
          villagecode_f + e8_f,
        data = sample1, vcov = "hetero"
      )
      results$m1 <- list(
        model = m1, n = nobs(m1),
        mean_dv = mean(sample1$toiletuse[!is.na(sample1$toiletuse)], na.rm = TRUE),
        coef_female = coef(m1)["female"],
        se_female = sqrt(vcov(m1)["female", "female"]),
        coef_interaction = coef(m1)["female:muslim_share"],
        se_interaction = sqrt(vcov(m1)["female:muslim_share", "female:muslim_share"])
      )
    }, error = function(e) results$m1 <<- list(error = e$message))

    tryCatch({
      m2 <- feols(
        toiletuse ~ female + female:muslim_share +
          e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
          hhid_f + e8_f,
        data = sample1, vcov = "hetero"
      )
      results$m2 <- list(
        model = m2, n = nobs(m2),
        mean_dv = mean(sample1$toiletuse[!is.na(sample1$toiletuse)], na.rm = TRUE),
        coef_female = coef(m2)["female"],
        se_female = sqrt(vcov(m2)["female", "female"]),
        coef_interaction = coef(m2)["female:muslim_share"],
        se_interaction = sqrt(vcov(m2)["female:muslim_share", "female:muslim_share"])
      )
    }, error = function(e) results$m2 <<- list(error = e$message))

    for (m_idx in 3:5) {
      m_name <- paste0("m", m_idx)
      dv <- paste0("latrine_pref", m_idx - 2)
      tryCatch({
        m <- feols(
          as.formula(paste(dv, "~ female + female:muslim_share +
            e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
            villagecode_f + e8_f")),
          data = sample2, vcov = "hetero"
        )
        results[[m_name]] <- list(
          model = m, n = nobs(m),
          mean_dv = mean(sample2[[dv]][!is.na(sample2[[dv]])], na.rm = TRUE),
          coef_female = coef(m)["female"],
          se_female = sqrt(vcov(m)["female", "female"]),
          coef_interaction = coef(m)["female:muslim_share"],
          se_interaction = sqrt(vcov(m)["female:muslim_share", "female:muslim_share"])
        )
      }, error = function(e) results[[m_name]] <<- list(error = e$message))
    }

    results$state <- state_label
    results
  }

  build_results_table <- function(all_results) {
    rows <- list()
    for (res in all_results) {
      state <- res$state
      for (m_name in c("m1", "m2", "m3", "m4", "m5")) {
        m <- res[[m_name]]
        if (!is.null(m$error)) {
          rows[[length(rows) + 1]] <- data.frame(
            State = state, Model = m_name, DV = NA, N = NA, Mean_DV = NA,
            Female_Coef = NA, Female_SE = NA, Interaction_Coef = NA, Interaction_SE = NA,
            Note = m$error, stringsAsFactors = FALSE
          )
        } else if (!is.null(m$model)) {
          dv_name <- switch(m_name, m1 = "toiletuse", m2 = "toiletuse",
                            m3 = "latrine_pref1", m4 = "latrine_pref2", m5 = "latrine_pref3")
          rows[[length(rows) + 1]] <- data.frame(
            State = state, Model = m_name, DV = dv_name, N = m$n,
            Mean_DV = round(m$mean_dv, 4),
            Female_Coef = round(m$coef_female, 4),
            Female_SE = round(m$se_female, 4),
            Interaction_Coef = round(m$coef_interaction, 4),
            Interaction_SE = round(m$se_interaction, 4),
            Note = "", stringsAsFactors = FALSE
          )
        }
      }
    }
    do.call(rbind, rows)
  }

  cat("Running Table 2 by state analysis...\n")
  pooled_results <- run_models(df, "All States (Pooled)")

  state_results <- list()
  for (state in unique(df$state_name[!is.na(df$state_name)])) {
    cat(sprintf("  Running models for %s...\n", state))
    state_results[[state]] <- run_models(df %>% filter(state_name == state), state)
  }

  all_results <- c(list(pooled_results), state_results)
  results_table <- build_results_table(all_results)

  write.csv(results_table, "output/replication/table2_by_state.csv", row.names = FALSE)
  cat("Saved: output/replication/table2_by_state.csv\n")
  results_table
}

# =============================================================================
# SECTION 2: TABLE 2 CONTROL SENSITIVITY
# =============================================================================

run_table2_control_sensitivity <- function() {
  df <- load_survey_data()

  filter_toiletuse <- quote(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 1 & (is.na(b2_3_) | b2_3_ != 1))
  filter_latrinepref <- quote(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & (is.na(b2_3_) | b2_3_ != 1) & selected == 1)

  df <- df %>%
    mutate(female_x_muslim = female * muslim_share)

  df_use <- df %>% filter(eval(filter_toiletuse))
  df_pref <- df %>% filter(eval(filter_latrinepref))

  run_specs <- function(data, outcome) {
    m1 <- lm(as.formula(paste(outcome, "~ female + female_x_muslim")), data = data)
    m2 <- feols(as.formula(paste(outcome, "~ female + female_x_muslim | villagecode_f")),
                data = data, vcov = "hetero")
    m3 <- feols(as.formula(paste(outcome, "~ female + female_x_muslim + e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t | villagecode_f")),
                data = data, vcov = "hetero")
    m4 <- feols(as.formula(paste(outcome, "~ female + female_x_muslim + e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t | villagecode_f + e8_f")),
                data = data, vcov = "hetero")

    get_row <- function(model, spec_name, is_lm = FALSE) {
      coef_f <- coef(model)["female"]
      se_f <- sqrt(diag(vcov(model)))["female"]
      coef_int <- coef(model)["female_x_muslim"]
      se_int <- sqrt(diag(vcov(model)))["female_x_muslim"]
      n <- nobs(model)
      pval_int <- 2 * (1 - pnorm(abs(coef_int / se_int)))

      data.frame(
        outcome = outcome, specification = spec_name, n = n,
        female_coef = round(coef_f, 4), female_se = round(se_f, 4),
        interaction_coef = round(coef_int, 4), interaction_se = round(se_int, 4),
        interaction_pval = round(pval_int, 4),
        stringsAsFactors = FALSE
      )
    }

    rbind(
      get_row(m1, "1_raw_no_controls", TRUE),
      get_row(m2, "2_village_fe_only"),
      get_row(m3, "3_village_fe_wealth"),
      get_row(m4, "4_paper_spec")
    )
  }

  results <- rbind(
    run_specs(df_use, "toiletuse"),
    run_specs(df_pref, "latrine_pref1"),
    run_specs(df_pref, "latrine_pref2"),
    run_specs(df_pref, "latrine_pref3")
  )

  write.csv(results, "output/replication/table2_control_sensitivity.csv", row.names = FALSE)
  cat("Saved: output/replication/table2_control_sensitivity.csv\n")

  cat("\nTable 2 Control Sensitivity Summary:\n")
  cat("=====================================\n")
  cat("Interaction coefficient (Female x Muslim Share) by specification:\n\n")
  for (out in unique(results$outcome)) {
    cat(sprintf("%s:\n", out))
    sub <- results[results$outcome == out, ]
    for (i in 1:nrow(sub)) {
      sig <- ifelse(sub$interaction_pval[i] < 0.05, "*", "")
      cat(sprintf("  %s: %.3f (%.3f)%s\n",
                  sub$specification[i], sub$interaction_coef[i], sub$interaction_se[i], sig))
    }
    cat("\n")
  }

  results
}

# =============================================================================
# SECTION 3: DOSE-RESPONSE PREFERENCES (Table 2)
# =============================================================================

run_dose_response_preferences <- function() {
  df <- load_survey_data()

  df_pref <- df %>%
    filter(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & (is.na(b2_3_) | b2_3_ != 1)) %>%
    filter(!is.na(latrine_pref1), !is.na(muslim_share), !is.na(female)) %>%
    mutate(muslim_bin = cut(muslim_share, breaks = seq(0, 1, by = 0.1), include.lowest = TRUE))

  cat("=================================================================\n")
  cat("Dose-Response: Latrine Preference by Muslim Share × Female\n")
  cat("=================================================================\n\n")
  cat("Paper mechanism: Women prefer toilets more in high-Muslim areas.\n")
  cat("If true, Diff should increase monotonically with Muslim share.\n\n")

  compute_dose <- function(data, label) {
    dose <- data %>%
      group_by(muslim_bin, female) %>%
      summarise(mean_pref = mean(latrine_pref1, na.rm = TRUE), n = n(), .groups = "drop") %>%
      filter(n >= 10)

    cat(sprintf("%s\n", label))
    cat("Muslim Share | Female=0 (N)  | Female=1 (N)  | Diff\n")
    cat(paste(rep("-", 58), collapse = ""), "\n")

    results <- data.frame()
    for (b in sort(unique(dose$muslim_bin))) {
      if (is.na(b)) next
      d0 <- dose %>% filter(muslim_bin == b, female == 0)
      d1 <- dose %>% filter(muslim_bin == b, female == 1)
      if (nrow(d0) > 0 && nrow(d1) > 0) {
        diff <- d1$mean_pref - d0$mean_pref
        cat(sprintf("%-12s | %5.2f (%4d)  | %5.2f (%4d)  | %+6.2f\n",
                    as.character(b), d0$mean_pref, d0$n, d1$mean_pref, d1$n, diff))
        results <- rbind(results, data.frame(
          state = label, muslim_bin = as.character(b),
          pref_female0 = d0$mean_pref, n_female0 = d0$n,
          pref_female1 = d1$mean_pref, n_female1 = d1$n, diff = diff
        ))
      }
    }
    cat("\n")
    results
  }

  all_results <- compute_dose(df_pref, "ALL STATES POOLED")

  for (st in c("Uttar Pradesh", "Madhya Pradesh", "Bihar", "Rajasthan", "Haryana")) {
    st_data <- df_pref %>% filter(state_name == st)
    if (nrow(st_data) > 50) {
      st_results <- compute_dose(st_data, st)
      all_results <- rbind(all_results, st_results)
    }
  }

  write.csv(all_results, "output/replication/dose_response_preferences.csv", row.names = FALSE)
  cat("Saved: output/replication/dose_response_preferences.csv\n")
  all_results
}

# =============================================================================
# SECTION 4: GAM TABLE 2 (Survey - Toilet Use and Preferences)
# =============================================================================

run_gam_table2 <- function() {
  df <- load_survey_data()

  run_gam_analysis <- function(data, outcome_var, outcome_label) {
    data <- data %>% filter(!is.na(.data[[outcome_var]]), !is.na(muslim_share), !is.na(female))

    cat(sprintf("\n=== %s ===\n", outcome_label))
    cat(sprintf("N = %d\n", nrow(data)))
    cat(sprintf("Muslim share: Mean = %.3f, Median = %.3f\n",
                mean(data$muslim_share), median(data$muslim_share)))
    cat(sprintf("%% below 0.10: %.1f%%\n\n", mean(data$muslim_share < 0.10) * 100))

    formula_linear <- as.formula(paste(outcome_var, "~ female * muslim_share"))
    m_linear <- lm(formula_linear, data = data)
    cat(sprintf("Linear: Female × Muslim Share = %.3f (SE: %.3f)\n\n",
                coef(m_linear)[4], summary(m_linear)$coefficients[4, 2]))

    data$female_f <- factor(data$female)
    formula_gam <- as.formula(paste(outcome_var, "~ female + s(muslim_share, by = female_f, k = 5)"))
    m_gam <- gam(formula_gam, data = data)

    cat("GAM: Female effect by Muslim share:\n")
    cat("Muslim Share | Effect | 95% CI | Sig?\n")
    cat(paste(rep("-", 50), collapse = ""), "\n")

    results <- data.frame()
    for (ms in seq(0.05, 0.50, by = 0.05)) {
      newdata0 <- data.frame(muslim_share = ms, female = 0, female_f = factor(0))
      newdata1 <- data.frame(muslim_share = ms, female = 1, female_f = factor(1))
      pred0 <- predict(m_gam, newdata0, se.fit = TRUE)
      pred1 <- predict(m_gam, newdata1, se.fit = TRUE)
      diff <- pred1$fit - pred0$fit
      se_diff <- sqrt(pred0$se.fit^2 + pred1$se.fit^2)
      ci_lo <- diff - 1.96 * se_diff
      ci_hi <- diff + 1.96 * se_diff
      sig <- (ci_lo > 0 | ci_hi < 0)

      cat(sprintf("    %.2f     | %+.3f | [%+.3f, %+.3f] %s\n",
                  ms, diff, ci_lo, ci_hi, ifelse(sig, "*", "")))

      results <- rbind(results, data.frame(
        muslim_share = ms, diff = diff, se_diff = se_diff,
        ci_lo = ci_lo, ci_hi = ci_hi, significant = sig
      ))
    }

    results$outcome <- outcome_label
    results
  }

  df_use <- df %>%
    filter(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 1 & (is.na(b2_3_) | b2_3_ != 1))

  df_pref <- df %>%
    filter(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & (is.na(b2_3_) | b2_3_ != 1))

  results_use <- run_gam_analysis(df_use, "toiletuse", "Toilet Use (Table 2, models 1-2)")
  results_pref <- run_gam_analysis(df_pref, "latrine_pref1", "Latrine Preference (Table 2, models 3-5)")

  all_results <- rbind(results_use, results_pref)
  write.csv(all_results, "output/replication/gam_table2.csv", row.names = FALSE)
  cat("\nSaved: output/replication/gam_table2.csv\n")

  p <- ggplot(all_results, aes(x = muslim_share, y = diff, color = outcome)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi, fill = outcome), alpha = 0.2, color = NA) +
    geom_line(linewidth = 1) +
    geom_point(aes(shape = significant), size = 3) +
    scale_shape_manual(values = c("FALSE" = 1, "TRUE" = 16),
                       labels = c("FALSE" = "Not Sig.", "TRUE" = "Sig.")) +
    geom_vline(xintercept = 0.10, linetype = "dotted", color = "darkred") +
    annotate("text", x = 0.11, y = max(all_results$ci_hi) * 0.9,
             label = "~80% of data\nbelow this", hjust = 0, size = 3, color = "darkred") +
    labs(x = "Muslim Share", y = "Female Effect",
         title = "GAM: Female Effect by Muslim Share (Table 2)",
         subtitle = "Toilet use shows real effect; preferences show null",
         color = "Outcome", fill = "Outcome", shape = "") +
    theme_minimal() +
    theme(legend.position = "bottom")

  ggsave("output/replication/gam_table2.pdf", p, width = 10, height = 6)
  cat("Plot saved: output/replication/gam_table2.pdf\n")
  all_results
}

# =============================================================================
# RUN ALL
# =============================================================================

if (sys.nframe() == 0) {
  cat("=== Running Table 2 Analyses ===\n\n")

  cat("--- Table 2 by State ---\n")
  run_table2_by_state()

  cat("\n--- Table 2 Control Sensitivity ---\n")
  run_table2_control_sensitivity()

  cat("\n--- Dose-Response Preferences ---\n")
  run_dose_response_preferences()

  cat("\n--- GAM Table 2 ---\n")
  run_gam_table2()

  cat("\n=== All Table 2 analyses complete ===\n")
}
