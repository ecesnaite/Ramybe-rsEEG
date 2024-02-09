%
clear all
eeglab

load('alpha_peaks_matchannel_locations_62.mat')
data = readtable('...\iaf_power_ch_groups.xlsx','Sheet','power_each_ch_sbj_removed_subj')

slope=readtable('slope_off_ch_groups.xlsx','Sheet','median_slope_groups')
OC_slope = table2array(slope(1,2:end))
IUD_slope = table2array(slope(2,2:end))
NCF_slope = table2array(slope(3,2:end))
NCL_slope = table2array(slope(4,2:end))

%split into groups
NCF = data(ismember(data.group, 'NCF'),:)
NCL = data(ismember(data.group, 'NCL'),:)
OC = data(ismember(data.group, 'OC'),:)
IUD = data(ismember(data.group, 'IUD'),:)

%take median of alpha power for each channel across one group
ap_NCL = nanmedian(table2array(NCL(:,3:end)))
ap_NCF = nanmedian(table2array(NCF(:,3:end)))
ap_OC = nanmedian(table2array(OC(:,3:end)))
ap_IUD = nanmedian(table2array(IUD(:,3:end)))

axis_data = [0 26]
axis_slope = [0.7 1.5]
%Plot Figure

input = NCL_slope
figure;
fig = topoplot(input, chan_loc, 'headrad', 'rim', 'whitebk','on')
title(char(['NCL_slope']),'Interpreter', 'none')
set(get(gca,'title'),'Position',[0 0.6 0.1])
xlim auto
ylim auto
set(gcf,'color','w');
colormap default
h = colorbar('WestOutside');
caxis(axis_slope);
set(h, 'ylim', axis_slope), %get min max values of the original scale by typing ylim
set(get(h,'title'), 'String', 'gamma')

close all

%check anova
women_only = data(~ismember(data.group, 'M'),:)
pow = nanmedian(table2array(women_only(:,3:end)),2)
group = table2array(women_only(:,2))
 [p,tbl,stats] = anova1(log10(pow), group)
