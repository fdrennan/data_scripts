library(rwunderground)
library(RPostgreSQL)
library(dplyr)


api_key = 'd364068bdb5bbcc9'

loc = set_location(territory = "Colorado", city = "Fort Collins")

cond = conditions(loc, key = api_key)


# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv,
                 dbname = "freddydb",
                 host = "mydatabase.c2pc3qmfwusq.us-east-2.rds.amazonaws.com",
                 port = 5432,
                 user = "fdrennan",
                 password = 'thirdday1')

cond <- as.data.frame(cond)

cond$time = as.character(Sys.time())

# writes df to the PostgreSQL database "postgres", table "cartable"
dbWriteTable(con, "focoWeather",
             value = cond, append = TRUE, row.names = FALSE)


