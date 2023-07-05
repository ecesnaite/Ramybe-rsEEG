# from contextlib import contextmanager

import os as os
from fooof import FOOOF, FOOOFGroup
import scipy.io as spio
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages




data = spio.loadmat('/home/raid3/steinfath/Desktop/Life/Test/psd_and_freq_for_FOOOF_with_passive_comp_removed_10secs.mat', squeeze_me=True)#a .mat file structure that contains all subjects (as rows) and their PSD values for each EEG channel in 'psd' structure
data_all = data['psd']

#data = spio.loadmat('/data/p_02035/Derivatives/psd_and_freq_for_FOOOF.mat', squeeze_me=True)#a .mat file structure that contains all subjects (as rows) and their PSD values for each EEG channel in 'psd' structure
#data_all = data['low_rsq_channels']

# data = spio.loadmat('/data/p_02035/Elena/play_FOOOF/psd_check_missed_alpha.mat', squeeze_me=True)#a .mat file structure that contains all subjects (as rows) and their PSD values for each EEG channel in 'psd' structure
# spectrum = data['psd_check'][1:91]

#freqs = [i for i in range(0,91)]
#freqs = np.transpose(freqs)/2

# Initialize FOOOF model
#fm = FOOOF()
#fm = FOOOF(peak_width_limits=[1, 8], max_n_peaks=6 , min_peak_height=0.15)
# Set the frequency range upon which to fit FOOOF
freq_range = [1, 40]

results = []
result =[]

# create a PdfPages object
#pdf = PdfPages('/home/raid3/steinfath/Desktop/LIFE_EEG/Slope Estimation/low_rsq_channels.pdf')

# define here the dimension of your figure
#fig = plt.figure()

subj=0
chan=0



#with suppress_stdout():
for subj in range(data_all.shape[0]):#range(data_all.shape[0]):#range(data['psd'][0][0].shape[0]):

    fm = FOOOF(peak_threshold=2.0)
    data = data_all['spect'][subj]
    name = data_all['ID'][subj]
    freqs = data_all['freq'][subj]

   # data = data_all['psd'][subj]
   # name = data_all['ID'][subj]

#    if len(data_all['psd'][subj]) == 91:
#       channels = 1
#    else:
    #channels = len(data_all['psd'][subj])

    for chan in range(data.shape[0]):

        spectrum = data[chan]

       # if len(data_all['psd'][subj]) == 91:
       #     spectrum = data
    #else:
        #    spectrum = data[chan]

        #spectrum = [val for sublist in spectrum for val in sublist]
        #spectrum = np.transpose(spectrum)
        #   for chan in range(spec_multi.shape[0]):#*

        # Run FOOOF model - calculates model, plots, and prints results
        #spectrum = spec_multi[chan] #*

        #Get Initial fit to the data
        #initial_fit = fm._simple_ap_fit(freqs, np.log10(spectrum))

        # Alternatively, just fit the model with FOOOF.fit() (without printing anything)
        fm.fit(freqs, spectrum, freq_range)
        fm.report()
        #Only Plot the Model Fit
        #plt_log = False


        #fig = plt.figure()
        #fig = fm.plot(plt_log)

       # plot1 = fm.plot(plt_log)

        # save the current figure
       # pdf.savefig(plot1)

        # destroy the current figure
        # saves memory as opposed to create a new figure
       # plt.clf()
       # plt.close(plot1)

#pdf.close()

        #fm.report()

        # Grab each model fit result with convenience method to gather all results
        ap_params, peak_params, r_squared, fit_error, gauss_params = fm.get_results()

        if r_squared < 0.8:

            fm = FOOOF(aperiodic_mode='knee')
            fm.fit(freqs, spectrum, freq_range)
            ap_params, peak_params, r_squared, fit_error, gauss_params = fm.get_results()

            # Get results actually returns a FOOOFResult object (a named tuple)
            fres = fm.get_results()

            result.append(fres)

            knee_parameter = '1'
            result.append(knee_parameter)

            result.append(fm.power_spectrum - fm._ap_fit)

            results.append(result)

            result = []

        else:

            # Get results actually returns a FOOOFResult object (a named tuple)
            fres = fm.get_results()
            result.append(fres)

            knee_parameter = '0'
            result.append(knee_parameter)

            result.append(fm.power_spectrum - fm._ap_fit)

            results.append(result)

            result = []

        results.append(name)

        #Save with scipy
        #savename = os.path.join("/data/p_02035/Elena/play_FOOOF/results_all/FOOOF_1_45Hz_knee_above_08_fixed", str(name) + ".txt")
        # #savename = os.path.join("/data/p_02035/Elena/play_FOOOF/temp")
        spio.savemat(savename, mdict={'results': results})

        #results = []
        #result.append(data['psd'][subj][2])
            #
            # savename = os.path.join("/data/p_02035/Elena/play_FOOOF/results_all/Simulated/", str(subj) + ".txt")
            # with open(savename, "wb") as fp:
            #     pickle.dump(result, fp)
            #
            #
            # # Re-load our database
            # with open(savename,'rb') as fp:
