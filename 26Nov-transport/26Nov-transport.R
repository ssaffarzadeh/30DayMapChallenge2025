# load libraries
library(terra)
library(sf)
library(ggplot2)
library(patchwork)
library(grid)
library(magick)

# load logo
logo_path <- "Logo_Rbanism_White.png"
logo <- image_read(logo_path)

# load vector layers
waterway <- st_read("waterway_nl.gpkg")

# not finished yet
