# Day 4: My Data

Cycling into the “Highlands” of the Netherlands: Veluwezoom (already too high for me!)
by Yehan Wu

## Content Description

This map shows a recent cycling tour I took in National Park Veluwezoom. Because the area is relatively “high” for the flat Netherlands, I added a terrain layer to show elevation differences (and to hint at how tough the climbs felt!). There is a short gap where I forgot to record after I stopped to rest and enjoyed the heathland views.

## Process Description

Regarding the speed and route, I processed the original GPX file recorded on my Apple Watch. The original file included tracking points (every one second), tracking route, and I converted them to different layers in the tracking.gpkg. To show the order and direction of the ride, I selected 5 track points and labelled them 1–5. Speed classes were created using quantile breaks. It was a new experience for me to arrange all elements on top of the DTM and to adjust their placement for clarity.

## Data Sources

DTM (30 m): Copernicus DEM GLO-30, via Google Earth Engine <https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_DEM_GLO30>

Cycling GPS: Apple Fitness outdoor cycling GPX exported from Apple Health (recorded on 13 September 2025).
