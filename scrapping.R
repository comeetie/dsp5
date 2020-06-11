library(curl)
# récupérer la page  
url = "https://stackoverflow.com/questions/tagged/R"
l  = curl(url=url)
res =curl(url)
#res = readLines(l)
library(XML)
resp  = htmlTreeParse(res,useInternalNodes = TRUE)
xpath = '//*[@id="mainbar"]/div[4]/div/div[1]'
# requete alternative
#xpath = '//div[@class="fs-body3 grid--cell fl1 mr12 sm:mr0 sm:mb12"]'

nodes = getNodeSet(resp,xpath)
val = xmlValue(nodes[[1]]) 
val = gsub("questions","",val)
val = gsub("[\r,\n, ]","",val)
val = as.numeric(val)
val



Library
library(XML)
library(RCurl)
## Loading required package: bitops
library(dplyr)
## 
## Attaching package: 'dplyr'
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
library(rjson)
library(httr)


# definition des termes à scrapper 
languages=c('python','r','sas','matlab','ggplot2')
# initialisation de la table
stackOF=data.frame(lang=languages,questions=NA)
# boucle sur les termes
for(i in 1:length(languages)){
  # récupérer la page
  base = "https://stackoverflow.com/questions/tagged/"
  res  = readLines(curl(paste(base,stackOF[i,'lang'],sep='')))
  # la parser et récupérer le noeud désiré (xpath)
  resp = htmlTreeParse(res,useInternal=T)
  ns1  = getNodeSet(resp, "//*[@id='mainbar']/div[4]/div/div[1]")  
  # récupérer la valeure et la nettoyer
  val  = xmlValue(ns1[[1]])
  valclean =  gsub("questions","",val);
  valclean = gsub("[ ,\n,\r]","",valclean)
  # stackOF[i,'questions'] = as.numeric(valclean)
  stackOF$questions[i]= paste(base,stackOF[i,'lang'],sep='') 
}
# faire un graphique
stackOF=stackOF[order(stackOF$questions,decreasing=T),]
date = format(Sys.time(), "%d/%m/%Y")
title=paste("Popularité sur stackOverFlow",date)
barplot(stackOF$questions,
        names.arg=stackOF$lang,
        main=title,ylab="Nombre de questions")

