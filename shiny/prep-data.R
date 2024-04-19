# Prepare data
# Load all the required datasets into a duckdb database - that database can 
# then be used to provide data in an organized way for the dashboard.
library(readxl)
library(duckdb)
library(readr)
library(lubridate)

##### Set up a Duckdb database #####

duckdb_file = "biosound-mbon.duckdb"
# Remove the previous DuckDB file because this script generates one from scratch from all the data
if (file.exists(duckdb_file)) {
  file.remove(duckdb_file)
}
con <- dbConnect(duckdb::duckdb(), duckdb_file)

##### Add a table containing all acoustic indices #####

root_dir = "shinydata/fromLiz/FWRI_KeyWest/"
csv_files <- list.files(path = root_dir, pattern = "\\.csv$", recursive = TRUE)

# Loop through each file path in the csv_files vector
for (file in csv_files) {
  # Read the CSV file into a data frame
  aco_data <- read_csv(paste0(root_dir, file), show_col_types = FALSE)
  aco_data$Date <- as.POSIXct(aco_data$Date, format = "%m/%d/%Y %H:%M")
  
  # Append the data to DuckDB table
  dbWriteTable(con, "acoustic_indices", aco_data, append = TRUE)
}

##### Add fish data to a different table #####

root_dir = "shinydata/fromLiz/"
fish_files <- list.files(path = root_dir, pattern = "\\.txt$", recursive = TRUE)

for (file in fish_files) {
  # Read the fish annotations CSV file into a data frame
  fish_data <- read_tsv(paste0(root_dir, file), show_col_types = FALSE)
  # call cutoff @ end,	calls overlap
  fish_data$`call cutoff @ end` <- NULL
  fish_data$`calls overlap` <- NULL
  fish_data$`Notes` <- NULL
  fish_data$`Begin Date Time` <- NULL
  fish_data$`End Date` <- NULL
  fish_data$`End Clock Time` <- NULL
  
  # There is a column with a filename, and in that file name there's a start date/time
  # Here, we extract the date from that file name
  if ("Begin File" %in% names(fish_data)) {
    fish_data$datetime <- ymd_hms(sub("T", " ", fish_data$`Begin File`))
    fish_data$`Begin File` <- NULL
  } else if ("Begin Path" %in% names(fish_data)) {
    fish_data$full_path <- gsub("\\\\", "/", fish_data$`Begin Path`)
    base_file_name <- basename(fish_data$full_path)
    fish_data$datetime <- ymd_hms(sub("T", " ", base_file_name))
    fish_data$`Begin Path` <- NULL
    fish_data$full_path <- NULL
  }
  
  fish_data$datetime <- fish_data$datetime + as.numeric(fish_data$`File Offset (s)`)
  
  # Append the data to DuckDB table
  dbWriteTable(con, "fish_data", fish_data, append = TRUE)
}

# Get some quick info on the database and table(s)

# Query to list all tables
tables_query <- dbGetQuery(con, "SHOW TABLES")
print(tables_query)

# Describe what's in the acoustic data table
describe_table_query <- dbGetQuery(con, "DESCRIBE fish_data")
print(describe_table_query)

# Preview data from a table
print(dbGetQuery(con, "SELECT * FROM fish_data LIMIT 10"))

dbDisconnect(con)

