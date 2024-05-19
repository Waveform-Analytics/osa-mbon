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
  labs(x="Hour of day", y="Index value") +
  theme_minimal() +
  theme(legend.position = "none",
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())

print(p_hour)

# Try out ggridges to make a ridge plot
p_ridge <- ggplot(df_hour_long, aes(x=value, y=hour, fill=hour)) +
  geom_density_ridges()

print(p_ridge)


## Try multiple indices - facet_grid
selected_indices2 <- c("ZCR", "ACI", "AEI", "ECV")
# selected_indices2 <- index_columns
df_hour2 <-
  subset_df %>%
  select(hour, all_of(selected_indices2))

df_hour2$hour <- factor(df_hour2$hour)

df_hour2_long <- pivot_longer(df_hour2, all_of(selected_indices2), 
                             names_to = "index")

df_hour_grouped <- df_hour2_long %>%
  group_by(index, hour) %>%
  summarise(
    mean = mean(value),
    .groups = "drop" 
  )

p_facets <- ggplot(df_hour_grouped, aes(x = hour, y = mean, group = index, color=index)) +
  geom_point() +  
  geom_line() +
  facet_grid(index ~ ., scales = "free_y", space = "fixed") + 
  theme_minimal() +  
  theme(
    strip.background = element_blank(), 
    strip.text = element_text(size = 12, face = "bold"),  
    axis.text.x = element_text(angle = 45, hjust = 1),  
    panel.spacing = unit(0.1, "lines")  
  ) +
  labs(
    x = "Hour",
    y = "Index Value",
  )+
  guides(color = FALSE)

# Print the plot
print(p_facets)


