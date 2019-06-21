library(DT)
library(shiny)
library(shinydashboard)

shinyServer(function(input, output) {
    
    output$plot1 <- renderPlot({
        data <- trip.data$Trip.Duration[seq_len(input$slider)]
        hist(data)
    })
    
    output$map_of_boston <- renderLeaflet({
        leaflet(data = station.data %>% filter(municipal==neighborhood)) %>% addTiles() %>%
            addCircleMarkers(~lng,~lat,radius = 4,color = 'red',stroke = FALSE,fillOpacity = 0.65,
                            popup = ~station)
    })
    
})
