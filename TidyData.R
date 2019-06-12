# TidyData.R
# Heatmap using tidy data.

library(pheatmap) # Pretty heatmaps.
library(tidyr)
library(RColorBrewer)

data2 <- read.csv("TidyData.csv", header = TRUE)
data2 <- spread(data2, Course, Week)
rownames(data2) <- data2$Topic
data2$Topic <- NULL
data2 <- as.matrix(data2)

# Have to adjust margins by changing cellheight and cellwidth.
pheatmap(data2, legend = FALSE,
         display_numbers = TRUE, number_format = "%i", fontsize_number = 25,
         cellheight = 75, cellwidth = 150,
         main = "Heatmap table of when topics occur across courses\n",
         color = c("red", "yellow", "green", "blue"))




