server_tab5 <- function(input, output, session) {
  
  # Function to select the appropriate dataset
  the_dataset <- reactive({
    if (input$normPick == "No") {df_aco} else {df_aco_norm}})
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t5_datasetPick", unique_datasets)
  
  # Index drop down selector
  selected_index <- server_indexPicker("t5_indexPick")
  
  # Sample rate set to 16kHz for all
  sr <- 16
  
  
  # Get the required data subset 
  df_dat <- reactive({
    req(the_dataset(), selected_dataset())
    
    the_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == sr,
             FFT == 512) 
  })
  
  # Prep the data for dygraphs
  df_durations <- reactive({
    req(df_dat(), selected_index())
    
    unq_durations <- as.character(df_dat() %>%
                                    distinct(Duration_sec) %>%
                                    pull())
    
    df_dat() %>%
      filter(month(start_time) == 2) %>%
      pivot_wider(
        names_from = Duration_sec,
        values_from = all_of(selected_index()),
        values_fill = list(value = NA) # Ensure NA is filled for missing values
      ) %>%
      group_by(start_time) %>%
      summarize(across(everything(), ~ max(.x, na.rm = TRUE))) %>%
      select(start_time, all_of(unq_durations)) %>%
      arrange(start_time)
  })
  
  # PLOT
  output$t5_plot_duration <- renderDygraph({
    req(df_durations())
    
    p <- dygraph(df_durations(), x = "start_time") %>%
      dyRangeSelector(height = 30)
    
    return(p)
  })
  
  
  
}
