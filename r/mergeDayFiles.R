library(dplyr)

path = "c:/models/flickr/pics/"
years = seq(2007,2017)


data = data.frame()

for (year in years){
for (fileIndex in 1:563){
  file_name = year * 1000 + fileIndex
  path_file_name = paste(path, file_name,".csv", sep = "")
  if (file.exists(path_file_name)) {
    dayData = read.csv(path_file_name,fileEncoding = "UTF-8")
    if(nrow(dayData) > 0){
      dayData = dayData[!duplicated(dayData),]
      dayData$year = year
      dayData$day = fileIndex
      data = rbind(data,dayData)
  }
  }
 }
}

#write/read outputs for later analysis

write.csv(data, paste(path,"output.csv", sep = ""), row.names = F)


data %>% group_by(year) %>% summarize(n())

#analyze users origin

data = read.csv(paste(path,"output.csv", sep = ""))


listOfLocations = data.frame(location = as.character(unique(data$location)))
listOfLocations$hasnich = grepl("nich", listOfLocations$location)
listOfLocations$hasnchen = grepl("nchen", listOfLocations$location)
listOfLocations$hasyern = grepl("yern", listOfLocations$location)
listOfLocations$visitor = if_else(listOfLocations$hasnich | listOfLocations$hasnchen | listOfLocations$hasyern, "resident", "visitor")
listOfLocations$visitor[listOfLocations$location==""] = "unknown"
listOfLocations = listOfLocations %>% select(location = location, type = visitor)
listOfLocations %>% group_by(type) %>% summarise(n = n())

simplePictureList = data %>% select(id, personId, time, lon, lat)

userType = merge(x=data, y=listOfLocations, by= "location") %>% select(personId,type)

userType %>% group_by(type) %>% summarize(n())


