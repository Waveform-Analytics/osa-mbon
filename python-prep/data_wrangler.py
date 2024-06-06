"""Module for preparing data for the OSA/BioSound MBON project"""

import glob
import os

import numpy as np
import pandas as pd
import duckdb
from pathlib import Path


def normalize_df(df_in: pd.DataFrame, col_names: list[str]) -> pd.DataFrame:
    """Normalize requested acoustic indices
    The requested acoustic indices are normalized such that they are between -1 and 1.

    Args:
        df_in: Pandas dataframe containing acoustic index information
        col_names: List of column names specifying which acoustic indices in df_in \
            should be normalized

    Returns:
        dataframe: same dataframe as df_in except that the requested columns are normalized
    """
    df_new = df_in.copy()
    for col in col_names:
        df_zero = df_in[col] - np.nanmedian(df_in[col])
        df_new[col] = df_zero / max(abs(df_zero))

    return df_new


def get_fish_presence(df_in, df_fishes, df_codes):
    """Generate columns for fish/annotations presence/absence
    Append columns for each of the unique fish codes, with a tally of how many
    were logged at each time step.
    """
    unq_codes = df_codes["code"].unique()

    df_fishes_sorted = df_fishes.sort_values("start_time").reset_index(drop=True)
    df_fishes_sorted["code"] = df_fishes_sorted["Labels"].map(dict(zip(df_codes["name"], df_codes["code"])))

    df_out = df_in.copy()
    for cidx, code in enumerate(unq_codes):
        # print("Code #" + str(cidx+1) + " of " + str(len(unq_codes)))
        df_this_species = df_fishes_sorted[df_fishes_sorted["code"] == code]

        # Convert to numpy.datetime64 for consistent comparison
        start_time_in = df_in["start_time"].values.astype('datetime64[ns]')
        end_time_in = df_in["end_time"].values.astype('datetime64[ns]')
        start_time_species = df_this_species["start_time"].values.astype('datetime64[ns]')
        end_time_species = df_this_species["end_time"].values.astype('datetime64[ns]')

        overlap_matrix = (start_time_species[:, None] <= end_time_in) & (end_time_species[:, None] >= start_time_in)
        n_fishes = overlap_matrix.sum(axis=0)
        is_present = (n_fishes > 0).astype(int)

        df_out[code + "_n"] = n_fishes
        df_out[code] = is_present

    return df_out


def prep_seascaper_data(input_file):
    """Prepare seascaper data

    Args:
        input_file: Path to seascaper file

    Returns: processed data frame

    """
    df_sea = pd.read_csv(input_file)
    df_sea["date"] = pd.to_datetime(df_sea["date"])

    return df_sea


def annotation_prep_kw_style(input_folder: str, output_file_path: str):
    """
    Combine annotation txt files into one txt fish_file. This is the Key West-style annotations data.
    The output fish_file should go with the other annotations data

    Args:
        input_folder: Path to folder containing annotation txt files
        output_file_path: Path to output csv fish_file

    Returns: None

    """
    fish_file_list = glob.glob(f"{input_folder}/**/*.txt", recursive=True)
    df_fish = pd.DataFrame()
    for fish_file in fish_file_list:
        df = pd.read_csv(fish_file, delimiter="\t")
        if "Begin File" in df.columns:
            df["start_time"] = pd.to_datetime(df['Begin File'].str[:-4], format='%Y%m%dT%H%M%S')
        elif "Begin Path" in df.columns:
            df["start_time"] = pd.to_datetime(df["Begin Path"].str[-19:-4], format='%Y%m%dT%H%M%S')
        df["end_time"] = df["start_time"] + pd.to_timedelta(df["Delta Time (s)"], unit="s")
        df_fish = pd.concat([df_fish, df])

    # Reduce columns
    df_fish_keywest = df_fish[["start_time", "end_time", 'Low Freq (Hz)', 'High Freq (Hz)',
                               'species', 'call variant', 'level']]

    # Rename columns
    df_fish_keywest.columns = ["start_time", "end_time", 'Low Freq (Hz)', 'High Freq (Hz)',
                               'Labels', 'call variant', 'level']

    df_fish_keywest.to_csv(output_file_path, index=False)


