# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

library(shiny)
library(googledrive)
library(googlesheets)
library(dplyr)
library(pheatmap)
library(tidyr)
library(DT)
library(readr)
library(superheat)

helpTxt <- read_lines("help.txt")

drive_auth(email = "rlent@holycross.edu")

stemData <-
    # drive_get("Test Please Ignore", team_drive = "Integrated Science/Neuroscience") %>%
    drive_get("STEMunit1", team_drive = "Integrated Science/Neuroscience") %>%
    select(id) %>%
    combine() %>%
    gs_key(lookup = FALSE, visibility = "private") %>%
    gs_read_csv()

ui <- fluidPage(
    titlePanel("STEMviz"),
    actionButton("apphelp", "Help", style="color: black; background-color: cyan; border-color: black;
                     margin-top: 0.5em;"),
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
    
    output$theHeatmap <- renderPlot({ # To make room for title. May have to tweak later.
        # Make the data matrix needed by pheatmap.
        stemData <- as.data.frame(stemData) # Convert back to data frame so we can have row names.
        stemData <- mutate(stemData, 'TopicCourse' = paste0(stemData$`Topic Name`, '-' , stemData$Course))
        theData <- select(stemData, 'TopicCourse', Course, input$theVariable)
        theData <- spread(theData, Course, input$theVariable)
        rownames(theData) <- theData$'TopicCourse'
        theData$'TopicCourse' <- NULL
        theData <- as.matrix(theData)
        output$theSheet <- DT::renderDataTable({
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
    
} # server

# Run the application 
shinyApp(ui = ui, server = server)


