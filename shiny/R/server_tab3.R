server_tab3 <- function(input, output, session) {
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t3_datasetPick", unq_datasets)
  
  # Index drop down selector
  selected_index <- server_indexPicker("t3_indexPick")
  
  # Sample Rate list
  selected_sr <- reactive({
    req(selected_dataset())
    sr_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset()) %>%
      distinct(Sampling_Rate_kHz) %>%
      pull(Sampling_Rate_kHz)
    sr_subset[1]
  })
  
  # Duration list
  selected_duration <- reactive({
    req(selected_dataset(), selected_sr())
    duration_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr()) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    duration_subset[1]
  })
  
  # Get the selected water class dataframe
  df_seascaper_sub <- reactive({
    req(selected_dataset())
    df_seascaper %>%
      filter(Dataset == selected_dataset(), !is.na(cellvalue))
  })
  
  unique_classes <- reactive({
    req(df_seascaper_sub())
    as.character(df_seascaper_sub() %>%
                   distinct(cellvalue) %>%
                   pull())
  })
    
  unique_classes_numeric <-  reactive({
    req(df_seascaper_sub())
    df_seascaper_sub() %>%
      distinct(cellvalue) %>%
      arrange(cellvalue) %>%
      pull()
  })
  
  # Prepare water class data
  # water class percentages
  df_water <- reactive({
    req(df_seascaper_sub())
    df_seascaper_sub() %>%
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
    return(df_water)
  })
  
  # Reactive: Filtered Data Subset
  # Note that for now we're just grabbing the first available sample
  # rate and duration, but these can be specified later as needed.
  subset_df <- reactive({
    req(selected_dataset(), selected_sr(), selected_duration())
    fcn_filterAco(df_aco_norm, selected_dataset(),
                  selected_sr(), selected_duration())
  })
  
}