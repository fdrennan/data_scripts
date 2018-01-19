library(rwunderground)
library(RPostgreSQL)
library(dplyr)
library(mailR)
library(lubridate)
library(stringr)
library(tidyverse)


api_key = 'd364068bdb5bbcc9'

loc = set_location(territory = "Colorado", city = "Fort Collins")

cond = conditions(loc, key = api_key)


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

cond <- as.data.frame(cond)

cond$time = as.character(Sys.time())

the_time = Sys.time()
the_time = with_tz(the_time, tzone = 'MST')

time_comparison = paste0(Sys.Date(), ' 22:00:00 MST')
# time_comparison = with_tz(time_comparison, tz = 'MST')
time_comparison = ymd_hms(time_comparison, tz = 'MST')



tc =abs(as.numeric(time_comparison-the_time)*60)

if(tc < 10) {
  
  retrieve_data <- function(database) {
    # Build the source object
    myRedshift <- src_postgres(
      dbname = 'freddydb',
      host = "mydatabase.c2pc3qmfwusq.us-east-2.rds.amazonaws.com",
      port = 5432,
      user = "fdrennan",
      password = "thirdday1")
    
    query = paste0('SELECT * FROM public.\"', database, "\"")
    
    psql_obj <- tbl(myRedshift, sql(query))
    # psql_obj <- tbl(myRedshift, sql(query))
    
    psql_obj
    
  }
  
  hist = retrieve_data('focoWeather') %>% as.data.frame() %>% as_tibble()
  
  today <-
    hist %>% 
    select(time, temp) %>% 
    mutate(
      time = ymd_hms(time)
    ) %>% 
    filter(
      time >= Sys.time() - hours(24)
    )
  
  savePlot <- function(myPlot) {
    pdf("myPlot.pdf")
    print(myPlot)
    dev.off()
  }
  
  yesterday_plot <- 
    hist %>% 
    select(time, temp) %>% 
    mutate(
      time = ymd_hms(time)
    ) %>% 
    filter(
      time >= Sys.time() - hours(24)
    ) %>% 
    mutate(
      time = time - hours(7)
    ) %>% 
    arrange(desc(time)) %>% 
    ggplot() +
    aes(x = time, y = temp) +
    geom_line()
      

  savePlot(yesterday_plot)
  
  forec = forecast3day(loc, key = api_key)
  
  message <- paste0(
    'The high for tomorrow is ',
    forec$temp_high[1], 
    ' and the low is ',
    forec$temp_low[1],
    ".",
    ' The weather will be ',
    forec$cond[1], 
    ' with a probability of rain at ',
    forec$p_precip[1],
    ' percent. ',
    'Since this time yesterday, the high was ',
    max(today$temp), 
    ' and the low was ',
    min(today$temp)
  )
  
  sender <- "drennanfreddy@gmail.com"
  recipients <- c("2549318313@txt.att.net", 'drennanfreddy@gmail.com')
  send.mail(from = sender,
            to = recipients,
            subject = "The Weather",
            body = message,
            smtp = list(host.name = "smtp.gmail.com", port = 465, 
                        user.name = "drennanfreddy@gmail.com",            
                        passwd = "11101147557-1BSr1!", ssl = TRUE),
            authenticate = TRUE,
            attach.files = c("myPlot.pdf"),
            send = TRUE)
  
}

# 
# 
# 
# writes df to the PostgreSQL database "postgres", table "cartable"
dbWriteTable(con, "focoWeather",
             value = cond, append = TRUE, row.names = FALSE)


