pacman::p_load(dplyr, data.table, ggplot2)



path = "c:/models/flickr/carto/"
file = "allPicsWithLandkreis_2.csv"
raw = read.csv(paste(path,file,sep=""))

#convert time in miliseconds to more realistic approach

raw$time_string = format(as.POSIXct(raw$time / 1000,
                                    origin = "1970-01-01", tz = "Europe/Paris"), "%d/%m/%y %H:%M:%OS3")
raw$time_d = format(as.POSIXct(raw$time / 1000,
                               origin = "1970-01-01", tz = "Europe/Paris"), "%d")
raw$time_mo = format(as.POSIXct(raw$time / 1000,
                               origin = "1970-01-01", tz = "Europe/Paris"), "%m")
raw$time_h = format(as.POSIXct(raw$time / 1000,
                               origin = "1970-01-01", tz = "Europe/Paris"), "%H")
raw$time_mi = format(as.POSIXct(raw$time / 1000,
                               origin = "1970-01-01", tz = "Europe/Paris"), "%M")
raw$time_s = format(as.POSIXct(raw$time / 1000,
                               origin = "1970-01-01", tz = "Europe/Paris"), "%OS3")

raw$time_d_of_year = paste(raw$time_d, raw$time_mo, sep = "/")

raw$time_s_of_day = as.numeric(raw$time_h) * 3600 +
  as.numeric(raw$time_mi) * 60 + as.numeric(raw$time_s)


#analyze daily patterns
raw$personId = as.character(raw$personId)

users = unique(as.character(raw$personId))
picsThreshold = 10

data = data.frame()
data_trips = data.frame()
id_counter = 0
for (user in users){
  user = as.character(user)
  this_user_pics = raw %>% filter(as.character(personId) == user)
  if(nrow(this_user_pics) > picsThreshold){
    days = unique(this_user_pics$time_d_of_year)
    for(day in days){
      day = as.character(day)
      this_user_day_pics = this_user_pics %>% filter(time_d_of_year == day)
      this_user_day_pics = this_user_day_pics[order(this_user_day_pics$time_s_of_day),]
      n_user_day_pics = nrow(this_user_day_pics)
      if(n_user_day_pics>2){
        for(i in 1:(n_user_day_pics - 1)){
          distance = sqrt((this_user_day_pics$xcoord[i] - this_user_day_pics$xcoord[i+1])^2 + 
                            (this_user_day_pics$ycoord[i] - this_user_day_pics$ycoord[i+1])^2)
          time = this_user_day_pics$time_s_of_day[i+1] - this_user_day_pics$time_s_of_day[i]
          row = data.frame(u = as.character(user),
                     d = as.character(day),
                     pic = i, 
                     dist = distance,
                     t = time, 
                     time_day = this_user_day_pics$time_s_of_day[i],
                     speed = distance/time, 
                     origx = this_user_day_pics$xcoord[i],
                     origy = this_user_day_pics$ycoord[i],
                     destx = this_user_day_pics$xcoord[i+1],
                     desty = this_user_day_pics$ycoord[i+1])
          data = rbind(data, row)
          if(distance > 500){
            row1 = data.frame(id = id_counter,
                              t = this_user_day_pics$time_s_of_day[i],
                              x = this_user_day_pics$xcoord[i],
                              y = this_user_day_pics$ycoord[i])
            row2 = data.frame(id = id_counter,
                              t = this_user_day_pics$time_s_of_day[i+1],
                              x = this_user_day_pics$xcoord[i+1],
                              y = this_user_day_pics$ycoord[i+1])
            data_trips = rbind(data_trips, row1, row2)
            id_counter = id_counter +1 
          }
          #print(i)
        }
      }
      #print(day)
    }
  }
  print(user)
}

write.csv(data_trips, file = paste(path,"trips_500m.csv", sep ="") , row.names = F)

trips = data %>% filter(dist > 1000)

ggplot(trips, aes(x=dist)) + geom_histogram()
ggplot(trips, aes(x=speed * 3.6)) + geom_histogram() + xlim(0,100)

ggplot(trips, aes(x=time_day)) + geom_histogram(binwidth = 3600)
