clc; clear all; close all
addpath "C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Matlab_scripts\toolboxes\eeglab_current\eeglab2022.0"
eeglab

duomenys = dir('C:\Users\ecesnait\Desktop\EEGManyPipelines\EEGManyPipelines S06\subj06\*.set')
saveDir = 'D:\Data_R1\Cleaning\First_step\Viewed\AfterICA'

% adjust some eeglab options
% pop_editoptions( 'option_storedisk', 0, 'option_savetwofiles', 1, 'option_saveversion6', 1, 'option_single', 1, 'option_memmapdata', 0, 'option_eegobject', 0, 'option_computeica', 1, 'option_scaleicarms', 1, 'option_rememberfolder', 1, 'option_donotusetoolboxes', 0, 'option_checkversion', 1, 'option_chat', 0);

Fig1 = figure('Name','electrode positions');
%Fig3 = figure('Name','spectrum of cleaned EEG'); set(gcf,'position',[10,10,1200,500]);
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
        %set(0, 'CurrentFigure', Fig2);
        plot_spec(EEG.data',EEG.srate, 45), title('original power spectrum');
        yLimit_spec = get(gca,'YLim');

 % --------------------------------------------------------------
        % Run ICLabel classification.
         % --------------------------------------------------------------

        EEG = iclabel(EEG);

        % Detect bad ICs with IC label.
        % --------------------------------------------------------------
        threshold = [0 0;0.8 1; 0.8 1; 0.9 1; 0.9 1; 0.8 1; 0.9 1];%Brain, Muscle,
        %            Eye, Heart, Line Noise, Channel Noise, Other.;
        EEG = pop_icflag(EEG, threshold);
        EEG = el_func_icareject_manualinspect(EEG, [1:length(EEG.icaweights)]);

        % --------------------------------------------------------------
        % Finally subtract all bad components.
        % --------------------------------------------------------------

        remove_ics = find(EEG.reject.gcompreject);
        fprintf('Removing %d components:\n', length(remove_ics))
        fprintf(' %g', remove_ics)
        fprintf('.\n')

        EEG_rej = pop_subcomp(EEG, remove_ics, 0);
        
        % --------------------------------------------------------------
        % plotting the spectrum of cleaned with active and passive components
        % --------------------------------------------------------------
        figure
        subplot(1,2,1), plot_spec(EEG_rej.data',EEG.srate,45), title('cleared with active components'), ylim(yLimit_spec)
        subplot(1,2,2), plot_spec(EEG.data',EEG_rej.srate,45), title('ORIGINAL SPECTRUM'),ylim(yLimit_spec)
        % --------------------------------------------------------------
        % saving
        % --------------------------------------------------------------
        EEG_rej = eeg_checkset(EEG_rej);
        cntu = input('SAVE? NO=''n'' - YES=any: ','s');

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