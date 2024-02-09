% The code was created to plot the mean PSD curves for wach group

load('psd_and_freq_for_FOOOF_06072023.mat')
load('alpha_peaks_matchannel_locations_62.mat')

%find Pz location: 24
for p = 1:length(psd)
    pz_psd(p,:) = psd(p).spect(24,:)
end

%save mean based on ID
ncf_psd = mean(pz_psd(contains({psd.ID}, 'NCF'),:))
ncg_psd = mean(pz_psd(contains({psd.ID}, 'NCG'),:))
uid_psd = mean(pz_psd(contains({psd.ID}, 'UID'),:))
oc_psd = mean(pz_psd(contains({psd.ID}, 'OC'),:))

freq = psd(1).freq

psd_avg.spect = [ncf_psd; ncg_psd; uid_psd; oc_psd]
psd_avg.freq = freq
save('pz_psd_groups','psd')

psd_group = table(ncf_psd', ncg_psd', uid_psd', oc_psd', freq)
psd_group.Properties.VariableNames = {'ncf', 'ncg', 'uid', 'oc', 'freq'}

writetable(psd_group, 'psd_group_pz.csv', 'Delimiter',',')

ncf = table(pz_psd(contains({psd.ID}, 'NCF'),:))
ncg = table(pz_psd(contains({psd.ID}, 'NCG'),:))
uid = table(pz_psd(contains({psd.ID}, 'UID'),:))
oc = table(pz_psd(contains({psd.ID}, 'OC'),:))

writetable(ncf, 'psd_ncf_pz.csv', 'Delimiter',',')
writetable(ncg, 'psd_ncg_pz.csv', 'Delimiter',',')
writetable(uid, 'psd_uid_pz.csv', 'Delimiter',',')
writetable(oc, 'psd_oc_pz.csv', 'Delimiter',',')



figure, plot(freq,oc_psd), hold on
plot(freq,ncf_psd)

