server_tab2 <- function(input, output, session) {

  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t2_datasetPick", unique_datasets_ann)

  # Index drop down selector
  selected_indices <- server_indexPicker("t2_indexPick")

  # Species drop down selector
  selected_species <- server_speciesPicker("t2_speciesPick", selected_dataset)

  # Sample Rate list
  this_unique_sr <- reactive({
    df_aco_norm %>%
      filter(Dataset == selected_dataset()) %>%
      distinct(Sampling_Rate_kHz) %>%
      pull(Sampling_Rate_kHz)
  })

  # Duration list
  this_unique_durations <- reactive({
    df_aco_norm %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == this_unique_sr()[1]) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
  })

  # # Testing
  # observe({
  #   print("Current dataset selection: ")
  #   print(selected_dataset())
  #   print("Current duration selection: ")
  #   print(this_unique_durations()[1])
  # })

  # Reactive: Filtered Data Subset
  # Note that for now we're just grabbing the first available sample
  # rate and duration, but these can be specified later as needed.
  subset_df <- reactive({
    req(selected_dataset(), selected_sr(), selected_duration())
    fcn_filterAco(df_aco_norm, selected_dataset(),
                  this_unique_sr()[1], this_unique_durations()[1])
  })

  # Reactive: Index Picks
  df_indexPicks <- reactive({
    req(subset_df(), selected_indices())
    subset_df() %>% select(start_time, selected_indices())
  })

}
