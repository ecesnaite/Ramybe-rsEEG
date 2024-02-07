clear all, close all
addpath C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Matlab_scripts\toolboxes\eeglab_current\eeglab2022.0\
eeglab nogui

dataDir = dir(['C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\BeforeICA\', '\*ICA_weights.set'])
saveDir = 'C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\AfterICA\'

for subj = 1%:length(dataDir)

    % --------------------------------------------------------------
    % Load data.
    % --------------------------------------------------------------
    EEG = pop_loadset(dataDir(subj).name, dataDir(subj).folder)
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );


    % --------------------------------------------------------------
    % Run IClabel to classify IC into 6 categories: Brain, Muscle, Eye,
    % Heart, Line Noise, Channel Noise, Other.
    % --------------------------------------------------------------
    fprintf('Detecting ICs with IClabel.\n')
    EEG = iclabel(EEG);% Info is then stored into EEG.ect.ic_classification.ICLabel


    % --------------------------------------------------------------
    % Detect artifactual components.
    % --------------------------------------------------------------
    % Example: only components that surpass the threshold will be marked as
    % artifacts
    threshold = [0 0;0.9 1; 0.85 1; 0.9 1; 0.9 1; 0.9 1; 0 0];
    EEG = pop_icflag(EEG, threshold) % saved into EEG.reject.gcompreject

    % Print number of noise components found
    fprintf(['Total number of components found: ', num2str(sum(EEG.reject.gcompreject)), newline,...
        'Noise components: ', num2str(find(EEG.reject.gcompreject)')])


    % --------------------------------------------------------------
    % Manual inspection.
    % --------------------------------------------------------------
    EEG = pop_selectcomps(EEG, [1:30]);


    % --------------------------------------------------------------
    % Remove components.
    % --------------------------------------------------------------
    remove_ics = find(EEG.reject.gcompreject);
    EEG = pop_subcomp(EEG, remove_ics, 0);


    % --------------------------------------------------------------
    % Visually inspect data.
    % --------------------------------------------------------------
    pop_eegplot(EEG, 1,1,1)
    
    % --------------------------------------------------------------
    % Save dataset.
    % --------------------------------------------------------------
    EEG = pop_saveset(EEG, 'filename', dataDir(subj).name(1:end-12),'filepath',saveDir);

    close all
    clearvars -except dataDir saveDir eeglab subj
end