#Koen Veenenbos & Tim Jak
#January 2017

#Select the data of the TsunamiDataOrigin file
SelectDataOrigin <- function(Year, Selection_origin){
  TsunamiCSVOriginYear <- TsunamiCSVOrigin[TsunamiCSVOrigin$YEAR>=Year,]
  Required <- c("ID", "YEAR", "LATITUDE", "LONGITUDE")
  TsunamiCSVOriginSel <<- subset(TsunamiCSVOriginYear, select = c(Required, Selection_origin))
}
