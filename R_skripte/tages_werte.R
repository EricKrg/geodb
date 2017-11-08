#script for the computation of the weekly values of "pegel-messdaten"
#database connection with r
#
#database access:
#
#

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
con <- dbConnect(drv, dbname = "Messdaten",        #change con to elephantsql database
                 host = "localhost", port = 5432,
                 user = "postgres", password = pw)
rm(pw) # removes the password

qry <- {"select * from pegel_messdaten inner join messdaten on pegel_messdaten.did = messdaten.did"
  } #Pegelmessdaten query

relevant <- dbGetQuery(con, qry)
relevant[,4] <- NULL

relevant <- cbind(relevant, "mon" = substr(relevant$datum, 5,6))
relevant <- cbind(relevant, "day" = substr(relevant$datum, 7,8))

##alt----

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

###neu----

##loop for daily values
stations <- relevant %>%
  select(stations_id) %>%
  distinct  # df of stations, for later iteration

df_list <- list()
for (i in 1: NROW(stations)){   #break down to stations
  df_list[[i]] <- assign(paste0("stat",stations$stations_id[i]),
                         subset(relevant, relevant$stations_id == stations$stations_id[i]))
}

days <- relevant %>%
  select(day) %>%
  distinct # df of days, for later iteration
day_list <- list()

i = 1
for (q in days$day){   #iteration of daily values
  print(q) #for day q
  for (j in 1:length(df_list) ){
  print(j)  #for station j
  temp <- df_list[[j]][which(df_list[[j]]$day == q),,drop=F] # all values form station j on day q
  durchfl <- sum(temp$durchfluss)/NROW(temp)  # mean daily values
  wassers <- sum(temp$wasserstand)/NROW(temp)
  station <- temp$stations_id[1]
  mon <- temp$mon[1]
  year <- substr(temp$datum[1],1,4 )
  day_list[[i]] <- assign(paste0("day",temp$day),
                          tibble(durchfluss = durchfl, wasserstand = wassers,
                          tag = q,mon = mon , station = station, year = year))
  i = i + 1
  }
}

day_df <- rbind_list(day_list)
day_df   #df of all daily-values for all stations

stations <- as.data.frame(day_df$station)
stations <- stations[!duplicated(stations[,1]),]

week_list = list()
n = 1
start = 0

duration = seq(day_df$tag[1], max(day_df$tag), by = 7) # one week duration (not yet working for monthly change)
for (a in duration){  # weekly iteration
  start =a
  print(start)#first day of the week
  for (k in stations){
    print(k)
    week_list[[n]]<- day_df %>%
      filter(station == k) %>%
      filter(tag >= start) %>%
      filter(tag <= start + 6) # filter one week, still includes shorter periodes then one week
    print("woche:")
    print(length(week_list))
    n = n + 1
    print(n)
    if (length(week_list) == NROW(stations)){  # if all stations been con. to a week per station
      print("next week")
      break
    }
  }
}
final_values = list()
q = 1
for(e in week_list){  # values per week + writing to db
  print(e)
  durchfluss <- sum(e$durchfluss)/NROW(e)
  wasserstand <- sum(e$wasserstand)/NROW(e)
  datum <- paste0(e$tag[1], "_", e$tag[NROW(e)], e$mon[1])
  station <- e$station[1]
  year <- e$year[1]
  final_values[[q]] <- assign(paste0(e$station[1],"_", datum, "_", year),      # maybe conditon to avoid double write
               tibble(durchfluss, wasserstand, start = substr(datum,1,2),
                      end = substr(datum,4,5 ),monat = substr(datum,6,7), station, year))
  q = q + 1
  }

dbWriteTable(con, "Wochenwerte_pegel", rbind_list(final_values))

