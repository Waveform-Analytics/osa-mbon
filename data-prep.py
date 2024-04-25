import glob
import numpy as np
import duckdb
import pandas as pd
import pandas as pd
from scipy.interpolate import interp1d
from sklearn.preprocessing import MinMaxScaler


def normalize_df(df_in, col_names):
    """
    Normalize the requested columns in the provided dataframe, and return a normalized version of the dataframe
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
        fishes = []
        for idx, row in df_in.iterrows():
            time_start = row['datetime']
            time_end = time_start + time_step
            overlap = df_fishes[(df_fishes["species"] == code) & (df_fishes['datetime'] >= time_start) & (df_fishes['datetime'] < time_end)]
            fishes.append(len(overlap))
        df_out[code] = fishes
    return df_out



if __name__ == "__main__":

    data_folder = "shiny/shinydata/fromLiz"

    # Set up the fish annotations table - this is specifically from key west data
    fish_file_list = glob.glob(f"{data_folder}/**/*.txt", recursive=True)
    df_fish = pd.DataFrame()
    for file in fish_file_list:
        df = pd.read_csv(file, delimiter="\t")
        print(df.columns)
        if ("Begin File" in df.columns): 
            df["time"] = pd.to_datetime(df['Begin File'].str[:-4], format='%Y%m%dT%H%M%S')
        elif ("Begin Path" in df.columns):
            df["time"] = pd.to_datetime(df["Begin Path"].str[-19:-4], format='%Y%m%dT%H%M%S')
        df_fish = pd.concat([df_fish, df])
    # Reduce columns
    df_fish = df_fish[["time", 'Low Freq (Hz)', 'High Freq (Hz)', 'Delta Time (s)',
       'species', 'call variant', 'level']]



    # Find the acoustic table files
    file_list = glob.glob(f"{data_folder}/**/*.csv", recursive=True)
    acoustic_index_files = [f for f in file_list if "Acoustic_Indices" in f]

   


