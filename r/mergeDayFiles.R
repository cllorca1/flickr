
path = "c:/models/flickr/"

data = data.frame()
for (fileIndex in 1:30){
  dayData = read.csv(paste(path,fileIndex,".csv", sep = ""))
  data = rbind(data,dayData)
}

write.csv(data, paste(path,"output.csv", sep = ""), row.names = F)