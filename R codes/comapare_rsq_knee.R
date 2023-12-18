
rm(list = ls())
library(tidyverse)
library(ggplot2)
install.packages("ggExtra")
library(ggExtra)
# Load data
data_knee <- read.csv("C:/Users/ecesnait/Desktop/BUSCHLAB/Hormones/Data/rsq_with_knee.csv")
indx_male <- startsWith(data_knee$ID, 'V') # find males
data_knee_f = data_knee %>% filter(!indx_male)#only female groups

data_no_knee <- read.csv("C:/Users/ecesnait/Desktop/BUSCHLAB/Hormones/Data/rsq_without_knee.csv")
indx_male_no <- startsWith(data_no_knee$ID, 'V') # find males
data_no_knee_f = data_no_knee %>% filter(!indx_male_no)#only female groups

# Match lists and combine
combined_data <- data_knee_f
combined_data$rsq_no_knee <- data_no_knee_f[match(data_knee_f$ID, data_no_knee_f$ID),2]
combined_data$group[startsWith(combined_data$ID, 'UID')]<- 'IUD'
combined_data$group[startsWith(combined_data$ID, 'OC')]<- 'OC'
combined_data$group[startsWith(combined_data$ID, 'NCG')]<- 'NCL'
combined_data$group[startsWith(combined_data$ID, 'NCF')]<- 'NCF'


# Plot scatterplot to compare the values
tiff("C:/Users/ecesnait/Desktop/BUSCHLAB/Hormones/Matlab_scripts/RestEEGhormones/figures/compare rsq.png", units="in", width=7, height=5, res=300)

p<-ggplot(combined_data, aes(x=mean_rsq, y=rsq_no_knee, color=group)) + 
  geom_point(size=3) +
  theme(text = element_text(size = 22), legend.text=element_text(size=20), legend.title = element_text(size=20),
        legend.position= "bottom",legend.key.height = unit(0.5, 'cm'))+xlab("R^2 with knee") + ylab("R^2 without knee")+
  xlim(0.85,1)
ggExtra::ggMarginal(p, type = "histogram")
dev.off()


# find min no knee value
which.min(combined_data$rsq_no_knee)
combined_data$ID[59]
