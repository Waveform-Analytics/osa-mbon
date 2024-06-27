# INDICES VS HOUR OF DAY
server_tab4 <- function(input, output, session) {
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t4_datasetPick", unique_datasets)
  
  # Hard coding the normalized dataset and making it reactive
  get_dataset <- reactive({
    df_aco_norm$month = month(df_aco_norm$start_time)
    df_aco_norm
  })
  
  selected_sr <- server_srPicker("t4_srPick", get_dataset, selected_dataset)
  
  # Index category selector
  selected_cat <- server_catPicker("t4_catPick", unique_index_types)
  selected_index <- server_subIndexPicker("t4_subIndexPick", selected_cat)
  
  index_cats_subset <- reactive({
    req({selected_cat()})
    this_selected_cat <- selected_cat()
    df_index_cats %>%
      filter(Category == this_selected_cat) %>%
      pull(index)
  })
  
  #### Get initial subset
  subset_df <- reactive({
    req(selected_dataset(), get_dataset(), selected_sr())
    
    dataset <- selected_dataset()
    this_dataset <- get_dataset() %>% filter(month == 2)
    sr <- selected_sr()
    
    duration_subset <- this_dataset %>%
      filter(Dataset == dataset, Sampling_Rate_kHz == sr) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    
    # Filtered Data Subset
    this_subset_df <-
      fcn_filterAco(this_dataset, dataset, sr, duration_subset[1])
    
    # Add hour of day column, make it a factor
    this_subset_df$hour <- hour(this_subset_df$start_time)
    
    return(this_subset_df)
    
  })
  
  # Get a subset with all datasets
  df_subset_all <- reactive({
    req(get_dataset())
    
    this_dataset <- get_dataset()
    
    this_dataset$hour <- hour(this_dataset$start_time)
    this_dataset$month <- month(this_dataset$start_time)
    
    this_dataset %>% 
      filter(Sampling_Rate_kHz == 16,
             month == 2) %>% 
      group_by(Dataset) %>%
      filter(Duration_sec == max(Duration_sec)) %>%
      ungroup()  
    
  })
  
  ###############################################################
  # Function to prep and filter the dataset for the first heatmap
  df_hours <- reactive({
    req(subset_df())
    
    sub_df <- subset_df()
    
    selected_indices <- index_columns
    
    df_hour_all <-
      sub_df %>%
      select(hour, all_of(selected_indices))
    df_hour_all$hour <- factor(df_hour_all$hour)
    
    df_hour_long <- pivot_longer(df_hour_all, all_of(selected_indices), names_to = "index")
    df_hour_grouped <- df_hour_long %>%
      group_by(index, hour) %>%
      summarise(summary_val = mean(value), .groups = "drop")
    df_hour_med <- df_hour_grouped %>%
      group_by(index) %>%
      summarise(
        min_val = min(summary_val),
        max_val = max(summary_val),
        range = max_val - min_val
      )
    df_hour_grouped %>%
      left_join(df_hour_med, b = "index") %>%
      mutate(norm = (summary_val - min_val) / range) %>%
      select(index, hour, norm)
  })
  
  #################################################
  ##### PREP data for 2nd plot (hour vs location)
  
  df_hour_location_norm <- reactive({
    req(selected_index(), df_subset_all())
    
    this_index <- selected_index()
    sub_df <- df_subset_all()
    
    df_hour_date <-
      sub_df %>%
      select(Dataset, hour, all_of(this_index))
    
    df_hour_date$hour <- factor(df_hour_date$hour)
    
    df_hour_long <- pivot_longer(df_hour_date, all_of(this_index), names_to = "index")
    
    df_hour_grouped <- df_hour_long %>%
      group_by(Dataset, hour) %>%
      summarise(summary_val = mean(value), .groups = "drop")
    
    df_hour_med <- df_hour_grouped %>%
      group_by(Dataset) %>%
      summarise(
        min_val = min(summary_val),
        max_val = max(summary_val),
        range = max_val - min_val
      )
    
    df_hour_grouped %>%
      left_join(df_hour_med, b = "Dataset") %>%
      mutate(norm = (summary_val - min_val) / range) %>%
      select(Dataset, hour, norm)
    
  })
  
  
  #################################################
  ##### PREP data for 3rd plot (day vs hour of day)
  
  df_hour_day_norm <- reactive({
    req(selected_index(), subset_df())
    
    this_index <- selected_index()
    sub_df <- subset_df()
    
    
    df_hour_date <-
      sub_df %>%
      mutate(day = as.Date(start_time)) %>%
      select(day, hour, all_of(this_index))
    
    df_hour_date$hour <- factor(df_hour_date$hour)
    
    df_hour_long <- pivot_longer(df_hour_date, all_of(this_index), names_to = "index")
    
    df_hour_grouped <- df_hour_long %>%
      group_by(day, hour) %>%
      summarise(summary_val = mean(value), .groups = "drop")
    
    df_hour_med <- df_hour_grouped %>%
      group_by(day) %>%
      summarise(
        min_val = min(summary_val),
        max_val = max(summary_val),
        range = max_val - min_val
      )
    
    df_hour_grouped %>%
      left_join(df_hour_med, b = "day") %>%
      mutate(norm = (summary_val - min_val) / range) %>%
      select(day, hour, norm)
    
  })
  
  
  ##########################################################
  
  output$text_output <- renderUI({
    req({selected_cat()})
    this_selected_cat <- selected_cat()
    df_index_cats_subset <- df_index_cats %>%
      filter(Category == this_selected_cat)
    index_description_text(df_index_cats_subset)
  })
  
  
  ##########################################################
  # PLOTTING
  # # Set the theme for the lattice plot (not working)
  # trellis.par.set(custom_lattice_font_theme)
  
  
  # HEATMAP 1
  output$p4_plot_hour_heatmap <- renderPlot({
    req(df_hours(), index_cats_subset())
    
    df_h <- df_hours()
    index_subset <- index_cats_subset()
    
    # Filter the dataframe to include only the subset of index values
    df_h <- df_h %>% filter(index %in% index_subset)
    
    # Sort the dataframe based on the 'index' column
    df_h <- df_h[order(df_h$index, decreasing = FALSE), ]

    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)
    
    p1 <- levelplot(
      norm ~ factor(index, levels = unique(df_h$index)) * 
        factor(hour, levels = rev(unique(df_h$hour))),
      data = df_h,
      ylab = list(label = "Hour of Day", cex = 1.4),
      xlab = list(label = "Index", cex = 1.4),
      col.regions = diverging_colors,
      colorkey = TRUE,
      scales = list(
        x = list(rot = 25, cex = 1.3),
        y = list(cex = 1.3)
      ),
      par.settings = list(
        strip.background = list(col = "white"),
        strip.shingle = list(col = "white"),
        par.strip.text = list(cex = 1.3)
      )
    )
    return(p1)
  })
  
  # HEATMAP 2
  output$p4_plot_hour_location_heatmap <- renderPlot({
    req(df_hour_location_norm())
    
    df_hour_location <- df_hour_location_norm()
    
    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)
    p2 <- levelplot(
      norm ~ as.factor(Dataset) * 
        factor(hour, levels = rev(unique(df_hour_location$hour))),
      data = df_hour_location,
      ylab = list(label = "Hour of Day", cex = 1.4),
      xlab = list(label = "Dataset", cex = 1.4),
      col.regions = diverging_colors,
      colorkey = TRUE,
      scales = list(
        x = list(rot = 25, cex = 1.3),
        y = list(cex = 1.3)
      ),
      par.settings = list(
        strip.background = list(col = "white"),
        strip.shingle = list(col = "white"),
        par.strip.text = list(cex = 1.3)
      )
    )
    return(p2)
  })
  
  # HEATMAP 3
  output$p4_plot_hour_day_heatmap <- renderPlot({
    req(df_hour_day_norm())
    
    df_hour_day <- df_hour_day_norm()
    
    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)
    
    p3 <- levelplot(
      norm ~ as.factor(day) * 
        factor(hour, levels = rev(unique(df_hour_day$hour))),
      data = df_hour_day,
      ylab = list(label = "Hour of Day", cex = 1.4),
      xlab = list(label = "Date", cex = 1.4),
      col.regions = diverging_colors,
      colorkey = TRUE,
      scales = list(
        x = list(rot = 45, cex = 1.3),
        y = list(cex = 1.3)
      ),
      par.settings = list(
        strip.background = list(col = "white"),
        strip.shingle = list(col = "white"),
        par.strip.text = list(cex = 1.3)
      )
    )
    return(p3)
  })
  
}
