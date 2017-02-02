#Koen Veenenbos & Tim Jak
#January 2017

#Select the data of the TsunamiData file
SelectData <- function(Year, Selection){
  TsunamiCSVYear <- TsunamiCSV[TsunamiCSV$YEAR>=Year,]
  Required <- c("TSEVENT_ID", "YEAR", "COUNTRY", "LATITUDE", "LONGITUDE")
  TsunamiCSVSel <<- subset(TsunamiCSVYear, select = c(Required, Selection))
}
