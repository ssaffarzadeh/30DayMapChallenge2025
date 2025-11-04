# Day 4 My Data
# 2025-11-04

library(sf)
library(terra)
library(tidyverse)
library(png)
library(grid)

# data
marks  <- st_read("data/tracking.gpkg", "markpoints", quiet=TRUE)
routes <- st_read("data/tracking.gpkg", "routelines",  quiet=TRUE)
gaps   <- st_read("data/tracking.gpkg", "unrecorded",  quiet=TRUE)
dem    <- rast("data/dtm.tif")
logo   <- "data/Logo_White.png"

# DTM legend setup
emin <- min(d$elevation, na.rm=TRUE); emax <- max(d$elevation, na.rm=TRUE)
mid  <- c(30,60,90); mid <- mid[mid>=emin & mid<=emax]
ebreaks <- c(emin, mid, emax); elabs <- c(round(emin), mid, round(emax))

# speed legend setup
qs <- quantile(routes$speed_kmh, probs=seq(0,1,length.out=5), na.rm=TRUE)
routes$pace <- cut(routes$speed_kmh, qs, include.lowest=TRUE)
pace_labels <- paste0(round(qs[-5]), "–", round(qs[-1]))

# palettes
pal_dtm <- colorRampPalette(c("#be761d","#f2e8d5","#009a85"))(100)
pal_speed  <- c("#FFE3B3","#F6B37F","#EA7B60","#5B2B2D")
marks <- mutate(marks, lbl = as.character(name))

p <- ggplot() +
  geom_raster(data=d, aes(x,y,fill=elevation)) +
  scale_fill_gradientn(colours=pal_dtm, name="Elevation (m)",
                       limits=c(emin,emax), breaks=ebreaks, labels=elabs,
                       guide=guide_colorbar(barheight=unit(45,"pt"),
                                            ticks=TRUE, draw.ulim=TRUE, draw.llim=TRUE,
                                            label.theme=element_text(size=8))) +
  geom_sf(data=routes, aes(color=pace), linewidth=1.4, lineend="round", linejoin="round") +
  scale_color_manual(name="Speed (km/h)", values=pal_speed, breaks=levels(routes$pace),
                     labels=pace_labels, guide=guide_legend(override.aes=list(linewidth=2.4))) +
  geom_sf(data=gaps, aes(linetype="unrecorded"), color="#333", linewidth=0.6) +
  scale_linetype_manual(name=NULL, values=c(unrecorded="33"), breaks="unrecorded", labels="unrecorded") +
  guides(fill=guide_colorbar(order=1), color=guide_legend(order=2), linetype=guide_legend(order=3)) +
  geom_sf(data=marks, shape=21, size=5.5, color="darkorange",
          fill=scales::alpha("white",0.5), stroke=1.1) +
  geom_sf_text(data=marks, aes(label=lbl), color="#333", size=3.2, fontface="bold", nudge_y=10) +
  coord_sf(expand=FALSE, clip="off") +
  annotate("text", x=x0+0.02*dx, y=y1-0.03*dy, label="#30DayMapChallenge Day 4: My data",
           hjust=0, vjust=1, size=3, color="white") +
  annotate("text", x=x0+0.02*dx, y=y1-0.10*dy,
           label="Cycling to the \"Highlands\" of\nthe Netherlands: Veluwezoom",
           hjust=0, vjust=1, lineheight=0.9, size=5.5, fontface="bold", color="#333") +
  annotate("text", x=x0+0.02*dx, y=y1-0.21*dy, label="(already too high for me!)",
           hjust=0, vjust=1, size=4.2, color="#333") +
  annotate("text", x=x1-0.02*dx, y=y0+0.02*dy,
           label="Data source: personal Apple Fitness GPX file of Yehan Wu\nNumbers show the order of route",
           hjust=1, vjust=0, size=2.7, color="white", lineheight=1.2) +
  theme_void() +
  theme(legend.position=c(0.1,0.49), legend.direction="vertical",
        legend.title=element_text(size=8.5, face="bold"),
        legend.text=element_text(size=7),
        legend.key.height=unit(8,"pt"), legend.key.width=unit(14,"pt"),
        legend.spacing.y=unit(13,"pt"))

p <- p + annotation_custom(rasterGrob(readPNG(logo)),
                             xmin=x1-0.11*dx, xmax=x1-0.05*dx,
                             ymin=y0+0.12*dy, ymax=y0+0.20*dy)
p
ggsave("4Nov_Mydata.png", p, width=7, height=5,dpi=300)
