path = "c:/models/flickr/byUser/"

library(dplyr)

dataUsers = data.frame()
for (fileIndex in 1:908){
  fileName = paste(path, fileIndex,".csv", sep = "")
  if (file.exists(fileName)) {
    userData = read.csv(fileName,fileEncoding = "UTF-8")
    dataUsers = rbind(dataUsers,userData)
  }
  
}

dataUsers = dataUsers %>% 
  filter(time != -1)

usersAndType = data %>% select(personId, type)

write.csv(dataUsers, paste(path,"outputByUser.csv", sep = ""), row.names = F)

simplePictureList2 = dataUsers %>% select(id, personId, time, lon, lat)

simplePictureList = rbind(simplePictureList, simplePictureList2)
simplePictureList = simplePictureList[!duplicated(simplePictureList),]



simplePictureList$personId = as.character(simplePictureList$personId)
userType$personId = as.character(userType$personId)


userType = userType[!duplicated(userType),]


simplePictureList = merge(x=simplePictureList, y=userType, by = "personId")

path = "c:/models/flickr/"
write.csv(simplePictureList, paste(path,"all.csv", sep = ""), row.names = F)
