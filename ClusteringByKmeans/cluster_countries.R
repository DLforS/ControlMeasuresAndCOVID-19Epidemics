######################################################################
# Clustering of national policies; Count the number and proportion of states in each category
######################################################################

### Clear the variables and set the working environment
rm(list = ls())
getwd() # get 'D:\\code_clustering'
setwd('D:\\code_clustering') # Replace the path output from the above code with this parenthesis


### Install and load the required macro package
# install.packages('ggpubr')
# install.packages('ggsci')
# install.packages('fpc')
# install.packages('ggrepel')
# install.packages('factoextra')
library(openxlsx)
library(ggplot2)
library(ggpubr)
library(Rtsne)
library(plyr)
library(car)
library(fpc)
library(ggsci)
library(scales)
library(ggrepel) # Comments do not overlap when you add comments to scatter points
library(factoextra)


### load data
indix_data = read.xlsx('Country_policy.xlsx', 
                       colNames = T,
                       rowNames = F)
country = indix_data$Countries

a <- indix_data
colnames(a) <- colnames(indix_data)
a = a[,-c(1,2)]


### data standardization
# normalization<-function(x){
#   return((x-min(x))/(max(x)-min(x)))
# }
# b <- apply(a,2,normalization)
# rownames(b) = country
# colnames(b) <- colnames(a)

## Another standardization of data
c <- scale(a)


### 1. k-means clustering
# (km) Select the appropriate number of center points
fviz_nbclust(c, kmeans, method = "wss") + geom_vline(xintercept = 4, linetype = 2)
km <- kmeans(c, 4, nstart = 25) 
Print result
print(km)

### Label the categories in order
for (i in 1:125){
  if (km$cluster[[i]] == 1){
    km$cluster[[i]] = 5
  }
  if (km$cluster[[i]] == 2){
    km$cluster[[i]] = 1
  }
  if (km$cluster[[i]] == 5){
    km$cluster[[i]] = 2
  }
}

# # Modify variable name
# names(km)[1] = 'Clusters'


# visualization
rownames(c) <- country
cluster <- as.factor(km$Clusters)

# install.packages("Cairo")
# install.packages('quartz')
# install.packages('showtext')
library(Cairo) 
library(showtext)
# CairoPDF("result1.pdf") 
# quartz(family = "STXihei")
CairoPDF("char_1.pdf",  width = 18, height = 12)

showtext_begin() # Add text
fviz_cluster(km, data = c,
             palette = c('#6a51a3','#0072B5FF','#20854EFF','#E18727FF'), # "#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"
             # palette = c('mediumslateblue','#8c510a','seagreen','red3'),
             ellipse.type = "convex",  # euclid, t, norm, confidence, convex
             star.plot = FALSE, 
             repel = TRUE,
             geom = c("point", "text"),  # c("point", "text"),
             pointsize = 4,
             labelsize = 20,
             show.clust.cent = FALSE,
             ellipse.level = 0.5,
             ellipse.alpha = 0.1,
             shape = NULL,
             ggtheme = theme_bw() #theme_minimal()
) + 
  ggtitle('') +
  scale_shape_manual(values = c(15,16,17,18))  +
  theme(legend.position = c(.4,.93),  
        legend.text = element_text(colour = 'black',
                                   size = 18,
                                   face = 'bold'),
        legend.title=element_blank(),   
        legend.background = element_blank(),
        legend.justification = c(0.1, 0.85))  +
  geom_text(aes(3.1,9.8),
            label = 'Clusters',
            size = 6.5,
            colour = 'gray8') +
  theme(axis.text.x = element_text(face="bold", size=12, family="simsun"),
        axis.text.y = element_text(face="bold", size=12, family="simsun"))  +  
  theme(axis.title.x = element_text(size=15,face = "bold", colour = "black" ,family="simsun"), 
        axis.title.y = element_text(size=15,face = "bold", colour = "black", family="simsun"))  
# Save the image size as 18*12
showtext_end() 
dev.off() 




### Save data in each category
a = km$cluster
a <- as.data.frame(a)
a[,c(2,3)] <- indix_data[,c(1,2)]

## cluster1
cluster1 <- a[a[,1] == 1,]
cluster2 <- a[a[,1] == 2,]
cluster3 <- a[a[,1] == 3,]
cluster4 <- a[a[,1] == 4,]

continents <- c('Europe','Asia','Africa','Americas')

data_final <- c(1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4)
data_final <- as.data.frame(data_final)

