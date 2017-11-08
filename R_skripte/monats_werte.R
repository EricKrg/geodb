#script for the computation of the weekly values of "pegel-messdaten"
#database connection with r
#
#database access:
#
#

require("RPostgreSQL")

pacman::p_load(dplyr, tidyverse)

pw <- {
  "user"
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "Messdaten",        #change con to elephantsql database
                 host = "localhost", port = 5432,
                 user = "postgres", password = pw)
rm(pw) # removes the password

qry <- {"select * from klima_messdaten inner join messdaten on klima_messdaten.did = messdaten.did"
} #Pegelmessdaten query


relevant <- dbGetQuery(con, qry)
relevant[7] <- NULL
relevant <- cbind(relevant, "mon" = substr(relevant$datum,5,6))


relevant <- relevant %>%
  filter(fm != -999) %>%
  filter(rsk!= -999) %>%
  filter(fx != -999) %>%
  filter(sdk!= -999)

mon_duration <- as.data.frame(relevant$mon)
mon_duration <- mon_duration[!duplicated(mon_duration[,1]),]

klimate_stations <- as.data.frame(relevant$stations_id)
klimate_stations <- klimate_stations[!duplicated(klimate_stations[,1]),]

year_list <- list()
q <- 1
for (i in klimate_stations){ #month
  print(i)
  df_list = list()
  n = 1
  for (j in mon_duration){  #station
    print(j)
    temp <- relevant[which(relevant$mon == j & relevant$stations_id == i),,drop = FALSE]
    df_list[[n]] <- temp
    n = n + 1
      if (j == mon_duration[12]){
        temp2 <- rbind_list(df_list)
        fm <- sum(temp2$fm)/NROW(temp2)
        rsk <- sum(temp2$rsk)/NROW(temp2)
        fx <- sum(temp2$fx)/NROW(temp2)
        sdk <- sum(temp2$sdk)/NROW(temp2)
        station <- temp2$stations_id[1]
        date <- paste0(substr(temp2[1,]$datum,3,4),"/",
                       substr(temp2[NROW(temp2),]$datum,3,4),
                       "_",temp2$mon[1],
                       "_",temp2$mon[NROW(temp2)])
        year_list[[q]] <- assign(paste0("klima", i),
               tibble(fm,rsk,fx,sdk,station,date))
        q = q +1
        print("full year")
        break
      }
    }
  }

dbWriteTable(con, "jahreswerte_klima", rbind_list(year_list))
