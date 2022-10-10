import copy
import pickle
from os.path import exists

import mne
import numpy as np


class AuxFuncs:
    def __init__(self, import_path):
        # import epochs data and meta-data
        with open(import_path, "rb") as file:
            [allEvents_df, allEpochs_condIdDict, configu] = pickle.load(file)

        self.allEpochs_condIdDict = allEpochs_condIdDict
        self.allEvents_df = allEvents_df
        self.config = configu
        self.info, self.montage = self.get_subject_info()

    def get_subject_info(self, example_subject="32"):
        subject_setfile_wake_n = f'{self.config["set_files_dir"]}\\s_{example_subject}_wake_night_referenced.set'
        output_file_path = (
            f"{self.config['outputs_dir_path'] }/epochs_Wn_s{example_subject}_file"
        )

        if exists(output_file_path):
            with open(output_file_path, "rb") as config_dictionary_file:
                epochs_Wn_example_sub = pickle.load(config_dictionary_file)
                # print(epochs_Wn_example_sub)
        else:
            epochs_Wn_example_sub = mne.io.read_epochs_eeglab(
                subject_setfile_wake_n,
                events=None,
                event_id=None,
                eog=(),
                verbose=None,
                uint16_codec=None,
            )
            with open(output_file_path, "wb") as epochs_Wn_s_example_file:
                pickle.dump(epochs_Wn_example_sub, epochs_Wn_s_example_file)

        montage = mne.channels.make_standard_montage("GSN-HydroCel-128")
        epochs_Wn_example_sub_piked = epochs_Wn_example_sub.pick_channels(
            self.config["ch_names"]
        )
        epochs_Wn_example_sub_monatged = epochs_Wn_example_sub_piked.set_montage(
            montage
        )
        epochs_info = epochs_Wn_example_sub_monatged.info
        return epochs_info, epochs_Wn_example_sub_monatged

    def getEpochsPerCond(self, cond_df, y_ax, dataset, outputType="dict"):
        df_minTrials = copy.deepcopy(cond_df)
        df_minTrials = df_minTrials[
            (df_minTrials.SamplesCount > 0)
        ]  # discard cond with 0 enough samples
        keys = (str(key) for key in df_minTrials.Cond_id)
        epochs_allSamples = {str_key: dataset[str_key] for str_key in keys}
        if outputType == "array":
            epochs_allSamples_arr = np.zeros(
                (len(self.config["electrodes"]), len(y_ax), 0)
            )
            for epoch_key in epochs_allSamples:
                epochs_allSamples_arr = np.concatenate(
                    (epochs_allSamples_arr, epochs_allSamples[epoch_key]), axis=2
                )
            return df_minTrials, epochs_allSamples_arr
        return df_minTrials, epochs_allSamples

    # output: [#epochs, #elect, #times]
    def getEpochsPerConstraint(self, constraints):
        curr_df = self.allEvents_df.copy(deep=True)
        # apply constraints
        for key in constraints:
            curr_df = curr_df[(curr_df[key] == constraints[key])]

        curr_df = curr_df[
            (curr_df.SamplesCount > 0)
        ]  # discard cond with 0 enough samples
        epochsPerCond = {}
        for key in curr_df.Cond_id:
            epochsPerCond[str(key)] = self.allEpochs_condIdDict[str(key)]

        # load the metadata first and them the data. More time efficient
        epochs_name_in_const = []
        epochs_trial_num_per_cond = []
        for cond in epochsPerCond:
            for curr_cond_trial in range(epochsPerCond[cond].shape[2]):
                if len(epochs_name_in_const) == 0:
                    epochs_name_in_const = [cond]
                    epochs_trial_num_per_cond = [curr_cond_trial]
                else:
                    epochs_name_in_const = np.append(epochs_name_in_const, cond)
                    epochs_trial_num_per_cond = np.append(
                        epochs_trial_num_per_cond, curr_cond_trial
                    )

        epochs_in_const = np.zeros(
            (
                len(epochs_name_in_const),
                len(self.config["electrodes"]),
                len(self.config["times"]),
            )
        )
        trial = 0
        for cond in epochsPerCond:
            for curr_cond_trial in range(epochsPerCond[cond].shape[2]):
                epochs_in_const[trial, :, :] = epochsPerCond[cond][
                    :, :, curr_cond_trial
                ]
                trial += 1

        return epochs_in_const, epochs_name_in_const, epochs_trial_num_per_cond

    # output: [#conds, #elect, #times]
    def getEvokedPerCondAndElectd(
        self,
        constraints,
        df,
        dataset,
        y_ax,
        outputType="array",
        tmin=-0.1,
        baseline=(None, 0),
    ):
        curr_df = copy.deepcopy(df)
        # apply constraints
        for key in constraints:
            curr_df = curr_df[curr_df[key] == constraints[key]]

        conds_df, epochsPerCond = self.getEpochsPerCond(curr_df, y_ax, dataset)
        evoked_perCond_andElectd = np.zeros(
            (len(epochsPerCond), np.size(self.config["electrodes"]), np.size(y_ax))
        )

        for cond_i, cond in enumerate(epochsPerCond):
            evoked_perCond_andElectd[cond_i] = np.squeeze(
                np.nanmean(epochsPerCond[cond], axis=2)
            )

        if outputType == "array":
            return conds_df, evoked_perCond_andElectd
        if outputType == "mne":
            mne_epochs = mne.EpochsArray(
                evoked_perCond_andElectd, self.info, tmin=tmin, baseline=baseline
            )
            return conds_df, mne_epochs