def annotation_prep_mr_style(file_name: str, output_file_path: str, df_codes: pd.DataFrame) -> None:
    """
    Extract the data sheet from the May River-style main annotations file.
    Args:
        file_name: Path and file name of the May River main annotations file (xlsx file)
        output_file_path: Path and file name of the desired output annotations file
        df_codes: dataframe summarizing all the possible annotation codes

    Returns:
        None

    """
    df_mayriver = pd.read_excel(file_name, sheet_name="Data")
    df_mayriver.rename(columns={"Date": "start_time"}, inplace=True)
    df_mayriver["end_time"] = df_mayriver["start_time"] + pd.to_timedelta(2, unit="h")

    # Arrange the mayriver dataframe, so it looks more like the keywest annotations
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
    df_final = df_long[df_long['is_present'] != 0].copy()
    mr_codes = df_codes[df_codes["Dataset"] == "May River"]
    df_final["species"] = df_final["species"].map(dict(zip(mr_codes["name"], mr_codes["code"]))).copy()
    df_final.dropna(subset=["species"], inplace=True)

    # Rename columns using rename method
    df_final = df_final.rename(columns={'species': 'Labels'})

    df_final.to_csv(output_file_path, index=False)


def prep_index_data(input_folder: str, normalize: bool= False) -> pd.DataFrame:
    """
    Load index data files, combine into one big dataframe, and

    Args:
        input_folder:
        normalize: Normalize the index values for each index

    Returns:
        dataframe: Dataframe containing index data

    """
    file_list = glob.glob(f"{input_folder}/*.csv")
    acoustic_index_files = [f for f in file_list if "Acoustic_Indices" in f]

    # Loop through acoustic index files and concatenate them to build one dataframe
    df_aco = pd.DataFrame()
    for idx, file in enumerate(acoustic_index_files):
        df = pd.read_csv(file)
        df["file_id"] = idx
        df_aco = pd.concat([df_aco, df])
        # for debugging:
        # print("Dataset: " + np.unique(df["Dataset"]) + ", file: " + os.path.basename(file))
    # The date strings in "Date" column are not consistently formatted, so we use "mixed"
    df_aco['start_time'] = pd.to_datetime(df_aco['Date'], format="mixed")
    # Drop duplicate rows
    df_aco = df_aco.drop_duplicates(subset=['Date', 'Dataset', 'Sampling_Rate_kHz', 'FFT', 'Duration_sec',
                                            'Thresholds_Hz', 'Filename', "file_id"], keep="first")

    # Generate an "end_time" column in df_aco_norm
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
    df_aco = df_aco.drop(columns=['file_id', 'time_diff', 'median_diff'])

    # Fix: Correct typo
    df_aco['Dataset'] = df_aco['Dataset'].replace('Caser Creek', 'Caesar Creek')

    if normalize:
        return normalize_df(df_aco, df_aco.columns[7:-2])
    else:
        return df_aco


