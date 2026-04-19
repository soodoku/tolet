# MNREGA Analysis
# Main effects and heterogeneous effects (Female × Muslim interaction)

library(fixest)
library(ivreg)
library(sandwich)

source("code/replication/00_utils.R")

# =============================================================================
# SECTION 1: MNREGA MAIN EFFECTS (Simple RD)
# =============================================================================

run_mnrega_main <- function() {
  df <- load_gp_data()

  for (year in 2011:2018) {
    df[[paste0("nrega_sanit_", year)]] <- 100 * (df[[paste0("sanitation_Labour_exp_Lakhs", year)]] +
                                                   df[[paste0("sanit_Material_exp_Lakhs", year)]]) / df[["tot_new"]]
    df[[paste0("nrega_water_", year)]] <- 100 * (df[[paste0("water_Labour_exp_Lakhs", year)]] +
                                                   df[[paste0("water_Material_exp_Lakhs", year)]]) / df[["tot_new"]]
    df[[paste0("nrega_total_", year)]] <- 100 * (df[[paste0("Labour_exp_disbursed_Lakhs", year)]] +
                                                   df[[paste0("Material_exp_disbursed_Lakhs", year)]]) / df[["tot_new"]]
  }

  df <- df %>%
    mutate(
      nrega_total_2016_17 = nrega_total_2016 + nrega_total_2017,
      nrega_sanit_2016_17 = nrega_sanit_2016 + nrega_sanit_2017,
      nrega_water_2016_17 = nrega_water_2016 + nrega_water_2017
    )

  bandwidths <- c(0.10, 0.075, 0.05)
  outcomes <- c(
    "nrega_total_2016", "nrega_total_2017", "nrega_total_2016_17",
    "nrega_sanit_2016", "nrega_sanit_2017", "nrega_sanit_2016_17",
    "nrega_water_2016", "nrega_water_2017", "nrega_water_2016_17"
  )
  outcome_labels <- c(
    "Total 2016", "Total 2017", "Total 16-17",
    "Sanit. 2016", "Sanit. 2017", "Sanit. 16-17",
    "Water 2016", "Water 2017", "Water 16-17"
  )

  run_rd_ols <- function(data, outcome_var, bw) {
    sample_data <- data %>%
      filter(abs(runningvar2_norm_std) <= bw) %>%
      filter(!is.na(.data[[outcome_var]]), !is.na(femalereservation)) %>%
      filter(is.finite(.data[[outcome_var]])) %>%
      mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)

    formula_obj <- as.formula(paste(outcome_var, "~ femalereservation + runningvar2_norm_std"))
    lm(formula_obj, data = sample_data, weights = weight)
  }

  csv_rows <- list()
  for (bw in bandwidths) {
    bw_label <- if (bw == 0.1) "10" else if (bw == 0.075) "075" else "05"
    models <- list()

    for (i in seq_along(outcomes)) {
      model <- run_rd_ols(df, outcomes[i], bw)
      models[[i]] <- model

      csv_rows[[length(csv_rows) + 1]] <- data.frame(
        Bandwidth = bw, Outcome = outcomes[i], Label = outcome_labels[i],
        N = nobs(model),
        FemaleRes_Coef = coef(model)["femalereservation"],
        FemaleRes_SE = sqrt(vcov(model)["femalereservation", "femalereservation"]),
        Running_Coef = coef(model)["runningvar2_norm_std"],
        Running_SE = sqrt(vcov(model)["runningvar2_norm_std", "runningvar2_norm_std"]),
        Constant = coef(model)["(Intercept)"],
        Adj_R2 = summary(model)$adj.r.squared,
        stringsAsFactors = FALSE
      )
    }

    notes <- c(
      paste0("Bandwidth = ", bw, ". Local linear RD with triangular kernel weights."),
      "Outcomes in Rs. per household. Elections held October 2015.",
      "* p < 0.05, ** p < 0.01, *** p < 0.001"
    )

    out_file <- paste0("output/replication/mnrega_main_bw", bw_label, ".tex")
    custom_stargazer(
      models, notes = notes, digits = 2, float.env = "sidewaystable",
      covariate.labels = c("Female Reservation", "Running Variable"),
      column.labels = outcome_labels,
      add.lines = list(c("Bandwidth", rep(as.character(bw), length(outcomes)))),
      out = out_file
    )
    cat("Saved:", out_file, "\n")
  }

  csv_df <- do.call(rbind, csv_rows)
  write.csv(csv_df, "output/replication/mnrega_main.csv", row.names = FALSE)
  cat("Saved: output/replication/mnrega_main.csv\n")
  csv_df
}

# =============================================================================
# SECTION 2: MNREGA HETEROGENEOUS EFFECTS (Female × Muslim interaction)
# Key finding: Sanitation spending shows NEGATIVE interaction, contradicting
# the paper's mechanism that female sarpanches prioritize sanitation in
# high-Muslim areas.
# =============================================================================

