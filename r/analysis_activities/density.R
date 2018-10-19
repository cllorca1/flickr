pacman::p_load(dplyr, data.table, ggplot2, MASS, reshape)



path = "c:/models/flickr/carto/"




kde_model = kde2d(raw$xcoord, h = 500, raw$ycoord,n = c(41*10,26*10), lims = c(c(4447000,4488000), c(5320000,5346000)))

x = kde_model$x
y = kde_model$y
z = data.frame(kde_model$z)
z$x = x

z_melt = melt(z,id.vars = "x")
y_vars = unique(z_melt$variable)
aux_y = data.frame(y = y, y_var = y_vars)
z_melt = merge(z_melt, aux_y, by.x = "variable", by.y = "y_var")

ggplot(z_melt, aes(x=x, y=y, fill = value)) + geom_raster() + 
  scale_fill_gradientn(colors = c("white","red","black"))



ggplot(z_melt, aes(x= value)) + stat_ecdf()

z_melt$density_bin = cut(z_melt$value, breaks = c(0,1e-8,+Inf))
 
ggplot(z_melt, aes(x=x, y=y, fill = as.numeric(density_bin))) + geom_raster() + 
  scale_fill_gradient(low = "white", high = "red")

write.csv(z_melt, file = paste(path, "density_kd2d.csv", sep = ""), row.names = F)
