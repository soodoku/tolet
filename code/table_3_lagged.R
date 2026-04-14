# Table 3 with Lagged Outcomes
# Same heterogeneous RD specification as Table 3, but using pre-treatment outcomes
# Tests: Coverage by FY + NREGA sanitation expenditure by year

library(haven)
library(dplyr)
library(ivreg)
library(sandwich)
library(kableExtra)

# Load GP-level data
panel <- read_dta("data/SBM_panel.dta")
gp_data <- read_dta("data/final election caste sbm.dta")

# Prepare the data
muslim_share_data <- panel %>%
  filter(post == 1) %>%
  group_by(eleid) %>%
  summarise(muslim_share = first(muslim_share), .groups = "drop")

femres_data <- panel %>%
  filter(post == 1) %>%
  group_by(eleid) %>%
  summarise(femalereservation = first(femalereservation), .groups = "drop")

df <- gp_data %>%
  left_join(muslim_share_data, by = "eleid") %>%
  left_join(femres_data, by = "eleid")

# Create NREGA sanitation expenditure variables (per household, in Rs.)
# Following paper: 100*(Labour + Material)/tot_new
for (year in 2011:2018) {
  labour_var <- paste0("sanitation_Labour_exp_Lakhs", year)
  material_var <- paste0("sanit_Material_exp_Lakhs", year)
  new_var <- paste0("nrega_sanit_", year)

  df[[new_var]] <- 100 * (df[[labour_var]] + df[[material_var]]) / df[["tot_new"]]
}

# Create Total NREGA expenditure variables (per household, in Rs.)
# 100*(Labour_exp_disbursed_Lakhs + Material_exp_disbursed_Lakhs)/tot_new
for (year in 2011:2018) {
  labour_var <- paste0("Labour_exp_disbursed_Lakhs", year)
  material_var <- paste0("Material_exp_disbursed_Lakhs", year)
  new_var <- paste0("nrega_total_", year)

  df[[new_var]] <- 100 * (df[[labour_var]] + df[[material_var]]) / df[["tot_new"]]
}

# Create interaction variables
df <- df %>%
  mutate(
    female_x_muslim = femalereservation * muslim_share,
    inst_x_muslim = femaleinstrument * muslim_share,
    running_x_inst = runningvar2_norm_std * femaleinstrument,
    running_x_muslim = runningvar2_norm_std * muslim_share,
    running_x_inst_x_muslim = runningvar2_norm_std * femaleinstrument * muslim_share
  )

# Function to run the heterogeneous 2SLS
run_het_2sls <- function(data, outcome_var, bw) {
  sample_data <- data %>%
    filter(abs(runningvar2_norm_std) <= bw) %>%
    filter(!is.na(.data[[outcome_var]])) %>%
    filter(!is.na(muslim_share)) %>%
    filter(!is.na(femalereservation)) %>%
    filter(is.finite(.data[[outcome_var]])) %>%
    mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)

  n_obs <- nrow(sample_data)

  if (n_obs < 100) {
    return(list(n = n_obs, coefs = NULL, ses = NULL, error = "Too few obs"))
  }

  formula_str <- sprintf(
    "%s ~ femalereservation + female_x_muslim + runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim | runningvar2_norm_std + running_x_inst + muslim_share + running_x_muslim + running_x_inst_x_muslim + femaleinstrument + inst_x_muslim",
    outcome_var
  )

  tryCatch({
    model <- ivreg(as.formula(formula_str), data = sample_data, weights = weight)
    vcov_robust <- vcovHC(model, type = "HC1")
    coef_est <- coef(model)
    se_robust <- sqrt(diag(vcov_robust))

    list(n = n_obs, coefs = coef_est, ses = se_robust, error = NULL)
  }, error = function(e) {
    list(n = n_obs, coefs = NULL, ses = NULL, error = e$message)
  })
}

# Helpers
format_coef <- function(coef, se) {
  if (is.null(coef) || is.na(coef)) return("-")
  pval <- 2 * (1 - pnorm(abs(coef / se)))
  stars <- ""
  if (pval < 0.01) stars <- "***"
  else if (pval < 0.05) stars <- "**"
  else if (pval < 0.1) stars <- "*"
  sprintf("%.3f%s", coef, stars)
}

