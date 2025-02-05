# get_NOAA
Weather data query from the National Oceanic and Atmospheric Administration (NOAA) weather station closest to a user-defined latitude and longitude. 

# Background Information
NOAA houses a wealth of historical weather/climate data that is often useful for IDEQ projects. You can go to NOAA's website to download historical data or you can use this R script. This script was developed to identify the physically closest weather station to a certain location that includes data from a defined period of interest. First the script will identify the closest station to a user-supplied latitude and longitude and period of interest, then extract the daily average temperature and precipitation will be extracted. With some small adjustments, this code can be used to download multiple stations of interest. 

This script reads daily files from NOAA's NCEI HTTPS Server (https://www.ncei.noaa.gov/pub/data/ghcn/daily/). For more information on how to interpret and analyze the data housed through NOAA, please visit their read.me file (https://www.ncei.noaa.gov/pub/data/ghcn/daily/readme.txt). 

# Getting Started
When using this script, begin by specifying the user inputs listed at the top of the file: decimal degree latitude, decimal degree longitude, start year, end year, and the username of your computer. After you specify those details, click on "Source" and watch the console to see if you run into any errors. If the script ran successfully, there will be an Excel file of weather data in your Downloads folder. 
