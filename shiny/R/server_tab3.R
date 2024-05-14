server_tab3 <- function(input, output, session) {
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t3_datasetPick", unique_datasets)
  
  # Index drop down selector
  selected_index <- server_indexPicker("t3_indexPick")
  
  # Class drop down selector
  selected_class <- server_classPicker("t3_classPick")
  
  # Selected sample rate (not a user choice)
  selected_sr <- reactive({
    req(selected_dataset())
    sr_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset()) %>%
      distinct(Sampling_Rate_kHz) %>%
      pull(Sampling_Rate_kHz)
    sr_subset[1]
  })
  
  # Selected duration (not a user choice)
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
    df_temp<- 
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
    df_temp$class <- as.factor(df_temp$class)
    return(df_temp)
  })
  
  # Get the list of dates from thie water column subset
  dates_list <- reactive({
    df_seascaper_sub() %>% 
      distinct(date) %>% 
      pull()
  })
  
  # Reactive: Filtered Data Subset
  # Note that for now we're just grabbing the first available sample
  # rate and duration, but these can be specified later as needed.
  df_filt <- reactive({
    req(selected_dataset(), selected_sr(), selected_duration())
    fcn_filterAco(df_aco_norm, selected_dataset(),
                  selected_sr(), selected_duration())
  })
  
  # 
  df_idx <- reactive({
    req(selected_index(), df_filt())
    df_idx_temp <- 
      df_filt() %>% 
      select(start_time, all_of(selected_index())) %>%
      mutate(date = cut(start_time, 
                        breaks = dates_list, 
                        include.lowest = TRUE, 
                        right = FALSE),
             date = as.POSIXct(date)) %>%
      rename(index = all_of(selected_index()))
    df_idx_temp$date <- as.factor(df_idx_temp$date)
    return(df_idx_temp)
  })
  
  
  df_combo <- reactive({
    df_idx_summ <- df_idx() %>%
      group_by(date) %>%
      summarise(mean = mean(index))
    df_water$date <- as.factor(df_water$date)
    df_idx_summ_temp <- left_join(df_idx_summ, df_water, by = "date")
    return(df_idx_summ_temp)
  })
  
  df_idx_big <- reactive({
    req(df_filt())
    df_temp <- 
      df_filt() %>% 
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
    df_temp$date <- as.factor(df_temp$date)
    return(df_idx)
  })
  
}