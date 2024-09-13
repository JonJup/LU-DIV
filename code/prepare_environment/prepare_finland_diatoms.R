# - Add environmental data to diatoms from Finland - # 

library(groundhog)
pkgs <- c("terra",
        "sf",
        "magrittr",
        "data.table",
        "dplyr",
        "landscapemetrics")
groundhog.library(pkgs,'2024-04-25')
rm(pkgs)

# load data --------------------------------------------------------------
data <- readRDS("data/diatom_data/diatoms_finland.rds")

# run script -------------------------------------------------------------
source("code/prepare_environment/prepare_environment2.R")

# save to file -----------------------------------------------------------
saveRDS(data, "data/diatom_data/preped_diatoms_finland.rds")
