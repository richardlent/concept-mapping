# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

helpTxt <- read_lines("help.txt")

# This performs authentication using a stored Google Sheets OAuth token obtained with gs_auth().
gs_auth(token = "googlesheetsToken.rds")

if(!exists("stemData")) {
    table <- "Copy of STEMunit1"     # The name of the Google Sheet.
    theSheet <- gs_title(table)      # Register the Google Sheet.
    stemData <- gs_read(theSheet)    # Read the Google Sheet into a tibble.
}

shinyServer(function(input, output, session) {

    output$theHeatmap <- renderPlot({ 
        
        # Make the data matrix needed by pheatmap and/or superheat.
        stemDataHeatmap <- as.data.frame(stemData) # Convert back to data frame so we can have row names.
        stemDataHeatmap <- mutate(stemDataHeatmap, 'TopicCourse' = paste0(stemDataHeatmap$`Topic Name`, '-' , stemDataHeatmap$Course))
        theData <- select(stemDataHeatmap, 'TopicCourse', Course, input$theVariable)
        theData <- spread(theData, Course, input$theVariable)
        # theData[is.na(theData)] <- 0        # Replace NAs with 0.
        rownames(theData) <- theData$'TopicCourse'
        theData$'TopicCourse' <- NULL
        theData <- as.matrix(theData)
        
        output$theGoogleSheet <- DT::renderDataTable({
            datatable(stemDataHeatmap)
        })
        
        superheat(theData, 
                  # X.text = theData, # Plot data values on top of heatmap cells.
                  title = paste0("Heatmap of\n", input$theVariable, "\nby Course and Topic\n"),
                  title.size = 10, # Default is 5.
                  # row.dendrogram = TRUE, col.dendrogram = TRUE,
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
            # stemDataSubset$`Early/Middle/Late`, 
            stemDataSubset$`Introduced/Reinforced`,
            stemDataSubset$`Class time`), 
            method="maximum"
        )
        
        # Do MDS.
        mds <- metaMDS(topics.dist, k = 3)
        
        # Merge scores with data so we can label points with topic names.
        plotThis <- cbind(stemDataSubset, as.data.frame(scores(mds)))
        
        # Make a 3D Plotly scatterplot of the MDS axes, with topics as labels.
        p <- plot_ly(type = 'scatter3d', mode = 'text') %>% 
            add_trace(
                data = plotThis,
                x = ~ NMDS1,
                y = ~ NMDS2,
                z = ~ NMDS3,
                text = ~ `Topic Name`
            ) %>% layout(font = list(size = 13))
        
    }) # renderPlotly
    
    observeEvent(input$apphelp, {
        helpContent <- HTML(helpTxt)
        showModal(modalDialog(size = "l",
            title = HTML("<center><h3>STEMviz Help</h3></center>"), helpContent
        ))
    }) # observeEvent(input$apphelp

}) # shinyServer
