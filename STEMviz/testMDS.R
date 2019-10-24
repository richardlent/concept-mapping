# testMDS.R
# Nonmetric Multidimensional Scaling (MDS) with the STEM data.
# Richard A. Lent, Tuesday, October 22, 2019 at 4:38 PM.

library(googlesheets)
library(vegan)
library(plotly)

# This performs authentication using a stored Google Sheets OAuth token obtained with gs_auth().
gs_auth(token = "googlesheetsToken.rds")

if(!exists("stemData")) {
  table <- "Copy of STEMunit1"     # The name of the Google Sheet.
  theSheet <- gs_title(table)      # Register the Google Sheet.
  stemData <- gs_read(theSheet)    # Read the Google Sheet into a tibble.
}

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

# p <-
#   plot_ly(
#     data = plotThis,
#     x = ~ NMDS1,
#     y = ~ NMDS2,
#     z = ~ NMDS3,
#     mode = 'text',
#     text = plotThis$`Topic Name`
#   ) 

p <- plot_ly(type = 'scatter3d', mode = 'text') %>% 
  add_trace(
    data = plotThis,
    x = ~ NMDS1,
    y = ~ NMDS2,
    z = ~ NMDS3,
    text = ~ `Topic Name`
    # hoverinfo = plotThis$Course
  ) 

print(p)

