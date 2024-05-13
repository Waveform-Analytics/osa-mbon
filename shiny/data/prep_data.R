# Prep data and variables

# #################################################################
# #################################################################
# READ FROM DATABASE

# Establish connection to DuckDB
con <- dbConnect(duckdb::duckdb(), "data/mbon.duckdb")

# Key West Annotations
df_fish_keywest <- dbReadTable(con, "t_fish_keywest") %>%
  select(start_time, end_time, species)

# May River Annotations
df_fish_mayriver <- dbReadTable(con, "t_fish_mayriver") %>%
  select(start_time, end_time, species)

# Grays Reef Ship Data
df_ships_graysreef <- dbReadTable(con, "t_ships_grays") %>%
  select(start_time, end_time, type)

# Acoustic indices.
df_aco <- dbReadTable(con, "t_aco")
df_aco_norm <- dbReadTable(con, "t_aco_norm")

# Seascaper
df_seascaper <- dbReadTable(con, "t_seascaper")

dbDisconnect(con)

# #################################################################
# #################################################################

# Combine the fish annotation data
df_fish_keywest$Dataset <- "Key West"
df_fish_mayriver$Dataset <- "May River"
df_fish <- rbind(df_fish_keywest, df_fish_mayriver)

# Combine ship data (only have one for now)
df_ships_graysreef$Dataset <- "Gray's Reef"
df_ships <- df_ships_graysreef

# Annotations lookup table
fish_codes <- read_csv("data/fish_codes.csv", show_col_types = FALSE)

# Get all of the unique datasets
unique_datasets <- df_aco %>%
  distinct(Dataset) %>%
  pull(Dataset)

# Get all of the unique sample rates for the selected dataset
unique_sr <- df_aco %>%
  filter(Dataset == unique_datasets[1]) %>%
  select(Sampling_Rate_kHz) %>%
  distinct() %>%
  pull(Sampling_Rate_kHz)

# Get unique durations based on previous selections
unique_durations <- df_aco %>%
  filter(Dataset == unique_datasets[1]) %>%
  filter(Sampling_Rate_kHz == unique_sr[1]) %>%
  select(Duration_sec) %>%
  distinct() %>%
  pull(Duration_sec)

# Extract the column names that represent all acoustic indices
col_names = names(df_aco)
index_columns_all <- col_names[8:(length(col_names)-4)]

# A subset of the index columns - update to pre-select a subset
# index_columns <- index_columns_all[1:10]
index_columns <- index_columns_all

# Unique datasets with annotations
unique_datasets_ann <- c("Key West", "May River")
unique_species <- fish_codes %>%
  filter(Dataset == unique_datasets_ann[1]) %>%
  distinct(code) %>% pull(code)

# #################################################################
# #################################################################
# SEASCAPER DATA
