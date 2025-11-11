**Description of the map**
This map presents an example of port pattern recognition using K-means clustering. It illustrates both the input data and the classification outcome side by side. The upper panel shows a true-color composite of the Copernicus Sentinel-2 image covering the Yangshan Port area in Shanghai. The lower panel displays the K-means clustering result derived from multiple spectral bands (Bands 2, 3, 4, 8, 11, and 12), revealing clear separations among water, vegetation, and built-up surfaces.
Using this workflow, similar analyses can be efficiently generated for ports worldwide. The next step would involve analyzing the clustering results and developing a typology of port landscapes based on these patterns.


**Reflection**
On K-means clustering:
The choice of the number of clusters and the selection of spectral bands should be carefully considered before conducting the analysis, depending on the research focus. While supervised classification can also be applied and may yield more meaningful results in some cases, my experience suggests that when the training dataset is limited, unsupervised clustering often produces more reliable outcomes.
On data:
The initial plan was to compare satellite images from two different time periods to observe port expansion over time. However, in practice, obtaining images of sufficient quality for clustering is not always possible for every study area.
