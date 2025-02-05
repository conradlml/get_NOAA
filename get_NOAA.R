
################################################################################
# Scraping the internet for historical NOAA weather data 
#
# Lily Conrad, IDEQ State Office 
# last update: 2/5/2025
################################################################################

### User inputs ----------------------------------------------------------------

# Enter your decimal degree latitude
my_lat <- 43.610701

# Enter your decimal degree longitude 
my_lon <- -116.180917

# Enter the start year for your period of interest
start_year <- 2000

# Enter the end year for your period of interest
end_year <- 2024

# Enter your username (the name at the beginning of your computer's file explorer
# path) in quotations
my_name <- "jdoe"



################################################################################
#                                 START
################################################################################

### Load packages and data -----------------------------------------------------

my_packages <- c("lubridate", "glue", "tidyverse", "openxlsx", "data.table")
install.packages(my_packages, repos = "http://cran.rstudio.com")

library(lubridate)
library(glue)
library(tidyverse)
library(openxlsx)
library(data.table)


### Identify your station of interest ------------------------------------------ 

# We want a high level overview of the different stations to get us started. In
# this case, the ghncd-inventory.txt file lists the periods of record for each 
# station and element and should do the trick. On NOAA's HTTPS Server, you can 
# see when that file was last updated (should be daily or something like that).
inventory_url <- "https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-inventory.txt"

# Read in the data and assign column names (because there aren't any as is). 
inventory <- read_table(inventory_url,
                        col_names = c("station", "lat", "lon", "variable", "start", "end")) 

# Convert my_lat and my_long from degrees to radians (radians are more mathematically
# relatable to geometry than degrees).
my_lat <- my_lat*2*pi/360
my_lon <- my_lon*2*pi/360

# Now we're going to calculate the difference between our latitude and longitude
# and the different station latitudes and longitudes. This allows us to identify
# the closest station (i.e., station with the smallest difference in distance). 

# You can probably get away with calculating a straight line distance, but we are
# going to use an equation that accounts for the curvature of the Earth to do 
# things properly (https://www.geeksforgeeks.org/program-distance-two-points-earth/).  

my_station <- inventory %>%
  mutate(lat_r = lat*2*pi/360, # converting NOAA's lat/long to radians  
         lon_r = lon *2*pi/360,
         d_mi = 3963*acos((sin(lat_r)*sin(my_lat)) + cos(lat_r)*cos(my_lat) * cos(my_lon-lon_r))) %>% # distance between our location and station in miles
  filter(start <= start_year & end >= end_year) %>% # make sure the station covers our period of interest
  arrange(d_mi) %>% # arrange from closest to furthest 
  slice_min(d_mi, n = 1) %>% # identify the closest station (adjust n if you want to see more than just this one)
  distinct(station) %>%
  pull(station) # get station name as a variable
my_station


### Identify your station of interest ------------------------------------------ 

# Now that we have our station name, it is time to download the daily data of
# interest. These data are also housed on NOAA's HTTPS Server (under by_station).

# The  glue function will create a URL based on my_station.
station_daily <- glue("https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_station/{my_station}.csv.gz") 

# Read the URL and do some formatting. There is some funkiness with how NOAA 
# reports data in these servers (see the readme.txt file for the details).
local_weather <- fread(station_daily) %>% 
  rename(station = V1,
         date = V2,
         variable = V3, 
         value = V4,
         a = V5, 
         b = V6, 
         c = V7, 
         d = V8) %>% 
  pivot_wider(names_from = "variable", values_from = "value") %>%
  mutate(date = ymd(date)) %>%
  mutate(TAVG.C = TAVG/10, # temp units are in tenths of degrees C, convert to degrees C
         TMAX.C = TMAX/10,
         TMIN.C = TMIN/10,
         PRCP.mm = PRCP/10, # prcp units are in tenths of a mm, converts to mm
         SNOW.mm = SNOW) %>% # already in mm
  select(station, date, TAVG.C, TMAX.C, TMIN.C, SNOW.mm, PRCP.mm) %>% 
  group_by(station, date) %>% 
  summarise(TAVG.C = mean(TAVG.C, na.rm = TRUE), # consolidating the NAs and dates
            TMAX.C = mean(TMAX.C, na.rm = TRUE), 
            TMIN.C = mean(TMIN.C, na.rm = TRUE), 
            SNOW.mm = mean(SNOW.mm, na.rm = TRUE), 
            PRCP.mm = mean(PRCP.mm, na.rm = TRUE)) %>% 
  mutate(SNOW.mm = ifelse(is.na(SNOW.mm), 0, SNOW.mm), # assuming if snow and prcp = NA, then that means 0 mm.
         PRCP.mm = ifelse(is.na(PRCP.mm), 0, PRCP.mm))


# Export as an Excel file if you'd like. This will save the file in your 
# downloads folder. Adjust the file path if you'd like it to save somewhere
# else. 
write.xlsx(local_weather, paste0("C:/Users/",my_name,"/Downloads/",Sys.Date(),"_","NOAA_daily_data.xlsx"))


################################################################################
#                                 END
################################################################################
