shinyServer(function(input, output, session) {
    map = createLeafletMap(session, 'map_of_boston')
    vars = reactiveValues()
    vars$unit <- "Weekdays"
    vars$wknd <- 0
    
    
    ##################################################################
    ##Selector Values Update##
    ##################################################################
    observeEvent(input$time_unit, {
        vars$unit <- input$time_unit
    })
    observeEvent(input$wknd, {
        vars$wknd <- input$wknd
    })
    
    
    
    
    
    ##################################################################
    ##Render Map##
    ##################################################################
    
    from_lines <- reactive ({
       
        from_stn = trip.data %>% filter(Start.Station != mapdata() & End.Station == mapdata()) %>%
            group_by(Start.Station) %>% rename(.,id=Start.Station) %>%
            summarise(Trips = n()) %>%left_join(stn_loc_lookup,.,by='id') %>%  top_n(.,n=10,wt=Trips) %>% head(10) %>% select(-id,-Trips)
        orig_stn <-data.frame(lat = c(rep(station.data$lat[station.data$id == mapdata()], 10)),
                              lng = c(rep(station.data$lng[station.data$id == mapdata()], 10)))
        orig_stn$sequence <- c(sequence = seq(1, length.out = 10, by=2))
        from_stn$sequence <- c(sequence = seq(2, length.out = 10, by=2))
        from_lines <- union(orig_stn,from_stn,by='sequence') %>% arrange(sequence)
        
        from_lines
    })
    
    to_lines <- reactive({
        to_stn = trip.data %>% filter(Start.Station == mapdata() & End.Station != mapdata()) %>%
            group_by(End.Station) %>% rename(.,id=End.Station) %>% 
            summarise(Trips = n()) %>%left_join(stn_loc_lookup,.,by='id') %>%  top_n(.,n=10,wt=Trips) %>% head(10) %>%  select(-id,-Trips)
        orig_stn <-data.frame(lat = c(rep(station.data$lat[station.data$id == mapdata()], 10)),
                              lng = c(rep(station.data$lng[station.data$id == mapdata()], 10)))
        orig_stn$sequence <- c(sequence = seq(1, length.out = 10, by=2))
        to_stn$sequence <- c(sequence = seq(2, length.out = 10, by=2))
        to_lines <- union(orig_stn,to_stn,by='sequence') %>% arrange(sequence)
        to_lines
    })
    
    orig_stn <- reactive({
        print(mapdata())
        orig_stn <-data.frame(lat = station.data$lat[station.data$id == mapdata()],
                              lng = station.data$lng[station.data$id == mapdata()])
        orig_stn
    })
    
    
    
    
    
    
    session$onFlush(once = T, function() {
        
        
        output$map_of_boston <- renderLeaflet({
            myMap <- leaflet(data = station.data)  %>%
                addTiles(
                    urlTemplate = "https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png?apikey=85f83fb1e0c44f6597929aa2de80d9fe",
                    attribution = "&copy; <a href='http://www.thunderforest.com/'>Thunderforest</a>,  &copy; <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a>",
                    options = tileOptions(variant = 'mobile-atlas', apikey = '85f83fb1e0c44f6597929aa2de80d9fe')
                ) %>%
                setView(.,lat = orig_stn()$lat,
                        lng = orig_stn()$lng,
                        zoom = 15) %>%
                setMaxBounds(
                    lat1 = 42.421100,
                    lng1 = -71.147464,
                    lat2 = 42.304661,
                    lng2 = -71.004335
                ) %>%
                addMarkers( ~ lng, ~ lat, label =  ~ station, icon = stationIcon) %>% 
                addPolylines(
                    data=from_lines(),
                    lng = ~lng,
                     lat = ~lat,
                     weight=3,
                    opacity=0.4,color = 'red') %>% 
                addPolylines(
                    data=to_lines(),
                    lng = ~lng,
                    lat = ~lat,
                    weight=3,
                    opacity=0.4,color = 'blue')
                
            
            
            # for(group in levels(df$group)) {
            #     myMap = addPolylines(myMap,
            #                          lng = ~ longitude,lat = ~ latitude,
            #                          data = df[df$group == group, ],color = ~ colour,weight = 3)
            # }
                
                
                
                
                    
                
                myMap
        })
    })
    
    
    ##################################################################
    ##Update On Map Marker Click##
    ##################################################################
    
    mapdata <- eventReactive(input$map_of_boston_marker_click, {
        click <- input$map_of_boston_marker_click
        
        if (is.null(click)) {
            station_select = 23
        } else {
            station_select = station.data$id[station.data$lat == click$lat &
                                                 station.data$lng == click$lng]
        }
        
        
        output$station_select <- renderText({
            station.data$station[station.data$id == station_select]
        })
        
        
        
        
        return(station_select)
        
    }, ignoreNULL = FALSE)
    
    
    ##################################################################
    ##Redraw Graphs##
    ##################################################################
    
    
    output$station_density <- renderPlot({
        tu <- vars$unit
        wd <- vars$wknd
        
        df <-
            sum_bikes_per_hour(trip.data,
                               mapdata(),
                               unit = tu,
                               wknd = wd)
        df$Net_Trips <- df$Arr - df$Dep
        
        ggplot(data = df, aes_string(x = tu, y = "Net_Trips")) +
            geom_bar(stat = 'identity', aes(fill = Net_Trips > 0)) +
            xlab("") + ylab("Net Trips") +
            ggtitle("Net Trips from this Station") +
            scale_fill_discrete(labels = c('Bikes Out', 'Bikes In')) +
            theme_solarized()  +
            theme(
                legend.position = c(.18, 1.01),
                legend.justification = c("right", "top"),
                legend.box.just = "top",
                legend.margin = margin(6, 6, 6, 6),
                legend.background = element_blank(),
                legend.title = element_blank()
            )
    })
    
    
    output$gender_chart <- renderPlot({
        tu <- vars$unit
        wd <- vars$wknd
        
        df_plot <-
            sum_bikes_per_hour(
                trip.data %>% filter(Gender == "Male"),
                mapdata(),
                unit = tu,
                wknd = wd
            ) %>%
            mutate(Male = Dep + Arr) %>% select(-Dep, -Arr)
        df_plot$Female <-
            sum_bikes_per_hour(
                trip.data %>% filter(Gender == "Female"),
                mapdata(),
                unit = tu,
                wknd = wd
            ) %>%
            mutate(Female = Dep + Arr) %>% select(-Dep, -Arr) %>% .[, 2]
        
        
        
        ggplot(data = melt(df_plot, id.vars = tu), aes_string(x = tu)) +
            geom_bar(aes(weight = value, fill = variable)) +
            ggtitle("Average Rides by Gender from this Station") + ylab("Number of Rides") +
            scale_fill_discrete() +
            theme_solarized()  +
            theme(
                legend.position = c(.15, 1.01),
                legend.justification = c("right", "top"),
                legend.box.just = "top",
                legend.margin = margin(6, 6, 6, 6),
                legend.background = element_blank(),
                legend.title = element_blank()
            )
        
    })
    
    output$sub_type_chart <- renderPlot({
        tu <- vars$unit
        wd <- vars$wknd
        df_plot <-
            sum_bikes_per_hour(
                trip.data %>% filter(Sub.Type == "Registered"),
                mapdata(),
                unit = tu,
                wknd = wd
            ) %>%
            mutate(Commuter = Dep + Arr) %>% select(-Dep, -Arr)
        
        df_plot$Casual <-
            sum_bikes_per_hour(
                trip.data %>% filter(Sub.Type == "Casual"),
                mapdata(),
                unit = tu,
                wknd = wd
            ) %>%
            mutate(Casual = Dep + Arr) %>% select(-Dep, -Arr) %>% .[, 2]
        
        ggplot(data = melt(df_plot, id.vars = tu),
               aes(
                   x = "",
                   y = value,
                   fill = variable
               )) +
            geom_bar(stat = 'identity', position = 'identity') +
            coord_polar("y", 0) +
            ggtitle("Average Trips By Consumer Type from this Station") +
            scale_fill_discrete(labels = c('Commuter', 'Casual')) +
            xlab("") + ylab("") +
            theme_solarized() +
            theme(
                legend.position = c(.22, 1.01),
                legend.justification = c("right", "top"),
                legend.box.just = "top",
                legend.margin = margin(6, 6, 6, 6),
                legend.background = element_blank(),
                legend.title = element_blank()
            )
        
    })
    
    
    ##################################################################
    ##Data Table Drawing & Station Statistics##
    ##################################################################
    output$station_table = DT::renderDataTable({
        out <- trip.data %>% filter(Start.Station == 3 | End.Station == 3)
        
        
        if (vars$wknd == 0) {
            return(out %>% filter(!(
                weekdays(to_pdate(Start.Date)) %in% c('Saturday', 'Sunday')
            )))
        } else if (vars$wknd == 1) {
            return(out %>% filter(weekdays(to_pdate(
                Start.Date
            )) %in% c('Saturday', 'Sunday')))
        } else {
            return(out)
        }
        
        
    })
    output$trips_table = DT::renderDataTable({
        trip.data
    })
    
    
    
})
