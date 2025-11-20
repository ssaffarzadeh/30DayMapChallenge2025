library(terra)
library(sf)
library(raster)
library(rayshader)
library(magick)
library(ggplot2)

dtm     <- rast("data/dtm.tif")
valley  <- vect("data/valley.gpkg")
streams <- vect("data/stream.gpkg")

valley  <- project(valley,  crs(dtm))
streams <- project(streams, crs(dtm))

valley_sf  <- st_as_sf(valley)
streams_sf <- st_as_sf(streams)

dtm_r <- raster(dtm)
elmat <- raster_to_matrix(dtm_r)

ray <- ray_shade(elmat, zscale = 1, sunaltitude = 35, sunangle = 315)
amb <- ambient_shade(elmat, zscale = 1)

pal <- colorRampPalette(c(
  "#4575b4","#91bfdb","#e0f3f8","#C27BB8","#8E3EA6"))(50)

base <- height_shade(elmat, texture = pal) |>
  add_shadow(ray, 0.55) |>
  add_shadow(amb, 0.50)

ext <- extent(dtm_r)

valley_fill <- generate_polygon_overlay(
  valley_sf, extent = ext, heightmap = elmat,
  palette = "#fae8d8", linecolor = NA)

valley_outline <- generate_polygon_overlay(
  valley_sf, extent = ext, heightmap = elmat,
  palette = NA, linecolor = "skyblue")

stream_blue <- generate_line_overlay(
  streams_sf, extent = ext, heightmap = elmat,
  linewidth = 3, color = "steelblue")

map_ink <- base |>
  add_overlay(valley_fill,    alphalayer = 0.55) |>
  add_overlay(valley_outline, alphalayer = 0.95) |>
  add_overlay(stream_blue,    alphalayer = 0.95)

# 3d rendering
plot_3d(map_ink, elmat, zscale=1, fov=0, theta=165, phi=18, zoom=0.18,
  background="white", windowsize=c(2000,1600))

render_highquality(filename = "valley_3d.png", samples = 200, light = FALSE)
rgl::rgl.close()

z_min <- min(elmat, na.rm = TRUE)
z_max <- max(elmat, na.rm = TRUE)
df_leg <- data.frame(x = 1, y = seq(z_min, z_max, length.out = 200))

legend_img <- image_graph(width = 350, height = 900, bg = "transparent")
print(ggplot(df_leg, aes(x, y, fill = y)) +
    geom_raster() +
    scale_fill_gradientn(colours = pal) +
    scale_y_continuous(
      name   = "Elevation (m)",
      breaks = seq(z_min, z_max, length.out = 5)) +
    theme_minimal(base_size = 22) +
    theme(legend.position = "none",
      axis.title.x = element_blank(),
      axis.text.x  = element_blank(),
      axis.ticks.x = element_blank(),
      panel.grid   = element_blank(),
      axis.title.y = element_text(size = 35, colour = "white"),
      axis.text.y  = element_text(size = 35, colour = "white")))
dev.off()
legend_img <- legend_img |> image_scale("x350")

# adjust elements
img  <- image_read("valley_3d.png")
logo <- image_read("data/Logo_Blue.png") |> image_scale("100x100")

img <- image_annotate(img, text = "30DayMapChallenge: Day 20 Water",
                      size = 30, color = "white",gravity= "northwest",
                      location = "+40+40", weight = 500)

img <- image_annotate(img, text= "Stream and its shaped valley in 3D view",
                      size = 50,color = "white",gravity  = "northwest",location = "+40+120")

img <- image_annotate(img, text= "Valley calculated using rcrisp",
                      size = 20,color = "white",gravity  = "southwest",location = "+40+170")

img <- image_composite(img,legend_img,gravity = "west",offset  = "+40+0")

img <- image_composite(img,logo,gravity = "southwest",offset  = "+40+40")

image_write(img, "valley_3d.png")