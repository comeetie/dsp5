library(rjson)
library(dplyr)
library(ggplot2)

url="http://vlsstats.ifsttar.fr/data/spatiotemporalstats_Lyon.json"
data=fromJSON(file=url)
extract = function(x){
  data.frame(id=x$'_id',
             time= x$download_date,
             nbbikes = x$available_bikes )
}

ll = lapply(data,extract)

st_tempstats.df=do.call(rbind,ll)

# selection de 3 stations
st_tempstats.df.pos = st_tempstats.df %>% 
  mutate(time=as.POSIXct(time,origin="1970-01-01"))

sel = unique(st_tempstats.df$id)[1:6]

st_tempstats_sub.df = st_tempstats.df.pos %>% 
  filter(id %in% sel)


ggplot(data=st_tempstats_sub.df)+
  geom_line(aes(x=time,y=nbbikes,group=id,color=factor(id)),size=2)+
  facet_grid(id ~ .)


data("iris")
ggplot()+
  geom_point(data=iris,aes(x=Petal.Width,y=Petal.Length,color=Species,shape=Species))+
  stat_density2d(data=iris,aes(x=Petal.Length,y=Petal.Width,color=Species))+ggtitle("Scatter plot iris petal")



mto = mtcars %>% mutate(label = rownames(mtcars)) %>% 
  arrange(mpg)  %>% 
  mutate(label=factor(label,levels=label))

ggplot(data=mto,aes(y=label,x=mpg))+geom_point()+
  geom_text(aes(y=label,x=mpg+1,label=label),hjust= "left")+
  scale_x_continuous(limits=c(10,50),"Miles / Gallon")+
  theme_dark()+
  theme(axis.title.y = element_blank(), axis.text.y = element_blank(),line = element_blank(),rect=element_blank(),axis.line.x = element_line(),axis.ticks.x.bottom = element_line())



library(tidyr)
# téléchargement et remise en forme des données
url = "http://vlsstats.ifsttar.fr/data/spatiotemporalstats_Lyon.json"
data=fromJSON(file=url)
extract = function(x){
  data.frame(id=x$'_id',
             time= x$download_date,
             nbbikes = x$available_bikes )
}
st_tempstats.df=do.call(rbind,lapply(data,extract))
# taille des stations
st_size.df = st_tempstats.df %>% group_by(id) %>% summarise(size=max(nbbikes))
# ratio de remplissage
st_fillratio.df = st_tempstats.df %>% left_join(st_size.df) %>% mutate(fillratio = nbbikes/size) %>% select(id,time,fillratio)
# passage en large
X = st_fillratio.df%>% spread(time,fillratio,fill = 0)
# kmeans
Xnum=X[,2:ncol(X)]
K=8
clust= kmeans(Xnum,K)
clust.df  = data.frame(id=X[,1],cluster=factor(clust$cluster,levels=1:K))
res.df = st_fillratio.df %>% left_join(clust.df) %>% mutate(fillratio=ifelse(is.na(fillratio),0,fillratio))
res.mean.df = res.df %>% group_by(time,cluster) %>% summarise(mfillratio=mean(fillratio))
ggplot()+geom_line(data=res.df,aes(x=as.POSIXct(time,origin="1970-01-01"),y=fillratio,color=cluster,group=id),alpha=0.05)+
  geom_line(data=res.mean.df,aes(x=as.POSIXct(time,origin="1970-01-01"),y=mfillratio,color=cluster,group=cluster),size=1.5)+
  facet_grid(cluster~.)+scale_x_datetime("")+scale_y_continuous("Fill / Ratio")


  