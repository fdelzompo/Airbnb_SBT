# List of action done to create data used in app
require(tidyverse)
require(cldr)
require(stringr)
require(purrr)
require(rvest)
require(ggthemes)
require(ggmap)
require(leaflet)
require(jsonlite)
source('airbnb.r')

# Step 0 - Create session on Airbnb
# session <- html_session('https://www.airbnb.com')
# url <- submit_form(session, 'San-Benedetto-del-Tronto', submit = )



# ************************************************************
# Step 1 - Create first search page URL
url_page1 <- 'https://www.airbnb.com/s/San-Benedetto-del-Tronto--Province-of-Ascoli-Piceno--Italy/homes?allow_override%5B%5D=&s_tag=uogtHCr-'

list_of_pages <- c(url_page1, str_c(url_page1,'&section_offset=',c(1:(num_pages(url_page1)-1))))

# Step 2 - Parse pages to get room links

Listings_in_SBT = NULL
for (page in list_of_pages){
  url <- read_html(page)
  Sys.sleep(0.3)
  Listings_in_SBT <- append(Listings_in_SBT, BuildRoomURL(url))
}

Listings_in_SBT = as.data.frame(Listings_in_SBT)
names(Listings_in_SBT) <- c('Link_to_Page', 'room_ID')
Listings_in_SBT$Link_to_Page <- as.character(Listings_in_SBT$Link_to_Page)
Listings_in_SBT$room_ID = as.integer(str_extract(Listings_in_SBT$Link_to_Page,'[0-9]{1,}'))

write_rds(Listings_in_SBT,'Listings_in_SBT')
Listings_in_SBT <- read_rds('Listings_in_SBT')

# Step 3 - Read information from rooms
Comments_SBT <- NULL
i = 0
for (link in Listings_in_SBT$Link_to_Page){
  i = i+1
  print(paste(as.character(i),link))
  Sys.sleep(0.1)
  comments <- Get_comments(link)
  Comments_SBT <- bind_rows(Comments_SBT, comments)
}
write_rds(Comments_SBT,'Comments_SBT')
Comments_SBT <- readRDS('comments_SBT')

Comments_SBT$Language <- detectLanguage(Comments_SBT$Comments)$detectedLanguage %>% str_to_title()
Comments_SBT$Language[Comments_SBT$Authors == 'No_reviews'] <- 'No_reviews'
Comments_SBT$Language <- Comments_SBT$Language %>% as.factor()
Comments_SBT$Date <- parse_date(Comments_SBT$Date, '%B %Y')


#Step 4 - Get information about users
User_info <- NULL
unique_users<- Comments_SBT %>% select(Authors)%>%filter(Authors != 'No_reviews')%>%unique()
i = 0
for (user in unique_users$Authors){
  i = i+1
  Sys.sleep(2)
  print(paste(as.character(i),user))
  info <- Get_info_users(user)
  User_info <- bind_rows(User_info, info)
}
write_rds(User_info, 'User_info')
User_info <- read_rds('User_info')

User_info$Joined <- parse_date(User_info$Joined, '%B %Y')
# geomap of the customers:
User_info <- User_info %>% bind_cols(geocode(User_info$Location))

