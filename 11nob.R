library(ggplot2)
library(maps)
library(mapproj)
library(patchwork)
library(magick)
library(grid)

# Load logo
logo_path <- "C:/Users/Roger M Y/Desktop/30_d_m_c/Logo_White.png"
logo <- image_read(logo_path)

# Load data
df <- read.csv("C:/Users/Roger M Y/Desktop/30_d_m_c/fomatted_whale_data.csv")

# World data
world_coordinates <- map_data("world")

# Base map
map_base <- ggplot() +
  geom_map(
    data = world_coordinates, map = world_coordinates,
    aes(long, lat, map_id = region),
    color = "#222222", fill = "#444444", linewidth = 0.1
  ) +
  geom_point(
    data = df,
    aes(x = lng, y = lat),
    color = "white", size = 1, alpha = .65, shape = 18
  ) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "black", color = NA),
    panel.background = element_rect(fill = "black", color = NA)
  )

# Two globe projections
p1 <- map_base + coord_map("ortho", orientation = c(90, 0, 0))
p2 <- map_base + coord_map("ortho", orientation = c(-90, 0, 0))

# Ploting
p <- (p1 | plot_spacer() | p2) +
  plot_layout(widths = c(1, -0.1, 1)) +  # Increase middle value for more space
  plot_annotation(
    title = "Blue Whale Sightings",
    subtitle = "Two orthographic globe projections",
    caption = "#30DayMapChallenge · Roger Marin de Yzaguirre, 2025",
    theme = theme(
      plot.background = element_rect(fill = "black", color = NA),
      plot.title = element_text(color = "white", size = 20, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(color = "white", size = 12, hjust = 0.5),
      plot.caption = element_text(color = "white", size = 9, hjust = 0.5)
    )
  )

# Save intermediate image
out_path <- "C:/Users/Roger M Y/Desktop/30_d_m_c/11Nov_wales.png"
ggsave(out_path, p, width = 14, height = 7, dpi = 300)

# Smaller logo
final_plot <- image_read(out_path)

# Resize logo
logo_small <- image_scale(logo, "250x250")

# Position logo
final <- image_composite(final_plot, logo_small, offset = "+3900+1775")  # tweak as needed

# Save final image
image_write(final, "C:/Users/Roger M Y/Desktop/30_d_m_c/11Nov_wales_logo.png")

