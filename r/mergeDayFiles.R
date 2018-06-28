library(dplyr)

path = "c:/models/flickr/byDay/"

data = data.frame()
for (fileIndex in 1:563){
  fileName = paste(path, fileIndex,".csv", sep = "")
  if (file.exists(fileName)) {
    dayData = read.csv(fileName,fileEncoding = "UTF-8")
    dayData = dayData[!duplicated(dayData),]
    data = rbind(data,dayData)
  }
  
}

#remove duplicates 



write.csv(data, paste(path,"output.csv", sep = ""), row.names = F)

#analyze users origin



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
