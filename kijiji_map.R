library(RColorBrewer)
library(classInt)
library(dplyr)
library(stringr)
library(ggplot2)
library(scales)
library(maptools)
library(sp)
#### Load cleaned data with geocoord ####
setwd("C:/Users/Client/Desktop/kijiji_map")
kijiji_df<- read.csv("kijiji.csv",sep=";",stringsAsFactors = FALSE)
kijiji_df$lon <- as.numeric(kijiji_df$lon)
kijiji_df$lat <- as.numeric(kijiji_df$lat)
kijiji_df$room[kijiji_df$room=="b-appartement-condo-3-1-2"] <- "3 et demi"
kijiji_df$room[kijiji_df$room=="b-appartement-condo-4-1-2"] <- "4 et demi"
kijiji_df$room[kijiji_df$room=="b-appartement-condo-5-1-2"] <- "5 et demi"
kijiji_df$room[kijiji_df$room=="b-appartement-condo-6-1-2-et-plus"] <- "6 et demi ou plus"

## Spatial join
area <- readShapePoly("QUARTIER/QUARTIER.shp")

kijiji_df <- kijiji_df[!is.na(kijiji_df$lon),]
coordinates(kijiji_df) <- ~lon+lat 
proj4string(kijiji_df) <- proj4string(area)
joined <- over(kijiji_df, area)
kijiji_df <- cbind.data.frame(kijiji_df,joined)
kijiji_df <- kijiji_df[!is.na(kijiji_df$NOM),] # keep only those in Quebec city

#### Price/ different type apartments ####
p_median <- kijiji_df %>% group_by(room)%>%
  summarise(med=median(price),no=n())

ggplot(kijiji_df, aes(x=room, y=price)) + 
  geom_boxplot(fill='#A4A4A4', color="black")+
  scale_y_continuous(labels=dollar_format(prefix="$"))+
  geom_text(data = p_median, aes(x = room, y = med,
                                 label = paste("$",med)), 
            size = 3, vjust = -1)+
  labs(x="",y="",title="Prix des logements selon le nombre de pièces")

#### Price/ area ####
district_stat<- kijiji_df %>% group_by(NOM)%>% 
  summarize(median_price= median(price),
            sd_price=sd(price),number=n())
area <- merge(area, district_stat, by='NOM')
area@data$density <- area@data$number/area@data$SUPERFICIE

ncat <-  5
pal <- brewer.pal(ncat, "YlOrRd")
density <- area@data$density
class_density <- classIntervals(density,n=ncat, style="quantile")
col_density <- findColours(class_density, pal)
par(bg = "grey90")
plot(area, col=col_density,border=rgb(0, 0, 0, 0.3))
title(main="Densité de logements à louer",sub="Source de données : kijiji.ca")
invisible(text(getSpPPolygonsLabptSlots(area), labels=as.character(area$NOM), cex=0.4))
