data = read.table("./data/exo1.csv",skip=5,header=TRUE,sep=",")
head(data)
str(data)

library(rjson)
exo2 = fromJSON(file="./data/exo2.json") 
str(exo2)

ldf = lapply(exo2, function(x){data.frame(id=x$id,mb=mean(x$available_bike_stands))})
df  = do.call(rbind,ldf)


ids = sapply(exo2,function(x){x$id})
mb = sapply(exo2,function(x){mean(x$available_bike_stands)})

df = data.frame(id=ids,mb=mb)
head(df)
