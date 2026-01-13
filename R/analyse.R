run_analysis <- function() {
  cli::cli_h1("Preparing master data frame")
  
  cli::cli_h2("Reading data")
  ct_07 <- wq_prepare_data("val_lvl07")
  ct_12 <- wq_prepare_data("val_lvl12")
  st <- wq_prepare_data("hydrobasins_sites")
  wc <- wq_prepare_data("water_chemistry")
  
  cli::cli_h2("Joining data frames")
  df_all <- wc |>
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

  cli::cli_h1("Running Linear Models")
}
