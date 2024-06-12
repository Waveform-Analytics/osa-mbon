# Filtered Data Subset
this_df <- df_aco_norm

# Add hour of day column, make it a factor
this_df$hour <- hour(this_df$start_time)

# Add month
this_df$month <- month(this_df$start_time)

# Only the common sample rate, only Feb, only max duration for each dataset
df_subset <- this_df %>% 
  filter(Sampling_Rate_kHz == 16, month == 2) %>%
  group_by(Dataset) %>%
  filter(Duration_sec == max(Duration_sec)) %>%
  ungroup()  


