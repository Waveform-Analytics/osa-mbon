# INDICES VS HOUR OF DAY
server_tab4 <- function(input, output, session) {
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t4_datasetPick", unique_datasets)
  
  # Hard coding the normalized dataset and making it reactive
  get_dataset <- reactive({
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
    this_dataset <- get_dataset()
    sr <- selected_sr()
    
    duration_subset <- this_dataset %>%
      filter(Dataset == dataset, Sampling_Rate_kHz == sr) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    
    # Filtered Data Subset
    this_subset_df <-
      fcn_filterAco(get_dataset(), dataset, sr, duration_subset[1])
    
    # Add hour of day column, make it a factor
    this_subset_df$hour <- hour(this_subset_df$start_time)
    
    return(this_subset_df)
    
  })
  
  # Get a subset with all datasets
  df_subset_all <- reactive({
    req(get_dataset(), selected_sr())
    
    this_dataset <- get_dataset()
    sr <- selected_sr()
    
    this_dataset
    
    
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
  ##### PREP data for 2nd plot (day vs hour of day)
  
  df_hour_day_norm <- reactive({
    req(selected_sr(), selected_index(), subset_df())
    
    this_index <- selected_index()
    sub_df <- subset_df()
    
    df_hour_date <-
      sub_df %>%
      filter(month(start_time) == 2) %>%
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
  
  # HEATMAP 1
  output$p4_plot_hour_heatmap <- renderPlot({
    req(df_hours(), index_cats_subset())
    
    df_h <- df_hours()
    index_subset <- index_cats_subset()
    
    # Filter the dataframe to include only the subset of index values
    df_h <- df_h %>% filter(index %in% index_subset)
    
    # Sort the dataframe based on the 'index' column
    df_h <- df_h[order(df_h$index, decreasing = TRUE), ]
    
    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)
    p1 <- levelplot(
      norm ~ factor(index, levels = unique(df_h$index)) * as.factor(hour),
      data = df_h,
      ylab = "Hour of Day",
      xlab = "Index",
      col.regions = diverging_colors,
      colorkey = TRUE,
      scales = list(x = list(rot = 90))  
    )  
    return(p1)
  })
  
  # HEATMAP 2
  output$p4_plot_hour_location_heatmap <- renderPlot({
    req(df_hour_day_norm())
    
    df_hour_day <- df_hour_day_norm()
    
    print(names(df_hour_day))
    
    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)
    p2 <- levelplot(
      norm ~ as.factor(day) * as.factor(hour),
      data = df_hour_day,
      ylab = "Hour of Day",
      xlab = "Date",
      col.regions = diverging_colors,
      colorkey = TRUE,
      scales = list(x = list(rot = 90)) 
    )  
    return(p2)
  })
  
  # HEATMAP 3
  output$p4_plot_hour_day_heatmap <- renderPlot({
    req(df_hour_day_norm())
    
    df_hour_day <- df_hour_day_norm()
    
    print(names(df_hour_day))
    
    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)
    p2 <- levelplot(
      norm ~ as.factor(day) * as.factor(hour),
      data = df_hour_day,
      ylab = "Hour of Day",
      xlab = "Date",
      col.regions = diverging_colors,
      colorkey = TRUE,
      scales = list(x = list(rot = 90)) 
    )  
    return(p2)
  })
  
}
