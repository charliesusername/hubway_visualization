library(shiny)
library(shinydashboard)
library(leaflet)

## Helper Functions
to_pdate <- function(x) {
  return (as.POSIXct(x, format = "%m/%d/%Y %H:%M:%S"))
}

## Pull Trip Data
trip.data <- data.table::fread(input="data/cleaned_trips.csv")
station.data <- data.table::fread(input="data/hubway_stations.csv")
choice <- colnames(trip.data%>% select(-Record.ID,-Trip.ID))


## Styling
# Make a list of icons for map markers
Station.Icons <- iconList(
  boston = makeIcon("www/iconfinder_flat-style-circle-add_1312548.png",18,18)
)

## Default Value
neighborhood = 'Boston'
  
