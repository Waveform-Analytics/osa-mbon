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

  selected_dataset <- server_datasetPicker("t1_datasetPick")
  selected_indices <- server_indexPicker("t1_indexPick")
  selected_sr <- reactive({
    req(get_dataset(), selected_dataset())
    server_srPicker("t1_srPick", get_dataset(),
                    selected_dataset())})
  selected_duration <- reactive({
    req(get_dataset(), selected_dataset(), selected_sr())
    server_durationPicker("t1_durationPick", get_dataset(),
                          selected_dataset(), selected_sr())})

  # Testing
  # observe({
  #   test <- selected_sr()
  #   print("Print out the selection:")
  #   print(test)
  # })

  # # Reactive: Unique Durations
  # unique_durations_pick <- reactive({
  #   req(selected_dataset(), selected_sr())
  #   get_dataset() %>%
  #     filter(Dataset == selected_dataset(),
  #            Sampling_Rate_kHz == selected_sr()) %>%
  #     distinct(Duration_sec) %>%
  #     pull(Duration_sec)
  # })
  #
  # # Observer: Update Duration Dropdown
  # observe({
  #   observeUpdateSelectInput(session, "p1DurationPick", choices = unique_durations_pick())
  # })

  # Reactive: Filtered Data Subset
  subset_df <- reactive({
    req(selected_dataset(), selected_sr(), selected_duration())
    get_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr(),
             Duration_sec == selected_duration())
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
