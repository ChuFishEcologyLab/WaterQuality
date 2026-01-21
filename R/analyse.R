#' Run analysis
#'
#' @param prepare_data A logical. Should the steps to prepare data be run?
#' @export
#'
run_analysis <- function(prepare_data = FALSE) {
  if (prepare_data) {
    cli::cli_h1("Preparing master data frame")

    cli::cli_h2("Reading data")
    ct_07 <- wq_prepare_data("val_lvl07")
    ct_12 <- wq_prepare_data("val_lvl12")
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
        ct_07 |>
          as.data.frame() |>
          dplyr::rename(
            hirsh_pearson_lvl7 = hirsh_pearson,
            theobald_lvl7 = theobald
          ),
        by = dplyr::join_by(h7_id)
      ) |>
      dplyr::inner_join(
        ct_12 |>
          as.data.frame() |>
          dplyr::rename(
            hirsh_pearson_lvl12 = hirsh_pearson,
            theobald_lvl12 = theobald
          ),
        by = dplyr::join_by(h12_id)
      )
  } else {
    df_wq <- wq_prepare_data("master_data")
  }

  ls_res <- list()
  chem_vars <- unique(df_wq$wc_variable)
  expl_vars <- c("hirsh_pearson_lvl7", "theobald_lvl7", "hirsh_pearson_lvl12", "theobald_lvl12")
  resp_vars <- c("thr_day", "thr_month", "thr_year")

  out <- expand.grid(
    stressor = chem_vars,
    explainatory_var = expl_vars,
    response_var = resp_vars
  )

  out$effect <- 0
  out$pval <- 0
  out$expl_dev <- 0

  cli::cli_progress_bar("GLMs", total = length(chem_vars))
  l <- 0
  for (i in chem_vars) {
    cli::cli_progress_update()
    df_tmp <- df_wq |>
      dplyr::filter(wc_variable == {{ i }})
    for (j in expl_vars) {
      for (k in resp_vars) {
        l <- l + 1
        mod <- stats::glm(
          as.formula(paste(k, "~", j)),
          data = df_tmp,
          family = binomial(link = "logit")
        )
        ls_res[[paste("res", i, j, k, sep = "_")]] <- mod
        sum_mod <- summary(mod)
        out$effect[l] <- coef(sum_mod)[2, 1]
        out$pval[l] <- coef(sum_mod)[2, 4]
        out$expl_dev[l] <- (sum_mod$null.deviance - sum_mod$deviance) / sum_mod$null.deviance
      }
    }
  }
  cli::cli_progress_done()


  out
}