format_se <- function(se) {
  if (is.null(se) || is.na(se)) return("")
  sprintf("(%.3f)", se)
}

# ============================================================================
# PANEL A: TOILET COVERAGE BY FISCAL YEAR
# ============================================================================
coverage_outcomes <- c(
  "coverage13_14" = "FY 2013-14",
  "coverage14_15" = "FY 2014-15",
  "coverage15_16" = "FY 2015-16",
  "coverage16_17" = "FY 2016-17"
)

# ============================================================================
# PANEL B: NREGA SANITATION EXPENDITURE BY YEAR
# ============================================================================
nrega_outcomes <- c(
  "nrega_sanit_2011" = "2011",
  "nrega_sanit_2012" = "2012",
  "nrega_sanit_2013" = "2013",
  "nrega_sanit_2014" = "2014",
  "nrega_sanit_2015" = "2015",
  "nrega_sanit_2016" = "2016",
  "nrega_sanit_2017" = "2017"
)

# ============================================================================
# PANEL C: TOTAL NREGA EXPENDITURE BY YEAR
# ============================================================================
nrega_total_outcomes <- c(
  "nrega_total_2011" = "2011",
  "nrega_total_2012" = "2012",
  "nrega_total_2013" = "2013",
  "nrega_total_2014" = "2014",
  "nrega_total_2015" = "2015",
  "nrega_total_2016" = "2016",
  "nrega_total_2017" = "2017"
)

bandwidths <- c(0.10, 0.075, 0.05)

# Run all models
results_coverage <- list()
for (outcome in names(coverage_outcomes)) {
  results_coverage[[outcome]] <- list()
  for (bw in bandwidths) {
    results_coverage[[outcome]][[as.character(bw)]] <- run_het_2sls(df, outcome, bw)
  }
}

results_nrega <- list()
for (outcome in names(nrega_outcomes)) {
  results_nrega[[outcome]] <- list()
  for (bw in bandwidths) {
    results_nrega[[outcome]][[as.character(bw)]] <- run_het_2sls(df, outcome, bw)
  }
}

results_nrega_total <- list()
for (outcome in names(nrega_total_outcomes)) {
  results_nrega_total[[outcome]] <- list()
  for (bw in bandwidths) {
    results_nrega_total[[outcome]][[as.character(bw)]] <- run_het_2sls(df, outcome, bw)
  }
}

# ============================================================================
# PRINT RESULTS
# ============================================================================
cat("\n")
cat("================================================================================\n")
cat("TABLE 3 WITH LAGGED OUTCOMES: Heterogeneous Impact by Muslim Share\n")
cat("================================================================================\n")
cat("\n")
cat("Key coefficient: Female reservation × Muslim share\n")
cat("Elections held: October 2015\n")
cat("Pre-treatment: FY 2013-14, FY 2014-15, Calendar 2011-2014\n")
cat("Post-treatment: FY 2015-16+, Calendar 2016+\n")
cat("\n")

# Panel A: Coverage
cat("================================================================================\n")
cat("PANEL A: TOILET COVERAGE (# HHs covered in fiscal year)\n")
cat("================================================================================\n")
cat(sprintf("%-20s %15s %15s %15s\n", "Fiscal Year", "BW=0.10", "BW=0.075", "BW=0.05"))
cat("--------------------------------------------------------------------------------\n")

for (outcome in names(coverage_outcomes)) {
  r1 <- results_coverage[[outcome]][["0.1"]]
  r2 <- results_coverage[[outcome]][["0.075"]]
  r3 <- results_coverage[[outcome]][["0.05"]]

  # Determine if pre or post treatment
  period_label <- coverage_outcomes[[outcome]]
  if (outcome %in% c("coverage13_14", "coverage14_15")) {
    period_label <- paste0(period_label, " [PRE]")
  } else {
    period_label <- paste0(period_label, " [POST]")
  }

  cat(sprintf("%-20s %15s %15s %15s\n", period_label,
              format_coef(r1$coefs["female_x_muslim"], r1$ses["female_x_muslim"]),
              format_coef(r2$coefs["female_x_muslim"], r2$ses["female_x_muslim"]),
              format_coef(r3$coefs["female_x_muslim"], r3$ses["female_x_muslim"])))
  cat(sprintf("%-20s %15s %15s %15s\n", "",
              format_se(r1$ses["female_x_muslim"]),
              format_se(r2$ses["female_x_muslim"]),
              format_se(r3$ses["female_x_muslim"])))
  cat(sprintf("%-20s %15s %15s %15s\n", "  N",
              format(r1$n, big.mark = ","),
              format(r2$n, big.mark = ","),
              format(r3$n, big.mark = ",")))
  cat("\n")
}

