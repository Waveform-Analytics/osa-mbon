"""Module for preparing data for the OSA/BioSound MBON project"""

import glob
import numpy as np
import duckdb
import pandas as pd
from scipy.interpolate import interp1d
from sklearn.preprocessing import MinMaxScaler


def normalize_df(df_in, col_names):
    """Normalize requested acoustic indices
    The requested acoustic indices are normalized such that they are between -1 and 1.

    Args:
        df_in (datafraem): Pandas dataframe containing acoustic index information
        col_names (list): List of column names specifying which acoustic indices in df_in \
            should be normalized

    Returns:
        dataframe: same dataframe as df_in except that the requested columns are normalized
    """
    df_new = df_in.copy()
    for col in col_names:
        df_zero = df_in[col] - np.median(df_in[col])
        df_new[col] = df_zero/max(abs(df_zero))

    return df_new

def get_fish_presence(df_in, df_fishes, unq_codes):
    """
    Append columns for each of the unique fish codes, with a tally of how many 
    were logged at each time step

    """
    df_out = df_in.copy()
    # Time step for the current acoustic indices data table
    time_step = np.median(np.diff(df_in['datetime'])).astype('timedelta64[s]')
    for code in unq_codes:
        n_fishes = []
        is_present = []
        for _, row in df_in.iterrows():
            time_start = row['datetime']
            time_end = time_start + time_step
            overlap = df_fishes[(df_fishes["species"] == code) &
                                (df_fishes['datetime'] >= time_start) &
                                (df_fishes['datetime'] < time_end)]
            n_fishes.append(len(overlap))
            is_present.append(len(overlap) > 0)
        df_out[code + "_n"] = n_fishes
        df_out[code + "_present"] = is_present
    return df_out



if __name__ == "__main__":

    DATA_FOLDER = "shiny/shinydata/fromLiz"

    # ################################################################################## #
    # KEY WEST ANNOTATIONS
    # Set up the fish annotations table - this is specifically from key west data
    fish_file_list = glob.glob(f"{DATA_FOLDER}/**/*.txt", recursive=True)
    df_fish = pd.DataFrame()
    for file in fish_file_list:
        df = pd.read_csv(file, delimiter="\t")
        if "Begin File" in df.columns:
            df["time"] = pd.to_datetime(df['Begin File'].str[:-4], format='%Y%m%dT%H%M%S')
        elif "Begin Path" in df.columns:
            df["time"] = pd.to_datetime(df["Begin Path"].str[-19:-4], format='%Y%m%dT%H%M%S')
        df_fish = pd.concat([df_fish, df])

    # Reduce columns
    df_fish = df_fish[["time", 'Low Freq (Hz)', 'High Freq (Hz)', 'Delta Time (s)',
       'species', 'call variant', 'level']]

    # KEY WEST: Load the fish codes info file
    FISH_CODES_FILE = "shiny/shinydata/fish_codes.csv"
    df_fish_codes = pd.read_csv(FISH_CODES_FILE)
    unique_codes = np.unique(df_fish_codes['code'])

    # ################################################################################## #
    # MAY RIVER ANNOTATIONS
    MAY_RIVER_DATA_FILE = ("shiny/shinydata/fromLiz/MayRiver/Annotations/Master_Manual_14M_2h_" +
                           "011119_071619.xlsx")
    df_mayriver = pd.read_excel(MAY_RIVER_DATA_FILE, sheet_name="Data")

    # ################################################################################## #
    # ACOUSTIC INDICES FILES - COMPILATION #
    # Find the acoustic table files
    file_list = glob.glob(f"{DATA_FOLDER}/**/*.csv", recursive=True)
    acoustic_index_files = [f for f in file_list if "Acoustic_Indices" in f]

    # Loop through acoustic index files and concatenate them to build one dataframe
    df_aco = pd.DataFrame()
    for idx, file in enumerate(acoustic_index_files):
        df = pd.read_csv(file)
        df["file_id"] = idx
        df_aco = pd.concat([df_aco, df])

    df_aco_norm = normalize_df(df_aco, df_aco.columns[7:])

    # now let's find all the sub-groups based on "file_id", and then within those, 


