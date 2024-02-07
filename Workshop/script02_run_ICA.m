
clear all, close all
addpath /C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Matlab_scripts\toolboxes\eeglab_current\eeglab2022.0\
eeglab nogui

dataDir = dir(['C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\BeforeICA\', '\*.set'])
saveDir = 'C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\BeforeICA\'

for subj = 1:length(dataDir)

     %% Load data %%
    EEG = pop_loadset(dataDir(subj).name, dataDir(subj).folder)

    %% Run ICA %%
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'chanind', [1:65], 'pca', 30);

    %% Save data %%
    EEG = pop_saveset(EEG, 'filename', [dataDir(subj).name(1:end-10), 'ICA_weights'],'filepath',saveDir);

    close all
    clearvars -except dataDir saveDir eeglab subj
end