# Panel B: NREGA
cat("================================================================================\n")
cat("PANEL B: NREGA SANITATION EXPENDITURE (Rs. per HH)\n")
cat("================================================================================\n")
cat(sprintf("%-20s %15s %15s %15s\n", "Calendar Year", "BW=0.10", "BW=0.075", "BW=0.05"))
cat("--------------------------------------------------------------------------------\n")

for (outcome in names(nrega_outcomes)) {
  r1 <- results_nrega[[outcome]][["0.1"]]
  r2 <- results_nrega[[outcome]][["0.075"]]
  r3 <- results_nrega[[outcome]][["0.05"]]

  year <- nrega_outcomes[[outcome]]
  if (as.numeric(year) <= 2014) {
    period_label <- paste0(year, " [PRE]")
  } else if (as.numeric(year) == 2015) {
    period_label <- paste0(year, " [ELECTION]")
  } else {
    period_label <- paste0(year, " [POST]")
  }

  cat(sprintf("%-20s %15s %15s %15s\n", period_label,
              format_coef(r1$coefs["female_x_muslim"], r1$ses["female_x_muslim"]),
              format_coef(r2$coefs["female_x_muslim"], r2$ses["female_x_muslim"]),
              format_coef(r3$coefs["female_x_muslim"], r3$ses["female_x_muslim"])))
  cat(sprintf("%-20s %15s %15s %15s\n", "",
              format_se(r1$ses["female_x_muslim"]),
              format_se(r2$ses["female_x_muslim"]),
              format_se(r3$ses["female_x_muslim"])))
  cat(sprintf("%-20s %15s %15s %15s\n", "  N",
              format(r1$n, big.mark = ","),
              format(r2$n, big.mark = ","),
              format(r3$n, big.mark = ",")))
  cat("\n")
}

# Panel C: Total NREGA
cat("================================================================================\n")
cat("PANEL C: TOTAL NREGA EXPENDITURE (Rs. per HH)\n")
cat("================================================================================\n")
cat(sprintf("%-20s %15s %15s %15s\n", "Calendar Year", "BW=0.10", "BW=0.075", "BW=0.05"))
cat("--------------------------------------------------------------------------------\n")

for (outcome in names(nrega_total_outcomes)) {
  r1 <- results_nrega_total[[outcome]][["0.1"]]
  r2 <- results_nrega_total[[outcome]][["0.075"]]
  r3 <- results_nrega_total[[outcome]][["0.05"]]

  year <- nrega_total_outcomes[[outcome]]
  if (as.numeric(year) <= 2014) {
    period_label <- paste0(year, " [PRE]")
  } else if (as.numeric(year) == 2015) {
    period_label <- paste0(year, " [ELECTION]")
  } else {
    period_label <- paste0(year, " [POST]")
  }

  cat(sprintf("%-20s %15s %15s %15s\n", period_label,
              format_coef(r1$coefs["female_x_muslim"], r1$ses["female_x_muslim"]),
              format_coef(r2$coefs["female_x_muslim"], r2$ses["female_x_muslim"]),
              format_coef(r3$coefs["female_x_muslim"], r3$ses["female_x_muslim"])))
  cat(sprintf("%-20s %15s %15s %15s\n", "",
              format_se(r1$ses["female_x_muslim"]),
              format_se(r2$ses["female_x_muslim"]),
              format_se(r3$ses["female_x_muslim"])))
  cat(sprintf("%-20s %15s %15s %15s\n", "  N",
              format(r1$n, big.mark = ","),
              format(r2$n, big.mark = ","),
              format(r3$n, big.mark = ",")))
  cat("\n")
}

