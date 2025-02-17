import duckdb
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

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
df_aco_daily = df_aco.groupby(['date', 'Dataset', 'Sampling_Rate_kHz', 'FFT', 'Duration_sec'])[index_columns].median().reset_index()
# merge df_aco with df_seascaper on the date_formatted column
merged_df = pd.merge(df_aco_daily, df_seascaper, on=['date', 'Dataset'])

# Clean up daily data and save
keep_columns_daily = ['date', 'Dataset', 'Sampling_Rate_kHz', 'FFT', 'Duration_sec'] + prefixes + ['cellvalue', 'n_cells']
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
#df_aco_norm.to_csv("index_data_all-cols.csv")

## correlating index vs water columns
datasets = np.unique(df_merged_clean['Dataset'])
sample_rate = 16

# Create a dictionary to store correlations, then convert to DataFrame
correlation_results = {}

for dataset in datasets:
    df_dataset = df_merged_clean[(df_merged_clean['Dataset'] == dataset)]
    df_dataset = df_dataset[df_dataset['Sampling_Rate_kHz'] == df_dataset['Sampling_Rate_kHz'].max]
    df_dataset.loc[:, 'pct'] = df_dataset.groupby('date')['n_cells'].transform(lambda x: x / x.sum() * 100)

    water_classes = np.unique(df_dataset['cellvalue'])

    # Initialize nested dictionary for this dataset
    correlation_results[dataset] = {}

    for water_class in water_classes:
        df_class = df_dataset[df_dataset['cellvalue'] == water_class]
        # Initialize dictionary for this water class
        correlation_results[dataset][f'Class_{water_class}'] = {}

        for idx in prefixes:
            df_idx_sub = df_class[idx]
            df_class_sub = df_class['pct']
            corr = np.corrcoef(df_idx_sub.values, df_class_sub.values)[0, 1]
            correlation_results[dataset][f'Class_{water_class}'][idx] = corr

# Convert to DataFrame - one table per dataset
correlation_tables = {}
for dataset in correlation_results:
    correlation_tables[dataset] = pd.DataFrame(correlation_results[dataset]).round(3)

# Display tables
for dataset, corr_table in correlation_tables.items():
    print(f"\nCorrelations for {dataset}:")
    print(corr_table)

    # Optionally create heatmaps for visual interpretation
    plt.figure(figsize=(10, 8))
    sns.heatmap(corr_table, annot=True, cmap='RdBu_r', center=0, vmin=-1, vmax=1)
    plt.title(f'Index-Water Class Correlations: {dataset}')
    plt.ylabel('Acoustic Indices')
    plt.xlabel('Water Classes')
    plt.tight_layout()
    plt.show()
