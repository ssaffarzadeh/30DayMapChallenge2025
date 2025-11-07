install.packages(c(
  "sf",
  "dplyr",
  "readr",
  "ggplot2",
  "nngeo",
  "ggspatial",
  "cowplot",
  "magick",
  "ggfx",
  "grid",
  "ggtext"
))

library(sf)
library(dplyr)
library(readr)
library(ggplot2)
library(nngeo)
library(ggspatial)
library(cowplot)
library(magick)
library(ggfx)
library(grid)
library(ggtext)

# DATA RETRIEVED ON Nov. 4th 2025 FROM:

# National Public Transport Access Nodes (NaPTAN) available at : https://beta-naptan.dft.gov.uk/
# Office of National Statistic available at : https://www.data.gov.uk/dataset/7b2f3f79-b262-49e4-903f-915699e58c4b/lower-layer-super-output-areas-december-2021-boundaries-ew-bfe-v10
# English Indice of Deprivation 2025 available at : https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025
# Rbanim Logo available at : https://github.com/Rbanism/30DayMapChallenge2025/tree/main/logos/Logo%20transparent%20background

lsoa_shp_path <- "C:/Users/izaid/Documents/C_MAPPING/MAP_Challenge_Nov7/data/LSOA_2021_EW_BFE_V10.shp"
imd_path <- "C:/Users/izaid/Documents/C_MAPPING/MAP_Challenge_Nov7/data/File_7_IoD2025_All_Ranks_Scores_Deciles_Population_Denominators.csv"
stations_path <- "C:/Users/izaid/Documents/C_MAPPING/MAP_Challenge_Nov7/data/Stops.csv"
logo_path <- "C:/Users/izaid/Documents/C_MAPPING/MAP_Challenge_Nov7/data/Logo_Rbanism_White.png"


# PREPARATION OF THE DATA

lsoa <- st_read(lsoa_shp_path, quiet = TRUE) %>% st_transform(4326)
lsoa_eng <- lsoa %>% filter(substr(LSOA21CD, 1, 1) == "E")

imd <- read_csv(imd_path, show_col_types = FALSE) %>%
  select(LSOA21CD = 1, IMD_rank = 6, IMD_decile = 7)
lsoa_eng <- lsoa_eng %>%
  left_join(imd, by = "LSOA21CD") %>%
  st_make_valid() %>%
  mutate(IMD_decile_map = 11 - IMD_decile)  # 1 = most deprived, 10 = most affluent

stations <- read_csv(stations_path, show_col_types = FALSE)
stations_major <- stations %>%
  filter(StopType == "RSE") %>%
  filter(!is.na(Longitude) & !is.na(Latitude)) %>%
  distinct(CommonName, .keep_all = TRUE) %>%
  st_as_sf(coords = c("Longitude","Latitude"), crs = 4326, remove = FALSE) %>%
  st_join(lsoa_eng, left = FALSE)

rbanism_logo <- image_read(logo_path)


# BRITISH NATIONAL GRID PROJECTION

lsoa_eng <- st_transform(lsoa_eng, 27700)
stations_major <- st_transform(stations_major, 27700)


# BBOXES FOR ZOOMING ON LEICETSR AND LONDON

london_bbox <- st_bbox(c(xmin=-0.510, xmax=0.334, ymin=51.286, ymax=51.691), crs=4326) %>%
  st_as_sfc() %>% st_transform(27700)
leicester_bbox <- st_bbox(c(xmin=-1.200, xmax=-1.050, ymin=52.610, ymax=52.670), crs=4326) %>%
  st_as_sfc() %>% st_transform(27700)

create_zoom <- function(lsoa_eng, stations_major, bbox_sfc, city_name) {
  lsoa_city <- suppressWarnings(st_intersection(lsoa_eng, bbox_sfc))
  stations_city <- stations_major[st_intersects(stations_major, bbox_sfc, sparse = FALSE), ]
  
  ggplot() +
    geom_sf(data = lsoa_city, aes(fill = IMD_decile_map), color = NA) +
    with_outer_glow(
      geom_sf(data = stations_city, colour = "#ccff00", size = 2, alpha = 0.6),
      colour = "#ccff00", sigma = 4, expand = 0.2
    ) +
    scale_fill_gradient(low = "white", high = "#222222") +
    theme_void() +
    theme(
      legend.position = "none",
      panel.background = element_rect(fill = "#222222", color = NA),
      plot.background = element_rect(fill = "#222222", color = NA),
      plot.title = element_text(color = "white", size = 13, hjust = 0.5)
    ) +
    labs(title = city_name) +
    geom_rect(aes(xmin = st_bbox(bbox_sfc)$xmin, xmax = st_bbox(bbox_sfc)$xmax,
                  ymin = st_bbox(bbox_sfc)$ymin, ymax = st_bbox(bbox_sfc)$ymax),
              fill = NA, color = "white", size = 0.5)
}