cat("================================================================================\n")
cat("Robust standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.1\n")
cat("================================================================================\n")

# ============================================================================
# SAVE CSV
# ============================================================================
csv_rows <- list()

# Coverage
for (outcome in names(coverage_outcomes)) {
  for (bw in bandwidths) {
    r <- results_coverage[[outcome]][[as.character(bw)]]
    csv_rows[[length(csv_rows) + 1]] <- data.frame(
      Panel = "Coverage",
      Outcome = outcome,
      Period = coverage_outcomes[[outcome]],
      Bandwidth = bw,
      N = r$n,
      FemaleRes_Coef = round(as.numeric(r$coefs["femalereservation"]), 4),
      FemaleRes_SE = round(as.numeric(r$ses["femalereservation"]), 4),
      Interaction_Coef = round(as.numeric(r$coefs["female_x_muslim"]), 4),
      Interaction_SE = round(as.numeric(r$ses["female_x_muslim"]), 4),
      stringsAsFactors = FALSE
    )
  }
}

# NREGA Sanitation
for (outcome in names(nrega_outcomes)) {
  for (bw in bandwidths) {
    r <- results_nrega[[outcome]][[as.character(bw)]]
    if (r$n > 0 && !is.null(r$coefs)) {
      csv_rows[[length(csv_rows) + 1]] <- data.frame(
        Panel = "NREGA_Sanitation",
        Outcome = outcome,
        Period = nrega_outcomes[[outcome]],
        Bandwidth = bw,
        N = r$n,
        FemaleRes_Coef = round(as.numeric(r$coefs["femalereservation"]), 4),
        FemaleRes_SE = round(as.numeric(r$ses["femalereservation"]), 4),
        Interaction_Coef = round(as.numeric(r$coefs["female_x_muslim"]), 4),
        Interaction_SE = round(as.numeric(r$ses["female_x_muslim"]), 4),
        stringsAsFactors = FALSE
      )
    }
  }
}

