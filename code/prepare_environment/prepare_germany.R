# - Add environmental data to finland - # 
library(terra)
library(sf)
library(magrittr)
library(data.table)
library(dplyr)
library(landscapemetrics)

# load data --------------------------------------------------------------
data <- readRDS("../../invertebrate data/monitoring_finnland/finland_monitoring_invertebrates.rds")

# run script -------------------------------------------------------------



# save to file -----------------------------------------------------------
saveRDS(data(), "data/invertebrate_data/preped_inverts_finland.rds")
