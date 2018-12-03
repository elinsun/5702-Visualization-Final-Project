# global.R

library(shiny)
library(leaflet)
library(dplyr)

df <- readRDS('~/Desktop/5702/project/toy.rds')
airbnb <- read.csv('~/Desktop/5702/project/cleaned_airbnb.csv')