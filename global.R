# global.R

library(shiny)
library(leaflet)
library(dplyr)
library(gmapsdistance)

df <- readRDS('~/Desktop/5702-visualization-project/crime_sample.rds')
airbnb <- read.csv('~/Desktop/5702-visualization-project/cleaned_airbnb.csv')
attractions <- read.csv('~/Desktop/5702-visualization-project/attractions.csv', header = TRUE)

# code used to transform
# d <- read.csv('~/Desktop/5702/project/final_crime_10.csv')
# saveRDS(d, '~/Desktop/5702/project/crime_sample.rds')
