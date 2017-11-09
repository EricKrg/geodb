#script for the computation of the weekly values of "pegel-messdaten"
#database connection with r
#
#database access:
#
#

require("RPostgreSQL")

pacman::p_load(dplyr, tidyverse, lubridate)

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

qry <- {"select * from pegel_messdaten"
  } #Pegelmessdaten query

relevant <- dbGetQuery(con, qry)

relevant <- cbind(relevant, "date" = as.Date(paste0(substr(relevant$mess_datum,1,4),
                                             "/", substr(relevant$mess_datum, 5,6),
                                             "/", substr(relevant$mess_datum,7,8))))
relevant<- as_tibble(relevant)


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

date<- relevant %>%
  select(date) %>%
  distinct # df of days, for later iteration

day_list <- list()

i = 1
for (q in date){   #iteration of daily values
  print(q) #for day q
  for (j in 1:length(df_list) ){
  print(j)  #for station j
  temp <- df_list[[j]][which(df_list[[j]]$date == q),,drop=F] # all values form station j on day q
  durchfl <- sum(temp$durchfluss)/NROW(temp)  # mean daily values
  wassers <- sum(temp$wasserstand)/NROW(temp)
  station <- temp$stations_id[1]
  date <- q
  day_list[[i]] <- assign(paste0("day",temp$day),
                          tibble(durchfluss = durchfl, wasserstand = wassers,
                          station = station, date))
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

duration = as_tibble(seq(day_df$date[1], max(day_df$date), by = 7)) # one week duration (not yet working for monthly change)

for (a in 1:NROW(duration)){  # weekly iteration
  start = duration$value[a]
  print(start)#first day of the week
  for (k in stations){
    print(k)
    week_list[[n]]<- day_df %>%
      filter(station == k) %>%
      filter(date >= start) %>%
      filter(date <= start + days(6)) # filter one week, still includes shorter periodes then one week
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
  date <- paste0(e$date[1], "_", e$date[NROW(e)])
  station <- e$station[1]
  full_week <- FALSE
  if (e$date[1] + days(6) == e$date[NROW(e)] ){
    full_week <- TRUE
  }
  final_values[[q]] <- assign(paste0(e$station[1],"_", date),
               tibble(station, durchfluss, wasserstand, start = e$date[1],
                      end = e$date[nrow(e)],full_week))
  q = q + 1
  }

dbWriteTable(con, "wochenwerte_pegel", rbind_list(final_values))

