# Filtered Data Subset
subset_df <-
  fcn_filterAco(df_aco_norm, "Key West",16, 30)

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

############################################################
# Prep for the big overview plot

selected_indices <- index_columns

df_hour_all <-
  subset_df %>%
  select(hour, all_of(selected_indices))

df_hour_all$hour <- factor(df_hour_all$hour)

df_hour_long <- pivot_longer(df_hour_all, all_of(selected_indices), 
                             names_to = "index")

df_hour_grouped <- df_hour_long %>%
  group_by(index, hour) %>%
  summarise(
    summary_val = mean(value),
    .groups = "drop" 
  ) 


df_hour_med <- df_hour_grouped %>%
  group_by(index) %>%
  summarise(
    min_val = min(summary_val),
    max_val = max(summary_val),
    range = max_val - min_val
  ) 

df_hour_norm <- df_hour_grouped %>%
  left_join(df_hour_med, b="index") %>%
  mutate(
    norm = (summary_val-min_val)/range
  ) %>%
  select(
    index, hour, norm
  )

########################################################################
# Plot hour of day heatmap (index vs hour of day)

diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)  
plot <- levelplot(norm ~ as.factor(hour) * as.factor(index), data = df_hour_norm,
                  xlab = "Hour of Day",  # Rename x-axis
                  ylab = "Index",  # Rename y-axis
                  col.regions = diverging_colors,  # Use the diverging color scale
                  colorkey = TRUE)  # Enable color key

# Print the plot
print(plot)

########################################################################
# Plot hour of day heatmap but with separate plots for each index 
# type/category

# Join the index type dataframe with the df_hour_norm dataframe
result <- left_join(df_hour_norm, df_index_cats, by = "index")

########################################################################
# Plot heatmap showing hour of day vs date (to see longer term trends)

this_index <- "Hf"

df_hour_date <-
  subset_df %>%
  filter(
    month(start_time) == 2
  ) %>%
  mutate(
    day = as.Date(start_time)
  ) %>%
  select(day, hour, all_of(this_index))


df_hour_date$hour <- factor(df_hour_date$hour)

df_hour_long <- pivot_longer(df_hour_date, all_of(this_index), 
                             names_to = "index")

df_hour_grouped <- df_hour_long %>%
  group_by(day, hour) %>%
  summarise(
    summary_val = mean(value),
    .groups = "drop" 
  ) 

df_hour_med <- df_hour_grouped %>%
  group_by(day) %>%
  summarise(
    min_val = min(summary_val),
    max_val = max(summary_val),
    range = max_val - min_val
  )

df_hour_norm <- df_hour_grouped %>%
  left_join(df_hour_med, b="day") %>%
  mutate(
    norm = (summary_val-min_val)/range
  ) %>%
  select(
    day, hour, norm
  )

diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)  
plot <- levelplot(norm ~ as.factor(hour) * as.factor(day), data = df_hour_norm,
                  xlab = "Hour of Day",  # Rename x-axis
                  ylab = "Date",  # Rename y-axis
                  col.regions = diverging_colors,  # Use the diverging color scale
                  colorkey = TRUE)  # Enable color key

# Print the plot
print(plot)

