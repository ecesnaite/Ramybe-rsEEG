% (C) Elena Cesnaite, email: e.cesnaite@gmail.com, page: https://www.researchgate.net/profile/Elena-Cesnaite

% ADAPTED VERSION

% This code was created to analyze data described in a paper:'Rhythms in the human
% body: the search for relationships between brain oscillations and fluctuations of sex hormones' by....
% This code was adapted to calculate alpha band parameters on non detrended psd
% Main parameters: broadpower, lower and upper alpha power, IAF
% Last updated 16.09.2023

clear all, close all

psd_all = load('psd_and_freq_for_FOOOF_06072023.mat'); % Original PSD

saveDir = 'C:\Users\ecesnait\Desktop\BUSCHLAB\Hormones\Data\';

% Initialize the structure to store alpha peak parameters
alpha_params = struct('ID', {}, 'alpha_broad_power', [], 'alpha1', [], 'alpha2', [], 'iaf', [], 'peak_start', [], 'peak_end', [], 'peak_width', []);

for p = 1:length(psd_all.psd)

    id = psd_all.psd(p).ID;
    spectrum = psd_all.psd(p).spect;
    fs = psd_all.psd(p).freq;

    for ch = 1:62
        chan_psd = spectrum(ch,:)
        % Find peaks using the original findpeaks function
        [pow, ifreq, width, ~,width_range] = findpeaks_ramybe(chan_psd, fs, 'MinPeakProminence', 0.05, 'Annotate', 'extents', 'WidthReference', 'halfheight');

        % Specify lower and upper alpha bounds
        lower_alpha_bound = 7;
        upper_alpha_bound = 13;

        % Find alpha peaks within the specified range
        any_alp = (ifreq >= lower_alpha_bound & ifreq <= upper_alpha_bound);

        if sum(any_alp) > 1 % if more than one peak in alpha range is present
            [val, alp_loc] = max(pow(any_alp)); % out of two alpha peaks which one is higher in amplitude
            loc = find(any_alp); % find two alpha peak locations out of every peak
            alp_loc = loc(alp_loc); % higher peak location out of every peak
            any_alp(:) = 0; % set everything to 0 as if no alpha peak was found
            any_alp(alp_loc) = 1; % set the maxima location of alpha peak to 1
        end


        if sum(any_alp) == 1 % if one alpha peak is present
            iaf = ifreq(any_alp);

            alpha_width = width(any_alp);

            if alpha_width > 7 % whenever the width of the peak is more than 3Hz, set it to 3
               % input('Inspect visually, the width is too broad')
               if iaf - width_range(any_alp,1)>3.5
                    width_range(any_alp,1) = iaf - 3.5
               elseif width_range(any_alp,2)-iaf > 3.5
                   width_range(any_alp,2) = iaf + 3.5
               end
               alpha_width = width(any_alp);
            end

            % calculate alpha power
            alpha_broad_power = sum(chan_psd(fs >= width_range(any_alp,1) & fs <= width_range(any_alp,2))) * 0.25;
            % lower alpha: peak start to IAF
            lower_alpha_power = sum(chan_psd(fs >= width_range(any_alp,1) & fs <= iaf)) * 0.25;
            % upper alpha: IAF to peak end
            upper_alpha_power = sum(chan_psd(fs >= iaf & fs <= width_range(any_alp,2))) * 0.25;

            alpha_pow(ch) = alpha_broad_power;
            alpha1(ch) = lower_alpha_power;
            alpha2(ch) = upper_alpha_power;
            alpha_freq(ch) = iaf;
            peak_start(ch) = width_range(any_alp,1);
            peak_end(ch) = width_range(any_alp,2);
            peak_width(ch) = alpha_width;


        else
%             error('no peak was found?');
            % Handle the case when no alpha peak is found
            alpha_pow(ch) = NaN;
            alpha1(ch) = NaN;
            alpha2(ch) = NaN;
            alpha_freq(ch) = NaN;
            peak_start(ch) = NaN;
            peak_end(ch) = NaN;
            peak_width(ch) = NaN;
        end


    end

    % Store the results in the alpha_params structure
    alpha_params(p).ID = id;
    alpha_params(p).alpha_broad_power = alpha_pow;
    alpha_params(p).alpha1 = alpha1;
    alpha_params(p).alpha2 = alpha2;
    alpha_params(p).iaf = alpha_freq;
    alpha_params(p).peak_start = peak_start;
    alpha_params(p).peak_end = peak_end;
    alpha_params(p).peak_width = peak_width;
    clearvars -except alpha_params p psd_all saveDir
end

% Saving the results
save([saveDir, 'alpha_params_findpeaks_non_detrend_threshold_05_180923'], 'alpha_params');

% Create matrices for alpha power
alpha_broad = struct();
alpha_broad.ID = {alpha_params.ID};

for i = 1:length(alpha_params)
    broadpow(i, :) = alpha_params(i).alpha_broad_power;
    lowerpow(i, :) = alpha_params(i).alpha1;
    upperpow(i, :) = alpha_params(i).alpha2;
    iaf(i, :) = alpha_params(i).iaf;
    peakstart(i, :) = alpha_params(i).peak_start;
    peakend(i, :) = alpha_params(i).peak_end;
    peakwidth(i, :) = alpha_params(i).peak_width;
end

% Saving the matrices
save([saveDir, 'alpha_pow_mtx_180923'], 'broadpow');
save([saveDir, 'alpha1_pow_mtx_180923'], 'lowerpow');
save([saveDir, 'alpha2_pow_mtx_180923'], 'upperpow');
save([saveDir, 'iaf_mtx_180923'], 'iaf');
save([saveDir, 'peak_start_mtx_180923'], 'peakstart');
save([saveDir, 'peak_end_mtx_180923'], 'peakend');
save([saveDir, 'peak_width_mtx_180923'], 'peakwidth');

ID_all = {psd_all.psd.ID};
save([saveDir, 'all_IDs'], 'ID_all');

%EEG = pop_loadset('NCF_201.set');
%chan_label = {EEG.chanlocs.labels};
%save([saveDir, 'channel_labels_62'], 'chan_label');

%chan_loc = EEG.chanlocs;
%save([saveDir, 'channel_locations_62'], 'chan_loc');
