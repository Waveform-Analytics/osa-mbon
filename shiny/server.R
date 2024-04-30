server <- function(input, output, session) {
  # bs_themer()
  
  # Get all of the unique sample rates for the selected dataset
  unique_sr_pick <- reactive({
    df_aco %>% 
      filter(Dataset == input$p1DatasetPick) %>%
      select(Sampling_Rate_kHz) %>%
      distinct()
  })
  
  # Update choices for sample rate drop down based on the selected Dataset
  observe({
    updateSelectInput(session, "p1SampleRatePick",
                      choices = unique_sr_pick()$Sampling_Rate_kHz)
  })
  
  # Get the unique durations for the selected sample rate and dataset
  unique_durations_pick <- reactive({
    df_aco %>%
      filter(Dataset == input$p1DatasetPick) %>%
      filter(Sampling_Rate_kHz == input$p1SampleRatePick) %>%
      select(Duration_sec) %>%
      distinct()
  })
  
  # Update choices for duration drop down 
  observe({
    updateSelectInput(session, "p1DurationPick",
                      choices = unique_durations_pick()$Duration_sec)
  })
  
  # Get unique fft lengths based on previous selections
  unique_fft_pick <- reactive({
    df_aco %>%
      filter(Dataset == input$p1DatasetPick) %>%
      filter(Sampling_Rate_kHz == input$p1SampleRatePick) %>%  
      filter(Duration_sec == input$p1DurationPick) %>%
      select(FFT) %>%
      distinct()
  })
  
  observe({
    updateSelectInput(session, "p1FFTPick",
                      choices = unique_fft_pick()$FFT)
  })
  
  # Extract the relevant subset based on the user's selections
  subset_df <- reactive({
    df_aco %>%
      filter(Dataset == input$p1DatasetPick, 
             Sampling_Rate_kHz == input$p1SampleRatePick, 
             Duration_sec == input$p1DurationPick)
  })
  
  # Filter subset_df based on selected value columns
  df_indexPicks <- reactive({
    req(subset_df())
    
    sub_df <- subset_df()
    selected_columns <- input$selectedIndices
    idxPicks <- sub_df[, c("start_time", selected_columns), drop = FALSE] 
    return(idxPicks)
  })
  
  ##### PLOTTING #####
  
  output$p1_plot_ts <- renderDygraph({
    req(input$p1DatasetPick, input$p1SampleRatePick, input$p1DurationPick, input$selectedIndices)
    req(df_indexPicks()) 
    
    df_idxPicks <- df_indexPicks()
    col_names_idx <- names(df_idxPicks[2:ncol(df_idxPicks)])
    plot_data <- df_idxPicks[, c("start_time", col_names_idx)]
    
    if ((length(col_names_idx) == 0) | (nrow(df_idxPicks) == 0)) {
      return(NULL)  # Return NULL if col_names_idx is empty
    }
    
    # Create dygraph plot
    dygraph(df_idxPicks, x = "start_time") %>%
      dyRangeSelector(height = 20)
    
  })
    

}
