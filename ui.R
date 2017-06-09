
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  # titlePanel("San Benedetto del Tronto - AirBnB Analytics"),
    fluidRow(
      column(6,
             plotOutput("distPlot")  
       ),
      column(6,
             leafletOutput("mymap")
      )
    ),
    fluidRow(
      column(6,"Worldcloud",
             selectInput("selectLanguage", "Select a language:",
                         choices = c('English','Italian')),
             plotOutput("wordcloud")#unique(Comments_SBT$Language
        
      )
    )  
    
  )
)
