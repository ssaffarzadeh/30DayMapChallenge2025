# Day 17: A New Tool

Mapping Co-Hotspots in Amsterdam: A Social-Spatial Network Analysis using SNoMaN Software by Shuyu Zhang

## Content Description

This map constructs a co-hotspots network of Amsterdam using TikTok data to identify social-spatial patterns of urban places. Each video was geo-parsed and geo-coded using OpenStreetMap (OSM) data to obtain geographic coordinates for hotspots. The network links hotspots that frequently co-occur in each video, highlighting hotspots of concentrated digital attention and their relationship.

The key contribution is the use of [SNoMaN Software](https://sites.gatech.edu/snoman/software-and-analytical-tools/snoman-software/), which allows users to explore both the network and the map. SNoMaN facilitates:  

1. Computation of traditional network metrics (e.g., node degree, centrality).  
2. Visualization of histograms for edge distances and node degrees.  
3. Exploration of an interoperable scatterplot for network attributes.  

This approach enables the identification of “digital place hotspots” in Amsterdam, we can better understand the spatial distribution of popular urban places and their digital representations. The SNoMaN platform is suitable for users without coding experience, while its [R package SSNtools](https://sites.gatech.edu/snoman/software-and-analytical-tools/r-tutorial/) allows reproducible analyses within R workflows.

## Process Description

The main steps of the map included:

1. Collecting TikTok meta data relevant to Amsterdam hotspots.  
2. Generating a co-hotspots network where nodes represent places and edges represent co-occurrence in videos.  
3. Geo-parsing and geo-coding each hotspot using OpenStreetMap to map them spatially.  
4. Importing the network and spatial data into SNoMaN to explore the network, compute metrics, and visualize edge distances and node degrees.  

Challenges included cleaning social media data for accurate place recognition. This workflow demonstrates how social media and geospatial data can be integrated to reveal urban place patterns interactively.


