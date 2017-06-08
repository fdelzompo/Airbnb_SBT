source('airbnb.r')

Listings_in_SBT <- read_rds('Listings_in_SBT')

Comments_SBT <- read_rds('Comments_SBT')
Comments_SBT$Language <- detectLanguage(Comments_SBT$Comments)$detectedLanguage %>% str_to_title()
Comments_SBT$Language[Comments_SBT$Authors == 'No_reviews'] <- 'No_reviews'
Comments_SBT$Language <- Comments_SBT$Language %>% as.factor()
Comments_SBT$Date <- parse_date(Comments_SBT$Date, '%B %Y')

User_info <- read_rds('User_info')
User_info$Joined <- parse_date(User_info$Joined, '%B %Y')

Comments_SBT %>%
                select(Authors)%>%
                mutate(Authors = if_else(Authors == 'No_reviews','No_reviews','With_reviews'))%>%
                group_by(Authors)%>%
                summarise(n = n())