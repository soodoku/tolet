# Replicate Table 2 by State
# This script replicates the analysis from table_2.do stratified by state
# Using SQUAT 2014 survey data

library(haven)
library(dplyr)
library(fixest)

# Load data
df <- read_dta("data/survey_sanitation_2014.dta")

# State mapping (from labeled values in data)
state_map <- c(
  `1` = "Haryana",
  `2` = "Bihar",
  `3` = "Uttar Pradesh",
  `4` = "Madhya Pradesh",
  `5` = "Rajasthan"
)

# Variable construction (replicating table_2.do)

# Open defecation and toilet use
df <- df %>%
  mutate(
    od = case_when(
      g2_1_ == 2 ~ 1,
      !is.na(g2_1_) ~ 0,
      TRUE ~ NA_real_
    ),
    toiletuse = case_when(
      od == 0 ~ 1,
      od == 1 ~ 0,
      TRUE ~ NA_real_
    )
  )

# Religion indicators
df <- df %>%
  mutate(
    hindu = case_when(
      h1 == 1 ~ 1,
      !is.na(h1) ~ 0,
      TRUE ~ NA_real_
    ),
    muslim = case_when(
      h1 == 2 ~ 1,
      !is.na(h1) ~ 0,
      TRUE ~ NA_real_
    ),
    other = case_when(
      !is.na(h1) & h1 != 1 & h1 != 2 ~ 1,
      !is.na(h1) ~ 0,
      TRUE ~ NA_real_
    )
  )

# Caste indicators
df <- df %>%
  mutate(
    huc = case_when(
      hindu == 1 & (h3 == 1 | h3 == 2) ~ 1,
      hindu == 0 | (hindu == 1 & h3 != 1 & h3 != 2) ~ 0,
      TRUE ~ NA_real_
    ),
    hlc = case_when(
      hindu == 1 & h3 != 1 & h3 != 2 ~ 1,
      hindu == 0 | (hindu == 1 & (h3 == 1 | h3 == 2)) ~ 0,
      TRUE ~ NA_real_
    ),
    hobc = case_when(
      hindu == 1 & h3 == 3 ~ 1,
      hindu == 0 | (hindu == 1 & h3 != 3) ~ 0,
      TRUE ~ NA_real_
    ),
    hsc = case_when(
      hindu == 1 & h3 == 4 ~ 1,
      hindu == 0 | (hindu == 1 & h3 != 4) ~ 0,
      TRUE ~ NA_real_
    )
  )

# Gender
df <- df %>%
  mutate(female = as.numeric(b1_2_ == 2))

# Household ID
df <- df %>%
  mutate(hhid = paste(villagecode, id, sep = "-"))

# Latrine preference thresholds
df <- df %>%
  mutate(
    latrine_pref1 = case_when(
      e13_N == 1 ~ 1,
      !is.na(e13_N) ~ 0,
      TRUE ~ NA_real_
    ),
    latrine_pref2 = case_when(
      e13_N == 1 | e13_N == 2 ~ 1,
      !is.na(e13_N) ~ 0,
      TRUE ~ NA_real_
    ),
    latrine_pref3 = case_when(
      e13_N == 1 | e13_N == 2 | e13_N == 3 ~ 1,
      !is.na(e13_N) ~ 0,
      TRUE ~ NA_real_
    )
  )

# Muslim share at village level
df <- df %>%
  group_by(villagecode) %>%
  mutate(muslim_share = mean(muslim, na.rm = TRUE)) %>%
  ungroup()

# State name
df <- df %>%
  mutate(state_name = state_map[as.character(a2)])

# Convert fixed effects to factors
df <- df %>%
  mutate(
    villagecode_f = as.factor(villagecode),
    e8_f = as.factor(e8),
    hhid_f = as.factor(hhid)
  )

# Define sample filters (using Stata-style NA handling: b2_3_ != 1 keeps NAs)
filter_toiletuse <- quote(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 1 & (is.na(b2_3_) | b2_3_ != 1))
filter_latrinepref <- quote(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & (is.na(b2_3_) | b2_3_ != 1) & selected == 1)

