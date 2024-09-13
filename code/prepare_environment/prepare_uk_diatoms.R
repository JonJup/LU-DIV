# - Add environmental data to UK - # 
# - Diatoms                      - # 


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
data <- readRDS("data/diatom_data/diatoms_uk.rds")

# run script -------------------------------------------------------------
source("code/prepare_environment/prepare_environment.R")

# save to file -----------------------------------------------------------
saveRDS(data, "data/diatom_data/preped_diatoms_UK.rds")
