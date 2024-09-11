# LU-DIV

Current status: in preparation

# GOAL of the Project

Agricultural landuse strongly impacts freshwater organisms. Many studies have successfully related the proportion of the catchment area under cultivation to various metrics of freshwater system status. Here, we argue that a second factor, which is computed just as easily, is commonly ignored, but explains additionaly variance: the diversity of land cover types. We conduct three small analyses to highlight the importance of land cover diversity to different freshwater state mertics.  

## Analysis pipeline 

#todos
- add link to wfd; ehype

Analysis one: Explaining ecological stauts. 

The Water Framework Directive regulates protective and management actions concerning freshwater ecosystems across Europe. Under it, all waterbodies are assigned one of fit status classes: bad, poor, moderate, good, high. Lemm *et al.* (2021) have compiled these data for the EHYPE catchment data base together with a selction of stressors. They used these data to establish a link between stressor intensity and ecological status. We add the Shannon diversity of land use and land cover and explore how much addtional variation can be explained by it. 

Analysis two: Predicting the occurrence of invertebrates

Next we aim to predict the abundance of invertebrates in four independet data sets. Each data set covers a whole country: Finland, France, Germany, or the UK. We collected environmental predictors including landscape composition and configuration (i.e. Shannon Diversity) and predict species abundances using the joint species distribution model HMSC. The explained variance will be partitioned between explanaotry variables to determine the role of environmental drivers across species.   

Analysis three: Predicting the occurrence of diatoms
Same as Analysis two but with diatoms. This adds a further dimension to the analysis as diatoms are primarily impacted more strongly by nutrients and macroinvertebrates by pesticides. 

# Overview of Repository
The repository has three folders: data, code, and document. 
The data for this project are on Zenodo (add link). In the **code** repository, there 

# Data availability 

## Biological data
Inverbrate and diatom data from France is available from [here](https://naiades.eaufrance.fr/france-entiere#/) and from the UK [here](https://environment.data.gov.uk/ecology/explorer/). 
The data from Germany and Finland, will be made available upon request. 

## Environmental data
Data on stressors and Ecological status as described in Lemm *et al.* (2021) is available [here](https://zenodo.org/records/4322819) and the associated publication [here](https://onlinelibrary.wiley.com/doi/full/10.1111/gcb.15504). 
Bioclimatic variables were derived from CHLESEA Karger *et al.* (2017) were used and are available [here](https://chelsa-climate.org/bioclim/). 
As a digital terrain model, we used v0.3 from [Hengl *et al*. (2020)](https://zenodo.org/records/4724549). 
Soil pH link [here](https://stac.ecodatacube.eu/sol_ph.h2o_eumap/collection.json). We used the surface soil (depth = 0 - 30cm) pH from 2016.  
As land use and land cover data, we used the data proivded by d'Andrimont *et al.* (2021) available [here](https://data.jrc.ec.europa.eu/dataset/15f86c84-eae1-4723-8e00-c1b35c8f56b9). 


# References 
d’Andrimont, R., Verhegghen, A., Lemoine, G., Kempeneers, P., Meroni, M., van der Velde, M., 2021. From parcel to continental scale – A first European crop type map based on Sentinel-1 and LUCAS Copernicus in-situ observations. Remote Sensing of Environment 266, 112708. https://doi.org/10.1016/j.rse.2021.112708    

Hengl, T., Leal Parente, L., Krizan, J., & Bonannella, C. (2020). Continental Europe Digital Terrain Model at 30 m resolution based on GEDI, ICESat-2, AW3D, GLO-30, EUDEM, MERIT DEM and background layers (v0.3) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.4724549. Accessed 09.09.2024.     

Karger, D.N., Conrad, O., Böhner, J., Kawohl, T., Kreft, H., Soria-Auza, R.W., Zimmermann, N.E., Linder, P., Kessler, M. (2017). Climatologies at high resolution for the Earth land surface areas. Scientific Data. 4 170122. https://doi.org/10.1038/sdata.2017.122   

Lemm, J.U., Venohr, M., Globevnik, L., Stefanidis, K., Panagopoulos, Y., Gils, J., Posthuma, L., Kristensen, P., Feld, C.K., Mahnkopf, J., Hering, D., Birk, S., 2021. Multiple stressors determine river ecological status at the European scale: Towards an integrated understanding of river status deterioration. Glob. Change Biol. 27, 1962–1975. https://doi.org/10.1111/gcb.15504