# Function to run all 5 models for a given subset
run_models <- function(data, state_label) {
  results <- list()

  # Sample for toilet use models
  sample1 <- data %>% filter(eval(filter_toiletuse))

  # Sample for latrine preference models
  sample2 <- data %>% filter(eval(filter_latrinepref))

  # Model 1: toiletuse with village FE
  tryCatch({
    m1 <- feols(
      toiletuse ~ female + female:muslim_share +
        e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
        villagecode_f + e8_f,
      data = sample1,
      vcov = "hetero"
    )
    results$m1 <- list(
      model = m1,
      n = nobs(m1),
      mean_dv = mean(sample1$toiletuse[!is.na(sample1$toiletuse)], na.rm = TRUE),
      coef_female = coef(m1)["female"],
      se_female = sqrt(vcov(m1)["female", "female"]),
      coef_interaction = coef(m1)["female:muslim_share"],
      se_interaction = sqrt(vcov(m1)["female:muslim_share", "female:muslim_share"])
    )
  }, error = function(e) {
    results$m1 <<- list(error = paste("Model 1 failed:", e$message))
  })

  # Model 2: toiletuse with household FE
  tryCatch({
    m2 <- feols(
      toiletuse ~ female + female:muslim_share +
        e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
        hhid_f + e8_f,
      data = sample1,
      vcov = "hetero"
    )
    results$m2 <- list(
      model = m2,
      n = nobs(m2),
      mean_dv = mean(sample1$toiletuse[!is.na(sample1$toiletuse)], na.rm = TRUE),
      coef_female = coef(m2)["female"],
      se_female = sqrt(vcov(m2)["female", "female"]),
      coef_interaction = coef(m2)["female:muslim_share"],
      se_interaction = sqrt(vcov(m2)["female:muslim_share", "female:muslim_share"])
    )
  }, error = function(e) {
    results$m2 <<- list(error = paste("Model 2 failed:", e$message))
  })

  # Model 3: latrine_pref1 with village FE
  tryCatch({
    m3 <- feols(
      latrine_pref1 ~ female + female:muslim_share +
        e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
        villagecode_f + e8_f,
      data = sample2,
      vcov = "hetero"
    )
    results$m3 <- list(
      model = m3,
      n = nobs(m3),
      mean_dv = mean(sample2$latrine_pref1[!is.na(sample2$latrine_pref1)], na.rm = TRUE),
      coef_female = coef(m3)["female"],
      se_female = sqrt(vcov(m3)["female", "female"]),
      coef_interaction = coef(m3)["female:muslim_share"],
      se_interaction = sqrt(vcov(m3)["female:muslim_share", "female:muslim_share"])
    )
  }, error = function(e) {
    results$m3 <<- list(error = paste("Model 3 failed:", e$message))
  })

  # Model 4: latrine_pref2 with village FE
  tryCatch({
    m4 <- feols(
      latrine_pref2 ~ female + female:muslim_share +
        e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
        villagecode_f + e8_f,
      data = sample2,
      vcov = "hetero"
    )
    results$m4 <- list(
      model = m4,
      n = nobs(m4),
      mean_dv = mean(sample2$latrine_pref2[!is.na(sample2$latrine_pref2)], na.rm = TRUE),
      coef_female = coef(m4)["female"],
      se_female = sqrt(vcov(m4)["female", "female"]),
      coef_interaction = coef(m4)["female:muslim_share"],
      se_interaction = sqrt(vcov(m4)["female:muslim_share", "female:muslim_share"])
    )
  }, error = function(e) {
    results$m4 <<- list(error = paste("Model 4 failed:", e$message))
  })

  # Model 5: latrine_pref3 with village FE
  tryCatch({
    m5 <- feols(
      latrine_pref3 ~ female + female:muslim_share +
        e11_a + e11_b + e11_c + e11_d + e11_e + e11_h + e11_j + e11_p + e11_t |
        villagecode_f + e8_f,
      data = sample2,
      vcov = "hetero"
    )
    results$m5 <- list(
      model = m5,
      n = nobs(m5),
      mean_dv = mean(sample2$latrine_pref3[!is.na(sample2$latrine_pref3)], na.rm = TRUE),
      coef_female = coef(m5)["female"],
      se_female = sqrt(vcov(m5)["female", "female"]),
      coef_interaction = coef(m5)["female:muslim_share"],
      se_interaction = sqrt(vcov(m5)["female:muslim_share", "female:muslim_share"])
    )
  }, error = function(e) {
    results$m5 <<- list(error = paste("Model 5 failed:", e$message))
  })

  results$state <- state_label
  return(results)
}