for (i in 1:4) {
  data_final[i,2] <- continents[i]
  data_final[i,3] <- sum(cluster1$Continents == continents[i])
}
for (i in 5:8) {
  data_final[i,2] <- continents[i-4]
  data_final[i,3] <- sum(cluster2$Continents == continents[i-4])
}
for (i in 9:12) {
  data_final[i,2] <- continents[i-8]
  data_final[i,3] <- sum(cluster3$Continents == continents[i-8])
}
for (i in 13:16) {
  data_final[i,2] <- continents[i-12]
  data_final[i,3] <- sum(cluster4$Continents == continents[i-12])
}
colnames(data_final) <- c('Clusters','Continents','Numbers')

# # Adjust the order of each category in the bar chart
# for (i in 1:4) {
#   data_final[i,1] <- 5
#   data_final[i+4,1] <- 1
#   data_final[i,1] <- 2
# }

# Calculated percentage
for (i in 1:4) {
  data_final[i,4] <- data_final[i,3]/3
  data_final[i+4,4] <- data_final[i+4,3]/10
  data_final[i+8,4] <- data_final[i+8,3]/51
  data_final[i+12,4] <- data_final[i+12,3]/61
}
# Keep 3 decimal places
data_final[,4] <- round(data_final[,4],3)
# # Combine specific values and percentages
# data_final[,4] <- as.character(data_final[,4] * 100)
# data_final[,5] <- as.character(data_final[,3])
# data_final[,6] <- paste(data_final[,5],'(',data_final[,4],'%',')',sep='') # joint
# data_final <- data_final[,-c(4,5)]
# colnames(data_final) <- c('Clusters','Continents','Numbers','text_percent')
# Combined percentage
data_final[,4] <- as.character(data_final[,4] * 100)
data_final[,5] <- as.character(data_final[,3])
data_final[,6] <- paste('(',data_final[,4],'%',')',sep='') # joint
data_final <- data_final[,-c(4,5)]
colnames(data_final) <- c('Clusters','Continents','Numbers','text_percent')

# install.packages('ggfittext')
library(ggfittext)

## Cluster bar chart
# install.packages('ggthemes')
library(ggthemes)

CairoPDF("char_1.pdf",  width = 10, height = 6)
showtext_begin() 

ggplot(data_final,aes(Clusters,Numbers,label = text_percent,fill = Continents))  +
  geom_bar(stat="identity",
           width = 0.7,
           position=position_dodge(width = 0.8))  +
  scale_fill_manual(values = c("#D6604D","#F4A582","#4393C3" ,"#2166AC")) + # ,"   "#FDDBC7","#92C5DE" 
  # scale_fill_manual(values = c("#f88421","#ffbc14","#00bdcd","#006b7b")) + 
  ylab('Number of countries') +
  theme(axis.ticks.length=unit(0.5,'cm'))+ 
  guides(fill=guide_legend(title=NULL)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,32)) +
  theme_bw() + 
  theme(axis.title.x = element_text(size=20,face = "bold", colour = "black"), 
        axis.title.y = element_text(size=20,face = "bold", colour = "black")) + # Horizontal and vertical text
  theme(legend.position = c(.1,.9),  # Specific location in the diagram
        legend.text = element_text(colour = 'black',
                                   size = 20,
                                   face = 'bold')) +
  theme(axis.text.x = element_text(face="bold", size=12),
        axis.text.y = element_text(face="bold", size=12))  + # Sets the number on the axis
  theme(panel.grid=element_line(colour=NA))  +#Remove the default gridlines
  theme(panel.border = element_blank()) + # Remove outer border
  theme(axis.line = element_line(size=0.5, colour = "black"))  +
  # geom_col(aes(fill = Continents), position = "dodge")   + 
  geom_text(aes(label = text_percent),
            position = position_dodge(width = 0.8),
            size = 6,
            vjust = -0.3) +
  geom_text(aes(label = Numbers),
            position = position_dodge(width = 0.8),
            size = 8,
            vjust = -1.1,
            hjust = +0.5)   
showtext_end() 
dev.off() 



# ### 2. DBSCAN  clustering
# 
# ## Test and select the appropriate parameters
# # install.packages('dbscan')
# library(dbscan)
# kNNdistplot(c, k = 3) 
# abline(h = 4, lty =2)
# 
# ## Compute DBSCAN
# library(factoextra)
# library(fpc)
# db <- dbscan(c, eps = 4, MinPts = 3, scale = FALSE)
# 
# ## Plot DBSCAN results
# fviz_cluster(db, c, stand = FALSE, frame = FALSE, geom = 'point') # geom = 'point'


# ### 3. agglomerative hierarchical clustering
# ## 
# hc<-hclust(dist(c,method = "euclidean"),method = "ward.D2")
# 
# ##
# plot(hc,hang = -0.01,cex=0.7)
