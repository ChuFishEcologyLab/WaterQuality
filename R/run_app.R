#' Run the Shiny Application
#'
#' This function launches the Water Quality Logistic Regression Explorer Shiny application.
#' The app allows users to interactively build and explore logistic regression models
#' using any numeric columns from the master dataset.
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @param options.shiny A list of options to pass to `shiny::shinyApp()`.
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
#' @importFrom stats as.formula binomial complete.cases fitted
run_app <- function(
    ...,
    options.shiny = list()
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      options = options.shiny
    ),
    golem_opts = list(...)
  )
}
