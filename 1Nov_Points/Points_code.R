library(tidyverse)
library(sf)
library(magick)
library(magrittr)
library(grid)
library(ggsflabel)

rbanism_logo <- image_read('Logos/Logo transparent background/Logo_White.png')

RBC <- st_read("1Nov_Points/data/limites-administratives-des-communes-en-region-de-bruxelles-capitale.geojson") |>
  st_union() |>
  st_cast(to = "POLYGON") |>
  st_as_sf() |>
  rename(geography = x)
# Data from: https://opendata.brussels.be/explore/dataset/limites-administratives-des-communes-en-region-de-bruxelles-capitale/information/?disjunctive.national_code&disjunctive.urbis_id&disjunctive.name_fr&disjunctive.name_nl

RBC$label = "Région Bruxelles Capital"

brussels <- st_read("1Nov_Points/data/grands_quartiers_vbx.geojson")
# Data from: https://opendata.brussels.be/explore/dataset/grands_quartiers_vbx/information/

distrib <- st_read("1Nov_Points/data/distributeurs_graines_contraceptives_pigeons_vbx.geojson") 
# Data from: https://opendata.brussels.be/explore/dataset/distributeurs_graines_contraceptives_pigeons_vbx/export/?disjunctive.postalcode&disjunctive.territory_fr

distrib_buffer <- distrib |>
  st_buffer(dist=1000) |>
  st_union() |>
  st_transform(st_crs(brussels))

distrib_buffer <- 
  st_intersection(distrib_buffer, brussels)

ggplot() +
  geom_sf(data = RBC, fill = alpha("black", 0.3), colour = NA) +
  geom_sf_label(data = RBC, aes(label = label), fill = alpha("black", 0.3),
                nudge_x = -0.045, nudge_y = -0.05, family="Fira Code") +
  geom_sf(data = brussels, fill = alpha("#00A99D", 0.6), colour = "white") +
  geom_sf(data = distrib_buffer, fill = alpha("white", 0.5), colour = NA) +
  geom_sf_label_repel(data = brussels, aes(label = name_fr), fill = alpha("#00A99D", 0.3),
                      nudge_x = 0.0, nudge_y = 0.015, size = 2.5, family="Fira Code") +
  geom_sf(data = distrib, colour = "white") +
  theme_minimal() +
  ggtitle("1 November: Points. Pigeons, beware!\n1km around distributors of contraceptive\nseeds in the City of Brussels") +
  xlab("#30DayMapChallenge. Clémentine Cottineau-Mugadza, 2025.\nSource: OpenData.brussels.be") +
  ylab("") +
  theme(plot.background = element_rect(fill = alpha("#00A99D", 0.5),colour = "white"),
        axis.title.x=element_text(family="Fira Code", hjust = 0, size=8,colour = "white"),
         plot.title = element_text(face = "bold", family="Fira Code", size=14, colour = "white"),
        axis.line =  element_blank(),
        axis.text =  element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        plot.margin=unit(c(1,25,1,1), "mm"))


grid.raster(rbanism_logo,
            x = 0.74, y=0.1,
            width = unit(55, "points"))
