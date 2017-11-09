###Bearbeitung Messdaten


library(dplyr)

## Data
setwd("C:/Users/Eric/Documents/geodb/klima_daten")

#dir_tb <- "brocken_raw.txt" # brocken  obvious name is obvious

#dir_tb <-"fehmarn_raw.txt" #fehmarn
dir_tb <- "Zugspitze_raw.txt" #zugspitze

Mess_df <- read.table(dir_tb, sep = ";", header = TRUE)



## Data construction

Mess_df <- cbind(Mess_df, DID = paste0(Mess_df$STATIONS_ID, Mess_df$MESS_DATUM))  # create unique DID

Mess_df <- cbind(Mess_df, Art = 1)

Mess_grob <- Mess_df %>%
  select(DID,STATIONS_ID,MESS_DATUM,Art)

Mess_df_all <- Mess_df %>%
  select(DID,STATIONS_ID,MESS_DATUM,Art,QN_3,FM,RSK,FX,SDK)

## data writing

#write.csv2(Mess_grob, file = paste0(dir_tb,"_klima.csv"), sep = ';')

write.table(Mess_df_all, file = paste0(substr(dir_tb,1, nchar(dir_tb)-4),"_klima.txt"),
            sep = ";", row.names = FALSE, col.names = FALSE, quote = F)

