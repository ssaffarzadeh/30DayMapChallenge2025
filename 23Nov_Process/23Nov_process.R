#load packages
library(ggplot2)
library(magick)
library(patchwork)
library(tidyverse)
library(terra)
library(grid)
library(RColorBrewer)

# load logo
logo <- image_read("Logo_Blue.png")

# read raster files
first <- rast("Landsat_1985_RGBNIR.tif")
first_df <- as.data.frame(first, xy = TRUE, na.rm = TRUE)
second <- rast("Landsat_2000_RGBNIR.tif")
second_df <- as.data.frame(second, xy = TRUE, na.rm = TRUE)
third <- rast("Landsat_2020_RGBNIR.tif")
third_df <- as.data.frame(third, xy = TRUE, na.rm = TRUE)

# define NDVI calculation
ndvi <- function(img){
  ndvi_df <- img |> 
    mutate(ndvi = (NIR - Red) / (NIR + Red)) |>
    select(-Red, -Green, -Blue, -NIR)
  return(ndvi_df)
}

# calculate the change
ndvi1985 <- ndvi(first_df)
ndvi2000 <- ndvi(second_df)
ndvi2020 <- ndvi(third_df)

# define the function for individual plot
pal <- colorRampPalette(brewer.pal(9, "YlGn"))(100)

plot_ndvi <- function(df, caption) {
  ggplot(df, aes(x, y, fill = ndvi)) +
    geom_raster() +
    scale_fill_gradientn(
      colours = pal,
      limits = c(0.1, 0.9),
      name = "NDVI"
    ) +
    coord_equal() +
    labs(title = NULL, caption = caption) +
    theme_void(base_family = "sans") +
    theme(
      plot.caption = element_text(hjust = 0.5, size = 10, face = "bold.italic", margin = margin(t = 10, b = 20)),
      legend.position = "bottom",
      legend.tit = element_text(size = 8),
      plot.background = element_rect(fill = "#FFFDEB", color = NA)
    )
}

# create the plot
p1 <- plot_ndvi(ndvi1985, "a. NDVI 1985")
p2 <- plot_ndvi(ndvi2000, "b. NDVI 2000")
p3 <- plot_ndvi(ndvi2020, "c. NDVI 2020")

combined <- p1 + p2 + p3 +
  plot_annotation(
    title = "A Heart of Green",
    subtitle = "Reforestation 1985-2020 on Loess Plateau, China",
    caption = paste0("#30DayMapChallenge. Yaying Hao. 2025\n", 
                     "Data sources: Landsat5/7/8"),
    theme = theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
      plot.subtitle = element_text(hjust = 0.5, size = 12, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 0.5, size = 9, margin = margin(t = 20)),
      plot.background = element_rect(fill = "#FFFDEB", color = NA)
    )
  )

ggsave("23Nov_process.png", combined, width = 12, height = 8, dpi = 300)

# Add logo
map <- image_read("23Nov_process.png")
logo <- image_scale(logo, "150")
final_with_logo <- image_composite(
  map,
  logo,
  offset = "+1740+2100"
)
image_write(final_with_logo, "23Nov_process_with_logo.png")