# def init(import_path) -> ImportedData:
#     with open(import_path, "rb") as file:
#         [allEvents_df, allEpochs_perCond, cfg] = pickle.load(file)

#     return ImportedData(cfg, allEpochs_perCond, allEvents_df)


# def get_subject_info(data: ImportedData, example_subject="32"):
#     subject_setfile_wake_n = (
#         f'{data.cfg["set_files_dir"]}\\s_{example_subject}_wake_night_referenced.set'
#     )
#     output_file_path = (
#         f"{data.cfg['outputs_dir_path'] }/epochs_Wn_s{example_subject}_file"
#     )

#     if exists(output_file_path):
#         with open(output_file_path, "rb") as config_dictionary_file:
#             epochs_Wn_example_sub = pickle.load(config_dictionary_file)
#             # print(epochs_Wn_example_sub)
#     else:
#         epochs_Wn_example_sub = mne.io.read_epochs_eeglab(
#             subject_setfile_wake_n,
#             events=None,
#             event_id=None,
#             eog=(),
#             verbose=None,
#             uint16_codec=None,
#         )
#         with open(output_file_path, "wb") as epochs_Wn_s_example_file:
#             pickle.dump(epochs_Wn_example_sub, epochs_Wn_s_example_file)

#     montage = mne.channels.make_standard_montage("GSN-HydroCel-128")
#     epochs_Wn_example_sub_piked = epochs_Wn_example_sub.pick_channels(
#         data.cfg["ch_names"]
#     )
#     epochs_Wn_example_sub_monatged = epochs_Wn_example_sub_piked.set_montage(montage)
#     epochs_info = epochs_Wn_example_sub_monatged.info
#     return epochs_info, epochs_Wn_example_sub_monatged


# def getEpochsPerCond(data: ImportedData, y_ax, outputType="dict") -> tuple[pd.DataFrame, dict]:
#     df_minTrials = data.events_df[
#         (data.events_df.SamplesCount > 0)  # type: ignore
#     ]  # discard cond with 0 enough samples
#     keys = (str(key) for key in df_minTrials.Cond_id)
#     epochs_allSamples = {str_key: data.epochs[str_key] for str_key in keys}
#     if outputType == "array":
#         epochs_allSamples_arr = np.zeros((len(data.cfg["electrodes"]), len(y_ax), 0))
#         for epoch_key in epochs_allSamples:
#             epochs_allSamples_arr = np.concatenate(
#                 (epochs_allSamples_arr, epochs_allSamples[epoch_key]), axis=2
#             )
#         return df_minTrials, epochs_allSamples_arr
#     return df_minTrials, epochs_allSamples


# # output: [#conds, #elect, #times]
# def getEvokedPerCondAndElectd(
#     data: ImportedData,
#     constraints,
#     y_ax,
#     outputType="array",
#     tmin=-0.1,
#     baseline=(None, 0),
#     info=None,  # add info if outputType=mne
# ):
#     curr_df = copy.deepcopy(data.events_df)
#     # apply constraints
#     for key in constraints:
#         curr_df = curr_df[curr_df[key] == constraints[key]]

#     conds_df, epochsPerCond = getEpochsPerCond(
#         ImportedData(data.cfg, data.epochs, curr_df), y_ax
#     )
#     evoked_perCond_andElectd = np.zeros(
#         (len(epochsPerCond), np.size(data.cfg["electrodes"]), np.size(y_ax))
#     )

#     for cond_i, cond in enumerate(epochsPerCond):
#         evoked_perCond_andElectd[cond_i] = np.squeeze(
#             np.nanmean(epochsPerCond[cond], axis=2)
#         )

#     if outputType == "array":
#         return conds_df, evoked_perCond_andElectd
#     if outputType == "mne":
#         mne_epochs = mne.EpochsArray(
#             evoked_perCond_andElectd, info, tmin=tmin, baseline=baseline
#         )
#         return conds_df, mne_epochs
