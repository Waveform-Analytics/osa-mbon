server_tab4 <- function(input, output, session) {
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t4_datasetPick", unique_datasets)
  
  # Hard coding the normalized dataset and making it reactive
  get_dataset <- reactive({df_aco_norm})
  
  selected_sr <- server_srPicker("t4_srPick", get_dataset, selected_dataset)
  
  # Function to prep and filter the dataset for the heatmap
  df_hours <- reactive({
    req(selected_sr(), selected_dataset())
    
    sr <- selected_sr()
    dataset <- selected_dataset()
    
    duration_subset <- get_dataset() %>%
      filter(Dataset == dataset,
             Sampling_Rate_kHz == sr) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    
    print("selected dataset")
    print(dataset)
    
    print("Duration subset")
    print(duration_subset)
    
    # Filtered Data Subset
    subset_df <-
      fcn_filterAco(get_dataset(), dataset, sr, duration_subset()[1])
    
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
    
    df_hour_grouped %>%
      left_join(df_hour_med, b="index") %>%
      mutate(
        norm = (summary_val-min_val)/range
      ) %>%
      select(
        index, hour, norm
      )
    
  })
  
}