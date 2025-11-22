# install.packages("ggplot2")
# install.packages("magick")
# install.packages("grid")
# install.packages("sf")


library(sf)
library(ggplot2)
library(magick)
library(grid)

hex <- st_read ("Spatial_Units.geojson", quiet = TRUE)

head(hex)

names(hex)

ggplot(data = hex) +
  geom_sf(data = hex, fill = alpha ("black", 0.3)) +
  labs(
    title = "MCDA analysis of streams in Dresden",
    subtitle = "Based on stream restoration project"
  ) +
  coord_sf(datum = st_crs(25832))

geom_sf(size = 0.5, fill = "darkblue", alpha = 0.77) +
  geom_text(data = hex, 
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