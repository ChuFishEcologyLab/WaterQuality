#' Plot to compare Hirsh and Theobald datasets
#'
#' @param master_data  Master dataset.
#' @param outdir Output directory (where figures are saved).
#'
#' @export

plot_hirsh_vs_theobald <- function(
  master_data = wq_prepare_data("master_data"),
  outdir = "figs"
) {
  df_wq <- master_data
  cor_07 <- cor(df_wq$hirsh_pearson_lvl7, df_wq$theobald_lvl7)
  cor_12 <- cor(df_wq$hirsh_pearson_lvl12, df_wq$theobald_lvl12)
  cli::cli_alert_info(
    "Correlation Hirsh vs Theobald: lvl 7 -> {cor_07}, lvl 12 -> {cor_12}"
  )

  dir.create(outdir, showWarnings = FALSE)
  p1 <- df_wq |>
    ggplot(aes(x = hirsh_pearson_lvl7, y = theobald_lvl7)) +
    geom_point() +
    labs(
      title = "Hydrobasins level 7",
      x = "Hirsh-Pearson Cummulative Threat",
      y = "Theobald Cummulative Threat"
    ) +
    scale_y_continuous(limits = ~ range(.x, 1)) +
    annotate(
      "text",
      x = 2, y = 0.96,
      label = paste("Correlation:", round(cor_07, 3))
    )

  p2 <- df_wq |>
    ggplot(aes(x = hirsh_pearson_lvl12, y = theobald_lvl12)) +
    geom_point() +
    scale_y_continuous(limits = ~ range(.x, 1)) +
    labs(
      title = "Hydrobasins level 12",
      x = "Hirsh-Pearson Cummulative Threat",
      y = "Theobald Cummulative Threat"
    ) +
    annotate(
      "text",
      x = 2, y = 0.96,
      label = paste("Correlation:", round(cor_12, 3))
    )


  p1 + p2
  ggsave(file.path(outdir, "fig_theobald_vs_hirsh.png"), height = 7, width = 18, dpi = 300)
}
