% (C) Elena Cesnaite, email: e.cesnaite@gmail.com, page: https://www.researchgate.net/profile/Elena-Cesnaite

% This code was created to analyze data described in a paper:'Rhythms in the human 
% body: the search for relationships between brain oscillations and fluctuations of sex hormones' by ...
% This code calculates power spectral density for each channel which will
% be used as in input data for the FOOOF algorythm.
% Last updated 01.08.2023

clc; clear all; close all

eeglab

aftDir = '' % dataDir
saveDir = ''

files = dir([aftDir, '*.set']);

for isb = 1:length(files)

    EEG = pop_loadset(files(isb).name, aftDir);
    name = extractBefore(files(isb).name, '.set')


    [spect freq] = plot_spec(EEG.data',EEG.srate,45)
    spect = spect';
    psd(isb).spect = spect
    psd(isb).freq = freq
    psd(isb).ID = name
    clear  EEG spect freq name %UPDATE
end

save([saveDir, 'psd_and_freq_for_FOOOF_moterys'], 'psd')







