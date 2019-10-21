# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

library(shiny)

shinyUI(fluidPage(
    titlePanel("STEMviz"),
    actionButton("apphelp", "Help", style="color: black; background-color: cyan; border-color: black;
                     margin-top: 0.5em;"),
    p(),
    selectInput(
        "theVariable",
        "Select the variable to map",
        c("Week", "Early/Middle/Late", "Introduced/Reinforced")
    ),
    DT::dataTableOutput("theGoogleSheet"),
    plotOutput("theHeatmap")
))
