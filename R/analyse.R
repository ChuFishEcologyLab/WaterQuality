#' Run analysis using Hirsh-Pearson and Theobald cumulative threats
#'
#' Fits logistic regressions (GLMs) for each water chemistry parameter against
#' cumulative threat indices (Hirsh-Pearson and Theobald) at hydrobasin levels
#' 7 and 12. Produces effect-size plots and regression plots.
#'
#' @param prepare_data A logical. Should the steps to prepare data be run?
#' @param outdir Output directory (where figures and csv of results are saved).
#'
#' @return A data frame with one row per stressor/explanatory/response
#'   combination, including effect size, p-value, confidence interval, and
#'   explained deviance.
#'
#' @import ggplot2 patchwork
#' @export
#'
run_analysis <- function(prepare_data = FALSE, outdir = "figs") {
  if (prepare_data) {
    # included for reproducibility sake
    df_wq <- prepare_master_data()
  } else {
    df_wq <- wq_prepare_data("master_data")
  }

  df_wq <- df_wq |>
    dplyr::mutate(
      hirsh_pearson_lvl7 = scale(hirsh_pearson_lvl7),
      theobald_lvl7 = scale(theobald_lvl7),
      hirsh_pearson_lvl12 = scale(hirsh_pearson_lvl12),
      theobald_lvl12 = scale(theobald_lvl12)
    )


  cli::cli_h1("Running GLMs")
  ls_res <- list()
  chem_vars <- unique(df_wq$wc_variable)
  expl_vars <- c(
    "hirsh_pearson_lvl7",
    "theobald_lvl7",
    "hirsh_pearson_lvl12",
    "theobald_lvl12"
  )
  resp_vars <- c("thr_day", "thr_month", "thr_year")

  out <- expand.grid(
    stressor = chem_vars,
    explanatory_var = expl_vars,
    response_var = resp_vars
  )

  out$effect <- out$pval <- out$pval_shape <- 0
  out$pval_signif <- FALSE
  out$conf_low <- out$conf_high <- 0
  out$expl_dev <- 0

  cli::cli_progress_bar("GLMs", total = nrow(out))
  l <- 0
  for (r in seq_len(nrow(out))) {
    l <- l + 1
    i <- out$stressor[r]
    j <- out$explanatory_var[r]
    k <- out$response_var[r]
    df_tmp <- df_wq |>
      dplyr::filter(wc_variable == {{ i }})
    fml <- as.formula(paste(k, "~", j))
    cli::cli_alert_info("Variable: {i}, Formula: {fml  |> deparse()}")
    mod <- stats::glm(
      fml,
      data = df_tmp,
      family = stats::binomial(link = "logit")
    )
    sum_mod <- summary(mod)
    out$effect[l] <- stats::coef(sum_mod)[2, 1]
    out$pval[l] <- stats::coef(sum_mod)[2, 4]
    out$pval_signif[l] <- out$pval[l] < 1e-3
    out$pval_shape[l] <- 19 + out$pval_signif[l] * 2
    suppressMessages(conf_int <- stats::confint(mod))
    out$conf_low[l] <- conf_int[2, 1]
    out$conf_high[l] <- conf_int[2, 2]
    out$expl_dev[l] <- (sum_mod$null.deviance - sum_mod$deviance) / sum_mod$null.deviance
    cli::cli_progress_update()
  }


  pd <- position_dodge(width = 0.6)
  for (i in resp_vars) {
    out |>
      dplyr::filter(response_var == i) |>
      dplyr::arrange(
        stressor, explanatory_var
      ) |>
      ggplot(
        aes(
          x = effect,
          y = stressor,
          color = explanatory_var,
          group = explanatory_var
        )
      ) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      geom_errorbar(
        aes(xmin = conf_low, xmax = conf_high),
        height = 0.2,
        position = pd
      ) +
      scale_shape_manual(values = c(21, 20)) +
      geom_point(aes(shape = pval_signif), position = pd, size = 2) +
      labs(
        x = "Effect size",
        y = NULL,
        color = "Group"
      ) +
      theme_minimal()
    ggsave(file.path(outdir, paste0("/fig_effect_", i, ".png")), height = 7, width = 9, dpi = 300)
  }

  # adding regression plots
  cli::cli_alert_info("Ploting regressions")
  p <- df_wq |>
    dplyr::filter(
      wc_variable %in% c("Dissolved_Oxygen", "Nitrate", "Total_Dissolved_Solids", "Dissolved_Chloride")
    ) |>
    dplyr::mutate(
      wc_variable = gsub("_", " ", wc_variable)
    ) |>
    ggplot(aes(x = hirsh_pearson_lvl12, y = thr_year)) +
    geom_point(alpha = 0.5) + # Add the raw data points
    stat_smooth(
      method = "glm",
      method.args = list(family = "binomial"),
      se = TRUE,
      color = "#8c21c6",
      linetype = "solid"
    ) +
    labs(
      x = "Hirsh-Pearson cumulative threat (scaled)",
      y = "Threshold exceedance (observed and predicted)"
    ) + # Label the y-axis
    facet_wrap(vars(wc_variable))
  ggsave(file.path(outdir, "fig_regression_hirsh.png"), height = 14, width = 18, dpi = 300)

  p <- df_wq |>
    dplyr::mutate(
      wc_variable = gsub("_", " ", wc_variable)
    ) |>
    dplyr::filter(
      wc_variable %in% c("Dissolved_Oxygen", "Nitrate", "Total_Dissolved_Solids", "Dissolved_Chloride")
    ) |>
    ggplot(aes(x = theobald_lvl12, y = thr_year)) +
    geom_point(alpha = 0.5) + # Add the raw data points
    stat_smooth(
      method = "glm",
      method.args = list(family = "binomial"),
      se = TRUE,
      color = "#8c21c6",
      linetype = "solid"
    ) +
    labs(
      x = "Hirsh-Pearson cumulative threat (scaled)",
      y = "Threshold exceedance (observed and predicted)"
    ) +
    facet_wrap(vars(wc_variable))
  ggsave(file.path(outdir, "fig_regression_theobald.png"), height = 14, width = 18, dpi = 300)


  out
}
