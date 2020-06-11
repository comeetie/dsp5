url = "https://www.education.gouv.fr/sites/default/files/imported_files/document/depp-rers-2019-donnees-fiche-01-03_1162719.xls"
library(readxl)
download.file(url,destfile = "excel1.xls")
df1  <- read_excel("excel1.xls",sheet = 2,range = "A5:E72")
names(df1) = c("dep","pop","evol","popt","tauxsc")
df2  <- read_excel("excel1.xls",sheet = 2,range = "G5:K72")
names(df2) = c("dep","pop","evol","popt","tauxsc")
df_t = rbind(df1,df2)
head(df_t)
