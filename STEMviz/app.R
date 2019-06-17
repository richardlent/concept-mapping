# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

library(shiny)
library(googledrive)
library(googlesheets)
library(dplyr)

ui <- fluidPage(
    
    titlePanel("STEMviz"),
    dataTableOutput("theSheet")

) # ui

server <- function(input, output) {
    
    stemData <-
        drive_get("STEM Topics Data", team_drive = "Integrated Science/Neuroscience") %>%
        select(id) %>%
        combine() %>%
        gs_key(lookup = FALSE,
               visibility = "private") %>%
        gs_read_csv()
    
    output$theSheet <- renderDataTable({
        stemData
    })

} # server

# Run the application 
shinyApp(ui = ui, server = server)


