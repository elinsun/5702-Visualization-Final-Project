# global.R

library(shiny)
library(leaflet)
library(dplyr)

df <- readRDS('~/Desktop/5702/project/crime_sample.rds')
airbnb <- read.csv('~/Desktop/5702/project/cleaned_airbnb.csv')

# code used to transform
# d <- read.csv('~/Desktop/5702/project/final_crime_10.csv')
# saveRDS(d, '~/Desktop/5702/project/crime_sample.rds')
