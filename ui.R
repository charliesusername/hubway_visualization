shinyUI(dashboardPage(
    dashboardHeader(title = "Hubway Visualization"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Stations", tabName = "map", icon = icon("globe")),
            fluidRow(column(width=12,
                            selectInput("station_dropdown", "Choose a station:",
                                        list(`Boston` = station.data$station[station.data$municipal=="Boston"],
                                             `Cambridge` = station.data$station[station.data$municipal=="Cambridge"],
                                             `SomerVille` = station.data$station[station.data$municipal=="Somerville"],
                                             `Brookline` = station.data$station[station.data$municipal=="Brookline"]))
            ))
           
        )
    ),
    
    
    
    dashboardBody(tabItems(
        #Map Tab
        tabItem(
            tabName = "map",
            tags$head(
                tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
            ),
            tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
            
            
            
            fluidRow(column(width = 4,
                            fluidRow(width = 12,
                                     column(
                                         width = 12,textOutput("station_select"),
                                         fluidRow(column(width = 12, selectInput("time_unit",label = 'Time By',choices = c('Hours', 'Months', 'Weekdays')))),
                                         fluidRow(column(width = 12, radioButtons("wknd", label = "Weekends", c("Yes", "No", "Only"))))
                                )
                            )),
                     column(
                         width = 8,
                         fluidRow(leafletOutput('map_of_boston'), style = "height:400px;width=200px;")
                     )
            ),
            
            fluidRow(
                column(width=4, fluidRow(plotOutput("station_density",width="100%"))),
                column(width=4, fluidRow(plotOutput("sub_type_chart",width="100%"))),
                column(width=4, fluidRow(plotOutput("gender_chart",width="100%")))
            )
            
            # fluidRow(box(width = 12,
            #              column(width = 2, offset =  4, "Selected Station: "),
            #              column(width = 6, textOutput("station_select"))))
            )
        )))
)
