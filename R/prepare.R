#' Read data used in the analysis
#'
#' @param type character. Type of data to read. One of:
#' - `"water_chemistry"`: Water chemistry data from 2015-2024 as SpatVector
#' - `"hydrobasins_sites"`: Site-level hydrobasins polygons as SpatVector
#' - `"hydrobasins_lvl07"`: Level 7 hydrobasins polygons as SpatVector
#' - `"hydrobasins_lvl12"`: Level 12 hydrobasins polygons as SpatVector
#' - `"val_lvl07"`: Cumulative threats for level 7 hydrobasins as data frame
#' - `"val_lvl07_components"`: Same as above but for the differents component of HP
#' - `"val_lvl12"`: Cumulative threats for level 12 hydrobasins as data frame
#' - `"val_lvl12_components"`: Same as above but for the differents component of HP
#' - `"master_data"`: Master dataset as data frame
#'
#' @return For spatial data types (water_chemistry, hydrobasins_*), returns a
#'   SpatVector object. For zonal statistics (val_lvl*), returns a data frame.
#'
#' @export
wq_prepare_data <- function(
  type = c(
    "water_chemistry",
    "hydrobasins_sites",
    "hydrobasins_lvl07",
    "hydrobasins_lvl12",
    "val_lvl07_components",
    "val_lvl12_components",
    "master_data"
  )
) {
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
      terra::vect() |>
      janitor::clean_names(),
    hydrobasins_lvl07 = path_input_data("hydrobasins_lvl07.gpkg") |>
      terra::vect() |>
      janitor::clean_names(),
    hydrobasins_lvl12 = path_input_data("hydrobasins_lvl12.gpkg") |>
      terra::vect() |>
      janitor::clean_names(),
    val_lvl07 = path_input_data("val_lvl07.csv") |>
      utils::read.csv() |>
      janitor::clean_names(),
    val_lvl12 = path_input_data("val_lvl12.csv") |>
      utils::read.csv() |>
      janitor::clean_names(),
    val_lvl07_components = path_input_data("val_lvl07_hp_components.csv") |>
      utils::read.csv() |>
      janitor::clean_names() |>
      dplyr::rename_with(~ paste0("lvl07_", .x), built:oil_gas),
    val_lvl12_components = path_input_data("val_lvl12_hp_components.csv") |>
      utils::read.csv() |>
      janitor::clean_names() |>
      dplyr::rename_with(~ paste0("lvl12_", .x), built:oil_gas),
    master_data = path_input_data("master_dataset.parquet") |>
      arrow::read_parquet() |>
      janitor::clean_names(),
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
