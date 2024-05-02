server_tab1 <- function(input, output, session) {

  # Helper function to update select inputs more cleanly
  observeUpdateSelectInput <- function(session, inputId, choices) {
    updateSelectInput(session, inputId, choices = choices)
  }

  # Function to select the appropriate dataset
  get_dataset <- reactive({
    if (input$normPick == "No") {
      df_aco
    } else {
      df_aco_norm
    }
  })

  # server_indexPicker("t1_indexPick")
  selected_dataset <- server_datasetPicker("t1_datasetPick")
  selected_indices <- server_indexPicker("t1_indexPick")
  selected_sr <- reactive({
    server_srPicker("t1_srPick", get_dataset(), selected_dataset())
  })

  # Use this reactive expression like a function to get the current value
  observe({
    test <- selected_sr()
    print("Print out the selection:")
    print(test)
  })

  # # Reactive: Unique Sample Rates
  # unique_sr_pick <- reactive({
  #   req(input$normPick, selected_dataset())
  #   get_dataset() %>%
  #     filter(Dataset == selected_dataset()) %>%
  #     distinct(Sampling_Rate_kHz) %>%
  #     pull(Sampling_Rate_kHz)
  # })
  #
  # # Observer: Update Sample Rate Dropdown
  # observe({
  #   observeUpdateSelectInput(session, "p1SampleRatePick", choices = unique_sr_pick())
  # })

  # Reactive: Unique Durations
  unique_durations_pick <- reactive({
    req(selected_dataset(), selected_sr())
    get_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr()) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
  })

  # Observer: Update Duration Dropdown
  observe({
    observeUpdateSelectInput(session, "p1DurationPick", choices = unique_durations_pick())
  })

  # Reactive: Unique FFT Lengths
  unique_fft_pick <- reactive({
    req(selected_dataset(), selected_sr(), input$p1DurationPick)
    get_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr(),
             Duration_sec == input$p1DurationPick) %>%
      distinct(FFT) %>%
      pull(FFT)
  })

  # Observer: Update FFT Dropdown
  observe({
    observeUpdateSelectInput(session, "p1FFTPick", choices = unique_fft_pick())
  })

  # Reactive: Filtered Data Subset
  subset_df <- reactive({
    req(selected_dataset(), selected_sr(), input$p1DurationPick)
    get_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr(),
             Duration_sec == input$p1DurationPick)
  })

  # Reactive: Index Picks
  df_indexPicks <- reactive({
    req(subset_df(), selected_indices())
    subset_df() %>%
      select(start_time, selected_indices())
  })

  # Render Dygraph
  output$p1_plot_ts <- renderDygraph({
    req(df_indexPicks())
    df_idxPicks <- df_indexPicks()
    if (nrow(df_idxPicks) == 0) {
      return(NULL)  # Return NULL if empty
    }

    # Create dygraph plot
    dygraph(df_idxPicks, x = "start_time") %>%
      dyRangeSelector(height = 30)
  })
}
