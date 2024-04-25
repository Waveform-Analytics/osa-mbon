library(shiny)
library(bslib)
# Tidy
library(tidyr)
library(lubridate)
library(dplyr)
# Plotting
library(corrplot)
library(ggplot2)
# DB
library(duckdb)
library(dbplyr)
conflicts_prefer(dplyr::filter)

source("helpers/getPresence.R")

# Establish connection to DuckDB
con <- dbConnect(duckdb::duckdb(), "biosound-mbon.duckdb")
# Access the tables via dplyr
acousticIndices <- tbl(con, "acoustic_indices")
fishData <- tbl(con, "fish_data")

# Extract the full acoustic indices dataframe
df_aco <- acousticIndices %>% collect()
# Extract the full fish data dataframe
df_fish <- fishData %>% collect()
# Rename columns
df_fish <- df_fish %>% rename(
  datetime_fish = datetime
)
df_aco <- df_aco %>% rename(
  datetime_aco = Date
)


# For testing, get a subset of df_aco
df_sub <- df_aco %>%
  filter((Dataset == "Key West") & (FFT == 512)) %>%
  distinct() %>%
  collect()

# Get all column names
aco_col_names <- colnames(acousticIndices)

# Extract the column names that represent all acoustic indices
index_columns_all <- aco_col_names[8:length(aco_col_names)]

# A subset of the index columns
index_columns <- index_columns_all[1:10]

# Pull out all the unique values in the "Dataset" column
unique_datasets <- acousticIndices %>%
  select(Dataset) %>%
  distinct() %>%
  collect() 

# Get the date range from the Date column
date_range <- acousticIndices %>% 
  summarize(
    MinDate = min(Date),
    MaxDate = max(Date)
  ) %>% 
  collect()

dbDisconnect(con)

