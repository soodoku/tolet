# Table 3 Dose-Response Analyses
# Dose-response coverage, GAM interaction

library(mgcv)
library(ggplot2)

source("code/replication/00_utils.R")

# =============================================================================
# SECTION 1: DOSE-RESPONSE COVERAGE (Table 3)
# =============================================================================

run_dose_response_coverage <- function() {
  df <- load_gp_data(bw = 0.10)

  df <- df %>%
    filter(!is.na(muslim_share), !is.na(femalereservation), !is.na(coverage16_17)) %>%
    mutate(muslim_bin = cut(muslim_share,
                            breaks = seq(0, max(muslim_share, na.rm = TRUE) + 0.01, by = 0.05),
                            include.lowest = TRUE, right = FALSE))

  dose_response <- df %>%
    group_by(muslim_bin, femalereservation) %>%
    summarise(
      mean_coverage = mean(coverage16_17, na.rm = TRUE),
      se_coverage = sd(coverage16_17, na.rm = TRUE) / sqrt(n()),
      n = n(),
      mean_muslim = mean(muslim_share, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    filter(!is.na(muslim_bin), n >= 20)

  cat("=======================================================\n")
  cat("Dose-Response: Coverage 16-17 by Muslim Share × Female\n")
  cat("=======================================================\n\n")
  cat("If interaction is real, Diff should increase monotonically with Muslim share.\n\n")
  cat("Muslim Share Bin | Female=0 (N)  | Female=1 (N)  | Diff\n")
  cat(paste(rep("-", 60), collapse = ""), "\n")

  results <- data.frame()
  for (b in sort(unique(dose_response$muslim_bin))) {
    d0 <- dose_response %>% filter(muslim_bin == b, femalereservation == 0)
    d1 <- dose_response %>% filter(muslim_bin == b, femalereservation == 1)

    if (nrow(d0) > 0 && nrow(d1) > 0) {
      diff <- d1$mean_coverage - d0$mean_coverage
      cat(sprintf("%-16s | %5.1f (%4d)  | %5.1f (%4d)  | %+6.1f\n",
                  as.character(b), d0$mean_coverage, d0$n, d1$mean_coverage, d1$n, diff))

      results <- rbind(results, data.frame(
        muslim_bin = as.character(b), mean_muslim = d0$mean_muslim,
        coverage_female0 = d0$mean_coverage, n_female0 = d0$n,
        coverage_female1 = d1$mean_coverage, n_female1 = d1$n, diff = diff
      ))
    }
  }

  write.csv(results, "output/replication/dose_response_coverage.csv", row.names = FALSE)
  cat("\nSaved: output/replication/dose_response_coverage.csv\n")

  p <- ggplot(dose_response, aes(x = mean_muslim, y = mean_coverage,
                                  color = factor(femalereservation))) +
    geom_point(aes(size = n)) +
    geom_line() +
    geom_errorbar(aes(ymin = mean_coverage - 1.96 * se_coverage,
                      ymax = mean_coverage + 1.96 * se_coverage), width = 0.01) +
    labs(x = "Muslim Share", y = "Coverage 16-17 (%)",
         title = "Dose-Response: Coverage by Muslim Share",
         subtitle = "If interaction is real, lines should diverge monotonically",
         color = "Female Res.", size = "N") +
    theme_minimal() +
    scale_color_manual(values = c("0" = "blue", "1" = "red"), labels = c("0" = "No", "1" = "Yes"))

  ggsave("output/replication/dose_response_coverage.pdf", p, width = 8, height = 6)
  cat("Plot saved: output/replication/dose_response_coverage.pdf\n")
  results
}

# =============================================================================
# SECTION 2: GAM INTERACTION (Table 3 - Coverage)
# =============================================================================

run_gam_interaction <- function() {
  df <- load_gp_data(bw = 0.10) %>%
    filter(!is.na(muslim_share), !is.na(femalereservation), !is.na(coverage16_17)) %>%
    mutate(female_f = factor(femalereservation))

  cat("==============================================\n")
  cat("GAM: Testing Linear vs Smooth Interaction\n")
  cat("==============================================\n\n")

  m_linear <- lm(coverage16_17 ~ femalereservation * muslim_share, data = df, weights = weight)
  cat("Linear model:\n")
  cat(sprintf("  Female × Muslim Share = %.1f (SE: %.1f)\n\n",
              coef(m_linear)[4], summary(m_linear)$coefficients[4, 2]))

  m_gam <- gam(coverage16_17 ~ femalereservation + s(muslim_share, by = female_f, k = 5),
               data = df, weights = weight)

  cat("GAM summary:\n")
  print(summary(m_gam)$s.table)

  cat("\n\nModel comparison (AIC):\n")
  cat(sprintf("  Linear: %.1f\n", AIC(m_linear)))
  cat(sprintf("  GAM:    %.1f\n", AIC(m_gam)))

  cat("\n\nPredicted Female effect by Muslim share (GAM):\n")
  cat("Muslim Share | Female=0 | Female=1 | Diff  | SE(Diff) | 95% CI\n")
  cat(paste(rep("-", 70), collapse = ""), "\n")

  results <- data.frame()
  for (ms in seq(0.05, 0.60, by = 0.05)) {
    newdata0 <- data.frame(muslim_share = ms, femalereservation = 0, female_f = factor(0))
    newdata1 <- data.frame(muslim_share = ms, femalereservation = 1, female_f = factor(1))

    pred0 <- predict(m_gam, newdata0, se.fit = TRUE)
    pred1 <- predict(m_gam, newdata1, se.fit = TRUE)

    diff <- pred1$fit - pred0$fit
    se_diff <- sqrt(pred0$se.fit^2 + pred1$se.fit^2)
    ci_lo <- diff - 1.96 * se_diff
    ci_hi <- diff + 1.96 * se_diff

    cat(sprintf("    %.2f     | %6.1f   | %6.1f   | %+5.1f |  %5.1f    | [%+6.1f, %+6.1f]%s\n",
                ms, pred0$fit, pred1$fit, diff, se_diff, ci_lo, ci_hi,
                ifelse(ci_lo > 0 | ci_hi < 0, " *", "")))

    results <- rbind(results, data.frame(
      muslim_share = ms, pred_female0 = pred0$fit, pred_female1 = pred1$fit,
      diff = diff, se_diff = se_diff, ci_lo = ci_lo, ci_hi = ci_hi,
      significant = (ci_lo > 0 | ci_hi < 0)
    ))
  }

  write.csv(results, "output/replication/gam_interaction.csv", row.names = FALSE)
  cat("\nSaved: output/replication/gam_interaction.csv\n")

  p <- ggplot(results, aes(x = muslim_share, y = diff)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.3, fill = "steelblue") +
    geom_line(color = "steelblue", linewidth = 1) +
    geom_point(aes(color = significant), size = 3) +
    scale_color_manual(values = c("FALSE" = "gray50", "TRUE" = "red"),
                       labels = c("FALSE" = "Not Sig.", "TRUE" = "Sig.")) +
    geom_vline(xintercept = 0.20, linetype = "dotted", color = "darkred") +
    annotate("text", x = 0.21, y = max(results$ci_hi) * 0.9,
             label = "80% of data\nbelow this", hjust = 0, size = 3, color = "darkred") +
    labs(x = "Muslim Share", y = "Female Reservation Effect (pp)",
         title = "GAM: Female Effect by Muslim Share",
         subtitle = "Effect only significant at Muslim share > 0.35 (tail of distribution)",
         color = "") +
    theme_minimal() +
    theme(legend.position = "bottom")

  ggsave("output/replication/gam_interaction.pdf", p, width = 8, height = 6)
  cat("Plot saved: output/replication/gam_interaction.pdf\n")
  results
}

# =============================================================================
# RUN ALL
# =============================================================================

if (sys.nframe() == 0) {
  cat("=== Running Table 3 Dose-Response Analyses ===\n\n")

  cat("--- Dose-Response Coverage ---\n")
  run_dose_response_coverage()

  cat("\n--- GAM Interaction (Table 3) ---\n")
  run_gam_interaction()

  cat("\n=== All Table 3 dose-response analyses complete ===\n")
}
