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


wochen_werte <- function(df){
  n = as.numeric(levels(df$day))[1]
  df_list = list()
  stations <- df %>%
    select(stations_id) %>%
    distinct

  for (i in 1: NROW(stations)){
    df_list[[i]] <- assign(paste0("stat",stations$stations_id[i]),
           subset(df, df$stations_id == stations$stations_id[i]))
  }
  df_list2 <- list()
  x = 1
  for (j in df_list){
    temp <- j %>%
      select(durchfluss)%>%
      sum/NROW(j)
    temp2 <- j %>%
      select(wasserstand) %>%
      sum/NROW(j)
    print(paste0("Wochendurchfluss: ", temp))
    print(paste0("Wochenwasserstand: ", temp2))
    df_list2[[x]] <- assign(paste0("woche", j$stations_id[1]),
                  data.frame(durchfluss = temp, wasserstand = temp2,
                             datum =as.character(paste0(j$datum[1],"_",j$datum[NROW(j)])),
                                                        station = j$stations_id[1]))
    x = x + 1
  }
  return(df_list2)
}
#funktioniert so nur mit dieser Art von Tabellen "voll generisch und so"

test<-wochen_werte(relevant)
unlist(test)




