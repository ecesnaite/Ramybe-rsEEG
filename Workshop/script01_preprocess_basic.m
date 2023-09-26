clear all, close all
addpath /Users/ecesnaite/Desktop/BuschLab/EEGManyPipelines/Matlab/toolboxes/eeglab-develop/
eeglab nogui

dataDir = dir(['/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/Workshop/data/', '*.set'])
saveDir = '/Users/ecesnaite/Desktop/BuschLab/Ramybe-rsEEG/Workshop/data/BeforeICA/'

for subj = 1%:length()

    % --------------------------------------------------------------
    % Load data.
    % --------------------------------------------------------------
    EEG = pop_loadset(dataDir(subj).name, dataDir(subj).folder)

    % --------------------------------------------------------------
    % Downsample.
    % --------------------------------------------------------------
    EEG = pop_resample(EEG, 256)

    % --------------------------------------------------------------
    % Recording length/number of markers/channel locations/ect.
    % --------------------------------------------------------------
    recording_length = (EEG.pnts/EEG.srate)/60
    figure, topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'numpoint', 'chaninfo', EEG.chaninfo)

    % --------------------------------------------------------------
    % Band-pass filter combined with the notch.
    % --------------------------------------------------------------
    [b1,a1] = butter(2,[1 45]/(EEG.srate/2));
    [b2,a2] = butter(2,[49 51]/(EEG.srate/2),'stop');

    EEG.data = filtfilt(conv(b1,b2),conv(a1,a2),double(EEG.data)')';

    % --------------------------------------------------------------
    % Remove bad data segmetns.
    % --------------------------------------------------------------
    pop_eegplot(EEG,1,1,1) % A1 electrode is flat because it's the reference electrode
    

    % --------------------------------------------------------------
    % Remove reference channel.
    % --------------------------------------------------------------
    EEG = pop_select(EEG, 'nochannel', find(contains({EEG.chanlocs.labels}, 'A1')))


    % --------------------------------------------------------------
    % Plot power spectral density and ispect for broken channels.
    % --------------------------------------------------------------
    figure, plot_spec(EEG.data',EEG.srate, 45); title(EEG.setname)

    
    % --------------------------------------------------------------
    % Save data.
    % --------------------------------------------------------------
    EEG = pop_saveset(EEG, 'filename',[dataDir(subj).name(1:end-10), '_preICA'],'filepath',saveDir);

    close all
    clearvars -except dataDir saveDir eeglab subj

end

