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

  for (i in 1: NROW(stations)){   #break down to stations
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
    date <- as.character(paste0(j$datum[1],"_",j$datum[NROW(j)]))
    print(paste0("Wochendurchfluss: ", temp))
    print(paste0("Wochenwasserstand: ", temp2))
    print(date)
    df_list2[[x]] <- assign(paste0("woche", j$stations_id[1]),
                  tibble(durchfluss = temp, wasserstand = temp2,
                             datum = as.character(date),
                             station =j$stations_id[1]))
    x = x + 1
  }
  return (df_list2)

}
#funktioniert so nur mit dieser Art von Tabellen "voll generisch und so"

value_list <- wochen_werte(relevant)

for (i in seq(value_list))
  assign(paste("df",value_list[[i]]$station, sep = ""), value_list[[i]])




stations <- relevant %>%
  select(stations_id) %>%
  distinct

df_list <- list()
for (i in 1: NROW(stations)){   #break down to stations
  df_list[[i]] <- assign(paste0("stat",stations$stations_id[i]),
                         subset(relevant, relevant$stations_id == stations$stations_id[i]))
}

days <- relevant %>%
  select(day) %>%
  distinct
for (q in days$day){

  print(q)
  day_list <- list()
  i = 1
  if (df_list[[1]]$day == q){  #break down to days
    temp <- subset(df_list[[1]], df_list[[1]]$day == q)
    durchfl <- sum(temp$durchfluss)/NROW(temp)
    wassers <- sum(temp$durchfluss)/NROW(temp)
    station <- df_list[[1]]$stations_id[1]
    day_list[[i]] <- assign(paste0("day",temp$day),
                       tibble(durchfluss = durchfl, wasserstand = wassers,
                              tag = q , station = station))
  }
  i = i + 1
}
unlist(day_list)


apply()
