#*****************************************************************************************
# Author: Francesco Del Zompo
# Purpose: Getting information from Airbnb websites, mainly used to understand the market of my hometown:
# San Benedetto del Tronto
# If you have the chance, go visit it, it's a lovely place :)
# Copyright: MIT License
# More info: took inspiration from https://gist.github.com/doctordo/83056a9d7708345487427b5df5a336b9
# but not really actively using any of his functions.
# endorsing scraping the AirBnB website.
#*****************************************************************************************
require(tidyverse)
require(cldr)
require(stringr)
require(rvest)
require(ggthemes)
require(ggmap)
require(leaflet)
require(tidytext)
require(wordcloud)



Get_Price <- function(room) {
  # Get Prices
  # Scrapes data off a given room page
  # Not WORKING YET!!!
  room <- 'https://www.airbnb.com/rooms/16737298?location=San%20Benedetto%20del%20Tronto%2C%20Province%20of%20Ascoli%20Piceno%2C%20Italy&check_in=2017-07-30&check_out=2017-08-05&s=6jrMmW4U'
  Test <- read_html(room) %>% 
    html_nodes(xpath = '//*[@id="book-it-price-string"]/') %>%
    # html_nodes('.text_5mbkop-o_O-size_small_1gg2mc-o_O-inline_g86r3e')%>% as.character()
    # html_children() %>%
    html_text() %>%
    str_subset(":")
}



Get_comments <- function(room){
  # Get comments information
  room_html <- read_html(room)
  number_comments <-  room_html%>%
                      html_node(xpath = '//*[@id="reviews"]/div/div/div/div[1]/div[1]/div[1]/div/h4/span/span')%>%
                      html_text()%>%
                      str_extract('[0-9]{1,}')%>%
                      as.numeric()
  room_Id <- as.integer(str_extract(room,'[0-9]{1,}'))
  if(!is.na(number_comments) && number_comments>0){
    comments <- room_html %>% html_nodes('div.row.review')
    info <- NULL
    for (i in 1:length(comments)){
      info <- bind_rows(info,Get_info_comments(comments[[i]]))
    }
    Authors <- info$Authors
    Date <- info$Date
    Comments <- info$Comments
    Replies <- info$Replies
  }else{
      Authors <- 'No_reviews'
      Date <- 'No_reviews'
      Comments <- 'No_reviews'
      Replies <- 'No_reviews'
      }
  Comments_data <- data.frame(
    room_Id,
    Authors,
    Date,
    Comments,
    Replies
  ) 
  Comments_data
}

Get_info_comments<- function(comment){
  # Finds unique information for each comment node
  Comments <- comment %>%html_node('div.expandable-content.expandable-content--hasDlsReducedText')%>%
    html_text()%>%
    as.character()
  Date <- comment %>% html_node('div.date')%>%
    html_text()%>%
    as.character()
  Authors <- comment %>% html_node('a.text-muted.link-reset')%>%
    html_attr('href')%>%
    as.character()
  Replies <- comment %>% html_node('div.media-body')%>%
    html_text()%>%
    as.character()
  Comment_data <- data.frame(
    Authors,
    Date,
    Comments,
    Replies
  )
  Comment_data
}

Get_info_users <- function(user){
  # get info about users
  user_html <- read_html(paste0('https://www.airbnb.com',user))
  name <- user_html %>% html_nodes('h1')%>%html_text()%>% str_trim()%>%word(3)%>%str_extract('[A-Za-z]+')
  Location <- user_html %>% html_nodes('.h5 .link-reset')%>%html_text()
  Joined <- user_html %>% html_nodes('.h5 .text-normal')%>%html_text()%>% str_trim()%>%word(3,4)
  Description <- user_html %>% html_nodes('.space-top-2 p')%>%html_text()%>%paste(collapse = " ")
  User_data <- data.frame(
    user,
    name,
    Location,
    Joined,
    Description
  )
  User_data
}

'%!in%' <- function(x,y)!('%in%'(x,y))


# Get_info_users('/users/show/42292389')
# paste0(Listings_in_SBT[34],'?&check_in=2017-07-30&check_out=2017-08-05')
# 

