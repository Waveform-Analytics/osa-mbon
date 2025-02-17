server_tab5 <- function(input, output, session) {
  
  # Function to select the appropriate dataset
  the_dataset <- reactive({
    if (input$normPick == "No") {df_aco} else {df_aco_norm}})
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t5_datasetPick", unique_duration_datasets)
  
  # Index drop down selector
  selected_index <- server_indexPicker("t5_indexPick")
  
  # Sample rate set to 16kHz for all
  sr <- 16
  
  # FFT length set to 512 for all
  fft <- 512
  
  
  # Get the required data subset 
  df_dat <- reactive({
    req(the_dataset(), selected_dataset())
    
    the_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == sr,
             FFT == fft) 
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
        values_fill = list(value = NA)
      ) %>%
      group_by(start_time) %>%
      summarize(across(everything(), ~ if(all(is.na(.x))) NA else max(.x, na.rm = TRUE))) %>%
      select(start_time, all_of(unq_durations)) %>%
      arrange(start_time) %>%
      # Fill small gaps to ensure continuous lines
      mutate(across(-start_time, ~ na.approx(.x, maxgap = 2, na.rm = FALSE)))
  })
  
  # Plot generation function
  generate_duration_plot <- function() {
    req(df_durations())
    
    # For static version (for download), create a ggplot
    df_plot <- df_durations()
    
    # Convert to long format for ggplot
    df_long <- df_plot %>%
      tidyr::pivot_longer(
        cols = -start_time,
        names_to = "Duration",
        values_to = "Value"
      )
    
    ggplot(df_long, aes(x = start_time, y = Value, color = Duration)) +
      geom_line() +
      labs(x = "Time", y = "Value") +
      theme_minimal() +
      theme(
        panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        legend.position = "bottom",
        legend.title = element_blank()
      )
  }
  
  # Interactive plot output
  output$t5_plot_duration <- renderDygraph({
    req(df_durations())
    
    dygraph(df_durations(), x = "start_time") %>%
      dyRangeSelector(height = 30)
  })
  
  # Download handler
  output$download_duration <- create_download_handler("ggplot", generate_duration_plot, "duration_comparison")
}
