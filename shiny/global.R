library(duckdb)
library(shiny)
library(dplyr)
library(tidyr)
library(bslib)
library(plotly)
library(lubridate)
library(corrplot)
library(ggplot2)
library(dbplyr)


# Establish connection to DuckDB
duckdb_file = "biosound-mbon.duckdb"
con <- dbConnect(duckdb::duckdb(), duckdb_file)

# Access the table via dplyr
acoustic_indices <- tbl(con, "acoustic_indices")

# Get all column names
aco_col_names <- colnames(acoustic_indices)

# Extract the column names that represent all acoustic indices
index_columns_all <- aco_col_names[8:length(aco_col_names)]

# A subset of the index columns
index_columns <- index_columns_all[1:10]

# Query to filter rows where dataset is "keywest"
data_subset <- acoustic_indices %>%
  filter((Dataset == "Key West") & (FFT == 512)) %>%
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

