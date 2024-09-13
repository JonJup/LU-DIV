# prepare data -----------------------------------------------------------
ehype   <- st_read("E://arbeit/Data/river_network/EHYPE3_subbasins/EHYPE3_subbasins.shp")

sites <- 
        unique(data, by = "site_id") %>% 
        st_as_sf(coords = c("x.coord", "y.coord"), crs = 3035)

ehype %<>% 
        st_transform(st_crs(sites)) %>%
        st_filter(sites)


#- soil
soil       <- rast("E://Arbeit/data/soil/sol_ph.h2o_lucas.iso.10694_m_30m_s0..0cm_2016_eumap_epsg3035_v0.2.tif")
ehype %<>% st_transform(crs(soil))
soil <- crop(soil, ehype)
soil <- mask(soil, ehype)
ext <- terra::extract(x = soil, 
        y = ehype)
setDT(ext)
names(ext) <- c("ID", "pH")
ext[, mean_ph := mean(pH, na.rm = T), by = "ID"]
ext <- unique(ext, by="ID") 
ehype$soil_ph <- ext$mean_ph
rm(soil)
rm(ext)

saveRDS(ehype, "data/quick_save_1_env.rds")

#- bioclim 
maxwarm    <- rast("E://Arbeit/Data/climate/bioclim_chelsa/CHELSA_bio10_05.tif") 
mincold    <- rast("E://Arbeit/Data/climate/bioclim_chelsa/CHELSA_bio10_06.tif") 
precwet    <- rast("E://Arbeit/Data/climate/bioclim_chelsa/CHELSA_bio10_13.tif") 
precdry    <- rast("E://Arbeit/Data/climate/bioclim_chelsa/CHELSA_bio10_14.tif") 
ehype %<>% st_transform(crs(maxwarm))
bioclim <- 
        list(maxwarm, mincold, precwet, precdry) %>%
        lapply(crop, ehype) %>%
        lapply(mask, ehype) %>%
        lapply(terra::extract, ehype) %>%
        lapply(function(x) setDT(x))
bioclim[[1]][, mean_bio05 := mean(CHELSA_bio10_05, na.rm = T), by = "ID"] 
bioclim[[2]][, mean_bio06 := mean(CHELSA_bio10_06, na.rm = T), by = "ID"] 
bioclim[[3]][, mean_bio13 := mean(CHELSA_bio10_13, na.rm = T), by = "ID"] 
bioclim[[4]][, mean_bio14 := mean(CHELSA_bio10_14, na.rm = T), by = "ID"] 
bioclim <- lapply(bioclim, function(x) unique(x, by = "ID"))
ehype$bioclim05 <- bioclim[[1]]$mean_bio05            
ehype$bioclim06 <- bioclim[[2]]$mean_bio06            
ehype$bioclim13 <- bioclim[[3]]$mean_bio13            
ehype$bioclim14 <- bioclim[[4]]$mean_bio14            
rm(bioclim)
rm(precdry, precwet, mincold, maxwarm)

gc()
saveRDS(ehype, "data/quick_save_2_env.rds")

# land use 

add_level_1_eu_name <- function(df) {
        df$Level_1_EU_Name <- case_when(
          df$EUCROPMAP_2018 == 100 ~ "Artificial land",
          df$EUCROPMAP_2018 >= 200 & df$EUCROPMAP_2018 <= 219 ~ "Cereals",
          df$EUCROPMAP_2018 >= 221 & df$EUCROPMAP_2018 <= 223 ~ "Root crops",
          df$EUCROPMAP_2018 >= 230 & df$EUCROPMAP_2018 <= 233 ~ "Non permanent industrial crops",
          df$EUCROPMAP_2018 == 240 ~ "Dry pulses, vegetables and flowers",
          df$EUCROPMAP_2018 == 250 ~ "Fodder crops",
          df$EUCROPMAP_2018 == 290 ~ "Bare arable land",
          df$EUCROPMAP_2018 == 300 ~ "Woodland and shrubland type of vegetation",
          df$EUCROPMAP_2018 == 500 ~ "Grassland",
          df$EUCROPMAP_2018 == 600 ~ "Bare land and lichens/moss",
          TRUE ~ "Unknown"  # For any codes not specified in the table
        )
        
        return(df)
      }


