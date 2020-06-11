large = data.frame(rbind(rnorm(1:100),rnorm(1:100)))
rownames(large)=c("france","allemagne")
colnames(large)=paste("t",1901:2000)

long = data.frame(pays=rep(c("france","allemagne"),each=100),year=1901:2000,val=rnorm(200))
