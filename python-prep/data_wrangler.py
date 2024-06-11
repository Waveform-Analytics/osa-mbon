"""Module for preparing data for the OSA/BioSound MBON project"""

import glob
import os
import numpy as np
import duckdb
import pandas as pd
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

    if (df_in["Dataset"].iloc[0] == "Key West, FL") | (df_in["Dataset"].iloc[0] == "May River, SC"):
        df_fishes_sorted["code"] = df_fishes_sorted["Labels"]
    else:
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


def annotation_prep_kw_style(input_folder: str, output_file_path: str) -> pd.DataFrame:
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

    # # Convert to strings so that it can be read into R later
    # df_fish_keywest['start_time'] = df_fish_keywest['start_time'].dt.strftime('%Y-%m-%d %H:%M:%S')
    # df_fish_keywest['end_time'] = df_fish_keywest['end_time'].dt.strftime('%Y-%m-%d %H:%M:%S')

    # Rename columns
    df_fish_keywest = df_fish_keywest.rename(columns={'species': 'Labels'})

    df_fish_keywest.to_csv(output_file_path, index=False)

    return df_fish_keywest


def annotation_prep_mr_style(file_name: str, output_file_path: str, df_codes: pd.DataFrame) -> pd.DataFrame:
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
    mr_codes = df_codes[df_codes["Dataset"] == "May River, SC"]
    df_final["species"] = df_final["species"].map(dict(zip(mr_codes["name"], mr_codes["code"]))).copy()
    df_final.dropna(subset=["species"], inplace=True)

    # Rename columns using rename method
    df_final = df_final.rename(columns={'species': 'Labels'})

    # # Convert to strings so that it can be read into R later
    # df_final['start_time'] = df_final['start_time'].dt.strftime('%Y-%m-%d %H:%M:%S')
    # df_final['end_time'] = df_final['end_time'].dt.strftime('%Y-%m-%d %H:%M:%S')

    df_final.to_csv(output_file_path, index=False)

    return df_final


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

    # Convert to pandas datetime
    df_aco['start_time'] = pd.to_datetime(df_aco['Date'])
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

    # # Convert to strings so that it can be read into R later
    # df_aco['start_time'] = df_aco['start_time'].dt.strftime('%Y-%m-%d %H:%M:%S')
    # df_aco['end_time'] = df_aco['end_time'].dt.strftime('%Y-%m-%d %H:%M:%S')

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
            df_sub_with_presence.dropna(axis=0, how='all')
            # Append the new subset onto the new dataframe
            df_new = pd.concat([df_new, df_sub_with_presence], axis=0)
        else:
            df_new = pd.concat([df_new, df_sub], axis=0)

    return df_new


def prep_seascaper_data(data_folder: str, df_config: pd.DataFrame) -> pd.DataFrame:
    """
    Load the seascaper data files and combine into a dataframe
    Args:
        data_folder: path to the seascaper data folder

    Returns:
        dataframe: Pandas dataframe containing seascaper data

    """
    seascaper_folder = Path(data_folder)
    seascaper_files = list(seascaper_folder.glob("*.csv"))

    s_list = []
    for s_file in seascaper_files:
        df_temp = pd.read_csv(s_file)
        df_temp["date"] = pd.to_datetime(df_temp["date"])
        this_dataset = df_config[df_config["Seascaper File"] == s_file.name]["short name"].values[0]
        df_temp["Dataset"] = this_dataset
        s_list.append(df_temp)

    return pd.concat(s_list)


# def update_time_zone(df_in: pd.DataFrame, df_config: pd.DataFrame) -> pd.DataFrame:
#     """
#     Convert start_time and end_time columns to local time using the df_config time zone information
#
#     Args:
#         df_in: dataframe that contains start_time and end_time columns that are in pandas datetime format
#         df_config: config file with columns for time zones: "tz in file" and "tz local"
#
#     Returns:
#         dataframe: dataframe with updated time zones for start_time and end_time columns
#
#     """
#     df_in["tz_file"] = df_in["Dataset"].map(dict(zip(df_config["Dataset"], df_config["tz in file"])))
#     df_in["tz_local"] = df_in["Dataset"].map(dict(zip(df_config["Dataset"], df_config["tz local"])))
#
#     # Set the time zone to the zone specified in the tz_file column and then convert to local time using tz_local
#     df_in["start_time"] = df_in.apply(
#         lambda row: row['start_time'].tz_localize(row['tz_file'],
#                                                   nonexistent='shift_forward').tz_convert(row['tz_local']), axis=1)
#     df_in["end_time"] = df_in.apply(
#         lambda row: row['end_time'].tz_localize(row['tz_file'],
#                                                   nonexistent='shift_forward').tz_convert(row['tz_local']), axis=1)
#
#     return df_in

def update_time_zone(df_in: pd.DataFrame, df_config: pd.DataFrame) -> pd.DataFrame:
    """
    Convert start_time and end_time columns to local time using the df_config time zone information

    Args:
        df_in: dataframe that contains start_time and end_time columns that are in pandas datetime format
        df_config: config file with columns for time zones: "tz in file" and "tz local"

    Returns:
        dataframe: dataframe with updated time zones for start_time and end_time columns

    """
    df_in["tz_file"] = df_in["Dataset"].map(dict(zip(df_config["Dataset"], df_config["tz in file"])))
    df_in["tz_local"] = df_in["Dataset"].map(dict(zip(df_config["Dataset"], df_config["tz local"])))

    # Set the time zone to the zone specified in the tz_file column and then convert to local time using tz_local
    df_in["start_time"] = df_in.apply(
        lambda row: row['start_time'].tz_localize(row['tz_file'], nonexistent='shift_forward')
                                        .tz_convert(row['tz_local']).tz_localize(None), axis=1)
    df_in["end_time"] = df_in.apply(
        lambda row: row['end_time'].tz_localize(row['tz_file'], nonexistent='shift_forward')
                                        .tz_convert(row['tz_local']).tz_localize(None), axis=1)

    # Optionally, drop the temporary columns if they are no longer needed
    df_in.drop(columns=["tz_file", "tz_local"], inplace=True)

    return df_in


def duckdb_export(db_name: str, dataframes: dict) -> None:
    """
    Take a list of dataframes, add them each as a table to a duckdb database, and save the duckdb locally.
    Args:
        db_name: name of the output duckdb database
        dataframes: dictionary containing dataframes to be exported. keys are the dataframe names and values are
            the dataframes.

    Returns:
        None
    """
    db_file = db_name
    if os.path.exists(db_file):
        os.remove(db_file)
    # Initiate a duckdb connection
    conn = duckdb.connect(db_name)

    for table_name, df in dataframes.items():
        # Register the DataFrame as a view
        view_name = table_name + "_view"
        conn.register(view_name, df)

        # Create a persistent table from the view
        conn.execute('CREATE TABLE ' + table_name + ' AS SELECT * FROM ' + view_name)

        # Don't forget to clear the view after it's no longer needed
        conn.unregister(view_name)

    # Close the connection
    conn.close()


def convert_time_to_string(df_in: pd.DataFrame, column_names) -> pd.DataFrame:
    """
    Convert pandas datetime format to string so that it can be handled correctly in R
    Args:
        df_in: input dataframe
        column_names: list of column names to convert to string

    Returns:
        dataframe: converted dataframe

    """
    for col in column_names:
        df_in[col] = df_in[col].dt.strftime('%Y-%m-%d %H:%M:%S')

    return df_in


if __name__ == "__main__":

    DATA_FOLDER = "../shiny/shinydata/fromLiz"
    OUT_FOLDER = "../shiny/shinydata/prepped_tables"


