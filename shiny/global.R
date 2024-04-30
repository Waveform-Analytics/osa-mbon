library(shiny)
library(bslib)
# Tidy
library(tidyr)
library(lubridate)
library(dplyr)
# Plotting
library(corrplot)
library(ggplot2)
library(dygraphs)
# DB
library(duckdb)
library(arrow)

# Establish connection to DuckDB
con <- dbConnect(duckdb::duckdb(), "mbon.duckdb")

# Load the tables into memory (may need to adjust this if we get bogged down)
df_fish_keywest <- dbReadTable(con, "t_fish_keywest")
df_fish_mayriver <- dbReadTable(con, "t_fish_mayriver")
df_aco <- dbReadTable(con, "t_aco")
df_aco_norm <- dbReadTable(con, "t_aco_norm")

# Get all of the unique datasets
unique_datasets <- df_aco %>% distinct(Dataset)

# Get all of the unique sample rates for the selected dataset
unique_sr <- df_aco %>% 
  filter(Dataset == unique_datasets$Dataset[1]) %>%
  select(Sampling_Rate_kHz) %>%
  distinct()

# Get unique durations based on previous selections
unique_durations <- df_aco %>%
  filter(Dataset == unique_datasets$Dataset[1]) %>%
  filter(Sampling_Rate_kHz == unique_sr$Sampling_Rate_kHz[1]) %>%
  select(Duration_sec) %>%
  distinct()

# Extract the column names that represent all acoustic indices
col_names = names(df_aco)
index_columns_all <- col_names[8:(length(col_names)-4)]

# A subset of the index columns - update to pre-select a subset
index_columns <- index_columns_all[1:10]
selected_columns <- c("ZCR")

subset_df_test <- df_aco %>%
    filter(Dataset == "Key West",
           Sampling_Rate_kHz == 48,
           Duration_sec == 30)
idxPicks_test <- subset_df_test[, c("start_time", selected_columns), drop = FALSE] 


dbDisconnect(con)

