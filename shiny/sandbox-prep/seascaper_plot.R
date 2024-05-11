df_seascaper_sub <- df_seascaper %>%
  filter(Dataset == "Key West", !is.na(cellvalue))

max_cells_notna <- df_seascaper_sub |>
  group_by(date) |>
  summarize(sum_n_cells = sum(n_cells)) |>
  pull(sum_n_cells) |>
  max()

unique_classes <- as.character(df_seascaper_sub %>%
  distinct(cellvalue) %>%
  pull())

# water class percentages
d_water <- df_seascaper_sub %>%
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

d_water$class <- as.factor(d_water$class)


p <- ggplot(d_water, aes(x = date, y=pct, fill=class)) +
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
  mutate(interval = cut(start_time, 
                        breaks = dates_list, 
                        include.lowest = TRUE, 
                        right = FALSE),
         interval = as.POSIXct(interval)) %>%
  rename(index = all_of(selected_index))

df_idx$interval <- as.factor(df_idx$interval)

p2 <- ggplot(df_idx, aes(x=interval, y=index)) +
  geom_boxplot()

print(p2)


###############################################
###############################################


