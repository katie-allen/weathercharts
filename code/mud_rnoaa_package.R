# packages to try:

# rwunderground - last update may 2018, 7/24 issues
# https://github.com/ALShum/rwunderground/issues

# rnoaa - last update feb 2021, 11/322 issues
# https://github.com/ropensci/rnoaa

# weatherData - last updated 2017, 24/12 issues
# https://github.com/Ram-N/weatherData

# riem - last updated april 2021, 3/22 issues
# https://github.com/ropensci/riem

# based on this, let's try rnoaa first??

#----------------------------------------------

if (!require("pacman")) install.packages("pacman")
pacman::p_load(rnoaa, tidyverse)

# this is very helpful
# https://recology.info/2015/07/weather-data-with-rnoaa/

# need an api key
# got it...not sure what to do with it
# https://stackoverflow.com/questions/22054303/how-do-i-load-my-api-key-into-rnoaa-using-r
my_noaa_token <- 'EzlFpeAQxwYWUYnxhAVRsgUBCpkampsC'
options(noaakey = my_noaa_token)

# searching for weather stations near rexburg
?ncdc_stations
rexburg_stations <- ncdc_stations(extent = c(43.79251, -111.83213, 43.859160, -111.732527))$data
rexburg_stations
rexburg_id <- "GHCND:USW00094194"

# sweet
# I wonder if different data is availabel for different stations?
# lapply(rexburg_stations$id, function(x)ncdc_datasets(stationid = x))
ncdc_datasets(stationid = rexburg_id)

ncdc_datacats(stationid = rexburg_id)
ncdc_datasets(stationid = rexburg_id)
ncdc_datatypes(datasetid = "GHCND", stationid = rexburg_id)


# get temperature data?
rtemp <- ncdc(datasetid = 'GHCND', # daily summaries
                stationid = rexburg_id,
                datatypeid = c("TMAX","TAVG"),
                startdate = '2020-01-01',
                enddate = '2020-12-31',
                limit = 1000,
              add_units = TRUE) # max is 1000
rtemp$meta
head(rtemp$data)
table(rtemp$data$datatype)
min(rtemp$data$date)
max(rtemp$data$date)

# get wind data separtely, because of limit max
rwind <- ncdc(datasetid = 'GHCND', # daily summaries
                stationid = rexburg_id,
                datatypeid = c("WDF2","WSF2"),
                startdate = '2020-01-01',
                enddate = '2020-12-31',
                limit = 1000,
              add_units = TRUE) # max is 1000
rwind$meta
head(rwind$data)
table(rwind$data$datatype)
min(rwind$data$date)
max(rwind$data$date)
# missing a day?

# huh....no wind data for September 7th?
rtemp$data$date[which(!(rtemp$data$date %in% rwind$data$date))]

#-----------------------------------------

colnames(rtemp$data)
colnames(rwind$data)

rexburg <- bind_rows(rtemp$data,rwind$data)
View(rexburg)

rexburg_units <- rexburg %>% distinct(datatype, units)
rexburg_units

# not sure what all the columns represent.....

rexburg <- rexburg %>% 
  select(date, datatype, value) %>% 
  pivot_wider(names_from = datatype,
              values_from = value)
head(rexburg)