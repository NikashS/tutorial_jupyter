# this only has to be done once (as the root ubuntu user)
# get 'gdal' needed for 'rgdal' and 'rgeos'
# http://robinlovelace.net/r/2013/11/26/installing-rgdal-on-ubuntu.html
# aptitude better package manager than apt-get for gdal

# sudo apt-get update
# sudo apt-get install aptitude
# sudo aptitude install libgdal-dev 
# sudo aptitude install libproj-dev

# choose rstudio as source package repository
#options(repos = c(CRAN = "http://cran.rstudio.com"));

# install.packages('deldir')
# install.packages('dplyr')
# install.packages('jsonlite',dependencies=TRUE)
# install.packages('maptools')
# install.packages('rgeos')
# install.packages('rgdal',dependencies=TRUE)
# install.packages('leaflet')
#install.packages('spatstat')

library(dplyr)
library(jsonlite)
library(maptools); gpclibPermit()
library(deldir)
library(rgeos)
library(rgdal)
library(leaflet)

sessionInfo()

# an [r] command to tell linux shell to 'download' a file from a url
# system() --> wget --> url

# download
#system('wget http://www2.census.gov/geo/tiger/TIGER2015/TRACT/tl_2015_06_tract.zip')

# unzip
#system('mkdir -p notebooks/gis_demog_misc')
#system('unzip notebooks/gis_demog_misc/tl_2015_06_tract.zip -d ~/notebooks/gis_demog_misc/tl_2015_06_tract')

#################
# shapefile - tract
#################

# library(maptools)
# directory location of shapefiles
shapefile_location = '~/notebooks/gis_demog_misc/tl_2015_06_tract/'
ca_shp <- readShapeSpatial(paste0(shapefile_location,'tl_2015_06_tract.shp'))

# specify projection
proj4string(ca_shp) <- "+proj=longlat +datum=WGS84"
plot(ca_shp)

# notice how long it takes, shapefiles are "bloated"

names(ca_shp)

# just subset to la county
la_county = subset(ca_shp, ca_shp$COUNTYFP == '037')
plot(la_county)

#################
# shapefile - tract
#################

# plot(la_county)
# locator to interactively choose points of convex hull for custom bbox

# Click points to draw your own custom boundary then hit keyboard 'esc' to finalize
chull_locat = locator()
plot(chull(chull_locat))

# use the new custom boundary points to crop out ignored areas

library(spatstat)
bbox_cust = bounding.box.xy(chull_locat)
bb_poly <- as((bbox_cust), "SpatialPolygons")
proj4string(bb_poly) <- CRS(proj4string(la_county))

library(raster)
la_county_zoom = raster::crop(la_county,bb_poly)
plot(la_county_zoom)

save(la_county_zoom,file='notebooks/gis_demog_misc/la_county_zoom_tvmagic.RData')

load("~/notebooks/gis_demog_misc/la_county_zoom_tvmagic.RData")
plot(la_county_zoom)

####################
# get la county bdry
# ?rgeos::gUnionCascaded to dissolve interior polygons
####################

# plot(la_county_zoom)
# library(rgeos)
la_county_bdry = rgeos::gUnionCascaded(la_county_zoom)
plot(la_county_bdry)