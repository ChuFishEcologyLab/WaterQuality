#' Run analysis for individual Hirsh-Pearson threat components
#'
#' Fits logistic regressions (GLMs) for each water chemistry parameter against
#' individual Hirsh-Pearson threat components (e.g. forestry, mining) at
#' hydrobasin levels 7 and 12. Produces effect-size plots per level and
#' response variable.
#'
#' @param prepare_data A logical. Should the steps to prepare data be run?
#' @param outdir Output directory (where figures are saved).
#' 
#' @return A data frame with one row per stressor/explanatory/response
#'   combination, including effect size, p-value, confidence interval, and
#'   explained deviance.
#'
#' @export
#'
run_analysis_components <- function(prepare_data = FALSE, outdir = "figs") {

  if (prepare_data) {
    # included for reproducibility sake
    df_wq <- prepare_component_data()
  } else {
    df_wq <- wq_prepare_data("component_data")
  }

  df_wq <- df_wq |>
    dplyr::mutate(dplyr::across(lvl07_built:lvl12_roads, scale))


  cli::cli_h1("Running GLMs")
  ls_res <- list()
  chem_vars <- unique(df_wq$wc_variable)
  vc_nm <- df_wq |> names()
  expl_vars <- vc_nm[grepl("^lvl[01][27]_.*", vc_nm)]
  resp_vars <- c("thr_day", "thr_month", "thr_year")

  out <- expand.grid(
    stressor = chem_vars,
    explanatory_var = expl_vars[!grepl("built|oil|dam", expl_vars)], # expl_vars,
    response_var = resp_vars
  )


  out$effect <- 0
  out$pval <- 0
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
    ls_res[[paste("res", i, j, k, sep = "_")]] <- mod
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
    for (j in c("lvl07", "lvl12")) {
      out |>
        dplyr::filter(response_var == i) |>
        dplyr::filter(grepl(j, explanatory_var)) |>
        dplyr::arrange(
          stressor, explanatory_var
        ) |>
        ggplot(aes(x = effect, y = stressor, color = explanatory_var, group = explanatory_var)) +
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
      dir.create(outdir, showWarnings = FALSE)
      ggsave(
        file.path(outdir, paste0("fig_effect_components_", i, "_", j, ".png")), 
        dpi = 300
      )
    }
  }

  out
}
