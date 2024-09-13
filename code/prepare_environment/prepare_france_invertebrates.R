# - Add environmental data to france - # 
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
data <- readRDS("data/invertebrate_data/invertebrates_france.rds")

# run script -------------------------------------------------------------
source("code/prepare_environment/prepare_environment.R")

# save to file -----------------------------------------------------------
saveRDS(data, "data/invertebrate_data/preped_inverts_france.rds")
