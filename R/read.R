#' Read data
#'
#' @param type data type.
#'
#' @export
wq_prepare_data <- function(type = c("water_chemistry")) {
  type <- match.arg(type)
  switch(type,
    water_chemistry = path_input_data("water_chemistry_2025.csv") |>
      utils::read.csv() |>
      janitor::clean_names() |>
      dplyr::mutate(
        sample_date = sample_date |> as.Date(format = "%m/%d/%Y")
      ) |>
      sf::st_as_sf(coords = c("longitude", "latitude")),
    cli::cli_abort("unknwon data type")
  )
}

#' INTERNAL
#'
#' @noRd
path_input_data <- function(filename) {
  fs::path_package("WaterQuality", "extdata", filename)
}

path_output_data <- function(filename) {
  fs::dir_create("output_data")
  fs::path("output_data", filename)
}

path_output_fig <- function(filename) {
  fs::dir_create("figs/v2")
  fs::path("figs/v2", filename)
}
