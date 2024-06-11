# Filtered Data Subset
subset_df <-
  fcn_filterAco(df_aco_norm, "Key West, FL",48, 30)

# Index Picks - with start and end time
# selected_index <- c("ZCR", "ACI")
selected_index <- "ZCR"
df_indexPicks <-
  subset_df %>%
  select(start_time, end_time, all_of(selected_index)) %>%
  rename("index" = all_of(selected_index))

# Annotations - Testing
# Select species
spp <- c("Mb", "Em")
# spp <- c("Em")
ann_spp <- df_fish %>%
  filter(Labels %in% spp, Dataset == "Key West, FL") %>%
  arrange(start_time)

A <- get_species_presence(df_indexPicks, ann_spp)
A$is_present <- ifelse(A$is_present, "Present", "Absent")

present_only <- A %>% filter(is_present == "Present")

######
# getting A and is_present without using get_species_presence
AA <- subset_df %>%
  select(start_time, all_of(selected_index), all_of(spp)) %>%
  rename("index" = all_of(selected_index)) %>%
  pivot_longer(cols = all_of(spp), names_to = "Labels", values_to = "is_present")

AA$is_present <- ifelse(AA$is_present == 1, "Present", "Absent")





# Plotting
## Time series and species presence
p1 <- ggplot(data = df_indexPicks, aes(x = start_time, y = index)) +
  geom_line() +
  geom_point(data = present_only, aes(color = species, shape = species), size = 1) +
  labs(title = paste0(selected_index, " over Time with Species Presence"),
       x = "Time", y = "Index", ) +
  theme_minimal()

ggplotly(p1)

##### Try with plotly directly

present_only <- present_only %>% arrange(start_time)
df_indexPicks <- df_indexPicks %>% arrange(start_time)
df_indexPicks$species <- 0

p1b <- plot_ly()

p1b <- p1b %>% add_trace(data=df_indexPicks, 
                         x=~start_time, y=~index,
                         type='scatter', mode='lines', 
                         line = list(color = 'gray'),
                         showlegend=FALSE)

p1b <- p1b %>% add_markers(data=present_only, name=~species,
                           x=~start_time, y=~index, 
                           color=~species)

p1b


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
