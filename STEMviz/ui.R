# STEMviz, a Shiny app for visualization of STEM topics and concept mapping.
# Richard Lent, Thursday, June 13, 2019.

shinyUI(fluidPage(
    
    titlePanel("STEMviz"),
    actionButton("apphelp", "Help", style="color: black; background-color: cyan; border-color: black;
                     margin-top: 0.5em;"),
    p(),
    selectInput(
        "theVariable",
        "Select variable for heatmap",
        c("Week", "Early/Middle/Late", "Introduced/Reinforced", "Class time")
    ),
    DT::dataTableOutput("theGoogleSheet"),
    br(), br(), br(), br(), br(), br(),
    HTML("<center>"),
    h3("Multidimensional Scaling"),
    h3("Ordination of Topics"),
    HTML("</center>"),
    plotlyOutput("mds", height = 1000, width = "100%"),
    plotOutput("theHeatmap")
    
)) # fluidPage
