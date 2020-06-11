
prenoms = read.table("./data/exo5_prenoms.csv",header=TRUE)
head(prenoms)
library(dplyr)

prenoms %>% filter(sex=="M") %>% head()

head(filter(prenoms,sex=="M"))

top_pr = prenoms[prenoms$sex=="M" & prenoms$year==2001,] %>% 
  group_by(dep) %>% 
  top_n(1,n) %>% 
  select(name,dep)

select(top_n(group_by(filter(prenoms ,sex=="M",year==2001),dep),1,n),name,dep)



head(top_pr)

deps = read.table("./data/exo5_dep.csv",header=TRUE,sep=",")
deps = deps %>% rename(ddep =dep)
head(deps)
names(deps)
names(top_pr)

top_pr_dep = deps %>% left_join(top_pr,by=c("ddep"="dep"))
head(top_pr_dep)

library(ggplot2)
ggplot(top_pr_dep) + geom_text(aes(x=lat,y=long,label=name,color=name))


pr = c("etienne","nicolas","thomas")
exlong = prenoms %>% 
  filter(name %in% pr) %>% 
  group_by(year,name) %>% 
  summarise(n=sum(n))


library(tidyr)
exlarge = exlong %>% spread(key = year,value = n)
head(exlarge)

exlarge[1,-1]