# Run pooled model first (all states) for verification
cat("Running pooled model (all states) for verification...\n")
pooled_results <- run_models(df, "All States (Pooled)")

# Run models by state
state_results <- list()
states <- unique(df$state_name)
states <- states[!is.na(states)]

for (state in states) {
  cat(sprintf("Running models for %s...\n", state))
  state_data <- df %>% filter(state_name == state)
  state_results[[state]] <- run_models(state_data, state)
}

# Helper function to format coefficients with stars
format_coef <- function(coef, se, n_digits = 4) {
  if (is.null(coef) || is.na(coef)) return(NA)
  pval <- 2 * (1 - pnorm(abs(coef / se)))
  stars <- ""
  if (!is.na(pval)) {
    if (pval < 0.01) stars <- "***"
    else if (pval < 0.05) stars <- "**"
    else if (pval < 0.1) stars <- "*"
  }
  sprintf("%.*f%s", n_digits, coef, stars)
}

# Build results table
build_results_table <- function(all_results) {
  rows <- list()

  for (res in all_results) {
    state <- res$state

    for (m_name in c("m1", "m2", "m3", "m4", "m5")) {
      m <- res[[m_name]]

      if (!is.null(m$error)) {
        rows[[length(rows) + 1]] <- data.frame(
          State = state,
          Model = m_name,
          DV = NA,
          N = NA,
          Mean_DV = NA,
          Female_Coef = NA,
          Female_SE = NA,
          Interaction_Coef = NA,
          Interaction_SE = NA,
          Note = m$error,
          stringsAsFactors = FALSE
        )
      } else if (!is.null(m$model)) {
        dv_name <- switch(m_name,
          m1 = "toiletuse",
          m2 = "toiletuse",
          m3 = "latrine_pref1",
          m4 = "latrine_pref2",
          m5 = "latrine_pref3"
        )
        rows[[length(rows) + 1]] <- data.frame(
          State = state,
          Model = m_name,
          DV = dv_name,
          N = m$n,
          Mean_DV = round(m$mean_dv, 4),
          Female_Coef = round(m$coef_female, 4),
          Female_SE = round(m$se_female, 4),
          Interaction_Coef = round(m$coef_interaction, 4),
          Interaction_SE = round(m$se_interaction, 4),
          Note = "",
          stringsAsFactors = FALSE
        )
      }
    }
  }

  do.call(rbind, rows)
}

# Combine all results
all_results <- c(list(pooled_results), state_results)
results_table <- build_results_table(all_results)

# Save CSV
write.csv(results_table, "output/table2_by_state.csv", row.names = FALSE)
cat("Saved results to output/table2_by_state.csv\n")

