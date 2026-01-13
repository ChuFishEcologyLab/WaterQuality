#' Read data
#'
#' @param type data type.
#'
#' @export
wq_prepare_data <- function(type = c("water_chemistry", "hydrobasins_sites", "hydrobasins_lvl07", "hydrobasins_lvl12")) {
  type <- match.arg(type)
  switch(type,
    water_chemistry = path_input_data("water_chemistry_2025.csv") |>
      utils::read.csv() |>
      janitor::clean_names() |>
      dplyr::mutate(
        sample_date = sample_date |> as.Date(format = "%m/%d/%Y")
      ) |>
      terra::vect(geom = c("longitude", "latitude")),
    hydrobasins_sites = path_input_data("hydrobasins_sites.gpkg") |>
      terra::vect(),
    hydrobasins_lvl07 = path_input_data("hydrobasins_lvl07.gpkg") |>
      terra::vect(),
    hydrobasins_lvl12 = path_input_data("hydrobasins_lvl12.gpkg") |>
      terra::vect(),
    cli::cli_abort("Unknown data type")
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
