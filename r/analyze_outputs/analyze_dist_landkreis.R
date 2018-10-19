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


#filter to the users that have been in Munich city
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

ggplot(summary_pics %>% filter(n > 50, type != "unknown"), aes(x=lkr_name, y = n, fill = type)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  scale_fill_manual(values = c("#009885", "#c73838")) + 
  theme_bw() + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+
  xlab("County") + ylab("Number of pictures")
  
 
  

#users by landkreis
users_muc_by_zone = data_users_muc %>%
  group_by(personId, lkr_id, lkr_name, type) %>%
  summarize(pictures = n())

summary_users = users_muc_by_zone %>%
  group_by(lkr_id,lkr_name, type) %>%
  summarize(n = n())

total_users_by_type = summary_users %>% filter(lkr_id == "9162000") %>% group_by(type) %>% summarize(total = sum(n))

summary_users = merge(x=summary_users, y=total_users_by_type, by = "type")
summary_users$percentage = summary_users$n / summary_users$total

summary_users$lkr_name = as.character(summary_users$lkr_name)
summary_users_ordered = summary_users

#get the order of lkr by number of visitors
aux = summary_users %>% filter(type=="visitor")
aux = aux[order(-aux$percentage),]

factor_levels = aux$lkr_name

summary_users_ordered$lkr_name = factor(summary_users_ordered$lkr_name, levels = factor_levels)

ggplot(summary_users_ordered %>% filter(type != "unknown"), aes(x=lkr_name, y = percentage*100, fill = type)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  theme_bw() + 
  scale_fill_manual(values = c("#009885", "#c73838")) +  
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) + ylim(0,10) + 
  facet_grid(type~.) + 
  xlab("County") + ylab("Percentage of Munich photographers at the county")

write.csv(summary_users, file = "c:/models/flickr/gis/usersByLandkreis.csv", row.names = F)

