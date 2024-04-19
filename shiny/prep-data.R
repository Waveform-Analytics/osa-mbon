# Prepare data
# Load all the required datasets into a duckdb database - that database can 
# then be used to provide data in an organized way for the dashboard.
library(readxl)


# csv_files <- list.files(pattern = "\\.csv$", recursive = TRUE)

# Load the main info file which provides metadata and paths to each of the 
# files 
file_info = "shinydata/file_info.xlsx"
acoustic_indices_summary <- read_excel(file_info, sheet="acoustic_indices")
fish_data_summary <- read_excel(file_info, sheet="fish_data")

