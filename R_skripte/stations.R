###Bearbeitung Messdaten


library(dplyr)

## Data
dir_tb <- "C:/Users/Eric/Documents/geodb/data/all_station_raw.CSV"
setwd("C:/Users/Eric/Documents/geodb/data/")
klima_station <- read.csv2(dir_tb, header = TRUE, sep = ";")

## cons

klima_station <- cbind(klima_station, "AID" = 1)

klima_station[9] <- NULL
klima_station[8] <- NULL
klima_station[3] <- NULL


## deci berechnung

klima_station <- cbind(klima_station, dez_br = 0)
klima_station <- cbind(klima_station, dez_ln = 0)

decimal <- function(Min, Gra){
  dec <- (Min/60)+ Gra
  return(dec)
}

klima_station$dez_br <- mapply(decimal, as.numeric(substr(klima_station$GEOGR..BREITE,5,6)),
                               as.numeric(substr(klima_station$GEOGR..BREITE,1,2)))
klima_station$dez_ln <- mapply(decimal, as.numeric(substr(klima_station$GEOGR..LÄNGE,5,6)),
                               as.numeric(substr(klima_station$GEOGR..LÄNGE,1,2)))

klima_station[6] <- NULL
klima_station[5] <- NULL
klima_station[1] <- NULL
## write
write.table(klima_station, file = "all_station.txt",
            sep = ';',
            quote = F,
            row.names = F,
            col.names = F)

