# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

source("global.R")

helpTxt <- read_lines("help.txt")

# Set where OAuth tokens are stored.
options(
  gargle_oauth_email = TRUE,
  gargle_oauth_cache = ".secrets"
)

# Full URL of the Google Sheet is:
# https://docs.google.com/spreadsheets/d/1M701ZK76GItnSC9BxzptZdOVP2I4XnGwREkt-dFVp6A/edit#gid=1914830905
# Owner: Richard Lent

sheetID <- "1M701ZK76GItnSC9BxzptZdOVP2I4XnGwREkt-dFVp6A"

if(!exists("stemData")) {
    
    stemData <- read_sheet(sheetID) # A tibble.
}

shinyServer(function(input, output, session) {
    
    showModal(modalDialog("Rendering graphics, please wait...", footer = modalButton("Dismiss"),
                          size = "s", easyClose = TRUE))

    output$theHeatmap <- renderPlot({ 
        
        # Make the data matrix needed by pheatmap and/or superheat.
        stemDataHeatmap <- as.data.frame(stemData) # Convert back to data frame so we can have row names.
        theData <- select(stemDataHeatmap, `Topic Name`, Course, input$theVariable)
        theData <- spread(theData, Course, input$theVariable)
        rownames(theData) <- theData$`Topic Name`
        theData$`Topic Name` <- NULL
        theData <- as.matrix(theData)
        
        output$theGoogleSheet <- DT::renderDataTable({
            datatable(stemDataHeatmap)
        })
        
        superheat(theData, 
                  # X.text = theData, # Plot data values on top of heatmap cells.
                  title = paste0("Heatmap of\n", input$theVariable, "\nby Course and Topic\n"),
                  title.size = 10, # Default is 5.
                  heat.na.col = "lightgrey",
                  left.label.size = 0.35, # Default size is 0.2.
                  force.grid.hline = TRUE,
                  force.grid.vline = TRUE,
                  column.title = "Courses",
                  row.title = "Topics",
                  column.title.size = 8,
                  row.title.size = 8
                  )
        
    }, height = 2000) # renderPlot
    
    output$mds <- renderPlotly({
        
        # Subset variables.
        stemDataSubset <- stemData[c('Topic Name', 'Week', 'Early/Middle/Late', 
                                     'Introduced/Reinforced', 'Class time', 'Course')]
        
        # Make a distance matrix of topics.
        topics.dist <- dist(cbind(
            stemDataSubset$Week, 
            stemDataSubset$`Introduced/Reinforced`,
            stemDataSubset$`Class time`), 
            method="maximum"
        )
        
        # Do MDS.
        mds <- metaMDS(topics.dist, k = 3)
        
        # Merge scores with data so we can label points with topic names.
        plotThis <- cbind(stemDataSubset, as.data.frame(scores(mds, display = "site")))
        
        # Make a 3D Plotly scatterplot of the MDS axes, with topics as labels
        # and course name as hover text.
        p <- plot_ly(type = 'scatter3d', mode = 'text') %>% 
            config(
                toImageButtonOptions = list(
                    format = "png",
                    width = 1700,
                    height = 1450
                )
            ) %>% 
            add_trace(
                data = plotThis,
                x = ~ NMDS1,
                y = ~ NMDS2,
                z = ~ NMDS3,
                text = ~ `Topic Name`,
                hovertext = ~ Course,
                hoverinfo = 'text'
            ) %>% layout(font = list(size = 13)) %>% 
            layout(
                scene = list(
                    xaxis = list(
                        showspikes = FALSE
                    ),
                    yaxis = list(
                        showspikes = FALSE
                    ),
                    zaxis = list(
                        showspikes = FALSE
                    )
                )) # layout
        
    }) # renderPlotly
    
    observeEvent(input$apphelp, {
        helpContent <- HTML(helpTxt)
        showModal(modalDialog(size = "l", easyClose = TRUE,
            title = HTML("<center><h3>STEMviz Help</h3></center>"), helpContent
        ))
    }) # observeEvent(input$apphelp

}) # shinyServer
