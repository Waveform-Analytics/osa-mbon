selected_dataset <- "Key West"
sr <- 16
sel_idx <- selected_indices[1]

df_dat <- df_aco_norm %>%
  filter(Dataset == selected_dataset,
         Sampling_Rate_kHz == sr,
         FFT == 512,
         ) 

p <- ggplot(df_dat, aes(x=start_time, y=ZCR)) +
  geom_line() +
  theme_minimal()

print(p)

# Dygraph plot
# Create a dataframe that has columns for each duration
unq_durations <- as.character(df_dat %>%
  distinct(Duration_sec) %>%
  pull())


df_durations <- df_dat %>%
  filter(month(start_time) == 2) %>%
  pivot_wider(
    names_from = Duration_sec,
    values_from = all_of(sel_idx),
    values_fill = list(value = NA) # Ensure NA is filled for missing values
  ) %>%
  group_by(start_time) %>%
  summarize(across(everything(), ~ max(.x, na.rm = TRUE))) %>%
  select(start_time, all_of(unq_durations)) %>%
  arrange(start_time)
  

p2 <- dygraph(df_durations, x = "start_time") %>%
  dyRangeSelector(height = 30)

p2
