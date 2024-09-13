# ———— fit HMSC to Finland invertebrates ————— # 
library(groundhog)
pkgs <- c("data.table", "Hmsc", "abind", "ggplot2", "gridExtra", "magrittr", "dplyr")
groundhog.library(pkgs,'2024-04-25')
rm(pkgs)

# load data --------------------------------------------------------------
inverts <- readRDS("data/invertebrate_data/preped_inverts_finland.rds")

# prepare data -----------------------------------------------------------

#- bring into wide format 
inverts_wide <- dcast(
  data = inverts, 
  formula = sample_id ~ lowest.taxon,
  value.var = "abundance",
  fill = 0
)
site_id_vec <- inverts_wide[,1]
inverts_wide[, sample_id := NULL]

XData <- 
  unique(inverts, by = "sample_id") %>%
  select(sample_id, date, x.coord:TRI) %>%
  as.data.frame()

all(XData$sample_id == site_id_vec)

#- Create response matrix 
Y = as.matrix(inverts_wide)
Y_occ <- (inverts_wide>0)*1

# 5% of sites are equal to 20.5; so at least 20 occurrencs
nrow(Y) * 0.05
drop_occ <- which(colSums(Y_occ) < 20)
Y_cmn <- Y[,-drop_occ]


# Setup HMSC Model -------------------------------------------------------
sampling_days <- 
  as.numeric(XData$date - min(XData$date)) %>% 
  factor()

studyDesign = data.frame(
  sample = as.factor(XData$sample_id),
  day    = sampling_days
)
#rownames(xy)=studyDesign[,1]
sData_matrix <- matrix(c(XData$x.coord, XData$y.coord), ncol = 2)
rownames(sData_matrix) <- levels(studyDesign$sample)
rL1 = HmscRandomLevel(
  sData = sData_matrix,
  sMethod = "Full" 
)
rL2 = HmscRandomLevel(
  units = studyDesign$day 
)
XFormula = ~ soil_ph + bioclim05 + bioclim06 + bioclim13 + bioclim14 + shannon_scale2 + woodland + urban + agriculture + elevation + slope + TRI

XData2 <- XData %>% select(!c(sample_id, date))

m1 = Hmsc(
  Y=Y_cmn, 
  XData = XData2, 
  XFormula=XFormula,
  XScale = TRUE,
  distr="lognormal poisson",
  studyDesign=studyDesign,
  ranLevels=list("sample"=rL1, "day" = rL2))


#FITTING THE MODEL

nChains = 1
samples = 100
thin = 1
transient = round(0.5*samples*thin)
m1 = sampleMcmc(
  m1, 
  thin = thin, 
  samples = samples,
  transient = transient,
  nChains = nChains
)


#EXAMINING MCMC CONVERGENCE
mpost = convertToCodaObject(m1)
effectiveSize(mpost$Beta)
gelman.diag(mpost$Beta,multivariate=FALSE)$psrf
effectiveSize(mpost$Alpha[[1]])
gelman.diag(mpost$Alpha[[1]],multivariate=FALSE)$psrf

#EVALUATING MODEL FIT
preds = computePredictedValues(m1)
mfit <- evaluateModelFit(hM=m1, predY=preds)

plot(mpost$Beta)


#COMPUTING VARIANCE PARTITIONING
library(ggplot2)
VP = computeVariancePartitioning(m1)
x11()
VP$vals %>% as.data.frame %>% tibble::rownames_to_column() %>% group_by(rowname) %>% tidyr::pivot_longer(cols = !rowname) %>% summarize(mean = mean(value)) %>% 
  ungroup() %>%
  mutate(rowname = factor(rowname)) %>% 
  mutate(name = forcats::fct_reorder(rowname, .x = mean)) %>% 
  ggplot(aes(y = rowname, x = mean)) + geom_col()


# x11()
# ff %>% mutate(name = factor(name)) %>% mutate(name = forcats::fct_reorder(name, .x = value)) %>% ggplot(aes(y = name, x = value)) + geom_col()


x11()
par(mar = c(5, 4, 4, 8) + 10)
Hmsc::plotVariancePartitioning(m1, VP)

#EXAMINING PARAMETER VALUES
m = models[[1]]
mpost = convertToCodaObject(m)
summary(mpost$Beta, quantiles = c(0.025, 0.5, 0.975))[[2]]
summary(mpost$Alpha[[1]], quantiles = c(0.025, 0.5, 0.975))[[2]]

#PREDICTIONS OVER ENVIRONMENTAL GRADIENTS
m = models[[1]]
Gradient = constructGradient(m,focalVariable = "clim",
                             non.focalVariables = list(hab = 1))
predY = predict(m, Gradient=Gradient,expected = TRUE)
plotGradient(m, Gradient, pred=predY, measure="Y", index = 1, showData = TRUE)

Gradient = constructGradient(m,focalVariable = "hab",
                             non.focalVariables = list(clim = 1))
predY = predict(m, Gradient=Gradient,expected = TRUE)
plotGradient(m, Gradient, pred=predY, measure="Y", index = 1, showData = TRUE)

#PREDICTIONS OVER SPACE
grid = read.csv("bird data\\grid_1000.csv")
grid = droplevels(subset(grid,!(Habitat=="Ma")))
xy.grid = as.matrix(cbind(grid$x,grid$y))
XData.grid = data.frame(hab=as.factor(grid$Habitat), clim=grid$AprMay)

m = models[[1]]
Gradient = prepareGradient(m, XDataNew = XData.grid, sDataNew = list(route=xy.grid))
predY = predict(m, Gradient=Gradient, predictEtaMean = TRUE, expected = TRUE)
length(predY)
length(predY[[1]])
EpredY = apply(abind(predY,along=3),c(1,2),mean)
length(EpredY)

mapData=data.frame(x=xy.grid[,1],y=xy.grid[,2], EpredY,H=XData.grid$hab, C=XData.grid$clim)
ggplot(data = mapData, aes(x=x, y=y, color=H))+geom_point(size=1.5) +
  ggtitle("Habitat") + scale_color_discrete(name="") +
  theme(legend.position="bottom")
ggplot(data = mapData, aes(x=x, y=y, color=C))+geom_point(size=1.5) +
  ggtitle("Climate") + scale_color_gradient(low="blue", high="red", name = "") +
  theme(legend.position="bottom") +labs(y="")
ggplot(data = mapData, aes(x=x, y=y, color=Corvus.monedula))+geom_point(size=1.5) + 
  ggtitle("Corvus monedula")+ scale_color_gradient(low="blue", high="red", name = "") +
  theme(legend.position="bottom")+labs(y="")
