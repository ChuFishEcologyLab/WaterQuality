#' Run analysis
#'
#' @param prepare_data A logical. Should the steps to prepare data be run?
#' @export
#'
run_analysis_components <- function(prepare_data = FALSE) {
  if (prepare_data) {
    cli::cli_h1("Preparing master data frame")

    cli::cli_h2("Reading data")
    ct_07 <- wq_prepare_data("val_lvl07_components")
    ct_12 <- wq_prepare_data("val_lvl12_components")
    st <- wq_prepare_data("hydrobasins_sites")
    wc <- wq_prepare_data("water_chemistry")

    cli::cli_h2("Joining data frames")
    df_wq <- wc |>
      as.data.frame() |>
      dplyr::inner_join(
        st |> as.data.frame(),
        by = dplyr::join_by(lj_site_id)
      ) |>
      dplyr::inner_join(
        ct_07
      ) |>
      dplyr::inner_join(
        ct_12,
        by = dplyr::join_by(h12_id)
      )
  } else {
    stop("Not ready yet")
    # df_wq <- wq_prepare_data("master_data")
  }

  df_wq <- df_wq |>
    dplyr::mutate(dplyr::across(lvl07_built:lvl12_oil_gas, scale))


  cli::cli_h1("Running GLMs")
  ls_res <- list()
  chem_vars <- unique(df_wq$wc_variable)
  expl_vars <- c(
    names(ct_07)[-1], names(ct_12)[-1]
  )
  resp_vars <- c("thr_day", "thr_month", "thr_year")

  out <- expand.grid(
    stressor = chem_vars,
    explanatory_var = expl_vars[!grepl("built|oil|dam", expl_vars)], #expl_vars,
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
      dir.create("figs", showWarnings = FALSE)
      ggsave(paste0("figs/fig_effect_components_", i, "_", j, ".png"), dpi = 300)
    }
  }

  out
}
