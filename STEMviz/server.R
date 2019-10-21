# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

library(shiny)
library(googlesheets)
library(dplyr)
library(pheatmap)
library(tidyr)
library(DT)
library(readr)
library(superheat)

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
        rownames(theData) <- theData$'TopicCourse'
        theData$'TopicCourse' <- NULL
        theData <- as.matrix(theData)
        output$theGoogleSheet <- DT::renderDataTable({
            # datatable(theData)
            datatable(stemData)
        })
        # Can adjust margins of the heatmap by changing cellheight and cellwidth.
        # pheatmap(theData, legend = FALSE,
        #          display_numbers = TRUE, number_format = "%i", fontsize_number = 25,
        #          cellheight = 75, cellwidth = 150,
        #          fontsize_row = 16, fontsize_col = 16, fontsize = 12,
        #          main = paste0("Heatmap of ", input$theVariable, " by Course and Topic\n"))
        superheat(theData)
    }, height = 2000)
    
    observeEvent(input$apphelp, {
        helpContent <- HTML(helpTxt)
        showModal(modalDialog(
            title = HTML("<center><h3>STEMviz Help</h3></center>"), helpContent
        ))
    }) # observeEvent(input$apphelp

}) # shinyServer
