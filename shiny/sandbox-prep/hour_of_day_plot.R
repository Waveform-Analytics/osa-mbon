# Filtered Data Subset
subset_df <-
  fcn_filterAco(df_aco_norm, "Key West",48, 30)

# Add hour of day column, make it a factor
subset_df$hour <- hour(subset_df$start_time)

# Index Picks - with start and end time
selected_indices <- c("ZCR")
df_hour <-
  subset_df %>%
  select(hour, all_of(selected_indices))

df_hour$hour <- factor(df_hour$hour)

df_hour_long <- pivot_longer(df_hour, all_of(selected_indices), 
                             names_to = "index")

# Plot
p_hour <- ggplot(df_hour_long, aes(x=hour, y=value, fill=index)) +
  geom_boxplot(outlier.shape = NA) +
  labs(x="Hour of day") +
  theme_minimal() +
  theme(legend.position = "none",
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())

print(p_hour)


