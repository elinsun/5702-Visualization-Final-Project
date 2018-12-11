#NYPD Dataset
library(ggplot2)
library(dplyr)
library(zipcode)
library(caret)
library(class)
library(FastKNN)
library(splitstackshape)

nypd_df <- read.csv('crime_real.csv')
nypd_df_true <- nypd_df[,-c(1,5)]
all_date <- as.Date(nypd_df_true$RPT_DT, format = "%m/%d/%Y")
nypd_df_true <- cbind(nypd_df_true, all_date)

nypd_df_out <-nypd_df_true[nypd_df_true$all_date >= '2013-01-01',]
nypd_df_out <- nypd_df_out[,-2]
nypd_df_out <- nypd_df_out[complete.cases(nypd_df_out),]
write.csv(nypd_df_out, 'cleaned_nypd.csv', row.names = FALSE)


airbnb_df <- read.csv('airbnb.csv')
airbnb_df <- airbnb_df[complete.cases(airbnb_df),-1]
airbnb_df_out <- airbnb_df
write.csv(airbnb_df_out, 'cleaned_airbnb.csv', row.names = FALSE)

data(zipcode)
zipcode <- zipcode[complete.cases(zipcode),]
zipcode_ny <- zipcode[c(zipcode$state == 'NY'),]

#match with the file given by Elin
elin_file <- read.csv('zipcode_nyc.csv')
colnames(elin_file) <- c('zip', 'boro', 'neighborhood')
final_crime_df <- merge(zipcode_ny, elin_file[, c("zip","neighborhood")], by="zip")
write.csv(final_crime_df, 'zipcode.csv', row.names = FALSE)

label_zip <- final_crime_df$zip
lat_long_zip <- final_crime_df[,c('latitude','longitude')]
colnames(nypd_df_out) <- c('CMPLNT_FR_TM', 'LAW_CAT_CD', 'latitude', 'longitude', 'all_date')
crime_lat_long <- nypd_df_out[,c('latitude','longitude')]

zip_out <- c()

zip_out_2 <- c()

for(each_val in length(zip_out)+1:nrow(crime_lat_long)){
  predicted_knn <- as.character(knn(train = lat_long_zip, test = crime_lat_long[each_val,], cl = factor(label_zip), k = 1))
  zip_out_2 <- append(zip_out_2, predicted_knn)
  if(each_val %% 10000 == 0){
    print(each_val)
  }
}

zip_out <- append(zip_out,zip_out_2)

zip = zip_out
nypd_df_out <- cbind(nypd_df_out, zip)
final_nypd_df_out <- merge(nypd_df_out, final_crime_df[,c('zip','neighborhood')], by='zip')

final_nypd_df_out <- within(final_nypd_df_out, month <- as.numeric(substr(as.character(all_date),6,7)))
final_nypd_df_out <- within(final_nypd_df_out, year <- as.numeric(substr(as.character(all_date),1,4)))
final_nypd_df_out <- within(final_nypd_df_out, hour <- as.numeric(substr(CMPLNT_FR_TM, 1,2)))
write.csv(final_nypd_df_out, 'final_crime_full.csv', row.names = FALSE)

var_care <- c('zip', 'year', 'hour', 'month', 'LAW_CAT_CD')
stratified_df <- stratified(final_nypd_df_out, var_care, 0.1)
write.csv(stratified_df, 'final_crime_10.csv', row.names = FALSE)