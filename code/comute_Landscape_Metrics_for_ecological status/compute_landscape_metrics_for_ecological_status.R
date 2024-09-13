library(groundhog)
pkgs <- c("terra",
          "purrr",
          "landscapemetrics",
          "magrittr",
          "dplyr",
          "sf",
          "data.table")
groundhog.library(pkgs,'2024-04-25')
rm(pkgs)

# prepare functions ------------------------------------------------------
compute_metrics <- function(polygon, raster) {
  cropped_raster <- crop(raster, polygon)
  masked_raster  <- mask(cropped_raster, polygon)
  metrics        <- calculate_lsm(masked_raster, metric = c("shdi"))$value
  return(metrics)
}

# load data --------------------------------------------------------------
# available at: https://data.jrc.ec.europa.eu/dataset/15f86c84-eae1-4723-8e00-c1b35c8f56b9
landcover  <- rast("E://Arbeit/Data/LULC/eu_crop_map/EUCROPMAP_2018.tif")
#- available at: https://zenodo.org/records/4322819
catchments <- st_read("E://Arbeit/data/books_and_papers/Lemm_et_al_21/MultipleStress_RiverEcoStatus.shp")

# prepare catchment data -------------------------------------------------
#- change coordinate reference system of catchments (WGS84; EPSG:4326) to that of the land use and land cover data (ETRS89, EPSG:3035)
catchments %<>% st_transform(crs = crs(landcover))

#- Convert catchment sf multipolygon object to a list of individual polygons
polygon_list <- 
        catchments %>% 
        st_cast("POLYGON") %>% 
        split(seq(nrow(.)))

metrics <- map_dbl(polygon_list, ~compute_metrics(., landcover))
saveRDS(metrics, "data/temp_shannon_metrics_delete_me.rds")

polygon_dt <- rbindlist(polygon_list)
polygon_dt[, shannon := metrics]
polygon_dt_sum <- polygon_dt[, mean(shannon, na.rm = T), by = "m_zhyd_1"]
polygon_dt2 <- polygon_dt_sum[polygon_dt, on = "m_zhyd_1"]

polygon_dt2[, shannon := NULL]
names(polygon_dt2)[2] <- "shannon"
polygon_dt2 <- unique(polygon_dt2, by = "m_zhyd_1")
polygon_dt2

#- alternative version using a loop
# for (i in 1:nrow(catchments)){
#   print(i/nrow(catchments))
#   catchments$shannon[i] = compute_metrics(polygon = catchments[i,], raster = landcover)
# }

# save to file ----------------------------------------------------------------------
saveRDS(polygon_dt2, "data/catchments_w_shannon.rds")
