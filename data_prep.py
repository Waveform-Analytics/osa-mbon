"""Module for preparing data for the OSA/BioSound MBON project"""

import glob

import numpy as np
import pandas as pd
import duckdb


def normalize_df(df_in, col_names):
    """Normalize requested acoustic indices
    The requested acoustic indices are normalized such that they are between -1 and 1.

    Args:
        df_in (dataframe): Pandas dataframe containing acoustic index information
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
    """Generate columns for fish/annotations presence/absence
    Append columns for each of the unique fish codes, with a tally of how many 
    were logged at each time step. 

    """
    df_out = df_in.copy()
    for code in unq_codes:
        n_fishes = []
        is_present = []
        for _, row in df_in.iterrows():
            df_this_species = df_fishes[df_fishes["species"] == code]
            overlap = df_this_species[(df_this_species["start_time"] <= row["end_time"]) &
                                      (row['start_time'] <= df_this_species["end_time"])]
            n_fishes.append(len(overlap))
            is_present.append(len(overlap) > 0)
        df_out[code + "_n"] = n_fishes
        df_out[code + "_present"] = is_present
    return df_out


if __name__ == "__main__":

    DATA_FOLDER = "shiny/shinydata/fromLiz"
    OUT_FOLDER = "shiny/shinydata/prepped_tables"

    # ################################################################################## #
    # KEY WEST ANNOTATIONS
    # Set up the fish annotations table - this is specifically from key west data
    fish_file_list = glob.glob(f"{DATA_FOLDER}/**/*.txt", recursive=True)
    df_fish = pd.DataFrame()
    for file in fish_file_list:
        df = pd.read_csv(file, delimiter="\t")
        if "Begin File" in df.columns:
            df["start_time"] = pd.to_datetime(df['Begin File'].str[:-4], format='%Y%m%dT%H%M%S')
        elif "Begin Path" in df.columns:
            df["start_time"] = pd.to_datetime(df["Begin Path"].str[-19:-4], format='%Y%m%dT%H%M%S')
        df["end_time"] = df["start_time"] + pd.to_timedelta(df["Delta Time (s)"], unit="s")
        df_fish = pd.concat([df_fish, df])

    # Reduce columns
    df_fish_keywest = df_fish[["start_time", "end_time", 'Low Freq (Hz)', 'High Freq (Hz)', 
       'species', 'call variant', 'level']]

    # KEY WEST: Load the fish codes info file
    FISH_CODES_FILE = "shiny/shinydata/fish_codes.csv"
    df_fish_codes = pd.read_csv(FISH_CODES_FILE)

    # ################################################################################## #
    # MAY RIVER ANNOTATIONS
    MAY_RIVER_DATA_FILE = ("shiny/shinydata/fromLiz/MayRiver/Annotations/Master_Manual_14M_2h_" +
                           "011119_071619.xlsx")
    df_mayriver = pd.read_excel(MAY_RIVER_DATA_FILE, sheet_name="Data")
    df_mayriver.rename(columns={"Date": "start_time"}, inplace=True)
    df_mayriver["end_time"] = df_mayriver["start_time"] + pd.to_timedelta(2, unit="h")
    
    # Arrange the mayriver dataframe so it looks more like the keywest annotations
    df_long = df_mayriver.melt(id_vars=['start_time', 'end_time'], 
                               value_vars=['Silver perch',
                                'Silver perch interruption', 'Oyster toadfish boat whistle',
                                'Oyster toadfish grunt', 'Oyster toadfish interruption', 'Black drum',
                                'Black drum interruption', 'Spotted seatrout',
                                'Spotted seatrout interruption', 'Red drum', 'Red drum interruption',
                                'Atlantic croaker', 'Weakfish', 'Fish interruption cause',
                                'Bottlenose dolphin echolocation', 'Bottlenose dolphin burst pulses',
                                'Bottlenose dolphin whistles', 'Vessel'],
                               var_name='species', value_name='is_present')
    df_final = df_long[df_long['is_present'] != 0]
    mr_codes = df_fish_codes[df_fish_codes["may_river"]==1]
    df_final["species"] = df_final["species"].map(dict(zip(mr_codes["species"], mr_codes["code"]))).copy()
    df_fish_mayriver = df_final.copy()

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
    # The date strings in "Date" column are not consistently formatted so we use "mixed"
    df_aco['start_time'] = pd.to_datetime(df_aco['Date'], format="mixed")
    # Drop duplicate rows 
    df_aco = df_aco.drop_duplicates(subset=['Date', 'Dataset', 'Sampling_Rate_kHz', 'FFT', 'Duration_sec', \
                                          'Thresholds_Hz', 'Filename', "file_id"], keep="first")

    ## Generate an "end_time" column in df_aco_norm
    # Sort by start_time and file_id
    df_aco = df_aco.sort_values(by=['file_id', 'start_time'])
    # Calculate differences within each file/dataset and convert to seconds
    df_aco['time_diff'] = df_aco.groupby(['file_id'])['start_time'].diff().dt.total_seconds()
    # Calculate the median difference for each file/dataset
    medians = df_aco.groupby('file_id')['time_diff'].median().reset_index()
    medians.columns = ['file_id', 'median_diff']
    # Merge the median differences back into the original DataFrame
    df_aco = df_aco.merge(medians, on='file_id', how='left')
    # Get the end time by adding median diff to start_time
    df_aco['end_time'] = df_aco['start_time'] + pd.to_timedelta(df_aco['median_diff'], unit='s')
    # Tidy up the dataframe
    df_aco = df_aco.drop(columns=['file_id','time_diff', 'median_diff'])

    # Normalize the indices
    df_aco_norm = normalize_df(df_aco, df_aco.columns[7:-2])

    # ################################################################################## #
    ## SAVE DATAFRAMES TO PARQUET TABLES

    df_aco.to_parquet(OUT_FOLDER + '/t_aco.parquet')
    df_aco_norm.to_parquet(OUT_FOLDER + '/t_aco_norm.parquet')

    # Sort out some type inconsistencies within columns
    df_fish_keywest_valid = df_fish_keywest.dropna().copy()
    df_fish_keywest_valid.drop("level", axis=1, inplace=True)
    # Save to parquet file
    df_fish_keywest_valid.to_parquet(OUT_FOLDER + '/t_fish_keywest.parquet')

    # Sort out some type inconsistencies within columns
    df_fish_mayriver_valid = df_fish_mayriver.dropna().copy()
    df_fish_mayriver_valid.to_parquet(OUT_FOLDER + '/t_fish_mayriver.parquet')

    # ################################################################################## #
    ## SAVE PARQUET TABLES TO DUCKDB DATABASE FILE`
    con = duckdb.connect('shiny/mbon.duckdb')
    con.execute("CREATE TABLE t_aco AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/t_aco.parquet')")
    con.execute("CREATE TABLE t_aco_norm AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/t_aco_norm.parquet')")
    con.execute("CREATE TABLE t_fish_keywest AS SELECT # FROM read_parquet('shiny/shinydata/prepped_tables/t_fish_keywest.parquet')")
    con.execute("CREATE TABLE t_fish_mayriver AS SELECT # FROM read_parquet('shiny/shinydata/prepped_tables/t_fish_keywest.parquet')")
    con.close()
