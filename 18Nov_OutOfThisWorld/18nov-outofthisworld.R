#install.packages(c("terra", "rayshader", "rgl", "magick", "showtext", "ggspatial"))
library(terra)
library(rayshader)
library(rgl)
library(magick)
library(showtext)
library(ggplot2)
library(ggspatial)

# 1. Load the MOLA topography ----
# Downloaded the megt44n180hb files (.img and .lbl) from: https://pds-geosciences.wustl.edu/missions/mgs/megdr.html
# and cropped it between lon 219-233E and lat 9-29N.
# Original raw data is not included in the repository due to size constraints.

dem_crop <- rast("olympus_mons_200m_crop.tif")

# 2. 2D Mars-like Visualization ----
# Basic elevation plot with Mars colors

# Define a Mars-like reddish gradient
mars_colors <- colorRampPalette(c("#3e0a03", "#8c3014", "#d56b1e", "#f5b65a", "#f8e5bb"))

# Plot cropped DEM with Mars colors
plot(dem_crop, col = mars_colors(100),
     main = "Olympus Mons – MOLA 128ppd Topography",
     axes = TRUE)

# 3. Prepare matrix for rayshader ----
mat <- as.matrix(dem_crop, wide = TRUE)
mat[is.na(mat)] <- min(mat, na.rm = TRUE)
mat <- mat - min(mat, na.rm = TRUE) 

# 4. Shading & color mapping ----
zscale <- 80  # vertical exaggeration (higher values, lower exaggeration)
mars_texture <- create_texture(
  lightcolor = "#f9d199",
  shadowcolor = "#8c3014",
  leftcolor = "#c65b1a",
  rightcolor = "#f79a3e",
  centercolor = "#fcd281"
)

# Generate hillshades
ray <- ray_shade(mat, zscale = zscale, multicore = TRUE)
amb <- ambient_shade(mat, multicore = TRUE)
map_tex <- sphere_shade(mat, texture = mars_texture) |>
  add_shadow(ray, 0.6) |>
  add_shadow(amb, 0.5)

# 5. 3D rendering ----
plot_3d(
  map_tex,
  mat,
  zscale = zscale,
  fov = 0,
  solid = FALSE,
  shadow = TRUE,
  shadow_darkness = 1,
  theta = 0,    # rotation around z-axis
  phi = 50,     # 90 = top-down
  windowsize = c(800, 800),
  zoom = 0.75,
  background = "white",
  baseshape = "circle"
)

render_camera(
    zoom = .75,
    theta = 0,    # rotation around z-axis
    phi = 50     # 90 = top-down
)

# calculate the extent of the scale (200 km in the map : 200000/(xmax(dem_crop) - xmin(dem_crop)) 
factor_scale <- round(200000/(xmax(dem_crop) - xmin(dem_crop)), 3)
scale_extent <- (xmax(dem_crop) - xmin(dem_crop)) * factor_scale / 1000 # units of DEM in meters so convert to km

render_scalebar(clear_scalebar = TRUE)
render_scalebar(limits=c(0, round(scale_extent/2, 0), round(scale_extent, 0)), 
                label_unit = "km", position = "S", y= 200, 
                scale_length = c(0.92-factor_scale, 0.92))

# 6. Save high-quality render ----
Sys.sleep(3)

# download an HDRI for environment lighting
u <- "https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/4k/photo_studio_loft_hall_4k.hdr"
hdri_file <- basename(u)

download.file(
    url = u,
    destfile = hdri_file,
    mode = "wb"
)

file_name <- "olympus_mons_mars_elevation.png"
hdri_file <- "photo_studio_loft_hall_4k.hdr"

render_highquality(
    filename = file_name,
    preview = FALSE,
    light = FALSE,
    environment_light = hdri_file,
    intensity_env = 1,
    interactive = FALSE,
    text_size = 30,
    text_angle = c(70, 70, 70),
    width = 1400,
    height = 1400
)

# 7. Post-process with magick ----
# Read image
img <- image_read(file_name)
txt_color_title <- "#3e0a03"
txt_color_subtitle <- "#4b2621"

# Title
img <- image_annotate(img, "Day 18: Out of this world - Dawn at Olympus Mons", font = "Consolas",
                      weight = 700, color = txt_color_title, size = 48, 
                       gravity = "north", location = "+0+50")

# Subtitle
img <- image_annotate(img, "Mars - Tallest mountain of the Solar System | Height: 21.9km - Width: 600km", font = "Consolas",
                      color = txt_color_subtitle, size = 30, gravity = "north",
                       location = "+0+170")

# Scale labels 
img <- image_annotate(img, "0km", font = "Consolas",
                      color = txt_color_subtitle, size = 30, gravity = "south",
                       location = "+230+270")

img <- image_annotate(img, "200km", font = "Consolas",
                      color = txt_color_subtitle, size = 30, gravity = "south",
                       location = "+530+270")
# Credit line
img <- image_annotate(img, 
                      "Day 18: Out of this World - #30DayMapChallenge. Ignacio Urria Yáñez, 2025.", 
                      font = "Consolas", location = "+150+50",
                      color = scales::alpha(txt_color_subtitle, .9), size = 25, weight = 100, gravity = "south")

img <- image_annotate(img,
                      "Data from MGS MOLA MEGDR Topography Data - NASA Planetary Data System (PDS).", 
                      font = "Consolas", location = "+150+25",
                      color = scales::alpha(txt_color_subtitle, .9), size = 25, weight = 100, gravity = "south")

# Logo
logo <- image_read("Logo_Rbanism_Full.png")
logo <- image_scale(logo, "200")    # adjust size as needed
logo <- image_trim(logo)
img <- image_composite(img, logo, operator = "over", gravity = "southwest", offset = "+20+20")

# save final image
image_write(img, path = "olympus_mons_mars_elevation.png", format = "png")