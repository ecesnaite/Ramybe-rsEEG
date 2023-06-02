
clc; clear all; close all
addpath "C:\Users\LAB-V144\OneDrive\Dokumentai\eeglab2020_0"
eeglab

duomenys = dir('D:\Data_R1\Cleaning\First_step\Viewed\ICA\*.set')
saveDir = 'D:\Data_R1\Cleaning\First_step\Viewed\AfterICA'

% adjust some eeglab options
% pop_editoptions( 'option_storedisk', 0, 'option_savetwofiles', 1, 'option_saveversion6', 1, 'option_single', 1, 'option_memmapdata', 0, 'option_eegobject', 0, 'option_computeica', 1, 'option_scaleicarms', 1, 'option_rememberfolder', 1, 'option_donotusetoolboxes', 0, 'option_checkversion', 1, 'option_chat', 0);

Fig1 = figure('Name','electrode positions');
Fig2 = figure('Name','spectrum of before any cleaning');
Fig3 = figure('Name',sprintf('fastICA Results - plot %d',1), 'units','normalized','outerposition',[0 0 1 1]);
Fig4 = figure('Name','spectrum of active/active&passive cleaned EEG'); set(gcf,'position',[10,10,1200,500]);
pause(0.5)

for i =1:length(duomenys)
    cntu = 'n';
    while cntu == 'n'
        clf(Fig1,'reset'); clf(Fig2,'reset'); clf(Fig3,'reset');clf(Fig4,'reset'); pause(0.5);

        % --------------------------------------------------------------
        % Load the dataset.
        % --------------------------------------------------------------
        EEG = pop_loadset('filename', duomenys(i).name, 'filepath', duomenys(i).folder);

        set(0, 'CurrentFigure', Fig1);
        topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'numpoint', 'chaninfo', EEG.chaninfo);
        set(0, 'CurrentFigure', Fig2);
        plot_spec(EEG.data',EEG.srate, 45), title('original power spectrum');
        yLimit_spec = get(gca,'YLim');


        [bad_cmp_acitive,bad_cmp_passive] = select_components(EEG.icawinv./std(EEG.icawinv),EEG.icaact,EEG.srate,EEG.chanlocs,'fig',{Fig3},'data',EEG.data);

        noisy_ds = input('NOISY? YES=''y'' - NO=''n'': ','s');
        if noisy_ds == 'y'
            fileID = fopen(fullfile(probDir,'EEG_noisy_subjects.txt'),'a+'); %do not overwrite
            fprintf(fileID,'\n %s %s %12s',datestr(datetime),char(name));
            fclose(fileID);

            fileID = fopen(fullfile(textDir,[char(name),'.txt']),'a+'); %do not overwrite
            fprintf(fileID,'\n %s %12s', datestr(datetime),';Noisy power spectrum. ');
            fclose(fileID);
        end
    end
    fprintf('Detecting ICs with IClabel.\n')
    % Detect bad ICs with IC label.
    % --------------------------------------------------------------
    threshold = [0 0.2;0.8 1; 0.8 1; 0.9 1; 0.9 1; 0.8 1; 0.9 1];%Brain, Muscle,
    %            Eye, Heart, Line Noise, Channel Noise, Other.;
    EEG = pop_icflag(EEG, threshold);


end