# NREGA Total
for (outcome in names(nrega_total_outcomes)) {
  for (bw in bandwidths) {
    r <- results_nrega_total[[outcome]][[as.character(bw)]]
    if (r$n > 0 && !is.null(r$coefs)) {
      csv_rows[[length(csv_rows) + 1]] <- data.frame(
        Panel = "NREGA_Total",
        Outcome = outcome,
        Period = nrega_total_outcomes[[outcome]],
        Bandwidth = bw,
        N = r$n,
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
write.csv(csv_df, "output/table3_lagged.csv", row.names = FALSE)
cat("\nSaved to output/table3_lagged.csv\n")

# ============================================================================
# SAVE LATEX (using kableExtra)
# ============================================================================

# Build data frame for kable
table_rows <- list()
row_idx <- 1

# Panel A: Coverage
panel_a_start <- row_idx
for (outcome in names(coverage_outcomes)) {
  r1 <- results_coverage[[outcome]][["0.1"]]
  r2 <- results_coverage[[outcome]][["0.075"]]
  r3 <- results_coverage[[outcome]][["0.05"]]

  pre_post <- ifelse(outcome %in% c("coverage13_14", "coverage14_15"), "[PRE]", "[POST]")

  table_rows[[row_idx]] <- data.frame(
    Outcome = paste(coverage_outcomes[[outcome]], pre_post),
    BW_10 = format_coef(r1$coefs["female_x_muslim"], r1$ses["female_x_muslim"]),
    BW_075 = format_coef(r2$coefs["female_x_muslim"], r2$ses["female_x_muslim"]),
    BW_05 = format_coef(r3$coefs["female_x_muslim"], r3$ses["female_x_muslim"]),
    stringsAsFactors = FALSE
  )
  row_idx <- row_idx + 1

  table_rows[[row_idx]] <- data.frame(
    Outcome = "",
    BW_10 = format_se(r1$ses["female_x_muslim"]),
    BW_075 = format_se(r2$ses["female_x_muslim"]),
    BW_05 = format_se(r3$ses["female_x_muslim"]),
    stringsAsFactors = FALSE
  )
  row_idx <- row_idx + 1
}
panel_a_end <- row_idx - 1

# Panel B: NREGA Sanitation
panel_b_start <- row_idx
for (outcome in names(nrega_outcomes)) {
  r1 <- results_nrega[[outcome]][["0.1"]]
  r2 <- results_nrega[[outcome]][["0.075"]]
  r3 <- results_nrega[[outcome]][["0.05"]]

  year <- as.numeric(nrega_outcomes[[outcome]])
  if (year <= 2014) pre_post <- "[PRE]"
  else if (year == 2015) pre_post <- "[ELEC]"
  else pre_post <- "[POST]"

  table_rows[[row_idx]] <- data.frame(
    Outcome = paste(nrega_outcomes[[outcome]], pre_post),
    BW_10 = format_coef(r1$coefs["female_x_muslim"], r1$ses["female_x_muslim"]),
    BW_075 = format_coef(r2$coefs["female_x_muslim"], r2$ses["female_x_muslim"]),
    BW_05 = format_coef(r3$coefs["female_x_muslim"], r3$ses["female_x_muslim"]),
    stringsAsFactors = FALSE
  )
  row_idx <- row_idx + 1

  table_rows[[row_idx]] <- data.frame(
    Outcome = "",
    BW_10 = format_se(r1$ses["female_x_muslim"]),
    BW_075 = format_se(r2$ses["female_x_muslim"]),
    BW_05 = format_se(r3$ses["female_x_muslim"]),
    stringsAsFactors = FALSE
  )
  row_idx <- row_idx + 1
}
panel_b_end <- row_idx - 1

# Panel C: Total NREGA
panel_c_start <- row_idx
for (outcome in names(nrega_total_outcomes)) {
  r1 <- results_nrega_total[[outcome]][["0.1"]]
  r2 <- results_nrega_total[[outcome]][["0.075"]]
  r3 <- results_nrega_total[[outcome]][["0.05"]]

  year <- as.numeric(nrega_total_outcomes[[outcome]])
  if (year <= 2014) pre_post <- "[PRE]"
  else if (year == 2015) pre_post <- "[ELEC]"
  else pre_post <- "[POST]"

  table_rows[[row_idx]] <- data.frame(
    Outcome = paste(nrega_total_outcomes[[outcome]], pre_post),
    BW_10 = format_coef(r1$coefs["female_x_muslim"], r1$ses["female_x_muslim"]),
    BW_075 = format_coef(r2$coefs["female_x_muslim"], r2$ses["female_x_muslim"]),
    BW_05 = format_coef(r3$coefs["female_x_muslim"], r3$ses["female_x_muslim"]),
    stringsAsFactors = FALSE
  )
  row_idx <- row_idx + 1

  table_rows[[row_idx]] <- data.frame(
    Outcome = "",
    BW_10 = format_se(r1$ses["female_x_muslim"]),
    BW_075 = format_se(r2$ses["female_x_muslim"]),
    BW_05 = format_se(r3$ses["female_x_muslim"]),
    stringsAsFactors = FALSE
  )
  row_idx <- row_idx + 1
}
panel_c_end <- row_idx - 1

results_df <- do.call(rbind, table_rows)
colnames(results_df) <- c("", "BW=0.10", "BW=0.075", "BW=0.05")

latex_table <- results_df %>%
  kbl(format = "latex", booktabs = TRUE, escape = FALSE, align = c("l", "c", "c", "c"),
      caption = "Table 3 with Lagged Outcomes: Female Reservation $\\times$ Muslim Share",
      label = "table3_lagged") %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10) %>%
  pack_rows("Panel A: Toilet Coverage (\\\\# HHs covered)", panel_a_start, panel_a_end, escape = FALSE) %>%
  pack_rows("Panel B: NREGA Sanitation Expenditure (Rs. per HH)", panel_b_start, panel_b_end) %>%
  pack_rows("Panel C: Total NREGA Expenditure (Rs. per HH)", panel_c_start, panel_c_end) %>%
  footnote(general = c(
    "Robust standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.1",
    "Elections held October 2015. PRE = pre-treatment, POST = post-treatment.",
    "Coefficient shown: Female reservation $\\\\times$ Muslim share (2SLS)."
  ), escape = FALSE, general_title = "")

writeLines(as.character(latex_table), "output/table3_lagged.tex")
cat("Saved to output/table3_lagged.tex\n")
