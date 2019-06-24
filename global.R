library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(ggplot2)
library(reshape2)
library(ggthemes)


## Helper Functions
to_pdate <- function(x) {
  return (as.POSIXct(x, format = "%m/%d/%Y %H:%M:%S"))
}

# Joins a dataframe Grouped By Hours to an empty set to fill out the empty Hours.
left_join_na <- function(x,unit,wknd) {
  if(unit=="Hours") {
    empty <- data.frame(Hours = seq(0,23))
  } else if (unit =="Weekdays") {
    if (wknd==2) {
      empty <- data.frame(Weekdays = seq(0, 6))
    } else if (wknd==1) {
      empty <- data.frame(Weekdays = c(0,6))
    } else if (wknd==0) {
      empty <- data.frame(Weekdays = seq(1,5))
    }
  } else if (unit == "Months") {
    empty <- data.frame(Months = seq(1,12))
  }
  result = left_join(empty, x, by=unit)
  result[,2] <- ifelse(is.na(result[,2]),0,result[,2])
  return(result)
}

# Averaged the number of bikes moved in/out by a given station over a given time unit.
# With a Weekend On/Off/Only toggle.
sum_bikes_per_hour <- function(df, stn, unit="Hours", wknd=0){
  dep_df <- df %>% filter(Start.Station == stn) %>%
    select(Start.Date, Record.ID) %>% mutate(Start.Date = to_pdate(Start.Date))
  
  arr_df <- df %>% filter(End.Station == stn) %>%
    select(End.Date, Record.ID) %>% mutate(End.Date = to_pdate(End.Date))
    
  if (unit == "Hours") {
    dep_df <- dep_df %>% mutate(Hours = as.numeric(strftime(Start.Date, format = "%H"))) %>% group_by(Hours)
    arr_df <- arr_df %>% mutate(Hours = as.numeric(strftime(End.Date, format = "%H"))) %>% group_by(Hours)
  } else if (unit == "Months") {
    dep_df <- dep_df %>% mutate(Months = as.numeric(strftime(Start.Date, format = "%m"))) %>% group_by(Months)
    arr_df <- arr_df %>% mutate(Months = as.numeric(strftime(End.Date, format = "%m"))) %>% group_by(Months)
  } else if (unit == "Weekdays") {
    dep_df <- dep_df %>% mutate(Weekdays = as.numeric(strftime(Start.Date, format = "%w"))) %>% group_by(Weekdays)
    arr_df <- arr_df %>% mutate(Weekdays = as.numeric(strftime(End.Date, format = "%w"))) %>% group_by(Weekdays)
  }
  
  if (wknd == 1) {
    dep_df <- dep_df %>%  filter(weekdays(Start.Date) %in% c('Saturday', 'Sunday'))
    arr_df <- arr_df %>%  filter(weekdays(End.Date) %in% c('Saturday', 'Sunday'))
  } else if (wknd == 0) {
    dep_df <- dep_df %>%  filter(!(weekdays(Start.Date) %in% c('Saturday', 'Sunday')))
    arr_df <- arr_df %>%  filter(!(weekdays(End.Date) %in% c('Saturday', 'Sunday')))
  }


  dep_df <- dep_df %>% summarise(Dep = n()) %>% left_join_na(., unit, wknd)
  arr_df <- arr_df %>% summarise(Arr = n()) %>% left_join_na(., unit, wknd)
  
  
  out_df <- left_join(dep_df, arr_df,by=unit)
  return (out_df)
   
}

#setwd("C:/Users/iamch/Desktop/data_science/projects/hubway_visualization_shiny/")

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

stn_loc_lookup = station.data %>% select(id,lat,lng)

stationIcon <- makeIcon(
  iconUrl = "www/HubwayLogo_green.png",
  iconWidth = 20, iconHeight = 20,
  iconAnchorX = 0, iconAnchorY = 0
)
