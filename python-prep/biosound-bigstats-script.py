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
df_fish_keywest = conn.execute("SELECT * FROM t_fish_keywest").fetchdf()
df_fish_mayriver = conn.execute("SELECT * FROM t_fish_mayriver").fetchdf()

# Close the connection
conn.close()

# Tidy up
df_aco['date_formatted'] = pd.to_datetime(df_aco['Date'])
df_seascaper['date_formatted'] = pd.to_datetime(df_seascaper['date'])


# Display the first few rows of each DataFrame
print("Acoustic Indices Data:")
print(df_aco.head())
print("\nNormalized Acoustic Indices Data:")
print(df_aco_norm.head())
print("\nSeascaper Data:")
print(df_seascaper.head())

# Exploratory Data Analysis

# 1. Check data types and missing values
print("Data Types and Missing Values:")
print(df_aco.info())
print(df_aco_norm.info())
print(df_seascaper.info())

# 2. Descriptive Statistics
print("\nDescriptive Statistics:")
print("Acoustic Indices:")
print(df_aco.describe())
print("\nNormalized Acoustic Indices:")
print(df_aco_norm.describe())
print("\nSeascaper Data:")
print(df_seascaper.describe())

# 3. Visualize distributions
# Set the style
sns.set_style("whitegrid")
# Plot distributions of a few acoustic indices
plt.figure(figsize=(12, 6))
sns.histplot(df_aco['ACI'], bins=30, kde=True)
plt.title('Distribution of ACI')
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.show()

# 4. Correlation Analysis
print("\nCorrelation Analysis:")
print("Acoustic Indices Correlation Matrix:")

# Extract only the indices
prefixes = df_index_cats["Prefix"].tolist()
# Filter df_aco columns based on the prefixes.
# Select columns in df_aco whose names match the prefix list
index_columns = [col for col in df_aco.columns if any (col == prefix for prefix in prefixes)]
df_aco_indices = df_aco[index_columns]
# Calculate the correlation matrix
correlation_matrix = df_aco_indices.corr()

# Plot the correlation matrix heatmap
plt.figure(figsize=(12, 8))
sns.heatmap(correlation_matrix, annot=False, cmap='coolwarm', center=0)
plt.title('Correlation Matrix of Acoustic Indices')
plt.show()

# 5. Explore relationships between indices and water classes
# Convert date_formatted to just date and not date/time
df_aco['date'] = pd.to_datetime(df_aco['date_formatted']).dt.date
# Re-convert the 'date' column back to pandas datetime64
df_aco['date'] = pd.to_datetime(df_aco['date'])
# take the daily median of each index (index_columns) from df_aco.
df_aco_daily = df_aco.groupby(['date', 'Dataset'])[index_columns].median().reset_index()
# merge df_aco with df_seascaper on the date_formatted column
merged_df = pd.merge(df_aco_daily, df_seascaper, on='date')



# Step 1: Filter relevant columns from merged_df
# Assume 'cellvalue' from df_seascaper, 'location', and indices from df_aco_daily are in merged_df
columns_to_plot = ['cellvalue'] + index_columns + ['Dataset_y']  # Replace 'location' with the actual column name if different
df_plot = merged_df[columns_to_plot]

# Step 2: Iterate and plot each acoustic index vs cellvalue
for index in index_columns:
    plt.figure(figsize=(10, 6))
    sns.scatterplot(data=df_plot, x=index, y='cellvalue', hue='Dataset_y', palette='viridis')
    plt.title(f"{index} vs Cellvalue (Split by Location)")
    plt.xlabel(index)
    plt.ylabel("Cellvalue")
    plt.legend(title="Location_y")
    plt.show()
