shinyServer(function(input, output, session) {
    map = createLeafletMap(session, 'map_of_boston')
    
    variables = reactiveValues()
    
    
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
        
        
        
        
        return(station_select)
        
    },ignoreNULL = FALSE)
    
    
    output$station_density <- renderPlot({
        
        df <- sum_bikes_per_hour(trip.data, mapdata())
        df$Net_Trips <- df$Arr - df$Dep
        
        ggplot(data = df,aes(x=Hours,y=Net_Trips)) +
            geom_bar(stat='identity',aes(fill=Net_Trips > 0)) +
            theme(legend.position = "None")
    })
    
    
    output$gender_chart <- renderPlot({
        data <- mapdata()
        
        
        
        df_plot <- sum_bikes_per_hour(trip.data %>% filter(Gender=="Male"),mapdata()) %>%  
            transmute(Hours=Hours, Male = Dep + Arr)
        df_plot$Female <- sum_bikes_per_hour(trip.data %>% filter(Gender=="Female"),mapdata()) %>%  
            transmute(Hours=Hours,Female = Dep + Arr) %>% .[,2]
        
        df_plot <- data.frame(Male = sum(df_plot$Male),Female = sum(df_plot$Female))
        
    
        ggplot(data=melt(df_plot), aes(x="",y=value, fill=variable)) + 
            geom_bar(stat='identity',width=1) +
            coord_polar("y", start=0) +
            ggtitle("Gender Use")
        
    })
    
    output$sub_type_chart <- renderPlot({
        
        df_plot <- sum_bikes_per_hour(trip.data %>% filter(Sub.Type=="Registered"),mapdata()) %>%  
            transmute(Hours=Hours,Commuter = Dep + Arr)
        
        df_plot$Casual <- sum_bikes_per_hour(trip.data %>% filter(Sub.Type=="Casual"),mapdata()) %>%  
            transmute(Hours=Hours,Casual = Dep + Arr) %>% .[,2]
        
        ggplot(data=melt(df_plot,id.vars="Hours"), aes(x=Hours,y=value, fill=variable)) + 
            geom_bar(stat='identity', position='identity', aes(alpha=0.3)) +
            ggtitle("Average Trips By Consumer Type \nCommuter v. Casual")
        
    })
    
    
    
    
    
    
    
})
