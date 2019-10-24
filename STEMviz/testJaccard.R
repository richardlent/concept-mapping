# Weems to work, but also seems useless.
# testJaccard.R
# Heatmap using Underlying Concept 1 dummy variables.
# Richard Lent, Thursday, July 25, 2019 at 3:39 PM.

library(proxy)
library(shiny)
library(googledrive)
library(googlesheets)
library(dplyr)
library(tidyr)
library(DT)
library(readr)
library(superheat)
library(pheatmap)
library(fastDummies)

# Get the data from Google Sheets.
# Assumes the presence of .httr-oauth.
stemData <-
  drive_get("STEMunit1", team_drive = "Integrated Science/Neuroscience") %>%
  select(id) %>%
  combine() %>%
  gs_key(lookup = FALSE, visibility = "private") %>%
  gs_read_csv()

# Create a unique row ID.
stemData <- as.data.frame(stemData) # Convert back to data frame so we can have row names.
stemData <- mutate(stemData, 'TopicCourse' = paste0(stemData$`Topic Name`, '-' , stemData$Course))

# Create dummy variables from Underlying Concept 1.
stemData <- dummy_columns(stemData, select_columns = "Underlying Concept 1", ignore_na = FALSE)

# Delete NA rows, then drop the NA dummy variable.
stemData <- filter(stemData, stemData$`Underlying Concept 1_NA` == 0)
stemData$`Underlying Concept 1_NA` <- NULL

# Select variables for analysis.
stemData <- select(stemData, Course, TopicCourse, contains("1_"))

# Create Jaccard distance matrix from the data frame.
stemDist <- proxy::dist(stemData, by_rows = TRUE, method = "Jaccard")

# Heatmap.
pheatmap(stemDist)
