library(readr)
library(XML)
library(RCurl)
library(dplyr)
library(stringr)
library(leaflet)


## Récupération des données de localisations des monuments historiques

data=read_library(readr)
monum <- read_delim("data/monuments-historiques.csv", ";", escape_double = FALSE, trim_ws = TRUE)
monum75 =monum %>% filter(Département=="Paris") %>% mutate(id=as.character(Référence))
u="https://fr.wikipedia.org/wiki/Liste_des_monuments_historiques_du_1er_arrondissement_de_Paris"
html = getURI(u)
tree= htmlTreeParse(html,useInternalNodes = TRUE)
table=readHTMLTable(tree)
mt = table[[1]]
ids = as.character(mt$V4[2:nrow(mt)])
pos = as.character(mt$V3[2:nrow(mt)])
coords= str_split(str_replace_all(pos,"[^[:digit:]°″,′]",""),"[°″,′  ]")
lat=sapply(coords,function(stc){as.numeric(stc[1]) + as.numeric(stc[2])/60  + as.numeric(stc[3])/3600})
long=sapply(coords,function(stc){as.numeric(stc[5]) + as.numeric(stc[6])/60  + as.numeric(stc[7])/3600})
monum_loc = data.frame(id=str_sub(ids,3,12),lat=lat,long=long,stringsAsFactors = FALSE)
Monum_loc=list()
Monum_loc[[1]]=monum_loc
for (a in 2:20){
  u=paste0("https://fr.wikipedia.org/wiki/Liste_des_monuments_historiques_du_",a,"e_arrondissement_de_Paris")
  html = getURI(u)
  tree= htmlTreeParse(html,useInternalNodes = TRUE)
  table=readHTMLTable(tree)
  mt = table[[1]]
  ids = as.character(mt$V4[2:nrow(mt)])
  pos = as.character(mt$V3[2:nrow(mt)])
  coords= str_split(str_replace_all(pos,"[^[:digit:]°″,′]",""),"[°″,′  ]")
  lat=sapply(coords,function(stc){as.numeric(stc[1]) + as.numeric(stc[2])/60  + as.numeric(stc[3])/3600})
  long=sapply(coords,function(stc){as.numeric(stc[5]) + as.numeric(stc[6])/60  + as.numeric(stc[7])/3600})
  monum_loc = data.frame(id=str_sub(ids,3,12),lat=lat,long=long,stringsAsFactors = FALSE)
  Monum_loc[[a]]=monum_loc
}

monum_loc75 = do.call(rbind,Monum_loc)
monum75 = monum75%>% left_join(monum_loc75,by=c('id'='id'))

## passage en data.frame sf
monum_loc75.sf=st_as_sf(monum_loc75 %>% filter(!is.na(lat)),coords=c("long","lat"),crs=4326)

## cartes interactives
leaflet(data = monum75) %>% addTiles() %>%
  addMarkers(~long, ~lat, popup = ~as.character(`Appellation courante`), label = ~as.character(`Appellation courante`))

leaflet(data = monum75) %>% addTiles() %>%
  addCircleMarkers(~long, ~lat, popup = ~as.character(`Appellation courante`), label = ~as.character(`Appellation courante`),radius=5,
                   stroke = FALSE)


# recupération des contours iris
iris.sf=read_sf("./data/CONTOURS-IRIS/1_DONNEES_LIVRAISON_2018-06-00105/CONTOURS-IRIS_2-1_SHP_LAMB93_FXX-2017/CONTOURS-IRIS.shp")
iris.sf=st_set_crs(iris.sf,2154)
# passage en lambert des deux df
monum_loc75_2154.sf=st_transform(monum_loc75.sf,2154)

# vérification
plot(st_geometry(iris[str_sub(iris.sf$INSEE_COM,1,2)=="75",]))
plot(monum_loc75_2154.sf,col = "red")

# comptage et mise en forme
iris_monum= st_contains(iris.sf,monum_loc75_2154.sf)
iris_monum_count = sapply(iris_monum, length) 

iris.sf$monumcount=iris_monum_count
iris.sf$area = st_area(iris.sf)
iris.sf = iris.sf %>% filter(monumcount>0) %>% mutate(monumdensity= monumcount/area*10000)

# carte
library(cartography)
choroLayer(x = iris.sf %>% filter(monumcount>0), var = "monumdensity",
           method = "quantile", nclass = 8)
