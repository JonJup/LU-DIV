### --- fit bayesian model              --- ### 
### --- to individual Broad River Types --- ### 

library(groundhog)
pkgs <- c("brms",
          "dplyr",
        "data.table")
groundhog.library(pkgs,'2024-04-25')
rm(pkgs)

# Load your data (replace with your actual data source)
data <- readRDS("data/catchments_w_shannon.rds")
data[, geometry := NULL]
# 58 catchments have missing shannon diversity. Drop them. 
# They are areas completely above 1000 m
data            <- filter(data, !is.na(shannon))
data$eco_stat_2 <- factor(data$eco_stat_2, levels = c("bad", "poor", "moderate", "good", "high"), ordered = TRUE)


# - loop over BRT
for (i in 1:12){

        #- filter data to broad river type 
        i.data <- filter(data, mars_bt12 == paste0("RT", i))

        #- scale variables 
        i.data$LoadTPArea <- c(scale(i.data$LoadTPArea))
        i.data$LoadTN_Are <- c(scale(i.data$LoadTN_Are))
        i.data$lu_r_urb   <- c(scale(i.data$lu_r_urb))
        i.data$lu_r_agr   <- c(scale(i.data$lu_r_agr))
        i.data$hy_maf_abs <- c(scale(i.data$hy_maf_abs))
        i.data$hy_bfi_abs <- c(scale(i.data$hy_bfi_abs))
        i.data$msPAFP5EC5 <- c(scale(i.data$msPAFP5EC5))
        i.data$shannon    <- c(scale(i.data$shannon))

        #- fit model 
        ## full model
        i.fit <- brms::brm(
                formula = eco_stat_2 ~
                        shannon + LoadTPArea + LoadTN_Are +
                        lu_r_urb + lu_r_agr + hy_maf_abs + hy_bfi_abs +
                        msPAFP5EC5,
                data = i.data,
                family = cumulative("logit"),
                cores = 6
        )
        saveRDS(i.fit, file = paste0("data/fitted_brms_models/fitted_model_RT",i,"_240909.rds"))
        rm(list = ls()[grepl(pattern = "^i\\.", x = ls())])
        print(i)
};rm(i)






