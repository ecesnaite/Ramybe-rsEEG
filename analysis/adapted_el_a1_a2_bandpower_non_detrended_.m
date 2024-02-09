% (C) Elena Cesnaite, email: e.cesnaite@gmail.com, page: https://www.researchgate.net/profile/Elena-Cesnaite

% ADAPTED VERSION 

% This code was created to analyze data described in a paper:'Rhythms in the human 
% body: the search for relationships between brain oscillations and fluctuations of sex hormones'
% This code was adapted to calculate alpha band parameters on non detrended psd
% Main parameters: broadpower, lower and upper alpha power, IAF
% Last updated 16.09.2023

clear all, close all

psd_all = load(''); % Original PSD

dataDir = ''; % Directory where FOOOF parameters are stored
saveDir = ''; % Directory to save alpha parameter files
files = dir([dataDir, '_parameters.mat']);

f_orig = [0:0.25:45]; % Original sampling frequency
fs = [3:0.25:40]; % Sampling frequency based on which FOOOF estimates were made between 3 - 40 Hz

% Initialize the structure to store alpha peak parameters
alpha_params = struct('ID', {}, 'alpha_broad_power', [], 'alpha1', [], 'alpha2', [], 'iaf', [], 'peak_start', [], 'peak_end', [], 'peak_width', []);

for p = 1:length(psd_all.psd)
    id = psd_all.psd(p).ID;
    original = psd_all.psd(strcmp({psd_all.psd.ID}, id));

    data = load([dataDir, strcat(id, '_parameters.mat')]);

    fields = fieldnames(data.ap_params);

    % Initialize variables
    alpha_pow = NaN(1, length(fields));
    alpha1 = NaN(1, length(fields));
    alpha2 = NaN(1, length(fields));
    iaf = NaN(1, length(fields));
    peak_start = NaN(1, length(fields));
    peak_end = NaN(1, length(fields));
    peak_width = NaN(1, length(fields));

    for ch = 1:length(fields)
        rsq = data.r_squared.(fields{ch});

        if rsq >= 0.7
            % Use original PSD data (not detrended)
            psd = original.spect(ch, f_orig >= 3 & f_orig <= 40);

            % Find peaks using the slightly adjusted findpeaks function to
            % map the width of the peak better. The function can be shared
            % under request
            [pow, ifreq, width, ~, bounds] = findpeaks_ramybe(psd, fs, 'MinPeakProminence', 0.05, 'Annotate', 'extents', 'WidthReference', 'halfheight');

            % Specify lower and upper alpha bounds
            lower_alpha_bound = 7;
            upper_alpha_bound = 13;

            % Find alpha peaks within the specified range
            any_alp = (ifreq >= lower_alpha_bound & ifreq <= upper_alpha_bound);
            if any(any_alp)
                if sum(any_alp) == 1 % if one alpha peak is present
                    freq = ifreq(any_alp);
                    range = bounds(any_alp, :);

                    if diff(range) > 6 % whenever the width of the peak is more than 3Hz, set it to 3
                        range = [freq - 3, freq + 3]; % here in og version 2.5 Hz (and 5 Hz) was used
                    end

                    % calculate alpha power
                    alpha_broad_power = sum(psd(fs >= round(range(1), 2) & fs <= round(range(2), 2))) * 0.25;
                    % lower alpha: peak start to IAF
                    lower_alpha_power = sum(psd(fs >= round(range(1), 2) & fs <= round(freq, 2))) * 0.25;
                    % upper alpha: IAF to peak end
                    upper_alpha_power = sum(psd(fs >= round(freq, 2) & fs <= round(range(2), 2))) * 0.25;

                    alpha_pow(ch) = alpha_broad_power;
                    alpha1(ch) = lower_alpha_power;
                    alpha2(ch) = upper_alpha_power;
                    iaf(ch) = freq;
                    peak_start(ch) = range(1);
                    peak_end(ch) = range(2);
                    peak_width(ch) = width(any_alp);


                elseif sum(any_alp) > 1 % if more than one peak in alpha range is present
                    [val, alp_loc] = max(pow(any_alp)); % out of two alpha peaks which one is higher in amplitude
                    loc = find(any_alp); % find two alpha peak locations out of every peak
                    alp_loc = loc(alp_loc); % higher peak location out of every peak
                    any_alp(:) = 0; % set everything to 0 as if no alpha peak was found
                    any_alp(alp_loc) = 1; % set the maxima location of alpha peak to 1

                    freq = ifreq(any_alp);
                    range = bounds(any_alp, :);

                    if diff(range) > 6 % whenever the width of the peak is more than 3Hz, set it to 3
                        range = [freq - 3, freq + 3];
                    end

                    % calculate alpha power
                    alpha_broad_power = sum(psd(fs >= round(range(1), 2) & fs <= round(range(2), 2))) * 0.25;
                    % lower alpha: peak start to IAF
                    lower_alpha_power = sum(psd(fs >= round(range(1), 2) & fs <= round(freq, 2))) * 0.25;
                    % upper alpha: IAF to peak end
                    upper_alpha_power = sum(psd(fs >= round(freq, 2) & fs <= round(range(2), 2))) * 0.25;

                    alpha_pow(ch) = alpha_broad_power;
                    alpha1(ch) = lower_alpha_power;
                    alpha2(ch) = upper_alpha_power;
                    iaf(ch) = freq;
                    peak_start(ch) = range(1);
                    peak_end(ch) = range(2);
                    peak_width(ch) = width(any_alp);
                
                else
                    error('no peak was found');
                    % Handle the case when no alpha peak is found 
                    alpha_pow(ch) = NaN;
                    alpha1(ch) = NaN;
                    alpha2(ch) = NaN;
                    iaf(ch) = NaN;
                    peak_start(ch) = NaN;
                    peak_end(ch) = NaN;
                    peak_width(ch) = NaN;
                  
                end
            end
        else
            % Handle the case when rsq is less than 0.7
            alpha_pow(ch) = NaN;
            alpha1(ch) = NaN;
            alpha2(ch) = NaN;
            iaf(ch) = NaN;
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
    alpha_params(p).iaf = iaf;
    alpha_params(p).peak_start = peak_start;
    alpha_params(p).peak_end = peak_end;
    alpha_params(p).peak_width = peak_width;
end

% Saving the results
save([saveDir, 'alpha_params_findpeaks_non_detrend_3_40_7_13_threshold_05'], 'alpha_params');

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
save([saveDir, 'alpha_pow_mtx'], 'broadpow');
save([saveDir, 'alpha1_pow_mtx'], 'lowerpow');
save([saveDir, 'alpha2_pow_mtx'], 'upperpow');
save([saveDir, 'iaf_mtx'], 'iaf');
save([saveDir, 'peak_start_mtx'], 'peakstart');
save([saveDir, 'peak_end_mtx'], 'peakend');
save([saveDir, 'peak_width_mtx'], 'peakwidth');

ID_all = {psd_all.psd.ID};
save([saveDir, 'all_IDs'], 'ID_all');

