shinyUI(dashboardPage(
    dashboardHeader(title = "Hubway Station Metrics",
                    titleWidth = 230,
                    tags$li('By Charles Cohen',
                            style = 'text-align: right;padding-top:17px; font-family: Arial, Helvetica, sans-serif;
                            font-weight: bold;  font-size: 13px;',
                            class='dropdown'),
                    tags$li(a(href = 'https://github.com/charliesusername/hubway_visualization_shiny',
                              img(src = 'GitHub_Logo.png',title = "github link", height = "18px")),
                            class = "dropdown")
                    ),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Stations", tabName = "map", icon = icon("globe")),
            menuItem("Dataset", tabName = "data", icon=icon("database"))
        )
    ),
    
    dashboardBody(tabItems(
        #Map Tab
        tabItem(
            tabName = "map",
            tags$head(
                
                tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
                tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
            ),
            tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
            
            
            
            fluidRow(column(width = 4,
                            fluidRow(
                                width = 12,
                                column(
                                    width = 12,
                                    textOutput("station_select"),
                                    fluidRow(column(
                                        width = 12, selectInput(
                                            "time_unit",
                                            label = 'Time By',
                                            choices = c('Hours', 'Months', 'Weekdays')
                                        )
                                    )),
                                    fluidRow(column(
                                        width = 12, radioButtons("wknd", label = "Weekends", c(
                                            "Yes" = 2,
                                            "No" = 0,
                                            "Only" = 1
                                        ))
                                    ))
                                )
                            )),
                     column(
                         width = 8,
                         fluidRow(leafletOutput('map_of_boston'), style = "height:400px;width=200px;")
                     )),
            tabsetPanel(type="tabs",
                        tabPanel("Graphs",fluidRow(
                            column(width = 4, fluidRow(
                                plotOutput("station_density", width = "100%")
                            )),
                            column(width = 4, fluidRow(
                                plotOutput("sub_type_chart", width = "100%")
                            )),
                            column(width = 4, fluidRow(
                                plotOutput("gender_chart", width = "100%")
                            ))
                        )),
                        tabPanel("Data",fluidRow(
                            column(width=12,DT::dataTableOutput("station_table"))
                        )))
            
        ),
        tabItem(tabName = "data",
                fluidRow(column(width=12,DT::dataTableOutput("trips_table"))))
    )))
)
