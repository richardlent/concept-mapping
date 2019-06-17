# TidyData.R
# Heatmap using tidy data.
# Richard A. Lent, June 12, 2019.

library(pheatmap) # Pretty heatmaps.
library(tidyr)
library(googledrive)
library(googlesheets)
library(dplyr)

# This variable eventually will be picked off an input list
# in the Shiny app.
x <- "Week" # The quantitative variable for the heatmap.

# Get the shared Google Sheet and read it into an R data frame.
# sheets_auth(email = "rlent@holycross.edu") # Probably should encrypt this.

stemData <-
  drive_get("Test Please Ignore", team_drive = "Integrated Science/Neuroscience") %>%
  select(id) %>%
  combine() %>%
  gs_key(lookup = FALSE,
         visibility = "private") %>%
  gs_read_csv()

# Make the data matrix needed by pheatmap.
stemData <- as.data.frame(stemData) # Convert back to data frame so we can have row names.
theData <- select(stemData, 'Topic Name', Course, x)
theData <- spread(theData, Course, x)
rownames(theData) <- theData$'Topic Name'
theData$'Topic Name' <- NULL
theData <- as.matrix(theData)

# Can adjust margins of the heatmap by changing cellheight and cellwidth.
pheatmap(theData, legend = FALSE,
         display_numbers = TRUE, number_format = "%i", fontsize_number = 25,
         cellheight = 75, cellwidth = 150,
         main = paste0("Heatmap of ", x, " by Course and Topic\n"))




