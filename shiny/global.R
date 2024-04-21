library(duckdb)
library(shiny)
library(dplyr)
library(tidyr)

# Establish connection to DuckDB
duckdb_file = "biosound-mbon.duckdb"
con <- dbConnect(duckdb::duckdb(), duckdb_file)

# Access the table via dplyr
acoustic_indices <- tbl(con, "acoustic_indices")

# Get all column names
aco_col_names <- colnames(acoustic_indices)

# Extract the column names that represent acoustic indices
index_columns <- aco_col_names[8:length(aco_col_names)]

# Query to filter rows where dataset is "keywest"
data_subset <- acoustic_indices %>%
  filter(Dataset == "Key West") %>%
  collect() 

# Pull out all the unique values in the "Dataset" column
unique_datasets <- acoustic_indices %>%
  select(Dataset) %>%
  distinct() %>%
  collect() 

# Get the date range from the Date column
date_range <- acoustic_indices %>% 
  summarize(
    MinDate = min(Date),
    MaxDate = max(Date)
  ) %>% 
  collect()

dbDisconnect(con)

