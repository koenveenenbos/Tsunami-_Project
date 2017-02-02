# -*- coding: utf-8 -*-
"""
Created on Wed Jan 25 12:38:16 2017

@author: Koen Veenenbos & Tim Jak
"""

#Import packages
import os, csv, urllib

#Choose the right working directory
os.chdir("/home/user/GeoscriptingProject")

#Create data directory
datadir = (r"/home/user/GeoscriptingProject/Data")
if not os.path.exists(datadir): os.makedirs(datadir)

#Download the data as .txt file
def DownloadFile (Inputurl, NameFile):
    url = Inputurl
    urllib.urlretrieve (url, NameFile)
  
DownloadFile ("https://www.ngdc.noaa.gov/nndc/struts/results?type_0=Exact&query_0=$ID&t=101650&s=71&d=86&dfn=tsrunup.txt", "Data/tsevent.txt")
DownloadFile ("https://www.ngdc.noaa.gov/nndc/struts/results?type_0=Exact&query_0=$ID&t=101650&s=69&d=59&dfn=tsevent.txt", "Data/tsorigin.txt")

#Convert from .txt to .csv
with open( "Data/tsevent.txt" , "rb") as txt_file:
     with open( "Data/tsevent.csv", "wb") as csv_file:
                in_txt = csv.reader(txt_file, delimiter = ',')
                out_csv = csv.writer(csv_file)
                out_csv.writerows(in_txt)
                
with open( "Data/tsorigin.txt" , "rb") as txt_file:
     with open( "Data/tsorigin.csv", "wb") as csv_file:
                in_txt = csv.reader(txt_file, delimiter = ',')
                out_csv = csv.writer(csv_file)
                out_csv.writerows(in_txt)
