# load the packages
library(terra)
library(ggplot2)
library(tidyverse)
library(viridis)
library(patchwork)
library(magick)
library(grid)

# load the logo
logo <- image_read("Logo_Blue.png")

# define the unsupervised classification function
unsupervised_classify <- function(
    img, n_classes = 5, iter_max = 100, n_start = 5, seed = 99){
  
  # Extract raster values and remove NAs
  v <- values(img)
  valid_cells <- !is.na(values(img[[1]]))
  v <- v[valid_cells, , drop = FALSE]
  
  # Perform k-means clustering
  set.seed(seed)
  km <- kmeans(v, centers = n_classes, iter.max = iter_max, nstart = n_start)
  
  # Create classified raster
  r_class <- rast(img[[1]])
  values(r_class) <- NA
  values(r_class)[valid_cells] <- km$cluster
  
  # Assign layer name and description
  names(r_class) <- "class"
  
  # Return both raster and model
  return(list(classified = r_class, model = km))
}

# load the satellite image
new <- rast("new.tif")[[c(3, 2, 1)]]
new_df <- as.data.frame(new, xy = TRUE, na.rm = TRUE)
names(new_df) <- c("x", "y", "R", "G", "B")
new_df$R <- new_df$R / max(new_df$R, na.rm = TRUE)
new_df$G <- new_df$G / max(new_df$G, na.rm = TRUE)
new_df$B <- new_df$B / max(new_df$B, na.rm = TRUE)

# apply the classification
result <- unsupervised_classify(new, n_classes = 7, iter_max = 250)
r_class <- result$classified
r_class_df <- as.data.frame(r_class, xy = TRUE, na.rm = TRUE)

# Create the plot
standard_theme <- theme(
  plot.background = element_rect(fill = "#bcd0d6", color = NA),
  panel.grid = element_line(color = "gray", linewidth = 0.3),
  plot.caption = element_text(size = 12, hjust = 0.45, margin = margin(t = 20, b = 20)),
  axis.title = element_text(size = 6),
  plot.margin = unit(c(5,20,5,20), "pt")
)

p1 <- ggplot() +
  geom_raster(data = new_df, aes(x = x, y = y, fill = rgb(R, G, B))) +
  scale_fill_identity() +
  coord_equal() +
  labs(
    caption = "True Color Composite",
    x = NULL, y = NULL
  ) +
  theme_minimal()

p2 <- ggplot() +
  geom_raster(data = r_class_df, aes(x = x, y = y, fill = factor(class))) +
  scale_fill_viridis_d(option = "viridis", direction = -1, name = "Cluster") +
  coord_equal() +
  labs(
    caption = "Unsupervised K-means Classification (7 clusters)",
    x = NULL, y = NULL
  ) +
  theme_minimal() +
  theme(
    legend.position = "right"
  ) 

p1 <- p1 + standard_theme
p2 <- p2 + standard_theme

final_plot <- (
  p1 / p2
) +
  plot_annotation(
    title = "What's On a Port?",
    subtitle = paste0("Port Pattern Recognition Using Unsupervised Classification\n",
                      "with Example of Yangshan Port, Shanghai"),
    caption = paste0("30DayMapChallenge, Yaying Hao, 2025.\n",
                     "Data: Copernicus Sentinel-2")
  ) &
  theme(
    plot.background = element_rect(fill = "#bcd0d6", color = NA),
    panel.background = element_rect(fill = "#bcd0d6", color = NA),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 10)),
    plot.subtitle = element_text(size = 14, face = "italic", hjust = 0.5, margin = margin(b = 10)), 
    plot.margin = unit(c(5,10,5,10), "pt")
  )

final_plot
grid.raster(logo, x = 0.1, y = 0.1, width = unit(50, "points"))

ggsave("29Nov_raster.png", final_plot, width = 8, height = 12, dpi = 300)
