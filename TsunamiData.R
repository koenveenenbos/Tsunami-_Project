#Koen Veenenbos & Tim Jak
#January 2017

#Import the necessary data
library(rvest) #To download the external internet data
library(plyr) #To count the number of occasions per country
library(maps) #To plot the dot map
library(rworldmap) #To plot the frequency map
library(RColorBrewer) #To get the colours for the frequency map
library(leaflet) #To create the interactive map
library(plotly) #To create interactive scatterplot

#Set the current working directory
setwd("/home/user/GeoscriptingProject")

#Import other R functions
source("./R/WikiToR.R")
source("./R/SelectData.R")
source("./R/SelectDataOrigin.R")

#-----------------------------------Defining variables----------------------------------
#Input variables
#Function SelectData
#Optional are: MONTH, DAY, LOCATION_NAME
Year <- 2000
Selection <- c("MONTH", "DAY", "LOCATION_NAME") 

#Function SelectDataOrigin
#Optional are: COUNTRY, DAY, HOUR, MINUTE, SECOND, CAUSE_CODE, FOCAL_DEPTH, PRIMARY_MAGNITUDE, TOTAL_DEATHS, TOTAL_HOUSES_DESTROYED
Selection_origin <- c("COUNTRY", "DAY", "HOUR", "MINUTE", "SECOND", "CAUSE_CODE", "FOCAL_DEPTH", "PRIMARY_MAGNITUDE", "TOTAL_DEATHS", "TOTAL_HOUSES_DESTROYED")

#Function ImportData
URL <- "https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)_per_capita"
NTable <- 5
Header1 <- "Country"
Header2 <- "US$"

#-------------------------------Script to create database-------------------------------
#Run Python code in R
system("python ./Python/DownloadConvertData.py")

#Retrieve the TsunamiData and TsunamiDataOrigin out of the csv file created in the Python script
#TsunamiData contains the data of tsunamis which entered the mainland, 
#while the TsunamiDataOrigin contains the source of the tsunami
TsunamiCSV <- read.csv("./Data/tsevent.csv", header = TRUE, sep = "\t", dec = ".")
TsunamiCSVOrigin <- read.csv("./Data/tsorigin.csv", header = TRUE, sep = "\t", dec = ".")

#Select the period and the specific data you need for the TsunamiData and TsunamiDataOrigin files
#Select the columns you want the data with those two functions
SelectData(Year, Selection)
SelectDataOrigin(Year, Selection_origin)

#Change the column names of the Origin Dataset, so they don't match with the other Tsunami DataSet
colnames(TsunamiCSVOriginSel) <- paste(colnames(TsunamiCSVOriginSel), "origin", sep = "_")

#Merge the TsunamiDataSet and the TsunamiDataSetOrigin (which contain the source locations of the tsunami)
MergeTsunamiData <- merge(TsunamiCSVSel, TsunamiCSVOriginSel, by.x = "TSEVENT_ID", by.y = "ID_origin", all = TRUE)

#Import additional data with this function:
#This function creates the variable GDPCountryDF, with information about GDP per country
ImportData(URL, NTable, Header1, Header2)

#Create a DataFrame out of the GDPCountry list
GDPCountryDF <- as.data.frame(GDPCountry)

#Make sure the countries are written in uppercase
GDPCountryDF$Country <- toupper(GDPCountryDF$Country)

#Merge the GDP data with the tsunami event data
MergeGDP <- merge(MergeTsunamiData, GDPCountryDF, by.x = "COUNTRY", by.y = "Country", all = TRUE)

#Count the number of times a country got hit
NCountry <- count(MergeTsunamiData$COUNTRY)

#Merge the number of occasions with the tsunami event data
TsunamiData <- merge(MergeGDP, NCountry, by.x = "COUNTRY", by.y = "x", all = TRUE)

#Delete the countries where no tsunami events have been recorded and the events without coordinates
TsunamiData <- TsunamiData[!is.na(TsunamiData$TSEVENT_ID),]
TsunamiData <- TsunamiData[!is.na(TsunamiData$LATITUDE) | !is.na(TsunamiData$LONGITUDE), ]

#------------------------------------Create dot map-------------------------------------
#Settings of outlines of the map
par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")

#Create map using standaard world map
map("world", fill=TRUE, col="cornsilk")
title("Tsunami events from 2000 till present")
points(TsunamiCSVSel$LONGITUDE, TsunamiCSVSel$LATITUDE, col="firebrick3", pch=16, cex = 0.5)  

#---------------------------------Create frequency map----------------------------------
#create a map-shaped window
mapDevice('x11')

#join to a coarse resolution map
ConnectMaps <- joinCountryData2Map(TsunamiData, joinCode="NAME", nameJoinColumn="COUNTRY")

#Plot the map according to the specified settings
mapCountryData(ConnectMaps, nameColumnToPlot = "freq", catMethod = "logFixedWidth", 
               colourPalette = brewer.pal(7, "YlOrRd"), 
               mapTitle = "Countries most hit by tsunami's from 2000 till present", 
               missingCountryCol = "gray96", oceanCol = "lightblue")

par(mai=c(0,0,0,0))

#--------------------------------Create interactive map---------------------------------
# Create tsunami icon
tsunami_icon <- makeIcon(iconUrl = 'Icons/tsunami.png',  
                         iconWidth = 32, iconHeight = 37, 
                         iconAnchorX = 16, iconAnchorY = 36)

# Map with clusterfunctie and changed popup
leaflet() %>% addTiles() %>%
  addMarkers(data = TsunamiData, 
             lng = TsunamiData$LONGITUDE, lat = TsunamiData$LATITUDE,
             popup = paste0("<B><U>Location: ", TsunamiData$LOCATION_NAME,", ", TsunamiData$COUNTRY, "</U></B><br>",
                            "Date: ", TsunamiData$DAY, "-", TsunamiData$MONTH, "-", TsunamiData$YEAR, "<br>",
                            "Tsunami ID: ", TsunamiData$TSEVENT_ID, "<br>",
                            "Earthquake magnitude: ", TsunamiData$PRIMARY_MAGNITUDE_origin, "<br>",
                            "Gross Domestic Product ($): ", TsunamiData$US.
                            ),
             icon = tsunami_icon,
             clusterOptions = markerClusterOptions()
  )

#----------------------------------Create scatterplot-----------------------------------
#Create scatterplot to show the relation between the magnitude of the earthquake and the number of deaths
#Interesting to see would be if the number of houses destroyed are affected by this as well
#Create a well describing legend name
colnames(TsunamiCSVOriginSel)[which(names(TsunamiCSVOriginSel) == "TOTAL_HOUSES_DESTROYED_origin")] <- "Houses_destroyed"

#Create the scatter plot
plot_ly(TsunamiCSVOriginSel, x=~PRIMARY_MAGNITUDE_origin, y=~TOTAL_DEATHS_origin, text=~paste(paste("Country:", COUNTRY_origin), paste("Year:", YEAR_origin), paste("Tsunami ID:", ID_origin), sep = "<br />"), 
        color=~Houses_destroyed, colors = "YlOrBr", type="scatter", mode="marker",
        marker = list(size = 10))%>%
  layout(title = 'Number of victims based on magnitude of earthquake',
         xaxis = list(showgrid = TRUE, title = "Magnitude earthquake"),
         yaxis = list(showgrid = TRUE, title = "number of deaths (log)", type = "log"),
         plot_bgcolor = "gainsboro",
         showlegend = FALSE)
