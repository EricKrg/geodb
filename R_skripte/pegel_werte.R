###Bearbeitung Messdaten


library(dplyr)

## Data

setwd("C:/Users/Eric/Documents/geodb/Pegel_daten")

#dir_tb <- "57521.0_Wasserstand_Wipperdorf.txt"
#dir_tb2 <-"57521.0_Durchfluss_Wipperdorf.txt"

#dir_tb <- "57027.0_Wasserstand_Rudolstadt.txt"
#dir_tb2 <- "57027.0_Durchfluss_Rudolstadt.txt"

dir_tb <- "42012.0_Wasserstand_Vacha.txt"
dir_tb2 <- "42012.0_Durchfluss_Vacha.txt"


#####
Mess_df <- read.table(dir_tb, header = TRUE)
Mess_df2 <- read.table(dir_tb2, header = TRUE)

Mess_df <- left_join(Mess_df, Mess_df2)

## data cons
Mess_df <- cbind(Mess_df, Stations_id = substr(dir_tb, 1,7))
Mess_df <- cbind(Mess_df, AID = "2")

Mess_df <- cbind(Mess_df,
                DID = paste0(gsub('[.]','',Mess_df$Stations_id),
                             gsub('[.]','', Mess_df$Datum),
                             gsub(':|,','',Mess_df$Uhrzeit)))

date_structur <- function(date){
  date = gsub('[.]','', date)
  year = substr(date,5,8)
  day  = substr(date,1,2)
  month = substr(date,3,4)
  n_date = paste0(year,month, day)
  return(n_date)
}

Mess_df$Datum <- mapply(date_structur, Mess_df$Datum)
Mess_df[2] <- NULL


# Pegel export
Mess_df_all <- Mess_df %>%
  select(DID,Stations_id,Datum, AID, Wasserstand,Durchfluss)

write.table(Mess_df_all, file = paste0(substr(dir_tb,21,nchar(dir_tb)-4),"_pegel.txt"),append = FALSE, sep = ";",
            row.names = FALSE, col.names = FALSE, quote = F)
