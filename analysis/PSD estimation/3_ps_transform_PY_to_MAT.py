import sys, os
import pickle
import numpy, scipy.io
#
subj = 0

data = scipy.io.loadmat('/data/p_02035/Elena/play_FOOOF/testFOOOFnew/fooof-master/tutorials/dat/psd_and_freq_for_FOOOF.mat', squeeze_me=True)

for subj in range(100):
    loadname = os.path.join("/data/p_02035/Elena/play_FOOOF/results_all/Simulated/", str(subj) + ".txt")

    savename = os.path.join("/data/p_02035/Elena/play_FOOOF/results_all/Simulated/", str(subj))

    # Re-load our database
    with open(loadname, 'rb') as fp:
        scores = pickle.load(fp)
        scipy.io.savemat(savename, mdict={'scores': scores})