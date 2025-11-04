# Attach packages ----
library(terra)
library(sf)
library(ggplot2)
library(viridis)
library(patchwork)
library(grid)
library(magick)

# Load Rbanism logo ----
rbanism_logo_path <- "5Nov-earth/Logo_Rbanism_ Blue.png"
rbanism_logo <- image_read(rbanism_logo_path)

# Get global DTM from OpenGeoHub ----
asset_href <- paste0("https://s3.opengeohub.org/global/edtm/",
  "legendtm_rf_30m_m_s_20000101_20231231_go_epsg.4326_v20250130.tif")
remote <- paste0("/vsicurl/", asset_href)
r <- rast(remote)

# Create sf polygon with the bounding box of Delft in lon/lat EPSG:4326 ----
xmin <- 4.33; xmax <- 4.40; ymin <- 51.98; ymax <- 52.02
bbox_poly_4326 <- st_sfc(st_polygon(list(rbind(c(xmin, ymin), c(xmin, ymax),
                                               c(xmax, ymax), c(xmax, ymin),
                                               c(xmin, ymin)))), crs = 4326)

# Prepare data for plot ----
r_crs <- crs(r, proj = TRUE)
delft_in_r_crs <- st_transform(bbox_poly_4326, st_crs(r_crs))
delft_bbox_trans <- st_bbox(delft_in_r_crs)
e <- ext(delft_bbox_trans["xmin"], delft_bbox_trans["xmax"],
         delft_bbox_trans["ymin"], delft_bbox_trans["ymax"])
r_sub <- crop(r, e)
r_proj <- project(r_sub, "EPSG:28992", method = "bilinear", res = 30)

# Get local DTM and crop global DTM to same extent----
r2 <- rast("5Nov-earth/tud-dtm-5m.tif")
e2 <- ext(r2)
r_proj_2 <- crop(r_proj, e2)
df2 <- as.data.frame(r_proj_2, xy = TRUE, na.rm = TRUE)
names(df2)[3] <- "value"
df3 <- as.data.frame(r2, xy = TRUE, na.rm = TRUE)
names(df3)[3] <- "value"

# Plot global DTM ----
p_top <- ggplot() +
  geom_raster(data = df2, aes(x = x, y = y, fill = value)) +
  scale_fill_viridis(name = "Elevation (m)", option = "viridis",
                     na.value = "transparent") +
  coord_equal() +
  theme_minimal() +
  labs(x = NULL, y = NULL)

# Plot local DTM ----
p_bottom <- ggplot() +
  geom_raster(data = df3, aes(x = x, y = y, fill = value)) +
  scale_fill_viridis(name = "Elevation (m)", option = "viridis",
                     na.value = "transparent") +
  coord_equal() +
  theme_minimal() +
  labs(x = NULL,y = NULL)

# Combine plots ----
base_tight_theme <- theme(panel.grid = element_blank(),
                          axis.text = element_blank(),
                          legend.justification = c(1.05, 1.05),
                          legend.key.size = unit(0.4, "cm"),
                          legend.direction = "vertical",
                          plot.margin = unit(c(0, 0, 0, 0), "pt"),
                          panel.spacing = unit(0, "pt"))

p_top2 <- p_top + base_tight_theme + coord_equal(expand = FALSE)
p_bottom2 <- p_bottom + base_tight_theme + coord_equal(expand = FALSE)

combined <- (p_top2 / p_bottom2) +
  plot_annotation(
    title = "Global vs. Local Terrain: Not Just a Resolution Issue",
    subtitle = paste0("Global GEDTM data (30m, top) compared to Local AHN data",
                      " (0.5m, bottom)"),
    caption = paste0("#30DayMapChallenge. Claudiu Forgaci, 2025.\n ",
                     "Data: OpenLandMap Ensemble Digital Terrain Model",
                     "(GEDTM30) and Actueel Hoogtebestand Nederland (AHN) DTM")
  ) & 
  theme(
    plot.background = element_rect(fill = "#fffee8", colour = NA),
    plot.title.position = "plot",
    plot.subtitle.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(hjust = 0.015, size = 14, face = "bold",
                              margin = margin(b = 6), colour = "#080b45"),
    plot.subtitle = element_text(hjust = 0.020, colour = "#080b45"),
    plot.caption = element_text(hjust = 0.01, size = 9, margin = margin(t = 6),
                                colour = "#080b45"),
    plot.margin = unit(c(5,10,5,30), "pt")
    )  
combined

grid.raster(rbanism_logo, x = 0.75, y=0.14, width = unit(50, "points"))
ggsave(filename = "5Nov-earth/Earth.png",
       combined, width = 10, height = 8, dpi = 300)