LULC    <- rast("E://Arbeit/Data/LULC/eu_crop_map/EUCROPMAP_2018.tif")
ehype %<>% st_transform(crs(LULC))

for (i in 1:nrow(ehype)) {

  print(paste(i, "/", nrow(ehype)))
  i.msk2 <- crop(x = LULC, ehype[i, ])
  i.msk2 <- mask(x = i.msk2, ehype[i, ])
  i.lsm2 <- lsm_l_shdi(i.msk2)
  i.ext <-
    terra::extract(i.msk2, y = ehype[i, ]) %>%
    # this correspondence can be tacken from Table 1 of d’Andrimont R. et al. (2021) “From parcel to continental scale – A first European crop type map based on Sentinel-1 and LUCAS Copernicus in-situ observations” Remote Sensing of Environment, 266:112708. 10.1016/j.rse.2021.112708
    add_level_1_eu_name()
  i.ext2 <- table(i.ext$Level_1_EU_Name)
  i.ext2 <- data.table(
    category = names(i.ext2),
    fraction = i.ext2 / sum(i.ext2) * 100
  )
  i.ext2[, fraction.V1 := NULL]
  i.combined_data <- i.ext2 %>%
    mutate(new_category = case_when(
      category %in% c(
        "Bare arable land", "Cereals", "Root crops",
        "Non permanent industrial crops",
        "Dry pulses, vegetables and flowers", "Fodder crops"
      ) ~ "Arable land",
      TRUE ~ category
    )) %>%
    group_by(new_category) %>%
    summarize(fraction.N = sum(fraction.N)) %>%
    arrange(desc(fraction.N))
  ehype$shannon_scale2[i] <- i.lsm2$value

  i.woodland       <-  filter(i.combined_data,new_category == "Woodland and shrubland type of vegetation") %>% pull(fraction.N) 
  i.urban          <-  filter(i.combined_data,new_category == "Artificial land") %>% pull(fraction.N) 
  i.agriculture    <-  filter(i.combined_data,new_category == "Arable land") %>% pull(fraction.N) 

  ehype$woodland[i]       <-  ifelse(length(i.woodland) > 0, i.woodland, 0)
  ehype$urban[i]          <-  ifelse(length(i.urban) > 0, i.urban, 0)
  ehype$agriculture[i]    <-  ifelse(length(i.agriculture) > 0, i.agriculture, 0)

  rm(list = ls()[grepl(pattern = "^i\\.", x = ls())])
}
# fix Nas
rm(LULC)
gc()

saveRDS(ehype, "data/quick_save_3_env.rds")

#- terrain
dem     <- rast("E://Arbeit/Data/DEM/DTM_Europe/dtm_elev.lowestmode_gedi.eml_mf_30m_0..0cm_2000..2018_eumap_epsg3035_v0.3.tif")
ehype %<>% st_transform(crs(dem))

for (i in 1:nrow(ehype)){
        print(paste(i, "/", nrow(ehype)))
        i.hype      <- ehype[i, ] 
        i.dem       <- crop(dem, i.hype)
        i.dem       <- mask(i.dem, i.hype)
        i.mean_elev <- i.dem %>% values %>% mean(na.rm = T)
        i.slope     <- terra::terrain(i.dem, v = "slope") %>% values %>% mean(na.rm = T)
        i.rough     <- terra::terrain(i.dem, v = "TRI"  ) %>% values %>% mean(na.rm = T)
        ehype$elevation[i] <- i.mean_elev
        ehype$slope[i]     <- i.slope
        ehype$TRI[i]       <- i.rough
        
}

rm(dem);gc()
saveRDS(ehype, "data/quick_save_4_env.rds")


ehype2 <- ehype
ehype2 %<>% select(SUBID)
sites2 <- select(sites, site_id)
ehype2 <- st_join(ehype,sites2)
ehype2 %<>% select(!c(SUBID, HAROID)) %>% st_drop_geometry()
data <- left_join(data, ehype2, by = "site_id")