zoom_london <- create_zoom(lsoa_eng, stations_major, london_bbox, "London")
zoom_leicester <- create_zoom(lsoa_eng, stations_major, leicester_bbox, "Leicester")


# MAIN MAP - MAP OF ENGLAND

p_main <- ggplot() +
  geom_sf(data = lsoa_eng, aes(fill = IMD_decile_map), color = NA) +
  with_outer_glow(
    geom_sf(data = stations_major, colour = "#ccff00", size = 0.8, alpha = 0.7),
    colour = "#ccff00", sigma = 4, expand = 1
  ) +
  scale_fill_gradient(
    low = "white",
    high = "#222222",
    breaks = c(1,10),
    labels = c("Most \naffluent","Most \ndeprived"),
    guide = guide_colorbar(
      title = NULL,
      barwidth = 0.2,
      barheight = 10,
      ticks.colour = "grey",
      frame.colour = "grey",
      label.position = "left",
      label.hjust = 0.5
    )
  ) +
  theme_void() +
  theme(
    legend.position = "left",
    legend.text = element_text(color = "white", size = 10),
    legend.background = element_rect(fill = "#222222", color = NA),
    panel.background = element_rect(fill = "#222222", color = NA),
    plot.background = element_rect(fill = "#222222", color = NA),
    plot.subtitle = element_markdown(color = "white", size = 16, hjust = 0.5)
  )


# COMMBINING THE ELEMENTS OF THE MAP

left_x <- 0.07 
final_map <- ggdraw() +
  draw_plot(ggplot() + theme_void() + theme(panel.background = element_rect(fill="#222222")), 
            x = 0, y = 0, width = 1, height = 1) +
  draw_grob(
    with_outer_glow(
      textGrob("ACCESS", x = left_x, y = 0.97, hjust = 0,
               gp = gpar(col = "#ccff00", fontsize = 22, fontface = "bold")),
      colour = "#ccff00", sigma = 8, expand = 2
    )
  ) +
  draw_text(" , A MATTER OF MEANS",
            x = left_x + 0.12, y = 0.97, hjust = 0,
            size = 22, color = "white", fontface = "bold") +
  draw_text("Major Rail Stations and Deprivation Index in England (2025)",
            x = left_x, y = 0.935, hjust = 0,
            color = "white", size = 13, fontface = "bold") +
  draw_text("#30DayMapChallenge | DAY 7: ACCESSIBILITY",
            x = left_x, y = 0.905, hjust = 0,
            color = "grey80", size = 11, fontface = "italic") +
  draw_plot(ggplotGrob(p_main), x=0.05, y=0.05, width=0.72, height=0.87) +
  draw_plot(ggplotGrob(zoom_leicester), x=0.78, y=0.55, width=0.22, height=0.33) +
  draw_plot(ggplotGrob(zoom_london), x=0.78, y=0.30, width=0.22, height=0.33) +
  draw_grob(
    with_outer_glow(
      grid::circleGrob(
        x = 0.11, y = 0.34, r = 0.009,
        gp = grid::gpar(col = "#ccff00", fill = NA, lwd = 1)
      ),
      colour = "#ccff00", sigma = 5, expand = 1
    )
  ) +
  draw_text("Major Railway Stations", x = 0.11, y = 0.32, color = "white", size=10, hjust=0.5) +
  draw_text("Author: Inès Zaid, 2025 \nSources: IMD 2025, NaPTAN, ONS",
            x=0.05, y=0.02, size=12, color="white", hjust=0, vjust=0) +
  draw_image(rbanism_logo, x=0.95, y=0.05, width=0.15, height=0.15, hjust=1, vjust=0)


# FINAL STEP!

print(final_map)
 