run_mnrega_heterogeneous <- function() {
  df <- load_gp_data()

  for (year in 2011:2018) {
    df[[paste0("nrega_sanit_", year)]] <- 100 * (df[[paste0("sanitation_Labour_exp_Lakhs", year)]] +
                                                   df[[paste0("sanit_Material_exp_Lakhs", year)]]) / df[["tot_new"]]
    df[[paste0("nrega_total_", year)]] <- 100 * (df[[paste0("Labour_exp_disbursed_Lakhs", year)]] +
                                                   df[[paste0("Material_exp_disbursed_Lakhs", year)]]) / df[["tot_new"]]
  }

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

  nrega_sanit_outcomes <- paste0("nrega_sanit_", 2011:2017)
  nrega_total_outcomes <- paste0("nrega_total_", 2011:2017)
  bandwidths <- c(0.10, 0.075, 0.05)

  cat("============================================================\n")
  cat("MNREGA Heterogeneous Effects: Female × Muslim Interaction\n")
  cat("============================================================\n\n")
  cat("Key test: Does the interaction for SANITATION spending match\n")
  cat("the paper's mechanism (positive = female sarpanches prioritize\n")
  cat("sanitation in high-Muslim areas)?\n\n")

  csv_rows <- list()
  for (outcome in c(nrega_sanit_outcomes, nrega_total_outcomes)) {
    panel <- if (grepl("sanit", outcome)) "NREGA_Sanitation" else "NREGA_Total"
    year <- as.numeric(gsub(".*_(\\d{4})$", "\\1", outcome))
    period <- if (year < 2015) "Pre-treatment"
              else if (year == 2015) "Partial"
              else "Post-treatment"

    for (bw in bandwidths) {
      r <- run_het_2sls(df, outcome, bw)
      if (!is.null(r$coefs)) {
        csv_rows[[length(csv_rows) + 1]] <- data.frame(
          Panel = panel, Outcome = outcome, Year = year, Period = period,
          Bandwidth = bw, N = r$n,
          FemaleRes_Coef = round(as.numeric(r$coefs["femalereservation"]), 4),
          FemaleRes_SE = round(as.numeric(r$ses["femalereservation"]), 4),
          Interaction_Coef = round(as.numeric(r$coefs["female_x_muslim"]), 4),
          Interaction_SE = round(as.numeric(r$ses["female_x_muslim"]), 4),
          stringsAsFactors = FALSE
        )
      }
    }
  }

  csv_df <- do.call(rbind, csv_rows)

  cat("Post-treatment NREGA Sanitation (2016-2017) - Interaction coefficients:\n")
  cat("(Positive = supports mechanism; Negative = contradicts mechanism)\n\n")
  cat("Year | BW=0.10          | BW=0.075         | BW=0.05\n")
  cat(paste(rep("-", 60), collapse = ""), "\n")

  for (yr in 2016:2017) {
    row_10 <- csv_df[csv_df$Outcome == paste0("nrega_sanit_", yr) & csv_df$Bandwidth == 0.10, ]
    row_075 <- csv_df[csv_df$Outcome == paste0("nrega_sanit_", yr) & csv_df$Bandwidth == 0.075, ]
    row_05 <- csv_df[csv_df$Outcome == paste0("nrega_sanit_", yr) & csv_df$Bandwidth == 0.05, ]

    if (nrow(row_10) > 0 && nrow(row_075) > 0 && nrow(row_05) > 0) {
      cat(sprintf("%d | %+.3f (%.3f) | %+.3f (%.3f) | %+.3f (%.3f)\n",
                  yr,
                  row_10$Interaction_Coef, row_10$Interaction_SE,
                  row_075$Interaction_Coef, row_075$Interaction_SE,
                  row_05$Interaction_Coef, row_05$Interaction_SE))
    }
  }

  cat("\n")
  post_sanit <- csv_df[csv_df$Panel == "NREGA_Sanitation" & csv_df$Period == "Post-treatment", ]
  neg_count <- sum(post_sanit$Interaction_Coef < 0)
  total_count <- nrow(post_sanit)
  cat(sprintf("Result: %d/%d post-treatment sanitation coefficients are NEGATIVE\n", neg_count, total_count))
  cat("This contradicts the mechanism: female sarpanches in high-Muslim areas\n")
  cat("are spending LESS on sanitation, not more.\n")

  write.csv(csv_df, "output/replication/mnrega_heterogeneous.csv", row.names = FALSE)
  cat("\nSaved: output/replication/mnrega_heterogeneous.csv\n")
  csv_df
}

# =============================================================================
# RUN ALL
# =============================================================================

if (sys.nframe() == 0) {
  cat("=== Running MNREGA Analysis ===\n\n")

  cat("--- MNREGA Main Effects ---\n")
  run_mnrega_main()

  cat("\n--- MNREGA Heterogeneous Effects ---\n")
  run_mnrega_heterogeneous()

  cat("\n=== MNREGA analysis complete ===\n")
}
