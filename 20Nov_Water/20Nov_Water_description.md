# Day 20: Water

## Content Description

This 3D map shows the Prießnitz stream in Dresden together with the valley extracted from the DTM.
The valley shape, calculated using rcrisp, is overlaid on the terrain so its shape can be directly compared with the real elevation surface.
This provides a simple visual check of how well the computed valley matches the landscape.

## Process Description

I combined the DTM, the Prießnitz stream, and the rcrisp-derived valley polygon. I rendered the terrain in 3D with rayshader <https://www.rayshader.com/>.
The 3D view makes the valley form and depth much clearer than in 2D.

## Data Sources

DTM (1 m): Sachsen open data downloaded via <https://www.geodaten.sachsen.de/downloadbereich-digitale-hoehenmodelle-4851.html>
Stream: OpenStreetMap via Geofabrik <https://download.geofabrik.de/europe/germany/sachsen.html>
Valley: calculated using rcrisp <https://github.com/CityRiverSpaces/rcrisp>
