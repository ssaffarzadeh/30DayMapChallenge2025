# install.packages("ggplot2")
# install.packages("magick")
# install.packages("ggrepel")
# install.packages("png")
# install.packages("grid")
# install.packages("sf")
# install.packages("patchwork")

library(png)
library(sf)
library(ggplot2)
library(magick)
library(grid)
library(ggrepel)
library(patchwork)

sf::sf_use_s2(FALSE)   #Avoiding geometry issues

#Load world map

af_eu_as <- st_read("World_Continents.shp", quiet = TRUE)

#For labeling the points
label_points <- st_point_on_surface(af_eu_as)

#Setting coord points for plotting labels
coords <- st_coordinates(label_points)
af_eu_as$x <- coords[,1]
af_eu_as$y <- coords[,2]

#Projections
crs_mercator <- 3857
crs_equalarea <- "+proj=laea +lat_0=30 +lon_0=10"

#Transform the region into each projection
af_eu_as_merc <- st_transform(af_eu_as, crs_mercator)
af_eu_as_laea <- st_transform(af_eu_as, crs_equalarea)



p1 <- ggplot(af_eu_as_merc) +
  geom_sf(size = 0.5, fill = "darkblue", alpha = 0.77) +
  geom_text(data = af_eu_as_laea, 
            aes(x = x, y = y,label = CONTINENT),
            size = 2.5, fontface = "plain", color = "white") +
  theme(panel.background = element_rect(fill = "grey10"),
        plot.background  = element_rect(fill = "grey10"),
        panel.grid.major  = element_line(color = "gray60"),   
        panel.grid.minor  = element_line(color = "gray70"),
        axis.text = element_text(color = "white"),            
        axis.title = element_blank(),       
        plot.title = element_text(color = "white")) +
  ggtitle("11 Nov: World Continents Mercator Projection Vs. Equal-Area Projection (LAEA)") +
  theme(theme(plot.title = element_text(hjust = 0.5)))

p2 <- ggplot(af_eu_as_laea) +
  geom_sf(size = 0.25, fill = "firebrick4", alpha = 0.8) +
  geom_text(data = af_eu_as_laea, 
            aes(x = x , y = y,label = CONTINENT),
            size = 2.5, fontface = "plain", color = "white") +
  theme(panel.background = element_rect(fill = "grey10"),
    plot.background  = element_rect(fill = "grey10"),
    panel.grid.major  = element_line(color = "gray60"),   
    panel.grid.minor  = element_line(color = "gray70"),
    axis.text = element_text(color = "white"),            
    axis.title = element_blank(),           
    plot.title = element_text(color = "white"))



#Read logo
logo <- image_read("Logo_Rbanism_ Blue.png")
logo_rgba <- as.raster(logo)
logo_grob <- rasterGrob(logo_rgba, interpolate = TRUE)

#Combined plot and caption 
final_plot <- (p1 | p2) +
  plot_annotation(
    caption = "#30DayMapChallenge — 'Projections' by Soroush Saffarzadeh, 2025. Data: ArcGIS Hub.",
    theme = theme(
      plot.caption = element_text(color = "white", hjust = 1, size = 10),
      plot.background = element_rect(fill = "grey10", color = NA)
    )
  )

#Add logo and plot
final_plot_with_logo <- final_plot +
  inset_element(
    logo_grob,
    left = 0.82,
    bottom = 0.03,
    right = 0.98,
    top = 0.25
  )

final_plot_with_logo









