### geodb connection with r

require("RPostgreSQL")

pacman::p_load(dplyr, tidyverse)

# create a connection
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
  "user"
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "Messdaten",
                 host = "localhost", port = 5432,
                 user = "postgres", password = pw)
rm(pw) # removes the password

qry <- {"select * from pegel_messdaten inner join messdaten on pegel_messdaten.did = messdaten.did"
  }

relevant <- dbGetQuery(con, qry)
relevant[,4] <- NULL


relevant <- cbind(relevant, "mon" = substr(relevant$datum, 5,6))
relevant <- cbind(relevant, "day" = substr(relevant$datum, 7,8))


#wochen_werte <- function(){


n = 11
for (j in 1:7){
  assign(paste0("day", n), subset(relevant, relevant$day == n))
  n = n + 1
}


relevant$day[n]
