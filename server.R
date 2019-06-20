library(DT)
library(shiny)

shinyServer(function(input, output) {
    output$table <- DT::renderDataTable({
        datatable(trip.data, rownames=FALSE) %>% 
            formatStyle(input$selected, background="skyblue", fontWeight='bold')
    })
    
    
})