
rm(list = ls())
library(tidyverse)
library(ggplot2)
#install.packages("ggExtra")
library(ggExtra)
# Load data
data_knee <- read.csv("C:/Users/ecesnait/Desktop/BUSCHLAB/Hormones/Data/rsq_with_knee.csv")
indx_male <- startsWith(data_knee$ID, 'V') # find males
data_knee_f = data_knee %>% filter(!indx_male)#only female groups

data_no_knee <- read.csv("C:/Users/ecesnait/Desktop/BUSCHLAB/Hormones/Data/rsq_without_knee.csv")
indx_male_no <- startsWith(data_no_knee$ID, 'V') # find males
data_no_knee_f = data_no_knee %>% filter(!indx_male_no)#only female groups

#medians
median(data_knee_f$mean_rsq)#0.9880715
median(data_no_knee_f$mean_rsq)#0.9890361

sd(data_knee_f$mean_rsq)#0.0153868
sd(data_no_knee_f$mean_rsq)#0.0213057

# Match lists and combine
combined_data <- data_knee_f
combined_data$rsq_no_knee <- data_no_knee_f[match(data_knee_f$ID, data_no_knee_f$ID),2]
combined_data$group[startsWith(combined_data$ID, 'UID')]<- 'IUD'
combined_data$group[startsWith(combined_data$ID, 'OC')]<- 'OC'
combined_data$group[startsWith(combined_data$ID, 'NCG')]<- 'NCL'
combined_data$group[startsWith(combined_data$ID, 'NCF')]<- 'NCF'

# difference
combined_data$diff <- combined_data$mean_rsq - combined_data$rsq_no_knee

#number of positive values would indicate that the model fit with knee is better for the number of subjects
length(combined_data$diff[combined_data$diff>0]) #56 subejcts have a slightly better model fit with knee
length(combined_data$diff[combined_data$diff<0]) #79 subjects have a slightly better model fit without

tiff("C:/Users/ecesnait/Desktop/BUSCHLAB/Hormones/Matlab_scripts/RestEEGhormones/figures/compare rsq difference.png", units="in", width=7, height=5, res=300)

ggplot(combined_data, aes(x=diff)) + 
  geom_histogram(color="black", fill="white")+
  theme(text = element_text(size = 22))+
  xlab("R^2 difference(knee - no knee)")+
  geom_vline(xintercept=0, linetype="dashed")+
  geom_text(x=-0.03, y=36, label="n = 79", size = 7)+
  geom_text(x=0.03, y=36, label="n = 56", size = 7)

dev.off()

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
