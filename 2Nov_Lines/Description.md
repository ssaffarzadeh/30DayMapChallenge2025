Day 2 - Lines. Postal horse roads in 1810 France
By Clémentine Cottineau-Mugadza

**Content Description**
This map represents the networks of postal horse roads in 1810 France, with road segments coloured according to the maximum slope in meter. Dark segments represent steep roads, for instance in mountainous areas such as the Alps (South-East) and Pyrenees (Southern border). The map also reveals hilly landscapes such as Normandy on the North-West. The data comes from a long-term historical geography project run by geographers at the UMR Géographie-cités in Paris. Data about postal roads and relays from 1632 to 1833 was recently made public under an ODC Open Database License, alongside a data paper published in Cybergeo, European Journal of Geography. I like how the postal roads seem to irrigate the country, and how this network suggests the hierarchical distribution of city size in France, without featuring cities themselves.

**Process Description**
To make this map, I had to create sf line objects from a csv file with point ID, by linking the coordinates of the points to the segments using point IDs, and later transform the objects into sf lines. I adapted some code I found on a blog post by Meng Gao, and therefore discovered this transport planner from Seattle who posts about spatial analysis, GIS and R. This was also the opportunity for me to dive more seriously into the font options of ggplot2 and use Rbanism's Fira Code in my map.


**References:**
Data: Verdier, N., Giraud, T., Mimeur, C., & Bretagnolle, A. (2024). Postal horse relays and roads in France, from the 17th to the 19th centuries. Zenodo. https://doi.org/10.5281/zenodo.11196161
Datapaper: Verdier, N., Giraud, T., Mimeur, C., & Bretagnolle, A. (2025). « Postal horse relays and roads in France, from the 17th to the 19th centuries », Cybergeo: European Journal of Geography, 1088, https://doi.org/10.4000/13gxr
Meng Gao's blog: https://www.adventuremeng.com/ 