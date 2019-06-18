# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

library(shiny)
library(googledrive)
library(googlesheets)
library(dplyr)
library(pheatmap)
library(tidyr)
library(DT)

ui <- fluidPage(
    
    titlePanel("STEMviz"),
    p(),
    selectInput(
        "theVariable",
        "Select the variable to map",
        c("Week", "Early/Middle/Late", "Introduced/Reinforced")
    ),
    DT::dataTableOutput("theSheet"),
    plotOutput("theHeatmap")

) # ui

server <- function(input, output) {
    
    stemData <-
        drive_get("Test Please Ignore", team_drive = "Integrated Science/Neuroscience") %>%
        select(id) %>%
        combine() %>%
        gs_key(lookup = FALSE,
               visibility = "private") %>%
        gs_read_csv()
    
    output$theHeatmap <- renderPlot({
        # Make the data matrix needed by pheatmap.
        stemData <- as.data.frame(stemData) # Convert back to data frame so we can have row names.
        theData <- select(stemData, 'Topic Name', Course, input$theVariable)
        theData <- spread(theData, Course, input$theVariable)
        rownames(theData) <- theData$'Topic Name'
        theData$'Topic Name' <- NULL
        theData <- as.matrix(theData)
        output$theSheet <- DT::renderDataTable({
            datatable(theData)
        })
        # Can adjust margins of the heatmap by changing cellheight and cellwidth.
        pheatmap(theData, legend = FALSE,
                 display_numbers = TRUE, number_format = "%i", fontsize_number = 25,
                 cellheight = 75, cellwidth = 150,
                 main = paste0("Heatmap of ", input$theVariable, " by Course and Topic\n"))
    })

} # server

# Run the application 
shinyApp(ui = ui, server = server)


