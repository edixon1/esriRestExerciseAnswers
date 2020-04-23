#Tahoe National Forest polygon
forest <- geojson_sf("https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_ForestSystemBoundaries_01/MapServer/0/query?where=FORESTNAME+LIKE+%27%25Tahoe+National%25%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&queryByDistance=&returnExtentOnly=false&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&featureEncoding=esriDefault&f=geojson")

#Get bounding box of taho national forest polygon and convert to
tahoeBbox <- st_bbox(forest) %>%
  st_as_sfc()

#split bounding box polygon into a 2x2 grid
bbox_split <- st_make_grid(tahoeBbox,n=2)

epsg <- st_crs(forest)$epsg

query <- urltools::param_set(baseURL,key="inSR", value=epsg) %>%
  param_set(key="spatialRel", value="esriSpatialRelIntersects") %>%
  param_set(key="f", value="geojson") %>%
  param_set(key="outFields", value="*")

#baseURL for  Forest Service invasive species API
baseURL <- "https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_InvasiveSpecies_01/MapServer/0/query?"

all_invasives <- data.frame()


mapview(bbox_split)
for(polygon in bbox_split){
  bbox <- st_bbox(polygon) %>%
    toString() %>%
    urltools::url_encode()
  query <- param_set(query,key="geometry", value=bbox)
  
  print(NROW(geojson_sf(query)))
  #all_invasives <- rbind(all_invasives,geojson_sf(query))
}




#baseURL for  Forest Service invasive species API
baseURL <- "https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_InvasiveSpecies_01/MapServer/0/query?"
#bounding box of tahoe national forest polygon
bbox <- st_bbox(forest)
#convert bounding box to character
bbox <- toString(bbox)
#encode for use within URL
bbox <- urltools::url_encode(bbox)
#EPSG code for coordinate reference system used by tahoe national forest polygon sf object
epsg <- st_crs(forest)$epsg

#set parameters for query
query <- urltools::param_set(baseURL,key="geometry", value=bbox) %>%
  param_set(key="inSR", value=epsg) %>%
  param_set(key="resultRecordCount", value=500) %>%
  param_set(key="spatialRel", value="esriSpatialRelIntersects") %>%
  param_set(key="f", value="geojson") %>%
  param_set(key="outFields", value="*")
invasives1 <- geojson_sf(query)


#baseURL for  Forest Service invasive species API
baseURL <- "https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_InvasiveSpecies_01/MapServer/0/query?"
