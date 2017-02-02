#Koen Veenenbos & Tim Jak
#January 2017

#Import the necessary data
library(rvest)
library(plyr) #To revalue

#Inser URL link from which you want to get the tabular data    
ImportData <- function(URL, NTable, Header1, Header2){
  URLlink <-  URL
  
  Table <- URLlink %>% 
    read_html %>%
    html_nodes("table")
  
  #Select the correct table from the website
  TableData <- html_table(Table[NTable], fill = TRUE, header = TRUE, trim = TRUE, dec = ".")
  GDPCountry <<- lapply(TableData, "[", c(Header1, Header2))
}
