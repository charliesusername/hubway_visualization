shinyUI(dashboardPage(
    dashboardHeader(title = "Hubway Visualization"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Stations", tabName = "map", icon = icon("globe")),
            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            fluidRow(column(width=12,
                            selectInput("station_dropdown", "Choose a station:",
                                        list(`Boston` = station.data$station[station.data$municipal=="Boston"],
                                             `Cambridge` = station.data$station[station.data$municipal=="Cambridge"],
                                             `SomerVille` = station.data$station[station.data$municipal=="Somerville"],
                                             `Brookline` = station.data$station[station.data$municipal=="Brookline"]))
                            
            ))
           
        )
    ),
    dashboardBody(
        tabItems(
            #Map Tab
            tabItem(tabName = "map",
                    # tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
                    # tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                    
                    
                    fluidRow(box(width = 4, column(width = 12, plotOutput("station_density"))),
                             box(width = 8, column(width = 12, leafletOutput('map_of_boston')))),
                    
                    fluidRow(box(
                        width = 12,
                        column(width = 4, offset = 4, "Selected Station: "),
                        column(width = 2, textOutput("station_select"))
                    ))),
            
            
            #Dashboard Tab
            tabItem(tabName = "dashboard",
                    h2("Dashboard tab content"),
                    fluidRow(
                        box(
                            title = 'plot1', status = 'primary',
                            plotOutput("plot1", height = 250)
                        ),
                        
                        box(title = "Controls", status = 'warning',
                            sliderInput("slider", "Number of observations:", 10000, 50000, 5000)
                        )
                    ))
        )
    )
))