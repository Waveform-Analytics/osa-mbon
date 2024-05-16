df_seascaper_sub <- df_seascaper %>%
  filter(Dataset == "Key West", !is.na(cellvalue))

unique_classes <- as.character(df_seascaper_sub %>%
  distinct(cellvalue) %>%
  pull())

unique_classes_numeric <- df_seascaper_sub %>%
  distinct(cellvalue) %>%
  arrange(cellvalue) %>%
  pull()

# water class percentages
df_water <- df_seascaper_sub %>%
  group_by(date) %>%
  mutate(
    total_cells = sum(n_cells), 
    pct = n_cells / total_cells *100) %>%
  pivot_wider(
    id_cols     = date,
    names_from  = cellvalue,
    values_from = pct, values_fill = 0) %>%
  pivot_longer(
    cols = unique_classes,
    names_to = "class",
    values_to = "pct"
  ) %>%
  mutate(
    class_num = as.numeric(class)
  ) %>%
  arrange(date, class_num) 

df_water$class <- as.factor(df_water$class)

p <- ggplot(df_water, aes(x = date, y=pct, fill=class)) +
  geom_area(alpha = 0.5) +
  geom_area(aes(color = class), fill = NA, size = .7) +
  theme_minimal() +
  labs(
    y="Water class percentage",
    x=NULL)

print(p)

###############################################
###############################################


# Get acoustic index values at each seascaper date
dates_list <- df_seascaper_sub %>% 
  distinct(date) %>% 
  pull()

extended_date <- max(dates_list) + days(8)
dates_list <- c(dates_list, extended_date)

# Dataset (location) subset
df_filt <- fcn_filterAco(df_aco_norm, "Key West", 48, 30)

# Index subset
selected_index <- "ACI"
df_idx <- 
  df_filt %>% 
  select(start_time, all_of(selected_index)) %>%
  mutate(date = cut(start_time, 
                        breaks = dates_list, 
                        include.lowest = TRUE, 
                        right = FALSE),
         date = as.POSIXct(date)) %>%
  rename(index = all_of(selected_index))
df_idx$date <- as.factor(df_idx$date)

p2 <- ggplot(df_idx, aes(x=date, y=index)) +
  geom_boxplot() +
  theme_minimal()

print(p2)


###############################################
###############################################

df_idx_summ <- df_idx %>%
  group_by(date) %>%
  summarise(mean = mean(index))
df_water$date <- as.factor(df_water$date)

df_combo <- left_join(df_idx_summ, df_water, by = "date")

this_class <- "3"
this_df_combo <- df_combo %>%
  filter(class == this_class)

# Fit the model
model <- lm(pct ~ mean, data = this_df_combo)

p3 <- ggplot(this_df_combo, aes(x=mean, y=pct, color=class)) + 
  geom_smooth(method = "lm", se = TRUE) +
  geom_point(shape = 21, size = 3, fill = NA, stroke = 1.5) +  
  theme_minimal() + 
  labs(y="Water class percentage", x="Mean index value") +    
  theme(legend.position = "none") +
  annotate("text", x = Inf, y = Inf, 
           label = sprintf("y = %.1fx + %.1f\nR² = %.2f",
                           coef(model)[2], coef(model)[1], 
                           summary(model)$r.squared),
           hjust = 1.1, vjust = 1.1, size = 5)

print(p3)


# Summary of the model
model_summary <- summary(model)

# Print the summary
print(model_summary)

###############################################
###############################################

# One dataset (location), all indices, summarized by date and index
df_idx_big <- 
  df_filt %>% 
  select(start_time, all_of(index_columns)) %>%
  mutate(date = cut(start_time, 
                    breaks = dates_list, 
                    include.lowest = TRUE, 
                    right = FALSE),
         date = as.POSIXct(date),
         # date = with_tz(date, "UTC")
         ) %>%
  pivot_longer(
    cols = all_of(index_columns),
    names_to = "index",
    values_to = "value"
  ) %>%
  group_by(date, index) %>%
  summarise(
    mean_val = mean(value),
    .groups = "keep"
  ) %>%
  mutate(
    date = force_tz(date, "UTC")
  )
df_idx_big$date <- as.factor(df_idx_big$date)

get_cor_value <- 
  function(df_index, 
           df_water_class, 
           this_class, 
           this_index) {
    
    this_pct <- df_water_class %>%
      filter(class_num == this_class)
    
    this_value <- df_index %>%
      filter(index == this_index)
    
    df_join <- inner_join(this_pct, this_value, by = "date")
    
    return(cor(df_join$pct, df_join$mean_val))
  }

# Initialize an empty dataframe with 'unique_classes' as columns
df_heatmap <- setNames(
  data.frame(matrix(ncol = length(unique_classes_numeric), 
                    nrow = length(index_columns))), 
  unique_classes_numeric)
rownames(df_heatmap) <- index_columns



# Populate the dataframe
for (index in index_columns) {
  for (class in unique_classes_numeric) {
    cor_value <- get_cor_value(df_idx_big, d_water, class, index)
    
    df_heatmap[index, as.character(class)] <- cor_value
  }
}

# Assuming df_heatmap is your DataFrame ready for the heatmap
pheatmap(df_heatmap,
         cluster_rows = FALSE,  # Disables clustering of rows
         cluster_cols = FALSE,  # Disables clustering of columns
         na_col = "grey",  # Color for NaN values
         display_numbers = FALSE,  # Optionally display the correlation values
         main = "Correlations: index vs water class")

pheatmap(df_heat(),
         cluster_rows = FALSE,  
         cluster_cols = FALSE,  
         na_col = "grey",  
         display_numbers = FALSE,  
         main = "Correlations: index vs water class")

