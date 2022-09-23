import pickle
from os.path import exists
import mne
import numpy as np
from mne import create_info

class AuxFuncs:
    def __init__(self, import_path):
        ## import epochs data and meta-data
        with open(import_path, 'rb') as file:
            [allEvents_df, allEpochs_perCond, cfg] = pickle.load(file)

        self.allEpochs_perCond = allEpochs_perCond
        self.allEvents_df = allEvents_df
        self.cfg = cfg
        self.info,self.montage = self.get_subject_info()

        self.max_freq =cfg['sample_freq']/2 # for tfr
        self.times = cfg['times']
        self.time0_i = np.where(self.times==0)[0][0]
        self.hz_y = np.fft.rfftfreq(len(self.times[self.time0_i:]), 1.0/cfg['sample_freq'])


    def get_subject_info(self, example_subject = '32'):
            subject_setfile_wake_n = f'{self.cfg["set_files_dir"]}\s_{example_subject}_wake_night_referenced.set'
            output_file_path = f"{self.cfg['outputs_dir_path'] }/epochs_Wn_s{example_subject}_file"

            if exists(output_file_path):
                with open(output_file_path, 'rb') as config_dictionary_file:
                    epochs_Wn_example_sub = pickle.load(config_dictionary_file)
                    #print(epochs_Wn_example_sub)
            else:
                epochs_Wn_example_sub = mne.io.read_epochs_eeglab(subject_setfile_wake_n, events=None, event_id=None,eog=(),verbose=None, uint16_codec=None)
                with open(output_file_path, 'wb') as epochs_Wn_s_example_file:
                    pickle.dump(epochs_Wn_example_sub, epochs_Wn_s_example_file)

            montage = mne.channels.make_standard_montage('GSN-HydroCel-128')
            epochs_Wn_example_sub_piked = epochs_Wn_example_sub.pick_channels(self.cfg['ch_names'])
            epochs_Wn_example_sub_monatged = epochs_Wn_example_sub_piked.set_montage(montage)
            epochs_info = epochs_Wn_example_sub_monatged.info
            return epochs_info, epochs_Wn_example_sub_monatged

    def getEpochsPerCond(self,cond_df,dataset):
        df_minTrials = cond_df[(cond_df.SamplesCount > 0)] # discard cond with 0 enough samples
        keys = (str(key) for key in df_minTrials.Cond_id)
        epochs_allSamples = {str_key: dataset[str_key] for str_key in keys}
        return df_minTrials, epochs_allSamples

    # output: [#conds, #elect, #times]
    def getEvokedPerCondAndElectd(self, constraints,dataset, y_ax,outputType='array', tmin=-0.1, baseline=(None, 0)):
        curr_df = self.allEvents_df.copy()
        # apply constraints
        for key in constraints: curr_df = curr_df[(curr_df[key] == constraints[key])]

        conds_df, epochsPerCond = self.getEpochsPerCond(curr_df,dataset)
        evoked_perCond_andElectd = np.zeros((len(epochsPerCond),np.size(self.cfg['electrodes']),np.size(y_ax)))

        for cond_i, cond in enumerate(epochsPerCond):
            evoked_perCond_andElectd[cond_i] = np.squeeze(np.nanmean(epochsPerCond[cond], axis=2))

        if outputType =='array':
            return conds_df, evoked_perCond_andElectd
        if outputType =='mne':
            print('new')
            mne_epochs = mne.EpochsArray(evoked_perCond_andElectd, self.info, tmin=tmin, baseline=baseline)
            return conds_df, mne_epochs
#%%
