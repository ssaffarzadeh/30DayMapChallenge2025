# Day 5: Earth

Comparing Global and Local Digital Terrain Models by Claudiu Forgaci

## Content Description

This map compares a recently released global Digital Terrain Model (DTM) with a spatial resolution of 1 arc-second (approximately 30 m) to a high-resolution 0.5 m DTM available for the Netherlands. The global dataset was produced using machine-learning–based data fusion, while the local DTM was created using a traditional interpolation method known as Inverse Distance Weighting (IDW).

My interest is in evaluating whether a global DTM—designed to represent the bare-earth surface without buildings or vegetation—can serve both as a more accurate alternative to widely used Digital Surface Models (DSM), which *do* include above-ground objects, and as a scalable input for analyses beyond the local level.

However, comparing the two datasets reveals that the difference is not only about resolution. Important questions emerge: **How reliable is the global model in urban areas? Does it truly remove above-ground features, or are buildings and trees still visible in the data?** This map is an invitation to explore those uncertainties.

## Process Description

While producing this map, I had to tackled a few challenges: acquiring the global DTM data from a STAC endpoint, combining two maps into one plot and adding the Rbanism logo. While the first and second challenges were resolved, the third remains a challenge :)

## Data Sources

**OpenLandMap Ensemble Digital Terrain Model (GEDTM30)** via OpenLandMap <https://stac.openlandmap.org/gedtm-30m/collection.json>

**Dataset: Actueel Hoogtebestand Nederland (AHN)** via PDOK <https://www.pdok.nl/introductie/-/article/actueel-hoogtebestand-nederland-ahn>
