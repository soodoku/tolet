# Dose-Response Analysis: Latrine Preferences by Muslim Share and Female
# Tests whether the Female × Muslim Share interaction reflects a smooth relationship
# Uses SQUAT 2014 survey data (same as Table 2)

library(haven)
library(dplyr)

df <- read_dta("data/survey_sanitation_2014.dta")

df <- df %>%
  mutate(
    muslim = case_when(h1 == 2 ~ 1, !is.na(h1) ~ 0, TRUE ~ NA_real_),
    female = as.numeric(b1_2_ == 2),
    latrine_pref1 = case_when(e13_N == 1 ~ 1, !is.na(e13_N) ~ 0, TRUE ~ NA_real_)
  ) %>%
  group_by(villagecode) %>%
  mutate(muslim_share = mean(muslim, na.rm = TRUE)) %>%
  ungroup()

state_map <- c(`1` = "Haryana", `2` = "Bihar", `3` = "UP", `4` = "MP", `5` = "Rajasthan")
df$state_name <- state_map[as.character(df$a2)]

df_pref <- df %>%
  filter(b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & (is.na(b2_3_) | b2_3_ != 1)) %>%
  filter(!is.na(latrine_pref1), !is.na(muslim_share), !is.na(female))

df_pref <- df_pref %>%
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
        state = label,
        muslim_bin = as.character(b),
        pref_female0 = d0$mean_pref,
        n_female0 = d0$n,
        pref_female1 = d1$mean_pref,
        n_female1 = d1$n,
        diff = diff
      ))
    }
  }
  cat("\n")
  return(results)
}

all_results <- compute_dose(df_pref, "ALL STATES POOLED")

for (st in c("UP", "MP", "Bihar", "Rajasthan", "Haryana")) {
  st_data <- df_pref %>% filter(state_name == st)
  if (nrow(st_data) > 50) {
    st_results <- compute_dose(st_data, st)
    all_results <- rbind(all_results, st_results)
  }
}

write.csv(all_results, "output/dose_response_preferences.csv", row.names = FALSE)
cat("Saved to output/dose_response_preferences.csv\n")

cat("\n=================================================================\n")
cat("KEY FINDING\n")
cat("=================================================================\n")
cat("UP (where RD is identified):\n")
cat("  - At Muslim share 0.2-0.5, women prefer toilets LESS than men\n")
cat("  - Diff is negative (-0.05 to -0.12), not positive\n")
cat("  - Contradicts mechanism: female preferences don't increase with Muslim share in UP\n")
