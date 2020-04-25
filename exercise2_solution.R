##Author: Eliot Dixon

library(sf)
library(leaflet)
library(geojsonsf)
library(dplyr)
library(urltools)

#Construct query to national forest API
tahoeBaseURL <- "https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_ForestSystemBoundaries_01/MapServer/0/query?"
tahoeQuery <- urltools::param_set(tahoeBaseURL, key="where", 
                          value=urltools::url_encode("FORESTNAME LIKE '%Tahoe National%'")) %>%
                        param_set(key="outFields", value="*") %>%
                        param_set(key="f", value="geojson")
#query national forest API
tahoe <- geojson_sf(tahoeQuery)

#obtain bounding box for tahoe national and convert to polygon
tahoeBox <- st_bbox(tahoe) %>%
  st_as_sfc()
#split bounding box ploygon into 2x2 grid
tahoeBoxSplit <- st_make_grid(tahoeBox, n=2)

#Construct query to invasive species location API
invasiveBaseURL <- "https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_InvasiveSpecies_01/MapServer/0/query?"
epsg <- st_crs(tahoeBoxSplit)$epsg
invasiveQuery <- param_set(invasiveBaseURL,key="inSR", value=epsg) %>%
  param_set(key="spatialRel", value="esriSpatialRelIntersects") %>%
  param_set(key="f", value="geojson") %>%
  param_set(key="outFields", value="*")


#for each quarter of the bounding box, query API and add each returned sf object to invasives list
invasives <- list()
for(i in 1:4){
  #derive and format bounding box of this quarter
  bbox <- st_bbox(tahoeBoxSplit[i]) %>%
    toString() %>%
    urltools::url_encode()
  #add formatted bounding box to query
  invasiveQuery <- param_set(invasiveQuery, key="geometry", value=bbox)
  #query API
  invasive <- geojson_sf(invasiveQuery)
  #add returned sf object to invasives list
  invasives[[i]] <- invasive
}

#vertically combine data returned for each quarter of tahoe bounding box
invasives <- do.call(rbind, invasives)

#filter observations that fall outside the tahoe national forest
insideInvasives <- st_join(invasives, tahoe) %>%
  na.omit()

#Plot four bbox quandrants, with invasives before(red) and after(blue) filtering and tahoe national
overlayGroups <- c("Tahoe Bounding Quandrants","Tahoe National","Inside Invasives","All invasives")
leaflet() %>%
  addProviderTiles("Esri.WorldStreetMap") %>%
  addPolygons(data=tahoeBoxSplit, weight=2, fill=FALSE, group="Tahoe Bounding Quandrants") %>%
  addPolygons(data=tahoe, weight=2, color="green", group="Tahoe National") %>%
  addPolygons(data=insideInvasives,weight=2, color="blue", group="Inside Invasives") %>%
  addPolygons(data=invasives, weight=1, color="red", group="All invasives") %>%
  addLayersControl(overlayGroups=overlayGroups, options=layersControlOptions(collapsed=FALSE))

