library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(ggplot2)

## Helper Functions
to_pdate <- function(x) {
  return (as.POSIXct(x, format = "%m/%d/%Y %H:%M:%S"))
}

# Joins a dataframe Grouped By Hours to an empty set to fill out the empty Hours.
left_join_na <- function(x) {
  empty <- data.frame(Hours = seq(0,23))
  result = left_join(empty, x, by="Hours")
  result[,2] <- ifelse(is.na(result[,2]),0,result[,2])
  return(result)
}

# Sums the number of bikes moved each hour by station
sum_bikes_per_hour <- function(stn){
  dep_df <- trip.data %>% filter(Start.Station == stn) %>%
    select(Start.Date, Record.ID) %>%
    mutate(Start.Date = to_pdate(Start.Date),
           Hours = as.numeric(strftime(Start.Date, format = "%H"))) %>%
    filter(!(weekdays(Start.Date) %in% c('Saturday', 'Sunday'))) %>% 
    group_by(Hours) %>% summarise(Dep = n()) %>% left_join_na(.)
  
  arr_df <- trip.data %>% filter(End.Station == stn) %>%
    select(End.Date, Record.ID) %>%
    mutate(End.Date = to_pdate(End.Date),
           Hours = as.numeric(strftime(End.Date, format = "%H"))) %>%
    filter(!(weekdays(End.Date) %in% c('Saturday', 'Sunday'))) %>% 
    group_by(Hours) %>% summarise(Arr = n()) %>% 
    left_join_na()
  
  out_df <- left_join(dep_df, arr_df, by="Hours")
  return(out_df)
}


## Pull Trip Data
trip.data <- data.table::fread(input="data/cleaned_trips.csv")
station.data <- data.table::fread(input="data/hubway_stations.csv") %>% 
   right_join(.,union(trip.data %>% select(Start.Station) %>% transmute(id = Start.Station),
                      trip.data %>% select(End.Station) %>% transmute(id = End.Station)) %>% 
                filter(!is.na(id)),by="id")

choice <- colnames(trip.data%>% select(-Record.ID,-Trip.ID))


## Styling
# Make a list of icons for map markers
Station.Icons <- iconList(
  boston = makeIcon("www/iconfinder_flat-style-circle-add_1312548.png",18,18)
)

## Default Value
neighborhood = 'Boston'



## Marker Stuff

stationIcon <- makeIcon(
  iconUrl = "www/HubwayLogo_green.png",
  iconWidth = 20, iconHeight = 20,
  iconAnchorX = 0, iconAnchorY = 0
)
