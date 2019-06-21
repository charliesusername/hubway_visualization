shinyUI(dashboardPage(
    dashboardHeader(title = "Hubway Visualization"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("Map", tabName = "map", icon = icon("globe"))
        )
    ),
    dashboardBody(
        tabItems(
            #Dashboard Tab
            tabItem(tabName = "dashboard",
                    h2("Dashboard tab content"),
                fluidRow(
                    box(title='plot1',status='primary',
                        plotOutput("plot1", height = 250)),
                    
                    box(
                        title = "Controls",status='warning',
                        sliderInput("slider", "Number of observations:", 10000, 50000, 5000)
                    )
                )
            ),
            
            #Map Tab
            tabItem(tabName = "map",
                    h2("Map tab content"),
                    fluidRow(
                        box(title='map1',
                            tags$style(type = "text/css", "#map_of_boston {width: calc(100vh - 80px) !important;}"),
                            leafletOutput('map_of_boston')
                            )
                    ))
        )
    )
))
                      
