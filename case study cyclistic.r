install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")

library(tidyverse)
library(lubridate)
library(ggplot2)
getwd()
setwd("/Users/parzival/Documents/project/")



#step 1 collecting data 
y2022_02 <- read.csv("202202-divvy-tripdata.csv")
y2022_01 <- read.csv("202201-divvy-tripdata.csv")
y2021_12 <- read.csv("202112-divvy-tripdata.csv")
y2021_11 <- read.csv("202111-divvy-tripdata.csv")
y2021_10 <- read.csv("202110-divvy-tripdata.csv")
y2021_09 <- read.csv("202109-divvy-tripdata.csv")
y2021_08 <- read_csv("202108-divvy-tripdata.csv")
y2021_07 <- read.csv("202107-divvy-tripdata.csv")
y2021_06 <- read.csv("202106-divvy-tripdata.csv")
y2021_05 <- read.csv("202105-divvy-tripdata.csv")
y2021_04 <- read.csv("202104-divvy-tripdata.csv")
y2021_03 <- read.csv("202103-divvy-tripdata.csv")

#step 2 Wrangle data and combine into a single file
colnames(y2022_02)
colnames(y2022_01)
colnames(y2021_08)
str(y2022_02)
str(y2021_03)
str(y2021_08)

#found that the df y2021_08 has the time data type so converting time data type into character
y2021_08 <- mutate(y2021_08,ride_length=as.character(ride_length))


#stacking all individual data_frame into big data_frame
all_trips <- bind_rows(y2022_02,y2022_01,y2021_12,y2021_11,y2021_10,y2021_09,y2021_08,y2021_07,y2021_06,y2021_05,y2021_04,y2021_03)

#removing lat,long as the data was dropped begining in 2020
all_trips <- all_trips %>% 
  select(-c(start_lat, start_lng, end_lat, end_lng,))

#step 3 celaning up data and add data to prepaer for analysis
colnames(all_trips)
nrow(all_trips)
head(all_trips)
#how many  observations fall under each usertype
table(all_trips$member_casual)

#reassigning to the desired values
all_trips <- all_trips %>% 
  mutate(member_casual=recode(member_casual
                              ,"Subscriber" = "member"
                              ,"Customer" = "casual"))

table(all_trips$member_casual)

#add columns that list the date,month,day and year of each ride
all_trips$date <- as.Date(all_trips$started_at) #this will format date as yyyy-mm-dd(default)
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$year <- format(as.Date(all_trips$date), "%d")
all_trips$day <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")

#adding ride_length calculation to all_trip (in seconds)
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)

#convert ride_length from factor to numeric so we can run calculations on the data is factor
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)


#removing bad data
all_trips_v <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),] %>%
  na.omit(all_trips$ride_length)

#step 4 Descriptice Analysis
#descriptive analysis on ride_length (all in seconds)
mean(all_trips_v$ride_length) #average of (total ride length / rides)
median(all_trips_v$ride_length) #midpoint num in the ascending array of the lengths
max(all_trips_v$ride_length) #longest ride
min(all_trips_v$ride_length) #shortest ride
summary(all_trips_v$ride_length) #mean,meadian,min,max all in 1 command

#comapairing members and casual users
aggregate(all_trips_v$ride_length ~ all_trips_v$member_casual, FUN = mean)
aggregate(all_trips_v$ride_length ~ all_trips_v$member_casual, FUN = median)
aggregate(all_trips_v$ride_length ~ all_trips_v$member_casual, FUN = max)
aggregate(all_trips_v$ride_length ~ all_trips_v$member_casual, FUN = min)

#average  ride time by reach day for menbers vs causal users
aggregate(all_trips_v$ride_length ~ all_trips_v$member_casual+all_trips_v$day_of_week, FUN = mean)
#notices that the days of the week are out of order
all_trips_v$day_of_week <- ordered(all_trips_v$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

#analyze ridership daya by type and weekday
all_trips_v %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  #creates weekday field using wday()
  group_by(member_casual, weekday) %>%  #groups by usertype and weekday
  summarise(number_of_rides = n()							#calculates the number of rides and average duration 
            ,average_duration = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, weekday)	#sort 


#visualize the number of ride by rider type
all_trips_v %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")

#visua for avergae duration
all_trips_v %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")


#step 5
#exporting summary file for further analysis
counts <- aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
write.csv(counts,"/home/Desktop/extracted_data.csv")

