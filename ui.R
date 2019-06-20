shinyUI(dashboardPage(
    dashboardHeader(title = "Hubway Visualization"),
    dashboardSidebar(
        sidebarUserPanel("", image = "Hubwaylogo2014.png"),
        sidebarMenu(
            menuItem("Map", tabName = "map", icon = icon("map")),
            menuItem("Data", tabName = "table", icon = icon("database"),
                     badgeLabel = 'new', badgeColor = 'green'),
            menuItem("Graph", tabname = "graph", icon = icon("bar-chart-o"),)
        ),
        selectizeInput("selected",
                       "Select Item to Display",
                       choice)
    ),
    dashboardBody(
        tags$head(
            tags$link(rel = 'stylesheet', type = 'text/css', href = 'custom.css')
        ),
        tabItems(
            tabItem(tabName = 'map',
                    fluidRow(box(htmlOutput("map"), width = 12))),
            tabItem(tabName = 'graphs',
                    fluidRow()),
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("table"), width = 12)))
        )
    )
))



#
#
# # Define UI for application that draws a histogram
# shinyUI(fluidPage(
#
#     # Application title
#     titlePanel("Hubway Visualization"),
#
#     # Sidebar with a slider input for number of bins
#     sidebarLayout(
#         sidebarPanel(
#             sliderInput("bins",
#                         "Number of bins:",
#                         min = 1,
#                         max = 50,
#                         value = 30)
#         ),
#
#         # Show a plot of the generated distribution
#         mainPanel(
#             plotOutput("distPlot")
#         )
#     )
# ))
