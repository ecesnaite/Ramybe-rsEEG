% Code description: 
% The code loads partly cleaned EEG datasets that contain ICA weights. It
% then applies IClabel algorithm to help classify components. Visual
% inspection is done to mark components that are related to artifacts.
% Code was written on 06.2023 for the publication:
% Gaizauskaite et al. (2024) "The search for the relationship between female hormonal status, alpha oscillations, and aperiodic features of resting state EEG"

clc; clear all; close all
addpath "" % path to the EEGLAB folder
eeglab

duomenys = dir('\*.set') % data files
saveDir = '' % saving directory

% adjust some eeglab options
% pop_editoptions( 'option_storedisk', 0, 'option_savetwofiles', 1, 'option_saveversion6', 1, 'option_single', 1, 'option_memmapdata', 0, 'option_eegobject', 0, 'option_computeica', 1, 'option_scaleicarms', 1, 'option_rememberfolder', 1, 'option_donotusetoolboxes', 0, 'option_checkversion', 1, 'option_chat', 0);

Fig1 = figure('Name','electrode positions');
pause(0.5)

for i =1:length(duomenys)

    cntu = 'n';
    while cntu == 'n'

        % --------------------------------------------------------------
        % Load the dataset.
        % --------------------------------------------------------------
        EEG = pop_loadset('filename', duomenys(i).name, 'filepath', duomenys(i).folder);

        % --------------------------------------------------------------
        % Plot the topography of channel locations and PSD before cleaning %
        % --------------------------------------------------------------
        set(0, 'CurrentFigure', Fig1);
        topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'numpoint', 'chaninfo', EEG.chaninfo);
        plot_spec(EEG.data',EEG.srate, 45), title('original power spectrum');
        yLimit_spec = get(gca,'YLim');

        % --------------------------------------------------------------
        % Run ICLabel classification.
        % --------------------------------------------------------------

        EEG = iclabel(EEG);

        % Detect bad ICs with IC label.
        % --------------------------------------------------------------
        threshold = [0 0;0.1 1; 0.5 1; 0.5 1; 0.5 1; 0.5 1; 0 0]; % Threshold are set for: Brain, Muscle, Eye, Heart, Line Noise, Channel Noise, Other.;
        % Important: these thresholds are used only for flagging the
        % components. The decision of whether to keep or reject the
        % component is done by visual inspection below.

        EEG = pop_icflag(EEG, threshold);
        EEG = el_func_icareject_manualinspect(EEG, [1:length(EEG.icaweights)]); % manual inspection of ICA components

        % --------------------------------------------------------------
        % Finally subtract all bad components.
        % --------------------------------------------------------------

        remove_ics = find(EEG.reject.gcompreject);
        fprintf('Removing %d components:\n', length(remove_ics))
        fprintf(' %g', remove_ics)
        fprintf('.\n')

        EEG_rej = pop_subcomp(EEG, remove_ics, 0);
        
        % --------------------------------------------------------------
        % plotting the power spectral density of cleaned data and original data (before ICA)
        % --------------------------------------------------------------
        figure
        subplot(1,2,1), plot_spec_adj(EEG_rej.data',EEG.srate,45), title('cleared with ICA'), ylim(yLimit_spec)
        subplot(1,2,2), plot_spec_adj(EEG.data',EEG_rej.srate,45), title('ORIGINAL SPECTRUM'),ylim(yLimit_spec)

        % --------------------------------------------------------------
        % saving
        % --------------------------------------------------------------
        EEG_rej = eeg_checkset(EEG_rej);
        cntu = input('SAVE? NO=''n'' - YES=any: ','s'); % In case you would like to re-run the component selection, press 'n'

        if cntu == 'n'
            %close all
        else
            EEG_rej.reject.icarejedcomp = remove_ics;

            name = extractBefore(duomenys(i).name, '.set')
            EEG_rej = pop_saveset( EEG_rej, 'filename',[char(name), '_prep'],'filepath',saveDir);
            close all

        end

        clearvars -except duomenys saveDir  probDir cntu textDir namesICA i Fig1 Fig2 Fig3 

    end

end
