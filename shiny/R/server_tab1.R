server_tab1 <- function(input, output, session) {

  # Helper function to update select inputs more cleanly
  observeUpdateSelectInput <- function(session, inputId, choices) {
    updateSelectInput(session, inputId, choices = choices)
  }

  # Function to select the appropriate dataset
  get_dataset <- reactive({
    if (input$normPick == "No") {df_aco} else {df_aco_norm}})

  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t1_datasetPick")

  # Index drop down selector
  selected_indices <- server_indexPicker("t1_indexPick")

  # Sample rate drop down selector
  selected_sr <- server_srPicker("t1_srPick", get_dataset, selected_dataset)

  # Duration drop down selector
  selected_duration <-
    server_durationPicker("t1_durationPick",
                          get_dataset,selected_dataset, selected_sr)

  # # Testing
  # observe({
  #   print("Current dataset selection: ")
  #   print(selected_dataset())
  #   print("Current sample rate selection: ")
  #   print(selected_sr())
  # })

  # Reactive: Filtered Data Subset
  subset_df <- reactive({
    req(selected_dataset(), selected_sr(), selected_duration())
    get_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr(),
             Duration_sec == selected_duration(),
             FFT == 512)
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
      return(NULL)
    }

    # Create dygraph plot
    dygraph(df_idxPicks, x = "start_time") %>%
      dyRangeSelector(height = 30)
  })
}
