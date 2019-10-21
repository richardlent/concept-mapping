# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

library(shiny)
library(googlesheets)
library(dplyr)
library(tidyr)
library(DT)
library(readr)
library(superheat)
library(htmltools)

helpTxt <- read_lines("help.txt")

# This performs authentication using a stored Google Sheets OAuth token obtained with gs_auth().
gs_auth(token = "googlesheetsToken.rds")

table <- "Copy of STEMunit1"     # The name of the Google Sheet.
theSheet <- gs_title(table)      # Register the Google Sheet.
stemData <- gs_read(theSheet)    # Read the Google Sheet into a tibble.

shinyServer(function(input, output, session) {

    output$theHeatmap <- renderPlot({ 
        # Make the data matrix needed by pheatmap and/or superheat.
        stemData <- as.data.frame(stemData) # Convert back to data frame so we can have row names.
        stemData <- mutate(stemData, 'TopicCourse' = paste0(stemData$`Topic Name`, '-' , stemData$Course))
        theData <- select(stemData, 'TopicCourse', Course, input$theVariable)
        theData <- spread(theData, Course, input$theVariable)
        # theData[is.na(theData)] <- 0        # Replace NAs with 0.
        rownames(theData) <- theData$'TopicCourse'
        theData$'TopicCourse' <- NULL
        theData <- as.matrix(theData)
        output$theGoogleSheet <- DT::renderDataTable({
            datatable(stemData)
        })
        superheat(theData, 
                  # X.text = theData, # Plot data values on top of heatmap cells.
                  title = paste0("Heatmap of ", input$theVariable, " by Course and Topic\n"),
                  title.size = 10,
                  # row.dendrogram = TRUE, col.dendrogram = TRUE,
                  heat.na.col = "white",
                  left.label.size = 0.35, # Default size is 0.2.
                  force.grid.hline = TRUE,
                  force.grid.vline = TRUE
                  )
    }, height = 2000)
    
    observeEvent(input$apphelp, {
        helpContent <- HTML(helpTxt)
        showModal(modalDialog(
            title = HTML("<center><h3>STEMviz Help</h3></center>"), helpContent
        ))
    }) # observeEvent(input$apphelp

}) # shinyServer
