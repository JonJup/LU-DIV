# - Add environmental data to france - # 
# - Diatoms -#
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
data <- readRDS("data/diatom_data/diatoms_france.rds")

# run script -------------------------------------------------------------
source("code/prepare_environment/prepare_environment.R")

# save to file -----------------------------------------------------------
saveRDS(data, "data/diatom_data/prepared_diatoms_france.rds")
