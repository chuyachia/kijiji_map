#### Clean json data ####
library(rjson)
library(dplyr)
library(stringr)
setwd("C:/Users/Client/Desktop/kijiji_map")
json_file <- "kijiji.json"
kijiji <- fromJSON(file=json_file)
kijiji_df <- data.frame(do.call("rbind",kijiji))
names(kijiji_df)
kijiji_df$title <- as.character(kijiji_df$title)
kijiji_df$address <- as.character(kijiji_df$address)
kijiji_df$code <- as.character(kijiji_df$code)
kijiji_df$date <- as.character(kijiji_df$date)
kijiji_df$date<-  as.Date(kijiji_df$date, "%d-%b-%y")
kijiji_df$room <- as.character(kijiji_df$room)
kijiji_df$room <- as.factor(kijiji_df$room)
kijiji_df$price <- as.numeric(kijiji_df$price)
kijiji_df <- kijiji_df[!is.na(kijiji_df$price),]
kijiji_df <- kijiji_df[kijiji_df$price<100000,]
kijiji_df$code<- str_extract(kijiji_df$code,"[:digit:]+")
kijiji_df <-unique(kijiji_df)

#### GeoCoordinate ####
library(ggmap)
loc <- NULL
for (i in 1:nrow(kijiji_df))
{
  
  loc <- rbind(loc,geocode(kijiji_df$address[i]))
}

kijiji_df <- cbind(kijiji_df,loc)