def add_new_columns(df_in: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    """
    Add new columns to a dataframe. The original dataframe is edited.
    Args:
        df_in: input dataframe
        columns: list of column names

    Returns:
        dataframe: edited dataframe

    """
    # First check if any of the requested columns already exists in the dataframe
    current_columns = df_in.columns
    # Add more columns appended with "_n" for counts
    columns_extend = [item + "_n" for item in columns]
    extra_columns = columns + columns_extend

    new_columns = [item for item in extra_columns if item not in current_columns]

    df_temp = pd.DataFrame(columns=new_columns)
    return pd.concat([df_in, df_temp], axis=1)


def fix_time_column_naming(df_in: pd.DataFrame) -> pd.DataFrame:
    """
    Sometimes time columns in the annotations dataframes don't follow the required naming format.
    Fixing that here.
    Args:
        df_in: input dataframe

    Returns:
        dataframe: dataframe with fixed time column names

    """
    if "Start_Date_Time" in df_in.columns:
        df_in.rename(columns={"Start_Date_Time": "start_time"}, inplace=True)
    if "ISOStartTime" in df_in.columns:
        df_in.rename(columns={"ISOStartTime": "start_time"}, inplace=True)
    if "End_Date_Time" in df_in.columns:
        df_in.rename(columns={"End_Date_Time": "end_time"}, inplace=True)
    if "ISOEndTime" in df_in.columns:
        df_in.rename(columns={"ISOEndTime": "end_time"}, inplace=True)

    return df_in


def add_annotations_to_df(df_in: pd.DataFrame, df_config: pd.DataFrame,
                          df_codes: pd.DataFrame, anno_folder: str) -> pd.DataFrame:
    """
    Fill in the annotations columns of an acoustic indices dataframe.
    Args:
        df_in: Acoustic index dataframe with extra index columns to be filled (might be better to add cols as needed)
        df_config: Config file that includes paths to the annotations files
        df_codes: Codes file that includes the full list of possible codes for all datasets
        anno_folder: Folder where the annotations files are located

    Returns:
        dataframe:

    """
    # Create a new empty dataframe with the same columns as df_in
    df_new = pd.DataFrame(columns=df_in.columns)

    # Loop through each of the datasets and add annotations if applicable
    unique_locations = np.unique(df_in["Dataset"])

    for location in unique_locations:
        # Get the index subset for this location
        df_sub = df_in[df_in["Dataset"] == location]

        # Get the appropriate annotations file
        anno_file = df_config[df_config["Dataset"]==location]["Annotations File"].iloc[0]
        if anno_file is not np.nan:
            anno_file_full_path = os.path.join(anno_folder, anno_file)
            # Load the annotations file
            df_anno0 = pd.read_csv(anno_file_full_path)
            # Fix the column names
            df_anno = fix_time_column_naming(df_anno0)
            # Add presence info
            df_sub_with_presence = get_fish_presence(df_sub, df_anno, df_codes)
            # Exclude columns with all NAs
            df_sub_with_presence.dropna(axis=1, how='all')
            # Append the new subset onto the new dataframe
            df_new = pd.concat([df_new, df_sub_with_presence], axis=1)

    return df_new



if __name__ == "__main__":

    DATA_FOLDER = "../shiny/shinydata/fromLiz"
    OUT_FOLDER = "../shiny/shinydata/prepped_tables"

    # ###
    # Data Summary File
    SUMMARY_FILE = "../shiny/data/BioSound_Datasets.csv"
    df_summary = pd.read_csv(SUMMARY_FILE)
    # ################################################################################## #
    # KEY WEST ANNOTATIONS
    # Set up the fish annotations table - this is specifically from key west data
    # fish_file_list = glob.glob(f"{DATA_FOLDER}/**/*.txt", recursive=True)
    # df_fish = pd.DataFrame()
    # for file in fish_file_list:
    #     df = pd.read_csv(file, delimiter="\t")
    #     if "Begin File" in df.columns:
    #         df["start_time"] = pd.to_datetime(df['Begin File'].str[:-4], format='%Y%m%dT%H%M%S')
    #     elif "Begin Path" in df.columns:
    #         df["start_time"] = pd.to_datetime(df["Begin Path"].str[-19:-4], format='%Y%m%dT%H%M%S')
    #     df["end_time"] = df["start_time"] + pd.to_timedelta(df["Delta Time (s)"], unit="s")
    #     df_fish = pd.concat([df_fish, df])
    #
    # # Reduce columns
    # df_fish_keywest = df_fish[["start_time", "end_time", 'Low Freq (Hz)', 'High Freq (Hz)',
    #                            'species', 'call variant', 'level']]

    # KEY WEST: Load the fish codes info file
    FISH_CODES_FILE = "../shiny/data/fish_codes.csv"
    df_fish_codes = pd.read_csv(FISH_CODES_FILE)

    # ################################################################################## #
    # MAY RIVER ANNOTATIONS
    MAY_RIVER_DATA_FILE = ("../shiny/shinydata/fromLiz/MayRiver_SC/Annotations/Master_Manual_14M_2h_" +
                           "011119_071619.xlsx")
    # df_mayriver = pd.read_excel(MAY_RIVER_DATA_FILE, sheet_name="Data")
    # df_mayriver.rename(columns={"Date": "start_time"}, inplace=True)
    # df_mayriver["end_time"] = df_mayriver["start_time"] + pd.to_timedelta(2, unit="h")
    #
    # # Arrange the mayriver dataframe, so it looks more like the keywest annotations
    # df_long = df_mayriver.melt(id_vars=['start_time', 'end_time'],
    #                            value_vars=['Silver perch',
    #                                        'Silver perch interruption', 'Oyster toadfish boat whistle',
    #                                        'Oyster toadfish grunt', 'Oyster toadfish interruption', 'Black drum',
    #                                        'Black drum interruption', 'Spotted seatrout',
    #                                        'Spotted seatrout interruption', 'Red drum', 'Red drum interruption',
    #                                        'Atlantic croaker', 'Weakfish', 'Fish interruption cause',
    #                                        'Bottlenose dolphin echolocation', 'Bottlenose dolphin burst pulses',
    #                                        'Bottlenose dolphin whistles', 'Vessel'],
    #                            var_name='species', value_name='is_present')
    # df_final = df_long[df_long['is_present'] != 0].copy()
    # mr_codes = df_fish_codes[df_fish_codes["Dataset"] == "May River"]
    # df_final["species"] = df_final["species"].map(dict(zip(mr_codes["species"], mr_codes["code"]))).copy()
    # df_fish_mayriver = df_final.copy()

    # ################################################################################## #
    # GRAY'S REEF ANNOTATIONS (VESSELS)
    GRAYS_REEF_DATA_FILE = ("../shiny/shinydata/fromLiz/GraysReef_GR01/sanctsound_products_detections_"
                            "gr01_sanctsound_gr01_01_ships_data_SanctSound_GR01_01_ships.csv")
    df_ships_grays = pd.read_csv(GRAYS_REEF_DATA_FILE)
    df_ships_grays.columns = ["start_time", "end_time", "type"]
    df_ships_grays["start_time"] = pd.to_datetime(df_ships_grays["start_time"])
    df_ships_grays["end_time"] = pd.to_datetime(df_ships_grays["end_time"])

    # ################################################################################## #
    # ACOUSTIC INDICES FILES - COMPILATION #
    # # Find the acoustic table files
    # file_list = glob.glob(f"{DATA_FOLDER}/**/*.csv", recursive=True)
    # acoustic_index_files = [f for f in file_list if "Acoustic_Indices" in f]
    #
    # # Loop through acoustic index files and concatenate them to build one dataframe
    # df_aco = pd.DataFrame()
    # for idx, file in enumerate(acoustic_index_files):
    #     df = pd.read_csv(file)
    #     df["file_id"] = idx
    #     df_aco = pd.concat([df_aco, df])
    # # The date strings in "Date" column are not consistently formatted, so we use "mixed"
    # df_aco['start_time'] = pd.to_datetime(df_aco['Date'], format="mixed")
    # # Drop duplicate rows
    # df_aco = df_aco.drop_duplicates(subset=['Date', 'Dataset', 'Sampling_Rate_kHz', 'FFT', 'Duration_sec',
    #                                         'Thresholds_Hz', 'Filename', "file_id"], keep="first")
    #
    # # # Generate an "end_time" column in df_aco_norm
    # # Sort by start_time and file_id
    # df_aco = df_aco.sort_values(by=['file_id', 'start_time'])
    # # Calculate differences within each file/dataset and convert to seconds
    # df_aco['time_diff'] = df_aco.groupby(['file_id'])['start_time'].diff().dt.total_seconds()
    # # Calculate the median difference for each file/dataset
    # medians = df_aco.groupby('file_id')['time_diff'].median().reset_index()
    # medians.columns = ['file_id', 'median_diff']
    # # Merge the median differences back into the original DataFrame
    # df_aco = df_aco.merge(medians, on='file_id', how='left')
    # # Get the end time by adding median diff to start_time
    # df_aco['end_time'] = df_aco['start_time'] + pd.to_timedelta(df_aco['median_diff'], unit='s')
    # # Tidy up the dataframe
    # df_aco = df_aco.drop(columns=['file_id', 'time_diff', 'median_diff'])
    #
    # # Fix: Correct typo
    # df_aco['Dataset'] = df_aco['Dataset'].replace('Caser Creek', 'Caesar Creek')
    #
    # # Normalize the indices
    # df_aco_norm = normalize_df(df_aco, df_aco.columns[7:-2])

    # ################################################################################## #
    # SATELLITE WATER CLASS DATA
    SEASCAPER_FOLDER = Path("../shiny/shinydata/fromLiz/All_SeascapeR")
    seascaper_files = list(SEASCAPER_FOLDER.glob("*.csv"))

    s_list = []
    for s_file in seascaper_files:
        df_temp = pd.read_csv(s_file)
        df_temp["date"] = pd.to_datetime(df_temp["date"])
        this_dataset = df_summary[df_summary["Seascaper File"] == s_file.name]["short name"].values[0]
        print(s_file)
        print(this_dataset)
        df_temp["Dataset"] = this_dataset
        s_list.append(df_temp)

    df_seascaper = pd.concat(s_list)

    # ################################################################################## #
    # # SAVE DATAFRAMES TO PARQUET TABLES
    df_aco_valid = df_aco.dropna()
    df_aco_valid.to_parquet(OUT_FOLDER + '/t_aco.parquet')

    df_aco_norm_valid = df_aco_norm.dropna()
    df_aco_norm_valid.to_parquet(OUT_FOLDER + '/t_aco_norm.parquet')

    # Sort out some type inconsistencies within columns
    df_fish_keywest_valid = df_fish_keywest.dropna().copy()
    df_fish_keywest_valid.drop("level", axis=1, inplace=True)
    # Save to parquet file
    df_fish_keywest_valid.to_parquet(OUT_FOLDER + '/t_fish_keywest.parquet')

    # Sort out some type inconsistencies within columns
    df_fish_mayriver_valid = df_fish_mayriver.dropna().copy()
    df_fish_mayriver_valid.to_parquet(OUT_FOLDER + '/t_fish_mayriver.parquet')

    # Grays Reef ship data
    df_ships_grays_valid = df_ships_grays.dropna().copy()
    df_ships_grays_valid.to_parquet(OUT_FOLDER + "/t_ships_grays.parquet")

    # Seascaper
    df_seascaper.to_parquet(OUT_FOLDER + "/t_seascaper.parquet")

    # ################################################################################## #
    # SAVE PARQUET TABLES TO DUCKDB DATABASE FILE`
    DB_FILE = '../shiny/data/mbon.duckdb'
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)

    con = duckdb.connect(DB_FILE)
    con.execute("CREATE TABLE t_aco AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/t_aco.parquet')")
    con.execute("CREATE TABLE t_aco_norm AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/"
                "t_aco_norm.parquet')")
    con.execute("CREATE TABLE t_fish_keywest AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/"
                "t_fish_keywest.parquet')")
    con.execute("CREATE TABLE t_fish_mayriver AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/"
                "t_fish_mayriver.parquet')")
    con.execute("CREATE TABLE t_ships_grays AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/"
                "t_ships_grays.parquet')")
    con.execute("CREATE TABLE t_seascaper AS SELECT * FROM read_parquet('shiny/shinydata/prepped_tables/"
                "t_seascaper.parquet')")
    con.close()
