# INDICES VS HOUR OF DAY
server_tab4 <- function(input, output, session) {
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t4_datasetPick", unique_datasets)
  
  # Hard coding the normalized dataset and making it reactive
  get_dataset <- reactive({df_aco_norm})
  
  selected_sr <- server_srPicker("t4_srPick", get_dataset, selected_dataset)
  
  # Index drop down selector
  # selected_index <- server_indexPicker("t4_indexPick")
  
  # Index category selector
  selected_cat <- server_catPicker("t4_catPick", unique_index_types)
  
  selected_index <- server_subIndexPicker("t4_subIndexPick", selected_cat)
  
  #### Get initial subset
  subset_df <- reactive({
    req(selected_dataset(), get_dataset(), selected_sr())
    
    dataset <- selected_dataset()
    this_dataset <- get_dataset()
    sr <- selected_sr()
    
    duration_subset <- this_dataset %>%
      filter(Dataset == dataset,
             Sampling_Rate_kHz == sr) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    
    # Filtered Data Subset
    this_subset_df <-
      fcn_filterAco(get_dataset(), dataset, sr, duration_subset[1])
    
    # Add hour of day column, make it a factor
    this_subset_df$hour <- hour(this_subset_df$start_time)
    
    return(this_subset_df)
    
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
    
    print(selected_indices)
    
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
    df_hour_grouped %>%
      left_join(df_hour_med, b="index") %>%
      mutate(
        norm = (summary_val-min_val)/range
      ) %>%
      select(
        index, hour, norm
      )
  })
  
  #################################################
  ##### PREP data for 2nd plot (day vs hour of day)
  
  df_hour_day_norm <- reactive({
    req(selected_sr(), selected_index(), subset_df())
    
    this_index <- selected_index()
    sub_df <- subset_df()
    
    df_hour_date <-
      sub_df %>%
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
    
    df_hour_grouped %>%
      left_join(df_hour_med, b="day") %>%
      mutate(
        norm = (summary_val-min_val)/range
      ) %>%
      select(
        day, hour, norm
      )
    
  })
  
  
  ##########################################################
  # Text descriptions
  output$text_output <- renderUI({
    req({selected_cat()})
    
    this_selected_cat <- selected_cat()
    
    df_index_cats_subset <- df_index_cats %>%
      filter(Category == this_selected_cat) %>%
      pull()
      
    generate_text_from_df(df_index_cats_subset)
  })
  
  
  ##########################################################
  # PLOTTING
  
  # HEATMAP 1
  output$p4_plot_hour_heatmap <- renderPlot({
    req(df_hours())
    
    df_h <- df_hours()
    
    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)  
    p1 <- levelplot(norm ~ as.factor(hour) * as.factor(index), data = df_h,
                      xlab = "Hour of Day",  # Rename x-axis
                      ylab = "Index",  # Rename y-axis
                      col.regions = diverging_colors,  # Use the diverging color scale
                      colorkey = TRUE)  # Enable color key
    return(p1)
  })
  
  # HEATMAP 2
  output$p4_plot_hour_day_heatmap <- renderPlot({
    req(df_hour_day_norm())
    
    df_hour_day <- df_hour_day_norm()
    
    diverging_colors <- colorRampPalette(brewer.pal(9, "GnBu"))(100)  
    p2 <- levelplot(norm ~ as.factor(hour) * as.factor(day), data = df_hour_day,
                      xlab = "Hour of Day",  # Rename x-axis
                      ylab = "Date",  # Rename y-axis
                      col.regions = diverging_colors,  # Use the diverging color scale
                      colorkey = TRUE)  # Enable color key
    return(p2)
  })
  
}

