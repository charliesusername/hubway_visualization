library(dplyr)
library(ggplot2)
library(data.table)
library(re)


to_date <- function(x) {
  
  temp = t(as.data.frame(strsplit(as.character(x),' ')))
  time = chron(dates = temp[,1],times=temp[,2],
               format = c('m/d/y','h:m:s'))
  return(time)
}

to_pdate <- function(x) {
  return (as.POSIXct(x, format = "%m/%d/%Y %H:%M:%S"))
}

trips = data.table::fread(file="./data/hubway_trips.csv")
stations = data.table::fread(file="./data/hubway_stations.csv")

colnames(trips) = c('Record.ID','Trip.ID','Status','Trip.Duration','Start.Date',
                    'Start.Station','End.Date','End.Station','Bike.ID','Sub.Type',
                    'Zipcode','Birthdate','Gender')

proc.trips = trips %>%
  select(-Status) %>% 
  filter(str_extract(Start.Date,pattern='\\d\\d\\d\\d')==2012) %>% 
  mutate(Trip.Duration = chron::minutes(to_date(End.Date) - to_date(Start.Date))) %>%  
  filter(Trip.Duration > 1)
    
 


saveRDS(proc.trips, file = "data/tripdata.rda")
bar <- readRDS(file="data/tripdata.rda")

str_extract(trips$Start.Date[],pattern='\\d\\d\\d\\d')==2012


data.table::fwrite(x = proc.trips,file="data/cleaned_trips.csv")

rm(list=ls())
