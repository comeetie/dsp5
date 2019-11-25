library(sqldf)
db = dbConnect(SQLite(), dbname="./sql-murder-mystery.db")

# a vous de jouer
sqldf('select * from ...', connection=db)

# vérification
dbSendStatement(db,'INSERT INTO solution VALUES (1, "XXX");')


