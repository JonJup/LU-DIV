### --- fit bayesian model --- ### 
library(groundhog)
pkgs <- c("brms",
          "dplyr")
groundhog.library(pkgs,'2024-04-25')
rm(pkgs)


# Load your data (replace with your actual data source)
data <- readRDS("data/catchments_w_shannon.rds")
data[, geometry := NULL]
# 58 catchments have missing shannon diversity. Drop them. 
# They are areas completely above 1000 m
data            <- filter(data, !is.na(shannon))
data$eco_stat_2 <- factor(data$eco_stat_2, levels = c("bad", "poor", "moderate", "good", "high"), ordered = TRUE)


#- working with a smaller subset 

#- distances between centroids are computed much faster 
# data2 <- st_centroid(data)
# data2 <- st_coordinates(data2)
# dm    <- parallelDist(data2, threads = 6)



# determine neighbors with spdep 
# neighbors       <- poly2nb(data, 
#                            snap = 1000)
# # which catchments do not have neighbors?
# isolated <- which(card(neighbors) == 0)
#- 40 catchments apparently do not have neighbors. 
#- This means that the exact sparse conditional auto regressive model can not be used in brms. 
#- Here, I loop over these catchments. 
# for (i in isolated){
#         print(which(isolated == i))
#         # select catchment 
#         i.iso <- data[i, ]
#         # find nearest catchment that is not i.iso
#         i.nf  <- st_nearest_feature(i.iso, data[-i,])
#         # account for the fact that i.iso is missing from the index i.nf
#         if (i.nf > i) i.nf = i.nf + 1
#         # assign the nearest catchment as neighbor
#         neighbors[[i]] <- as.integer(i.nf)
#         #neighbor.distanes[which(isolated == i)] <- st_distance(data[i,], data[i.nf,])
#         rm(i.iso, i.nf, i)
# }
# check if none are isolated. Should evaluate to TRUE
# length(which(card(neighbors) == 0)) == 0 

# neighbors       <- nb2mat(neighbours = neighbors, 
#                           style = "B",         # binary neighborhood coding 
#                           zero.policy = FALSE  # return error if any polygon has no neighbors
# )
# n_mat           <- matrix(neighbors, ncol = nrow(data), nrow = nrow(data))
# n_mat2 <- neighbors > 0
# object.size(n_mat2)/object.size(neighbors)
# n2 <- neighbors[1:10, 1:10]
# object.size(n2)
# object.size(n_mat2)
# rm(neighbors)
# Fit the Bayesian Spatial Ordinal Model using brms
data$LoadTPArea <- c(scale(data$LoadTPArea))
data$LoadTN_Are <- c(scale(data$LoadTN_Are))
data$lu_r_urb   <- c(scale(data$lu_r_urb))
data$lu_r_agr   <- c(scale(data$lu_r_agr))
data$hy_maf_abs <- c(scale(data$hy_maf_abs))
data$hy_bfi_abs <- c(scale(data$hy_bfi_abs))
data$msPAFP5EC5 <- c(scale(data$msPAFP5EC5))
data$shannon    <- c(scale(data$shannon))

# cor.data <- st_drop_geometry(data[, c(5:11,13)])
# cor.data <- cor.data[-which(is.na(cor.data$shannon)), ]
# cor(cor.data) %>%corrplot::corrplot()

## full model
fit <- brms::brm(
        formula = eco_stat_2 ~
                shannon + LoadTPArea + LoadTN_Are +
                lu_r_urb + lu_r_agr + hy_maf_abs + hy_bfi_abs +
                msPAFP5EC5,
        data = data,
        family = cumulative("logit"),
        cores = 6
)


saveRDS(fit, file = "data/fitted_brms_models/itted_brms_model_all_BRT_240912.rds")
