if (!require("pacman")) install.packages("pacman")
pacman::p_load(rnoaa, dplyr, readr, tidyr)

options(noaakey = 'EzlFpeAQxwYWUYnxhAVRsgUBCpkampsC')

# Rexburg airport
rexburg_id <- "GHCND:USW00094194"

# get temperature data
rtemp <- ncdc(datasetid = 'GHCND',            # daily summaries
              stationid = rexburg_id,         
              datatypeid = c("TMAX","TAVG"),  # max temp (average doesn't work??)
              startdate = '2020-01-01',   
              enddate = '2020-12-31',
              limit = 1000,                   # max limit is 1000
              add_units = TRUE) 

# get wind data
rwind <- ncdc(datasetid = 'GHCND',
              stationid = rexburg_id,
              datatypeid = c("WDF2","WSF2"),
              startdate = '2020-01-01',
              enddate = '2020-12-31',
              limit = 1000,
              add_units = TRUE)

# combine temperature and wind
rexburg <- bind_rows(rtemp$data,rwind$data)

# save units for future reference
rexburg_units <- rexburg %>% distinct(datatype, units)
rexburg_units

# filter to the data we need,
# reformat for visualization
rexburg <- rexburg %>% 
  select(date, datatype, value) %>% 
  pivot_wider(names_from = datatype,
              values_from = value)

write_csv(rexburg_units, "./data/units.csv")
write_csv(rexburg, "./data/rexburg2020.csv")
