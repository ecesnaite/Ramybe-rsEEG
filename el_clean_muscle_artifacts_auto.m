clear all, close all

addpath C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Matlab_scripts\toolboxes\eeglab_current\eeglab2022.0
eeglab

data = dir(['C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\BeforeICA\ICA64\ICA64\*set'])
saveDir = 'C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\AfterICA\'

for i = 1:length(data)
    EEG = pop_loadset(data(i).name, data(i).folder)

%     figure, topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'numpoint', 'chaninfo', EEG.chaninfo);
%     pause(0.5)

    % Detect bad ICs that were labeled as muscle activity by IC label as more than 70%.
    % --------------------------------------------------------------

    EEG = iclabel(EEG);
    threshold = [0 0;0.1 1; 0.5 1; 0.5 1; 0.5 1; 0.5 1; 0 0];%Brain, Muscle,
        %            Eye, Heart, Line Noise, Channel Noise, Other.;
     EEG = pop_icflag(EEG, threshold);

    remove_ics = find(EEG.reject.gcompreject);
    fprintf('Removing %d components:\n', length(remove_ics))
    fprintf(' %g', remove_ics)

    EEG_rej = pop_subcomp(EEG, remove_ics, 0);

    figure('Position', [300 300 1300 600]),
    subplot(1,2,1), plot_spec(EEG.data',EEG_rej.srate,45), title('ORIGINAL SPECTRUM'),
    yLimit_spec = get(gca,'YLim')
    subplot(1,2,2), plot_spec(EEG_rej.data',EEG.srate,45), title('cleared with active components'),ylim(yLimit_spec)
    pause(0.5)

%     input(['name: ', data(i).name, '. continue?'], 's')
    EEG_rej.reject.icarejedcomp = remove_ics;

    name = extractBefore(data(i).name, '_imp')
    EEG_rej = pop_saveset( EEG_rej, 'filename',[char(name), '_icLabelClean'],'filepath',saveDir);
    clearvars remove_ics EEG_rej EEG
    close all
end
% pop_eegplot(EEG,1,1,1)