# Generate LaTeX table
generate_latex <- function(results_table) {
  states <- unique(results_table$State)

  latex <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Table 2 Replication by State}",
    "\\label{tab:table2_by_state}",
    "\\small",
    "\\begin{tabular}{llccccc}",
    "\\hline\\hline",
    "State & Variable & (1) & (2) & (3) & (4) & (5) \\\\",
    " &  & toiletuse & toiletuse & latrine\\_pref1 & latrine\\_pref2 & latrine\\_pref3 \\\\",
    "\\hline"
  )

  for (state in states) {
    state_data <- results_table[results_table$State == state, ]

    # Female row
    female_coefs <- sapply(c("m1", "m2", "m3", "m4", "m5"), function(m) {
      row <- state_data[state_data$Model == m, ]
      if (nrow(row) == 0 || is.na(row$Female_Coef)) return("-")
      format_coef(row$Female_Coef, row$Female_SE, 3)
    })

    female_ses <- sapply(c("m1", "m2", "m3", "m4", "m5"), function(m) {
      row <- state_data[state_data$Model == m, ]
      if (nrow(row) == 0 || is.na(row$Female_SE)) return("")
      sprintf("(%.3f)", row$Female_SE)
    })

    # Interaction row
    int_coefs <- sapply(c("m1", "m2", "m3", "m4", "m5"), function(m) {
      row <- state_data[state_data$Model == m, ]
      if (nrow(row) == 0 || is.na(row$Interaction_Coef)) return("-")
      format_coef(row$Interaction_Coef, row$Interaction_SE, 3)
    })

    int_ses <- sapply(c("m1", "m2", "m3", "m4", "m5"), function(m) {
      row <- state_data[state_data$Model == m, ]
      if (nrow(row) == 0 || is.na(row$Interaction_SE)) return("")
      sprintf("(%.3f)", row$Interaction_SE)
    })

    # N row
    ns <- sapply(c("m1", "m2", "m3", "m4", "m5"), function(m) {
      row <- state_data[state_data$Model == m, ]
      if (nrow(row) == 0 || is.na(row$N)) return("-")
      format(row$N, big.mark = ",")
    })

    # Mean DV row
    means <- sapply(c("m1", "m2", "m3", "m4", "m5"), function(m) {
      row <- state_data[state_data$Model == m, ]
      if (nrow(row) == 0 || is.na(row$Mean_DV)) return("-")
      sprintf("%.3f", row$Mean_DV)
    })

    latex <- c(latex,
      sprintf("\\multicolumn{7}{l}{\\textbf{%s}} \\\\", gsub("_", "\\\\_", state)),
      sprintf(" & Female & %s \\\\", paste(female_coefs, collapse = " & ")),
      sprintf(" &  & %s \\\\", paste(female_ses, collapse = " & ")),
      sprintf(" & Muslim Share $\\times$ Female & %s \\\\", paste(int_coefs, collapse = " & ")),
      sprintf(" &  & %s \\\\", paste(int_ses, collapse = " & ")),
      sprintf(" & N & %s \\\\", paste(ns, collapse = " & ")),
      sprintf(" & Mean DV & %s \\\\", paste(means, collapse = " & ")),
      "\\hline"
    )
  }

  latex <- c(latex,
    "\\multicolumn{7}{l}{\\footnotesize Robust standard errors in parentheses. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\",
    "\\multicolumn{7}{l}{\\footnotesize Models (1)-(2): Village/HH FE, toilet use sample. Models (3)-(5): Village FE, latrine pref sample.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )

  return(latex)
}

latex_output <- generate_latex(results_table)
writeLines(latex_output, "output/table2_by_state.tex")
cat("Saved LaTeX table to output/table2_by_state.tex\n")

# Print summary
cat("\n=== Summary of Results ===\n\n")
print(results_table[, c("State", "Model", "DV", "N", "Female_Coef", "Interaction_Coef")])

# Verification: Compare pooled results to original Table 2
cat("\n=== Verification: Pooled Results vs Original Table 2 ===\n")
cat("Original Table 2 (from toiletpref_muslimshare.tex):\n")
cat("  Model 1: Female = 0.0833***, Muslim Share x Female = 0.125***, N = 7,752\n")
cat("  Model 2: Female = 0.0833***, Muslim Share x Female = 0.133***, N = 7,738\n")
cat("  Model 3: Female = 0.0325, Muslim Share x Female = 0.336, N = 1,477\n")
cat("  Model 4: Female = -0.012, Muslim Share x Female = 0.434**, N = 1,477\n")
cat("  Model 5: Female = 0.00107, Muslim Share x Female = 0.378**, N = 1,477\n")
cat("\nPooled results from this script:\n")
pooled_data <- results_table[results_table$State == "All States (Pooled)", ]
for (i in 1:nrow(pooled_data)) {
  row <- pooled_data[i, ]
  cat(sprintf("  %s: Female = %.4f, Interaction = %.4f, N = %s\n",
              row$Model, row$Female_Coef, row$Interaction_Coef,
              format(row$N, big.mark = ",")))
}
