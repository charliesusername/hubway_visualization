library(dplyr)
library(ggplot2)
library(data.table)
library(chron)
library(shiny)
library(shinydashboard)
library(googleVis)
library(DT)

## Pull Trip Data
trip.data <- data.frame(data.table::fread(input="data/cleaned_trips.csv"))
colnames(trip.data) <- c('Record.ID','Trip.ID','Trip.Duration','Start.Date','Start.Station','End.Date','End.Station','Bike.ID','Subscription.Type','Zipcode','Birthdate','Gender')

choice <- colnames(trip.data%>% select(-Record.ID,-Trip.ID))
