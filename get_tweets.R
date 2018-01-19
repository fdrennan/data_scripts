library(RPostgreSQL)
library(twitteR)
library(stringr)
library(rvest)
library(lubridate)
library(drentools)
consumer_key <- "s4h5t47KxmlKiVRvqXLOzGiDG"
consumer_secret <- "7p3ulGMcFtSTbbvhMYavLklSReUbAJ6BSfZPZx1BXKGbE3XsWL"
access_token <- "273988968-ZWeALI3PklEaxIvOTCWoft95qBimpguNM6ib7FL0"
access_secret <- "d0mNClHjuS9WvbxSngWsSWz0ZAlBejSc3BijEfTaymuQG"




setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

user_name <- "realDonaldTrump"

# Download tweets from user profile
tweets <- userTimeline(user_name, n = 500)

# Convert tweets to a data frame
trumpTweets <- twListToDF(tweets)
tt <- trumpTweets
trumpTweets$actual = NA
trumpTweets$links = NA

filtered = ymd_hms(trumpTweets$created) > (Sys.time() %>% ymd_hms) - hm("0, 10")
trumpTweets = trumpTweets[filtered,]
#   
if(nrow(trumpTweets) != 0) {
  
  
  for(i in 1:nrow(trumpTweets)) {
    returnedValue <-   
      str_extract(trumpTweets$text[i], "https://.*") 
    if(!is.na(returnedValue)) {
      returnedValue = strsplit(returnedValue, " ")[[1]]
      returnedValue = returnedValue[length(returnedValue)]
      returnedValue <- 
        returnedValue %>%  
        read_html() %>%
        html_node('.tweet-text') %>% 
        as.character
      
      trumpTweets$actual[i] <- returnedValue
    }
    print(i)
  }
  
  
  
  
  
  
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  # creates a connection to the postgres database
  # note that "con" will be used later in each connection to the database
  con <- dbConnect(drv,
                   dbname = "freddydb",
                   host = "mydatabase.c2pc3qmfwusq.us-east-2.rds.amazonaws.com",
                   port = 5432,
                   user = "fdrennan",
                   password = 'thirdday1')
  
  
  
  trumpTweets$time = as.character(Sys.time())
  Encoding(trumpTweets$text) = 'byte'
  
  # writes df to the PostgreSQL database "postgres", table "cartable"
  dbWriteTable(con, 
               "trumpTweets",
               value = trumpTweets, 
               append = TRUE, 
               row.names = FALSE)


}

mongoConn <- drentools::mongo_connect('tweets', 'twitter')

tt$text <- 
  tt$text %>% 
  lapply(
    function(x) sub("\xed\xa0\xbc\xed\xb7\xba\xed\xa0\xbc\xed\xb7\xb8", "", x )
  ) %>% 
  as.vector()

tt = tt %>% nest

tt$time = as.character(Sys.time())

tt$person = 'trump'
print(.libPaths())
# insert to db.
mongoConn$insert(tt)
