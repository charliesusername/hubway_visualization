shinyServer(function(input, output, session) {
    map = createLeafletMap(session, 'map_of_boston')
    
    ##################################################################
                             ##Render Map##
    ##################################################################
    
    session$onFlushed(once=T,function(){
        output$map_of_boston <- renderLeaflet({
            leaflet(data=station.data) %>% setView(lng = -71.06629, lat = 42.35115, zoom = 13) %>% addTiles() %>% 
                addProviderTiles(providers$CartoDB.Positron) %>% 
                addProviderTiles(providers$Stamen.TonerLines,
                                 options = providerTileOptions(opacity=0.35)) %>% 
                addProviderTiles(providers$Stamen.TonerLabels) %>% 
                addMarkers(~lng,~lat,label=~station,icon=stationIcon)
        })
    })
    
    
    ##################################################################
                    ##Update On Map Marker Click##
    ##################################################################
    
    mapdata <- eventReactive(input$map_of_boston_marker_click,{
        
        click <- input$map_of_boston_marker_click
        if(is.null(click)) {
            station_select = 3
        } else {
            station_select = station.data$id[station.data$lat==click$lat & station.data$lng==click$lng]
        }
    
        
        output$station_select <- renderText({
            station.data$station[station.data$id==station_select]
        })
        
        return(sum_bikes_per_hour(station_select))
        
    },ignoreNULL = FALSE)
    
    output$station_select <- renderText({
        paste("You chose", input$station_dropdown)
    })
    
    output$station_density <- renderPlot({
        ggplot(data = mapdata()) +
            geom_line(aes(x = Hours, y = Arr, color = 'blue')) +
            geom_line(aes(x = Hours, y = Dep, color = 'red')) +
            theme(legend.position = "bottom")
    })
    
    
    output$plot1 <- renderPlot({
        data <- trip.data$Trip.Duration[seq_len(input$slider)]
        
    })
    
    
    
})
