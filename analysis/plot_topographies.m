%load table 4 x 62 where rows are groups (IUD, OC, NCF, NCL) and columns are
%channels holding info on median per channel per group


%Plot Figure
figure;
fig = topoplot(input, chanlocs, 'maplimits', 'absmax', 'headrad', 'rim', 'whitebk','on', 'emarker2', {[marked_electrodes],'x', 'k'})
title(char(['Alpha power decrease with age']),'Interpreter', 'none')
set(get(gca,'title'),'Position',[0 0.6 0.1])
xlim auto
ylim auto
set(gcf,'color','w');
colormap(coolWarm)
h = colorbar('WestOutside');
set(h, 'ylim', [min(rho) max(rho)]), %get min max values of the original scale by typing ylim
set(get(h,'title'), 'String', 'rho')

saveDir = '/data/p_02035/Derivatives/Matrices for correlations/Plot/'

export_fig([saveDir, 'Alpha power change with age a stages 5min'], '-r300', '-a2');