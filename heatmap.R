# heatmap.R
# Heatmap of when topics occur across courses.
# Uses CSV file data1.csv.
# Richard A. Lent, June 2019.

library(pheatmap) # Pretty heatmaps.

data1 <- as.matrix(read.csv("data1.csv", header = TRUE))
rownames(data1) <- c("scientific method", "neurons", "memory", "development", "experiment", 
                     "pH", "metabolism", "enzymes", "heredity", "dna")

# Have to adjust margins by changing cellheight and cellwidth.
pheatmap(data1, legend_breaks = c(1, 2, 3), legend_labels = c("early", "middle", "late"),
         display_numbers = TRUE, number_format = "%i", fontsize_number = 25,
         cellheight = 75, cellwidth = 150,
         main = "Heatmap table of when topics occur across courses\n")




