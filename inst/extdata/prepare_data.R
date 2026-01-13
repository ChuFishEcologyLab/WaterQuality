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

## Hirsh-Pearson dataset 

wc_sites  <- terra::vect("inst/extdata/hydrobasins_sites.gpkg")
wc_lvl07  <- terra::vect("inst/extdata/hydrobasins_lvl07.gpkg")
wc_lvl12  <- terra::vect("inst/extdata/hydrobasins_lvl12.gpkg")


cum_threat_hp <- terra::rast(
    "inst/data-raw/doi-10.5683-sp2-evkavl/cum_threat2020.02.18.tif"
    )

# TODO
cum_threat_th <- terra::rast(
    "inst/data-raw/doi-10.5683-sp2-evkavl/cum_threat2020.02.18.tif"
)


val_lvl07_hp  <- terra::extract(cum_threat_hp, wc_lvl07)
val_lvl07_hp$H7_ID <- wc_lvl07$HyB7ID[val_lvl07_hp$ID]

val_lvl07_th <- terra::extract(cum_threat_hp, wc_lvl07)
val_lvl07_th$H7_ID <- wc_lvl07$HyB7ID[val_lvl07_th$ID]

# using the mean 

val_lvl07 <- val_lvl07_hp  |>
    dplyr::group_by(Hy07ID) |>
    dplyr::summarise(
        hirsh_pearson = mean(cum_threat2020.02.18, na.rm = TRUE)
    ) |> 
    dplyr::inner_join(
        val_lvl07_th |>
            dplyr::group_by(Hy07ID) |>
            dplyr::summarise(
                theobald = mean(cum_threat2020.02.18, na.rm = TRUE)
            )
    )

utils::write.csv(val_lvl07, "inst/extdata/val_lvl07.csv")


val_lvl12_hp <- terra::extract(cum_threat_hp, wc_lvl12)
val_lvl12_hp$H12_ID <- wc_lvl12$H12_ID[val_lvl12_hp$ID]

val_lvl12_th <- terra::extract(cum_threat_hp, wc_lvl12)
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
                theobald = mean(cum_threat2020.02.18, na.rm = TRUE)
            )
    )
utils::write.csv(val_lvl12, "inst/extdata/val_lvl12.csv")


# Prepare master data frame
