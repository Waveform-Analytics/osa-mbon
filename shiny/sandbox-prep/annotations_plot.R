# Filtered Data Subset
subset_df <-
  fcn_filterAco(df_aco_norm, "Key West",48, 30)

# Index Picks - with start and end time
selected_index <- "ZCR"
df_indexPicks <-
  subset_df %>%
  select(start_time, end_time, all_of(selected_index)) %>%
  rename("index" = all_of(selected_index))

# Annotations - Testing
# Extract just one species from the key west annotations
spp <- c("Mb", "Em", "Vs")
# spp <- c("Em")
ann_spp <- df_fish %>%
  filter(species %in% spp, Dataset == "Key West") %>%
  arrange(start_time)

A <- get_species_presence(df_indexPicks, ann_spp)
A$is_present <- ifelse(A$is_present, "Present", "Absent")

present_only <- A %>% filter(is_present == "Present")

# Plotting
## Time series and species presence
p1 <- ggplot(data = df_indexPicks, aes(x = start_time, y = index)) +
  geom_line() +
  geom_point(data = present_only, aes(color = species, shape = species), size = 1) +
  labs(title = paste0(selected_index, " over Time with Species Presence"),
       x = "Time", y = "Index", ) +
  theme_minimal()

ggplotly(p1)

## box plots - presence/absence
p2 <- ggplot(A, aes(x=species, y=index, fill=is_present)) +
  geom_boxplot() +
  labs(title = paste0(selected_index, ": Species and Presence"),
       x = "Annotation", y = "Index", fill = NULL) +
  theme_minimal() +
  theme(text = element_text(size = 14))

print(p2)

## index vs hour of day
# p3 <- ggplot(df_indexPicks,)
