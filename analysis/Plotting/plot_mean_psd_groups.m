% The code was created to save and plot aperiodic component for different
% groups

clear all, close all

load('alpha_peaks_matchannel_locations_62') % Pz is 24
load('group_avg_ap_parameters.mat')%1-offset, 2-exponent

groups = {'NCF', 'NCL', 'IUD', 'OC'}
pz_aperiodic = table()

% re-create line
ap_line=table()
n=1
fs = [3:0.25:40];
f_names = fieldnames(ap_params)
for l = 1:4
    offset = ap_params.(f_names{l})(1)
    slope = ap_params.(f_names{l})(2)

    logL = offset - slope*log10(fs);
    L = 10.^logL;
    ap_line = [ap_line, table(L')]
    ap_line.Properties.VariableNames = groups(1:n)
    n = n+1
end
ap_line.freq = fs'
writetable(ap_line, 'aperiodic_decay_group_plots.csv', 'Delimiter',',')

%plot an example

load('pz_psd_groups.mat')
figure, plot(psd(1).freq, log(psd(1).spect(1,:))), hold on,
plot(ap_line.freq, log(L))
