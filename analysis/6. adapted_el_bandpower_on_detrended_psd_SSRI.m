% (C) Elena Cesnaite, email: e.cesnaite@gmail.com, page: https://www.researchgate.net/profile/Elena-Cesnaite

% This code was created to analyze data described in a paper:'Rhythms in the human 
% body: the search for relationships between brain oscillations and fluctuations of sex hormones' by....
% This code calculates alpha band parameters on detrended psd
% Last updated 11.07.2023

clear all, close all

psd_all=load('/Users/linagladutyte/Documents/LABES/RAMYBE/FOOF/scripts/psd_and_freq_for_FOOOF_06072023.mat') %original PSD

dataDir = '/Users/linagladutyte/Documents/LABES/RAMYBE/FOOF/params_all_subjects/'
saveDir = '/Users/linagladutyte/Documents/LABES/RAMYBE/FOOF/alpha_peaks_mat'
files= dir([dataDir,'_parameters.mat'])

f_orig = [0:0.25:45]; %original sampling frequency
fs = [3:0.25:40]; %sampling frequency based on which FOOOF estimates were made between 3 - 40 Hz



for p = 1:length(psd_all.psd)
    id = psd_all.psd(p).ID;
    original = psd_all.psd(strcmp({psd_all.psd.ID}, id));

    data = load([dataDir, strcat(id, '_parameters.mat')]); % 1 - background params (offset and exponent (slope)); 2 - peak params (central freq, ampl, bandwi); 3 - r_squared; 5 - gaussian_params

    fields = fieldnames(data.ap_params)% fieldnames in structure, e.g. cahnnel_1

    for ch = 1:length(fields) % loop through channels
        rsq = data.r_squared.(fields{ch});

        if rsq >= 0.7
            aperiodic = data.ap_params.(fields{ch});
            offset = aperiodic(1);
            slope = aperiodic(2);

            logL = offset - slope*log10(fs);
            L = 10.^logL;

            % subtract the slope from the original psd %
            detrend = original.spect(ch,f_orig>=3 & f_orig<=40) - L;

            %find peaks that exceed 0.05 uV
            [pow,ifreq,width,~,bounds] = findpeaks_adjusted_new_SSRI(detrend,fs,'MinPeakProminence',0.05,'Annotate','extents','WidthReference','halfheight');% min peak for power threshold

            any_alp = (ifreq >= 8 & ifreq <= 13);
            if any(any_alp)
                if sum(any_alp)==1 % if one alpha peak is present

                    freq = ifreq(any_alp);
                    range = bounds(any_alp,:);

                    if diff(range) > 5      %whenever the width of the peak is more than 3Hz, set it to 3
                        range = [freq-2.5, freq+2.5];
                    end

                    alpha_broad_power = sum(detrend(fs>=round(range(1),2) & fs<=round(range(2),2)))*0.25;

                    alpha_pow(ch) = double(alpha_broad_power);
                    iaf(ch) = freq;
                    slp(ch) = slope;
                    off(ch) = offset;

%                     if iaf(ch)==8 
%                         findpeaks_adjusted_new_SSRI(detrend,fs,'MinPeakProminence',0.05,'Annotate','extents','WidthReference','halfheight');% min peak for power threshold
%                         display(iaf(ch))
%                         input('8 Hz alpha', 's')
%                         close
%                     end
                    clearvars any_alp freq range alpha_broad_power pow ifreq width detrend L logL bounds aperiodic offset slope

                elseif sum(any_alp)>1 % if more than one peak in alpha range is present

                    [val alp_loc] = max(pow(any_alp)); %out of two alpha peaks which one is higher in amplitude
                    loc = find(any_alp); % find two alpha peak locations out of every peak
                    alp_loc = loc(alp_loc); %higher peak location out of every peak
                    any_alp(:) = 0; % set everything to 0 as if no alpha peak was found
                    any_alp(alp_loc) = 1; %set the maxima location of alpha peak to 1

                    freq = ifreq(any_alp);
                    range = bounds(any_alp,:);

                    if diff(range) > 5      %whenever the width of the peak is more than 3Hz, set it to 3
                        range = [freq-2.5, freq+2.5];
                    end

                    alpha_broad_power = sum(detrend(fs>=round(range(1),2) & fs<=round(range(2),2)))*0.25;

                    alpha_pow(ch) = double(alpha_broad_power);
                    iaf(ch) = freq;
                    slp(ch) = slope;
                    off(ch) = offset;

%                     if iaf(ch)==8 
%                         findpeaks_adjusted_new_SSRI(detrend,fs,'MinPeakProminence',0.05,'Annotate','extents','WidthReference','halfheight');% min peak for power threshold
%                         display(iaf(ch))
%                         input('8 Hz alpha', 's')
%                         close
%                     end
                    clearvars val alp_loc loc any_alp freq range alpha_broad_power pow ifreq width detrend L logL bounds aperiodic offset slope

                else
                    error('no peak was found')
                    alpha_pow(ch) =NaN;
                    iaf(ch) = NaN;
                    slp(ch) = slope;
                    off(ch) = offset;
                end
            else
                alpha_pow(ch) =NaN;
                iaf(ch) = NaN;
                slp(ch) = slope;
                off(ch) = offset;
            end
        else
            alpha_pow(ch) =NaN;
            iaf(ch) = NaN;
            slp(ch) = NaN;
            off(ch) = NaN;
            clearvars rsq

        end
    end

    alpha_params(p).ID = id
    alpha_params(p).power = alpha_pow
    alpha_params(p).freq = iaf
    alpha_params(p).slope= slp
    alpha_params(p).offset= off

    clearvars -except p f_orig fs files saveDir dataDir psd_all alpha_params
end

save([saveDir, 'alpha_params_findpeaks_detrend_3_40_7_13_threshold_05'], 'alpha_params')

%% create matrixes for alpha power %%

alpha_broad=struct()
alpha_broad.ID = {alpha_params.ID};

for i = 1:length(alpha_params)
    broadpow(i,:) = alpha_params(i).power;
    iaf(i,:) = alpha_params(i).freq;
    slope(i,:) = alpha_params(i).slope;
    offset(i,:) = alpha_params(i).offset;
end

save([saveDir, 'alpha_pow_mtx_05'], 'broadpow')
save([saveDir, 'alpha_freq_mtx_05'], 'iaf')
save([saveDir, 'slope_mtx_05'], 'slope')
save([saveDir, 'offset_mtx_05'], 'offset')

ID_all = {psd_all.psd.ID}
save([saveDir, 'all_IDs_174'], 'ID_all')

EEG = pop_loadset('NCF_201.set')
chan_label = {EEG.chanlocs.labels}
save([saveDir, 'channel_labels_62'], 'chan_label')

chan_loc = EEG.chanlocs
save([saveDir, 'channel_locations_62'], 'chan_loc')

%% Negative values could appeared due to a small alpha peak that is estimated under the PSD curve. Check if there are any
[row channel] = find(broadpow<0)%NONE
