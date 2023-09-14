clear all, close all
addpath C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Matlab_scripts\toolboxes\eeglab_current\eeglab2022.0\
eeglab nogui

dataDir = dir(['C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\AfterICA\', '\*ICA.set'])
saveDir = 'C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\AfterICA\'

for subj = 1:length(dataDir)

    % --------------------------------------------------------------
    % Load data.
    % --------------------------------------------------------------
    EEG = pop_loadset(dataDir(subj).name, dataDir(subj).folder)
    
    % --------------------------------------------------------------
    % Interpolate channels.
    % --------------------------------------------------------------
    bad_channels = {'T8', 'TP8'}
    EEG = eeg_interp(EEG, find(contains({EEG.chanlocs.labels}, bad_channels)), 'spherical');


    % --------------------------------------------------------------
    % Visually inspect data.
    % --------------------------------------------------------------
    pop_eegplot(EEG, 1,1,1)


    % --------------------------------------------------------------
    % Re-reference data.
    % --------------------------------------------------------------
    EEG = pop_reref(EEG, [])

     % --------------------------------------------------------------
    % Save dataset.
    % --------------------------------------------------------------
    EEG = pop_saveset(EEG, 'filename', [dataDir(subj).name(1:end-8), 'clean'],'filepath',saveDir);

    close all
    clearvars -except dataDir saveDir eeglab subj

end