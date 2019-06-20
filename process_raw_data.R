library(dplyr)
library(ggplot2)
library(data.table)

to_POSIXct_date <- function(x) {
  return (as.POSIXct(x, format="%m/%d/%Y %H:%M:%S"))
}

trips = data.table::fread(file="./data/hubway_trips.csv")
stations = data.table::fread(file="./data/hubway_stations.csv")

colnames(trips) = c('record.id','trip.id','status','trip.duration','start.date','start.station','end.date','end.station','bike.id','sub.type','zip.code','birthdate','gender')

proc.trips = trips %>%
  select(-status) %>% 
  mutate(start.date = to_date(start.date),
         end.date = to_date(end.date),
         trip.duration = chron::minutes(end.date - start.date),
         zip.code = as.factor(gsub(pattern="'",replacement="",x=zip.code)),
         gender = as.factor(gender),
         sub.type = as.factor(sub.type),
         start.station = as.factor(start.station),
         end.station = as.factor(end.station)
         ) %>% 
  filter(trip.duration > 1)


sapply(proc.trips, class)


to_date <- function(x) {
  
  temp = t(as.data.frame(strsplit(as.character(x),' ')))
  time = chron(dates = temp[,1],times=temp[,2],
               format = c('m/d/y','h:m:s'))
  return(time)
}


data.table::fwrite(x = proc.trips,file="data/cleaned_trips.csv")
