rm(list = ls())

myData <-read.csv("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/analysis/psd_group_pz.csv")
library(ggplot2)
library(tidyr)
library(RColorBrewer)
data_long = gather(myData[,c(1:4)], factor_key = T)
data_long$y <- myData$freq

mycolors_all <- brewer.pal(n = 4, "Set3")
mycolors_all <- mycolors_all[c(1,2,4,3)]

tiff("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/figures/psd_all_avg.png", units="in", width=4, height=3, res=300)

ggplot(data_long, aes(x=y, y= log(value), group=key)) +
  geom_line(aes(color=key), size = 1)+ theme_classic() + 
  scale_colour_manual(values=mycolors_all, labels = c("NCF", "NCG", "UID", "OC")) + 
  labs(x="Frequency (Hz)", y = "log Power", color = "Groups")+
  theme(axis.text=element_text(size=12), legend.text = element_text(size=12), legend.title = element_text(size=12))

dev.off()

## Each group separately ##

ncf <- read.csv("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/analysis/psd_ncf_pz.csv")
ncg <- read.csv("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/analysis/psd_ncg_pz.csv")
uid <- read.csv("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/analysis/psd_uid_pz.csv")
oc <- read.csv("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/analysis/psd_oc_pz.csv")

t_ncf <- as.data.frame(t(ncf))
t_ncf_long <- gather(t_ncf, factor_key = T)
t_ncf_long$freq <- myData$freq

nfc_mean <- data_long[data_long$key=="ncf",]
display.brewer.all() 

my_green = brewer.pal(n = 9, "Greens")[3:9] #there are 9, I exluded the two lighter hues
green_palette = colorRampPalette(c(my_green[1], my_green[4], my_green[6]), space = "Lab")
my_green2 = green_palette(34)

tiff("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/figures/psd_ncf.png", units="in", width=4, height=3, res=300)

ggplot(t_ncf_long, aes(x=freq, y= log(value), group=key)) +
  geom_line(aes(color=key), alpha=0.2) + 
  geom_line(data = nfc_mean,aes(x=y, y= log(value)), alpha = .8, size = 1) +
  scale_colour_manual(values=my_green2)+theme_classic() + 
  labs(title = "NCF", x="Frequency (Hz)", y = "log Power") + theme(legend.position="none",axis.text=element_text(size=12))
dev.off()

## NCG Plots ##
t_ncg <- as.data.frame(t(ncg))
t_ncg_long <- gather(t_ncg, factor_key = T)
t_ncg_long$freq <- myData$freq

ncg_mean <- data_long[data_long$key=="ncg",]
display.brewer.all() 

my_yellow = brewer.pal(n = 9, "YlOrBr")[1:7] #there are 9, I exluded the two lighter hues
yellow_palette = colorRampPalette(c(my_yellow[1], my_yellow[4], my_yellow[6]), space = "Lab")
my_yellow2 = yellow_palette(35)

tiff("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/figures/psd_ncg.png", units="in", width=4, height=3, res=300)

ggplot(t_ncg_long, aes(x=freq, y= log(value), group=key)) +
  geom_line(aes(color=key), alpha=0.2) + 
  geom_line(data = ncg_mean,aes(x=y, y= log(value)), alpha = .8, size = 1) +
  scale_colour_manual(values=my_yellow2)+theme_classic() + 
  labs(title = "NCG", x="Frequency (Hz)", y = "log Power") + theme(legend.position="none",axis.text=element_text(size=12))
dev.off()

## UID Plots ##
t_uid <- as.data.frame(t(uid))
t_uid_long <- gather(t_uid, factor_key = T)
t_uid_long$freq <- myData$freq

uid_mean <- data_long[data_long$key=="uid",]
display.brewer.all() 

my_orange = brewer.pal(n = 9, "OrRd")[3:9] #there are 9, I exluded the two lighter hues
orange_palette = colorRampPalette(c(my_orange[1], my_orange[4], my_orange[6]), space = "Lab")
my_orange2 = orange_palette(30)

tiff("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/figures/psd_uid.png", units="in", width=4, height=3, res=300)

ggplot(t_uid_long, aes(x=freq, y= log(value), group=key)) +
  geom_line(aes(color=key), alpha=0.2) + 
  geom_line(data = uid_mean,aes(x=y, y= log(value)), alpha = .8, size = 1) +
  scale_colour_manual(values=my_orange2)+theme_classic() + 
  labs(title = "UID", x="Frequency (Hz)", y = "log Power") + theme(legend.position="none",axis.text=element_text(size=12))

dev.off()


## OC Plots ##
t_oc <- as.data.frame(t(oc))
t_oc_long <- gather(t_oc, factor_key = T)
t_oc_long$freq <- myData$freq

oc_mean <- data_long[data_long$key=="oc",]
display.brewer.all() 

my_purple = brewer.pal(n = 9, "BuPu")[3:9] #there are 9, I exluded the two lighter hues
purple_palette = colorRampPalette(c(my_purple[1], my_purple[4], my_purple[6]), space = "Lab")
my_purple2 = purple_palette(36)

tiff("/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/figures/psd_oc.png", units="in", width=4, height=3, res=300)

ggplot(t_oc_long, aes(x=freq, y= log(value), group=key)) +
  geom_line(aes(color=key), alpha=0.2) + 
  geom_line(data = oc_mean,aes(x=y, y= log(value)), alpha = .8, size = 1) +
  scale_colour_manual(values=my_orange2)+theme_classic() + 
  labs(title = "OC", x="Frequency (Hz)", y = "log Power") + theme(legend.position="none",axis.text=element_text(size=12))

dev.off()
