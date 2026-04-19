library(stargazer)
library(haven)
library(dplyr)

cons_term <- "Statistical significance symbols for the constant terms are suppressed."

load_gp_data <- function(bw = NULL) {
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
    mutate(
      female_x_muslim = femalereservation * muslim_share,
      inst_x_muslim = femaleinstrument * muslim_share,
      running_x_inst = runningvar2_norm_std * femaleinstrument,
      running_x_muslim = runningvar2_norm_std * muslim_share,
      running_x_inst_x_muslim = runningvar2_norm_std * femaleinstrument * muslim_share,
      running_sq = runningvar2_norm_std^2
    )

  if (!is.null(bw)) {
    df <- df %>%
      filter(abs(runningvar2_norm_std) <= bw) %>%
      mutate(weight = (bw - abs(runningvar2_norm_std)) / bw)
  }

  df
}

load_survey_data <- function() {
  df <- read_dta("data/survey_sanitation_2014.dta")

  state_map <- c(
    `1` = "Haryana",
    `2` = "Bihar",
    `3` = "Uttar Pradesh",
    `4` = "Madhya Pradesh",
    `5` = "Rajasthan"
  )

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
      ),
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
      ),
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
      ),
      female = as.numeric(b1_2_ == 2),
      hhid = paste(villagecode, id, sep = "-"),
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
    ) %>%
    group_by(villagecode) %>%
    mutate(muslim_share = mean(muslim, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(
      state_name = state_map[as.character(a2)],
      villagecode_f = as.factor(villagecode),
      e8_f = as.factor(e8),
      hhid_f = as.factor(hhid),
      female_f = factor(female)
    )

  df
}

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

format_se <- function(se) {
  if (is.null(se) || is.na(se)) return("")
  sprintf("(%.3f)", se)
}

custom_stargazer <- function(models, notes, digits = 2, float.env = "table", ..., out = NULL) {
    stargazer_output <- capture.output(
        stargazer(
            models,
            header = FALSE,
            type = "latex",
            model.names = FALSE,
            omit.stat = c("rsq", "ser", "f"),
            digits = digits,
            column.sep.width = "0pt",
            dep.var.caption = "",
            dep.var.labels.include = FALSE,
            star.cutoffs = c(0.05, 0.01, 0.001),
            report = "vc*s",
            no.space = TRUE,
            single.row = FALSE,
            font.size = "scriptsize",
            notes.append = FALSE,
            notes = NULL,
            notes.align = "l",
            ...
        )
    )

    repeat {
        new_output <- gsub(
            pattern = "(Constant.*?)(\\$.*?\\$)",
            replacement = "\\1",
            x = stargazer_output,
            perl = TRUE
        )
        if (identical(new_output, stargazer_output)) break
        stargazer_output <- new_output
    }

    stargazer_output <- stargazer_output[
        !grepl("\\\\begin\\{table\\}|\\\\end\\{table\\}|\\\\begin\\{sidewaystable\\}|\\\\end\\{sidewaystable\\}", stargazer_output)
    ]

    if (float.env == "table") {
        wrapped_output <- paste0(
            "\\begin{table}[!htbp]\n",
            "\\centering\n",
            "\\begin{threeparttable}\n",
            paste(stargazer_output, collapse = "\n"),
            "\n\\begin{tablenotes}[flushleft]\n\\scriptsize\n",
            paste0("\\item[] ", notes, collapse = "\n"),
            "\n\\end{tablenotes}\n",
            "\\end{threeparttable}\n",
            "\\end{table}"
        )
    } else if (float.env == "sidewaystable") {
        wrapped_output <- paste0(
            "\\begin{sidewaystable}[!htbp]\n",
            "\\centering\n",
            "\\begin{threeparttable}\n",
            paste(stargazer_output, collapse = "\n"),
            "\n\\begin{tablenotes}[flushleft]\n\\setlength{\\itemindent}{0em}\n\\scriptsize\n",
            paste0("\\item[] ", notes, collapse = "\n"),
            "\n\\end{tablenotes}\n",
            "\\end{threeparttable}\n",
            "\\end{sidewaystable}"
        )
    } else {
        stop("Invalid float_env. Use 'table' or 'sidewaystable'.")
    }

    if (!is.null(out)) {
        writeLines(wrapped_output, con = out)
    } else {
        cat(wrapped_output, sep = "\n")
    }
}
