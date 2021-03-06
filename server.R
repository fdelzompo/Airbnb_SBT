
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
        geom_col(show.legend = FALSE)+
        coord_flip()+
        geom_text(aes(label = Tot_comm_lan, y = Tot_comm_lan+3),
                  position = position_dodge(0.9),
                  hjust = 0)+
        xlab(NULL)+ylab(NULL)+ggtitle('Language frequency in comments')+
        theme_bw()
  })
  
  output$mymap <- renderLeaflet({
    leaflet()%>%
      addTiles()%>%
      addCircleMarkers(data = User_info, lng =~ lon, lat =~lat, clusterOptions = markerClusterOptions())
  })
  
  
  output$wordcloud <- renderPlot(
    Comments_SBT %>%
      filter(Language == input$selectLanguage )%>%
      unnest_tokens(word, Comments)%>%
      # inner_join(get_sentiments("bing")) %>%
      # count(word, sentiment, sort = TRUE) %>%
      # acast(word ~ sentiment, value.var = "n", fill = 0) %>%
      # comparison.cloud(colors = c("#F8766D", "#00BFC4"),
      #                  max.words = 100)
      anti_join(stop_words) %>%
      count(word) %>%
      with(wordcloud(word, n, max.words = 100,colors=brewer.pal(8, "Dark2")))
  )
  
})


# Elaboration area for charts


  


