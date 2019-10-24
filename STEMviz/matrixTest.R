# matrixTest.R
# Create and process the topics x topics matrix.
# NOTE: Probably don't need this.

setwd("~/Dropbox/Data/Notes/Projects/AloBasuConceptMapping/STEMviz")

library(dplyr)

stemData <- readRDS("stemData.rds") # Tidy data from the Google Sheet.

# Deal with duplicate topics. Variable `Topic and Course` is a unique 
# identifier pairing each topic with its course.
stemData <- mutate(stemData, 'TopicCourse' = paste0(stemData$`Topic Name`, ' - ' , stemData$Course))

# Create a topics x topics matrix of all zeroes.
theMatrix <- matrix(nrow=length(stemData$TopicCourse), ncol=length(stemData$TopicCourse), 
    dim=list(names=stemData$TopicCourse, colnames=stemData$TopicCourse))
for (r in rownames(theMatrix)) {
  for (c in colnames(theMatrix)) {
    theMatrix[r, c] <- 0
  }
}

# Compute pairwise intersections of underlying concepts.
# So far: Does nothing.
for (r in rownames(theMatrix)) {
  for (c in colnames(theMatrix)) {
    rr <- filter(stemData, TopicCourse == r)
    rr <- select(rr, "Underlying Concept 1":"Underlying Skill 3")
    cc <- uh <- filter(stemData, TopicCourse == c)
    cc <- select(cc, "Underlying Concept 1":"Underlying Skill 3")
  }
}
