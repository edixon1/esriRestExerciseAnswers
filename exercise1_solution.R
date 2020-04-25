##Author: Eliot Dixon

library(sf)
library(leaflet)
library(geojsonsf)
library(dplyr)
library(urltools)

#Build query to country boundaries API
spainBaseURL <- "https://bio.discomap.eea.europa.eu/arcgis/rest/services/Internal/Basemap_EEA_countries_WM/MapServer/5/query"
spainQuery <- param_set(spainBaseURL, key="where", value=urltools::url_encode("ISO_2DIGIT = 'ES'")) %>%
  param_set(key="f", value="geojson")

#Query API
spain <- geojson_sf(spainQuery)

#derive and format bounding box
bbox <- st_bbox(spain) %>%
  toString() %>%
  urltools::url_encode()

#get CRS for spain polygon
epsg <- st_crs(spain)$epsg

#Build query to hydrology API
riverBaseURL <- "https://maratlas.discomap.eea.europa.eu/arcgis/rest/services/Maratlas/Hydrography/MapServer/13/query"
riverQuery <- param_set(riverBaseURL, key="geometry",value=bbox) %>%
  param_set(key="inSR", value=epsg) %>%
  param_set(key="f", value="geojson") %>%
  param_set(key="outFields", value="*") %>%
  param_set(key="spatialRel", value="esriSpatialRelIntersects")

#query API
rivers <- geojson_sf(riverQuery)

#filter out rivers that do not intersect Spain polygon
riversOfSpain <- st_join(rivers,spain) %>%
  na.omit()


#Plot Rivers
leaflet() %>%
  addProviderTiles("Esri.WorldStreetMap") %>%
  addPolylines(data=riversOfSpain, weight = 2)


