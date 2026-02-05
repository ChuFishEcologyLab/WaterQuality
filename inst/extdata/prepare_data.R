# inst/extdata/water_chemistry_2025.csv
# is tab from the xlsx file exported as a csv file

sf::read_sf(
  "inst/data-raw/3_WatershedsandWQsites/commondata/wqdata.gdb",
) |>
  dplyr::select(c("LATITUDE", "LONGITUDE", "H7_ID", "H12_ID", "LJ_Site_ID")) |>
  sf::st_write("inst/extdata/hydrobasins_sites.gpkg")

sf::read_sf(
  "inst/data-raw/3_WatershedsandWQsites/commondata/wqdata.gdb",
  layer = "H7_WQ"
) |>
  sf::st_write("inst/extdata/hydrobasins_lvl07.gpkg")

sf::read_sf(
  "inst/data-raw/3_WatershedsandWQsites/commondata/wqdata.gdb",
  layer = "H12_WQ"
) |>
  sf::st_write("inst/extdata/hydrobasins_lvl12.gpkg")


# Value Extraction fron the two large datasets

wc_sites <- terra::vect("inst/extdata/hydrobasins_sites.gpkg")
wc_lvl07 <- terra::vect("inst/extdata/hydrobasins_lvl07.gpkg")
wc_lvl12 <- terra::vect("inst/extdata/hydrobasins_lvl12.gpkg")

cum_threat_hp <- terra::rast(
  "inst/data-raw/doi-10.5683-sp2-evkavl/cum_threat2020.02.18.tif"
)

cum_threat_th <- terra::rast(
  "inst/data-raw/HMv20240801_2022s_AA_300.tif"
)


val_lvl07_hp <- terra::extract(cum_threat_hp, wc_lvl07)
val_lvl07_hp$H7_ID <- wc_lvl07$HyB7ID[val_lvl07_hp$ID]

val_lvl07_th <- terra::extract(cum_threat_th, wc_lvl07)
val_lvl07_th$H7_ID <- wc_lvl07$HyB7ID[val_lvl07_th$ID]

# using the mean

val_lvl07 <- val_lvl07_hp |>
  dplyr::group_by(H7_ID) |>
  dplyr::summarise(
    hirsh_pearson = mean(cum_threat2020.02.18, na.rm = TRUE)
  ) |>
  dplyr::inner_join(
    val_lvl07_th |>
      dplyr::group_by(H7_ID) |>
      dplyr::summarise(
        theobald = mean(HMv20240801_2022s_AA_300, na.rm = TRUE)
      )
  )

utils::write.csv(val_lvl07, "inst/extdata/val_lvl07.csv", row.names = FALSE)


val_lvl12_hp <- terra::extract(cum_threat_hp, wc_lvl12)
val_lvl12_hp$H12_ID <- wc_lvl12$H12_ID[val_lvl12_hp$ID]

val_lvl12_th <- terra::extract(cum_threat_th, wc_lvl12)
val_lvl12_th$H12_ID <- wc_lvl12$H12_ID[val_lvl12_th$ID]


val_lvl12 <- val_lvl12_hp |>
  dplyr::group_by(H12_ID) |>
  dplyr::summarise(
    hirsh_pearson = mean(cum_threat2020.02.18, na.rm = TRUE)
  ) |>
  dplyr::inner_join(
    val_lvl12_th |>
      dplyr::group_by(H12_ID) |>
      dplyr::summarise(
        theobald = mean(HMv20240801_2022s_AA_300, na.rm = TRUE)
      )
  )
utils::write.csv(val_lvl12, "inst/extdata/val_lvl12.csv", row.names = FALSE)


# Prepare master data frame

# use this is wq_prepare_data
df_all <- run_analysis()

write.csv(df_all, "inst/extdata/master_dataset.csv", row.names = FALSE)

jj <- wq_prepare_data("master_data")
plot(jj$hirsh_pearson_lvl7, jj$theobald_lvl7)


## All components HP

vc_comps <- c(
  "built",
  "crop",
  "dam_and_associated_reservoir",
  "forestry_harvest",
  "mines",
  "nav_water",
  "night_lights",
  "oil_gas"
)

ls_threat_lvl7 <- list()
for (comp in vc_comps) {
  cli::cli_alert_info(comp)
  threat <- terra::rast(
    paste0("inst/data-raw/doi-10.5683-sp2-evkavl/", comp, ".tif")
  )
  val_lvl07_hp <- terra::extract(threat, wc_lvl07)
  val_lvl07_hp$H7_ID <- wc_lvl07$HyB7ID[val_lvl07_hp$ID]

  ls_threat_lvl7[[comp]] <- val_lvl07_hp |>
    dplyr::group_by(H7_ID) |>
    dplyr::summarise(
      {{ comp }} := mean(.data[[comp]], na.rm = TRUE)
    )
}

ls_threat_lvl7 |>
  Reduce(f = inner_join) |>
  utils::write.csv(
    "inst/extdata/val_lvl07_hp_components.csv",
    row.names = FALSE
  )




ls_threat_lvl12 <- list()
for (comp in vc_comps) {
  cli::cli_alert_info(comp)
  threat <- terra::rast(
    paste0("inst/data-raw/doi-10.5683-sp2-evkavl/", comp, ".tif")
  )
  val_lvl12_hp <- terra::extract(threat, wc_lvl12)
  val_lvl12_hp$H12_ID <- wc_lvl12$H12_ID[val_lvl12_hp$ID]

  ls_threat_lvl12[[comp]] <- val_lvl12_hp |>
    dplyr::group_by(H12_ID) |>
    dplyr::summarise(
      {{ comp }} := mean(.data[[comp]], na.rm = TRUE)
    )
}


ls_threat_lvl12 |>
  Reduce(f = inner_join) |>
  utils::write.csv(
    "inst/extdata/val_lvl12_hp_components.csv",
    row.names = FALSE
  )


# using the mean

val_lvl07 <- val_lvl07_hp |>
  dplyr::group_by(H7_ID) |>
  dplyr::summarise(
    hirsh_pearson = mean(cum_threat2020.02.18, na.rm = TRUE)
  )

utils::write.csv(val_lvl07, "inst/extdata/val_lvl07.csv", row.names = FALSE)


val_lvl12_hp <- terra::extract(cum_threat_hp, wc_lvl12)
val_lvl12_hp$H12_ID <- wc_lvl12$H12_ID[val_lvl12_hp$ID]

val_lvl12_th <- terra::extract(cum_threat_th, wc_lvl12)
val_lvl12_th$H12_ID <- wc_lvl12$H12_ID[val_lvl12_th$ID]


val_lvl12 <- val_lvl12_hp |>
  dplyr::group_by(H12_ID) |>
  dplyr::summarise(
    hirsh_pearson = mean(cum_threat2020.02.18, na.rm = TRUE)
  ) |>
  dplyr::inner_join(
    val_lvl12_th |>
      dplyr::group_by(H12_ID) |>
      dplyr::summarise(
        theobald = mean(HMv20240801_2022s_AA_300, na.rm = TRUE)
      )
  )
utils::write.csv(val_lvl12, "inst/extdata/val_lvl12.csv", row.names = FALSE)
