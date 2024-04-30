# cluster_countries.R
Main file. National policies are clustered, including K-means clustering, DBSCAN  clustering and agglomerative hierarchical clustering ; 
Count the number and proportion of states in each category；

# Country_policy.xlsx
Data file. Policy implementation by countries. The source of this data is The Oxford Covid-19 Government Response Tracker (OxCGRT)(https://www.bsg.ox.ac.uk/research/covid-19-government-response-tracker).


# Requirements
The code is implemented in R-3.6.2.

For generating plots to visualize results, the required packages are listed: 
* openxlsx
* ggplot2
* ggpubr
* Rtsne
* plyr
* car
* fpc
* ggsci
* scales
* ggrepel
* factoextra
* Cairo
* showtext
* ggfittext
* ggthemes