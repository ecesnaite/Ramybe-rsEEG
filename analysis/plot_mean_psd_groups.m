
load('alpha_peaks_matchannel_locations_62') % Pz is 24
slope = readtable('slope_off_ch_groups.xlsx')
offset = readtable('slope_off_ch_groups.xlsx', 'Sheet', 'offset_each_ch_sbj')

pz_slope = slope.channel_24
pz_offset = offset.channel_24

groups = {'NCF', 'NCL', 'IUD', 'OC'}
pz_aperiodic = table()

for g = 1:length(groups)

    indx_group = ismember(slope.group,groups(g))
    pz_slope_group = mean(pz_slope(indx_group))
    pz_offset_group = mean(pz_offset(indx_group))

    pz_aperiodic.slope(g) = pz_slope_group
    pz_aperiodic.offset(g) = pz_offset_group
end

pz_aperiodic.group = groups'
writetable(pz_aperiodic, 'aperiodic_pz_groups.xlsx')

% re-create line
ap_line=table()
n=1
fs = [3:0.25:40];
for l = 1:4
    logL = pz_aperiodic.offset(l) - pz_aperiodic.slope(l)*log10(fs);
    ap_line = [ap_line, table(logL')]
    ap_line.Properties.VariableNames = groups(1:n)
    n = n+1
end
ap_line.freq = fs'
writetable(ap_line, 'aperiodic_decay_group_plots.csv', 'Delimiter',',')
L = 10.^logL;