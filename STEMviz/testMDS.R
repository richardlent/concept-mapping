# testMDS.R
# Nonmetric Multidimensional Scaling (MDS) with the STEM data.
# Richard A. Lent, Tuesday, October 22, 2019 at 4:38 PM.

library(googlesheets4)
library(vegan)
library(plotly)

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
plotThis <- cbind(stemDataSubset, as.data.frame(scores(mds, display = "site")))

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

