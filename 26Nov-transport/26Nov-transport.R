# load libraries
library(terra)
library(sf)
library(ggplot2)
library(patchwork)
library(grid)
library(magick)
library(png)

# load logo
logo_path <- "Logo_Rbanism_White.png"
logo <- image_read(logo_path)

# load vector layers
waterway <- st_read("waterway_nl.gpkg")
borders <- st_read("CNTR_RG_01M_2024_3035_1.gpkg")
eu_borders <- borders[borders$EU_STAT == "T",]
eu_borders_tr <- st_transform(eu_borders, st_crs(waterway))
rhein <- st_read("rhein.gpkg")
nl_borderline <- st_read("nl_landgrens.gpkg")    # a more detailed border for displaying

# prepare the vector data
bbox1 <- st_bbox(waterway)
bbox2 <- st_bbox(nl_borderline)
bbox <- c(
  xmin = min(bbox1["xmin"], bbox2["xmin"]),
  ymin = min(bbox1["ymin"], bbox2["ymin"]),
  xmax = max(bbox1["xmax"], bbox2["xmax"]),
  ymax = max(bbox1["ymax"], bbox2["ymax"])
)
Belgium <- eu_borders_tr[eu_borders_tr$CNTR_ID == "BE",]
Netherlands <- eu_borders_tr[eu_borders_tr$CNTR_ID == "NL",]
land <- st_union(Belgium, Netherlands)
sea_routes <- st_difference(waterway, land)
inland_routes <- st_intersection(waterway, land)

# create the plot
p <- ggplot() +
  geom_sf(data = eu_borders_tr, color = "orange", fill = NA, linewidth = 0.2) +
  geom_sf(data = nl_borderline, fill = "white", color = "orange", alpha = 0.1) +
  geom_sf(data = inland_routes, color = "#FFFFFF", linewidth = 0.2) +
  geom_sf(data = rhein, color = "#FFFFFF", linewidth = 0.2) +
  geom_sf(data = sea_routes, color = "#FFFFFF", linetype = "dashed", linewidth = 0.15) +
  coord_sf(xlim = c(bbox["xmin"], bbox["xmax"]), 
           ylim = c(bbox["ymin"], bbox["ymax"]),
           expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "black", color = NA),
    panel.background = element_rect(fill = "black", color = NA),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(color = "#FFFFFF", size = 20, face = "bold",
                              hjust = 0.5, margin = margin(b = 10)),
    plot.subtitle = element_text(color = "#CCCCCC", size = 12, hjust = 0.5, margin = margin(b = 10)),
    plot.caption = element_text(color = "#CCCCCC", hjust = 0.5, size = 9),
    plot.margin = unit(c(5,10,5,10), "pt"),
    legend.background = element_rect(fill = "black"),
    legend.text = element_text(color = "#FFFFFF"),
    legend.title = element_text(color = "#FFFFFF")
  ) +
  labs(
    title = "Netherlands: Gateway of European Import",
    subtitle = "Sea and Inland Water Transportation Networks of the Netherlands",
    caption = "#30DayMapChallenge. Yaying Hao, 2025.\n ",
              "Data: PDOK, gisco-services.ec.europa.eu, OpenStreetMap"
  )
grid.raster(logo, x = 0.75, y = 0.1, width = unit(50, "points"))

# save the plot
ggsave("26Nov_transport.png", p, width = 8, height = 12, dpi = 300)
