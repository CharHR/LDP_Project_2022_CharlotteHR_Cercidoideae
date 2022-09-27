#LDP Project data download
#Charlotte Hagelstam Renshaw
#September 16 2022

#An initial script which downloads my data and uses groundhog to manage packages


#install.packages("groundhog")
library(groundhog)

#Load packages using groundhog

groundhog.library(dplyr, date = "2022-08-31")
groundhog.library(tidyverse, date = "2021-08-31")
groundhog.library(raster, date = "2021-08-31")
groundhog.library(sp, date = "2021-08-31")
groundhog.library(ggplot2, date = "2021-08-31")

#Data was downloaded from https://www.gbif.org/ on Tuesday July 21st 2020 for the genus Cheniella 
#DOI: https://doi.org/10.15468/dl.as44t9 

Cheniella_occurrences<- read.csv('data/CheniellaEdited_Oct_2021.csv')
