# Day 18: Out Of This World

Render a 3D map of Olympus Mons on Mars using elevation data by Ignacio Urria Yáñez.

## Content Description

This map visualizes Olympus Mons, the tallest volcano and mountain in the solar system, located on Mars. The visualization is created using Digital Elevation Model (DEM) data from the Mars Global Surveyor's Mars Orbiter Laser Altimeter (MOLA) instrument. The final output is a high-resolution 3D rendering of Olympus Mons, using a lighting and color scheme designed to evoke the appearance of Martian terrain at dawn. 

I took the opportunity of this challenge to explore data from other planets and see what type of maps I could create with. I find fascinating the idea of visualising landscapes beyond Earth, and Olympus Mons, being the tallest known volcano in the solar system, is a perfect subject for such an exploration. While exploring the potential data sources, I was in awe with the wealth of planetary data that has such precision that it is possible to create visualisations of extraterrestrial terrains from my own computer with such detail.

## Process Description

The process was a good opportunity to learn several new tools for processing raster data and 3D visualisation. The first challenge was to identify the right data source and the specific tile where Olympus Mons is located. For this I had to understand the geography of the planet and the coordinate systems used for Mars. The second challenge was to produce an aesthetically pleasing rendering that evoked the feel of Mars. I experimented with different color palettes and lighting angles to achieve a look that felt appropriate for the Martian surface. The final rendering was done using `rayshader`, which allowed me to create a detailed 3D representation of the terrain. For this step, the repositories and tutorials by Milos Popovic on creating 3d visualisations with `rayshader` were particularly helpful (e.g., https://github.com/milos-agathon/3d-land-cover-map).

## Data Sources

- Smith, D.E., M.T. Zuber, G.A. Neumann, E.A. Guinness, and S. Slavney, Mars Global Surveyor Laser Altimeter Mission Experiment Gridded Data Record, MGS-M-MOLA-5-MEGDR-L3-V1.0, NASA Planetary Data System, 2003. DOI: 10.17189/1519460. Retrieved from: https://pds-geosciences.wustl.edu/missions/mgs/megdr.html
