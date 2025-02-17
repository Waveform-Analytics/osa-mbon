import duckdb
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Connect to the DuckDB database
data_file_name = "../shiny/data/mbon11.duckdb"
conn = duckdb.connect(data_file_name, read_only=True)

# Get the index categories
df_index_cats = pd.read_csv("../shiny/data/Updated_Index_Categories_v2.csv")

# Load the relevant tables into DataFrames
df_aco = conn.execute("SELECT * FROM t_aco2").fetchdf()
df_aco_norm = conn.execute("SELECT * FROM t_aco_norm2").fetchdf()
df_seascaper = conn.execute("SELECT * FROM t_seascaper").fetchdf()

# Load the fish annotations for Key West and May River
df_fish_keywest = conn.execute("SELECT start_time, end_time, Labels FROM t_fish_keywest").fetchdf()
df_fish_keywest['is_present'] = 1  # Add is_present column

df_fish_mayriver = conn.execute("SELECT start_time, end_time, Labels, is_present FROM t_fish_mayriver").fetchdf()

# Close the connection
conn.close()

# Tidy up
df_aco['date_formatted'] = pd.to_datetime(df_aco['Date'])
df_seascaper['date_formatted'] = pd.to_datetime(df_seascaper['date'])

# Extract only the indices
#prefixes = df_index_cats["Prefix"].tolist()
prefixes = ["ACI", "ZCR", "BGNt", "EVNtCount", "Ht", "ADI", "BI", "Hf", "NDSI", "MEANf", "SNRf"]
# Filter df_aco columns based on the prefixes.
# Select columns in df_aco whose names match the prefix list
index_columns = [col for col in df_aco.columns if any (col == prefix for prefix in prefixes)]
df_aco_indices = df_aco[index_columns]
# Calculate the correlation matrix
correlation_matrix = df_aco_indices.corr()

# 5. Explore relationships between indices and water classes
# Convert date_formatted to just date and not date/time
df_aco['date'] = pd.to_datetime(df_aco['date_formatted']).dt.date
# Re-convert the 'date' column back to pandas datetime64
df_aco['date'] = pd.to_datetime(df_aco['date'])
# take the daily median of each index (index_columns) from df_aco.
df_aco_daily = df_aco.groupby(['date', 'Dataset'])[index_columns].median().reset_index()
# merge df_aco with df_seascaper on the date_formatted column
merged_df = pd.merge(df_aco_daily, df_seascaper, on='date')

# Clean up daily data and save
keep_columns_daily = ['date', 'Dataset_y'] + prefixes + ['cellvalue', 'n_cells']
df_merged_clean = merged_df[keep_columns_daily].dropna()
#df_merged_clean.to_csv("daily_data.csv")

# Clean up index data and save
keep_columns = ['Date', 'Dataset', 'Sampling_Rate_kHz', 'Duration_sec'] + prefixes
df_aco_norm_clean = df_aco_norm[keep_columns].dropna()
df_aco_norm_clean['Date'] = pd.to_datetime(df_aco_norm_clean['Date'])
df_aco_norm_clean = df_aco_norm_clean[
    (df_aco_norm_clean['Date'].dt.month == 2) & (df_aco_norm_clean['Sampling_Rate_kHz'] == 16)
]
#df_aco_norm_clean.to_csv("index_data.csv")
