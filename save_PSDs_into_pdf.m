% This code loads raw resting-state EEG files before processing, plots PSD and
% saves them into a pdf file. 

clear all, close all
addpath ..\toolboxes\eeglab_current\eeglab2022.0\ %path to the eeglab folder
eeglab

%data directory where .set files are located
dataDir = dir(['C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\AfterICA\', '*.set']) % add path where the data lives
fileName = 'afterICA_PSD_ICLabel64.pdf' % pdf file name

for f=1:length(dataDir)
for f=2:length(dataDir)

    EEG = pop_loadset(fullfile(dataDir(f).folder, dataDir(f).name)) % load the data
%     [b1,a1] = butter(2,0.1/(EEG.srate/2), 'high');% high-pass filter at 0.1 Hz to remove the DC shifts 
%     EEG.data = filtfilt(b1,a1,double(EEG.data)');

    figure, plot_spec(EEG.data',EEG.srate, 45); title(EEG.setname),% ylim([-15, 25]);
    fig = gcf
    exportgraphics(fig, fileName,'Append',true)
    close(fig)
    
    clearvars EEG b1 b2 fig
end
