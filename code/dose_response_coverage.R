# Dose-Response Analysis: Coverage by Muslim Share and Female Reservation
# Tests whether the Female × Muslim Share interaction reflects a smooth relationship

library(haven)
library(dplyr)
library(ggplot2)

panel <- read_dta("data/SBM_panel.dta")
gp_data <- read_dta("data/final election caste sbm.dta")

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
  left_join(femres_data, by = "eleid") %>%
  filter(!is.na(muslim_share), !is.na(femalereservation), !is.na(runningvar2_norm_std))

bw <- 0.10
df_bw <- df %>%
  filter(abs(runningvar2_norm_std) <= bw)

df_bw <- df_bw %>%
  mutate(muslim_bin = cut(muslim_share,
                          breaks = seq(0, max(muslim_share, na.rm = TRUE) + 0.01, by = 0.05),
                          include.lowest = TRUE, right = FALSE))

dose_response <- df_bw %>%
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
bins <- sort(unique(dose_response$muslim_bin))
for (b in bins) {
  d0 <- dose_response %>% filter(muslim_bin == b, femalereservation == 0)
  d1 <- dose_response %>% filter(muslim_bin == b, femalereservation == 1)

  if (nrow(d0) > 0 && nrow(d1) > 0) {
    diff <- d1$mean_coverage - d0$mean_coverage
    cat(sprintf("%-16s | %5.1f (%4d)  | %5.1f (%4d)  | %+6.1f\n",
        as.character(b),
        d0$mean_coverage, d0$n,
        d1$mean_coverage, d1$n,
        diff))

    results <- rbind(results, data.frame(
      muslim_bin = as.character(b),
      mean_muslim = d0$mean_muslim,
      coverage_female0 = d0$mean_coverage,
      n_female0 = d0$n,
      coverage_female1 = d1$mean_coverage,
      n_female1 = d1$n,
      diff = diff
    ))
  }
}

write.csv(results, "output/dose_response_coverage.csv", row.names = FALSE)
cat("\nSaved to output/dose_response_coverage.csv\n")

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

ggsave("output/dose_response_coverage.pdf", p, width = 8, height = 6)
cat("Plot saved to output/dose_response_coverage.pdf\n")
