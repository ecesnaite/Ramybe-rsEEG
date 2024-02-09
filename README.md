# RestEEGhormones
These codes were created to pre-process and analyze data described in 'The search for the relationship between female hormonal status, alpha oscillations, and aperiodic features of resting state EEG ' by Gaizauskaite et al.

EEG data underwent pre-processing using the MATLAB-based EEGLAB toolbox (version 2020.0). The codes used for pre-processing can be found in the *preprocessing* folder. Steps 2 and 3 are omitted, as artifact rejection was performed manually and ICA weights were calculated using the Darbeliai v2022.12.22.1 toolbox (https://github.com/embar-/eeglab_darbeliai/blob/master/README.txt), which employs a drop-down menu interface for operation.   

To determine the 1/f decay of the power spectral density in the resting state we used the fooof algorithm implemented in Python (details: https://fooof-tools.github.io/fooof/index.html). Additionally, custom MATLAB scripts were used for extracting individual alpha frequency and alpha power. These codes are located in the *analysis* folder. 

Statistical analysis was conducted using the R programming language. Codes for statistical analysis are located in *Statistical analysis* folder.  

The codes are grouped into folders according to the analysis stages. 

We performed additional analysis to compare our results to the ones that were previously published by a different research group. You can find more details about these analyses in the paper mentioned above.

