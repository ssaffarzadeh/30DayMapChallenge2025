###############################################
## PREAMBLE
###############################################

library(dplyr)
library(sf)
library(sp)
library(spdep)
library(ggplot2)
library(raster)
library(tmap)
library(scales)

###############################################
## Amsterdam: Lag Q05 variation 2009–2023
###############################################

Amsterdam <- Muni_2009 %>% 
  st_make_valid() %>% 
  filter(GW_NAAM == "Amsterdam")

Amsterdam_dis <- districts_2009 %>% 
  st_make_valid() %>% 
  filter(GW_NAAM == "Amsterdam")

panel_data_city <- panel_data %>% 
  filter(Municipality == "Amsterdam")

#######################################################
## Extract centroids from the 100m grids
#######################################################

panel_data_city <- panel_data_city %>% 
  filter(!is.na(vrlvierkant100m)) %>% 
  mutate(
    easting  = as.numeric(substr(vrlvierkant100m, 2, 5)) * 100,
    northing = as.numeric(substr(vrlvierkant100m, 7, 10)) * 100
  )

#######################################################
## Create the variable to map
#######################################################

df_2009 <- panel_data_city %>% 
  filter(year == 2009) %>% 
  dplyr::select(vrlvierkant100m, social_housing, household_count, lag_q05.x) %>% 
  rename(lag_q05_2009 = lag_q05.x)

df_2023 <- panel_data_city %>% 
  filter(year == 2023) %>% 
  dplyr::select(vrlvierkant100m, social_housing, household_count, lag_q05.x) %>% 
  rename(lag_q05_2023 = lag_q05.x)

#######################################################
## Δ — change in spatial lag
#######################################################

delta_df <- left_join(df_2023, df_2009, by = "vrlvierkant100m") %>% 
  mutate(delta_lag_q05 = lag_q05_2023 - lag_q05_2009)

coords_df <- panel_data_city %>% 
  filter(year == 2023) %>% 
  dplyr::select(vrlvierkant100m, easting, northing) %>% 
  distinct()

grid_df <- left_join(delta_df, coords_df, by = "vrlvierkant100m") %>% 
  filter(!is.na(easting) & !is.na(northing))

#######################################################
## Create spatial object with centroids
#######################################################

grids_sf <- st_as_sf(grid_df, coords = c("easting", "northing"), 
                     crs = 28992, remove = FALSE)

grids_sf_clean <- grids_sf %>% 
  filter(!is.na(delta_lag_q05))

q <- stats::quantile(grids_sf_clean$delta_lag_q05, c(0.05, 0.95), na.rm = TRUE)
L <- max(abs(q))

#######################################################
## Plot with ggplot2 
#######################################################

ggplot(grids_sf_clean, aes(x = easting, y = northing, fill = delta_lag_q05)) +
  geom_tile(width = 100, height = 100) +
  scale_fill_gradient2(
    low = "#7B3294", mid = "white", high = "#008837",
    midpoint = 0, limits = c(-L, L),
    oob = scales::squish,
    name = "Δ 2009–23"
  ) +
  coord_fixed() +
  labs(title = "Amsterdam: spatial lag Q05") +
  geom_sf(data = Amsterdam_dis, fill = NA, color = "gray40", size = 0.3, inherit.aes = FALSE) +
  annotation_north_arrow(location = "tl", which_north = "true",
                         style = north_arrow_minimal()) +
  annotation_scale(location = "bl", width_hint = 0.3) +
  theme_bw() +
  theme(axis.text = element_blank(), axis.title = element_blank())

ggsave(filename = "AmsterdamQ05.png", plot = last_plot(),
       path = "H:/Diego/Policy Evaluation/ECONOMIC_SEGREGATION/Maps",
       width = 8, height = 6, dpi = 600)

#######################################################
## Smooth version
#######################################################

r <- raster::rasterize(grids_sf_clean, 
                       raster(grids_sf_clean, res = 100),
                       field = "delta_lag_q05")

w <- matrix(1, nrow = 7, ncol = 7)

r_smooth <- focal(r, w = w, fun = mean, na.rm = TRUE)

grids_sf_clean$delta_lag_q05_smoothed <- raster::extract(r_smooth, grids_sf_clean)

#######################################################
## Plot smoothed version
#######################################################

ggplot(grids_sf_clean, aes(x = easting, y = northing, fill = delta_lag_q05_smoothed)) +
  geom_tile(width = 100, height = 100) +
  scale_fill_gradient2(
    low = "#7B3294", mid = "white", high = "#008837",
    midpoint = 0, limits = c(-L, L),
    oob = scales::squish,
    name = "Δ 2009–23"
  ) +
  coord_fixed() +
  labs(title = "Amsterdam: Spatial Lag Q05 (smoothed)") +
  geom_sf(data = Amsterdam_dis, fill = NA, color = "gray40", size = 0.3, inherit.aes = FALSE) +
  annotation_north_arrow(location = "tl", which_north = "true",
                         style = north_arrow_minimal()) +
  annotation_scale(location = "bl", width_hint = 0.3) +
  theme_bw() +
  theme(axis.text = element_blank(), axis.title = element_blank())

ggsave(filename = "AmsterdamQ05_smoothed.png", plot = last_plot(),
       path = "H:/Diego/Policy Evaluation/ECONOMIC_SEGREGATION/Maps",
       width = 8, height = 6, dpi = 600)

#######################################################
## Save the database
#######################################################

grids_sf_clean_ch <- grids_sf_clean %>% 
  dplyr::select(vrlvierkant100m, household_count.x, delta_lag_q05)

write.csv(grids_sf_clean_ch,
          file = "H:/Diego/Policy Evaluation/ECONOMIC_SEGREGATION/grids_sf_clean_ch_05.csv")
