pacman::p_load(dplyr, data.table, ggplot2)



path = "c:/models/flickr/carto/"
file = "allPicsWithLandkreis.csv"
raw = read.csv(paste(path,file,sep=""))


data = raw %>% select(personId, id, time, lon, lat, type, lkr_id = region_id, lkr_name = region_name, month, week)

#if not merged the AT and DE data, should run the following lines
#data = raw %>% select(personId, id, time, lon, lat, type, FA, FA_NR, GEN, AGS)
#data = data %>% rowwise() %>% mutate(lkr_id = if_else(is.na(FA_NR),AGS,FA_NR))
#data = data %>% rowwise() %>% mutate(lkr_name = if_else(as.character(FA)=="",as.character(GEN),as.character(FA)))
#data = data %>% select(personId, id, time, lon, lat, type, lkr_id, lkr_name)

data = data %>% rowwise() %>% mutate(lkr_name = paste(lkr_name, " (", lkr_id,")", sep = ""))


#filter to the users that havebeen in Munich city
users_muc = data %>% filter(lkr_id == 9162000) %>% select(personId, type) %>% group_by(personId, type) %>% summarize(pics = n())

#summary by type
users_muc %>% group_by(type) %>% summarize(count = n(), pics = sum(pics))


#manually store the totals
visitors_muc = nrow(users_muc %>% filter(type == "visitor"))
unknowk = nrow(users_muc %>% filter(type == "unknown"))
total = nrow(users_muc)

#pictures of those who have taken a picture in Munich
data_users_muc = data %>% filter(personId %in% users_muc$personId)

#pics by landkreis by type
summary_pics = data_users_muc %>%
  group_by(lkr_id,lkr_name, type) %>%
  summarize(n = n())

aux = summary_pics %>% group_by(lkr_id,lkr_name) %>% summarize(n = sum(n))

levels = aux$lkr_id[order(aux$n)]
summary_pics$lkr_id = factor(summary_pics$lkr_id, levels = levels)

ggplot(summary_pics %>% filter(n > 50), aes(x=lkr_name, y = n, fill = type)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))
  

#users by landkreis
users_muc_by_zone = data_users_muc %>%
  group_by(personId, lkr_id, lkr_name, type) %>%
  summarize(pictures = n())

summary_users = users_muc_by_zone %>%
  group_by(lkr_id,lkr_name, type) %>%
  summarize(n = n())

total_users_by_type = summary_users %>% filter(lkr_id == "9162000") %>% group_by(type) %>% summarize(total = sum(n))

summary_users = merge(x=summary_users, y=total_users_by_type, by = "type")

ggplot(summary_users, aes(x=as.factor(lkr_name), y = n/total, fill = type)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) + ylim(0,0.1)

write.csv(summary_users, file = "c:/models/flickr/gis/usersByLandkreis.csv", row.names = F)

