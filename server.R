
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyServer(function(input, output) {

  output$distPlot <- renderPlot({
    Comments_SBT%>%filter(Language %!in% c('Unknown','No_reviews'))%>%
                   group_by(Language)%>%
                   summarize(Tot_comm_lan = n()) %>%
                   arrange(Tot_comm_lan) %>%  
                   mutate(Language = factor(Language, levels = Language))%>%
      ggplot(aes(Language,Tot_comm_lan))+
        geom_point()+
        coord_flip()+
        geom_text(aes(label = Tot_comm_lan, y = Tot_comm_lan+3),
                  position = position_dodge(0.9),
                  hjust = 0)+
        theme_tufte()
    })
  
  output$mymap <- renderLeaflet({
    leaflet()%>%
      addTiles()%>%
      addCircleMarkers(data = User_info, lng =~ lon, lat =~lat, clusterOptions = markerClusterOptions())
  })
  
})


# Elaboration area for charts




