server_tab2 <- function(input, output, session) {

  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t2_datasetPick", unique_datasets_ann)

  # Index drop down selector
  selected_index <- server_indexPicker("t2_indexPick")

  # Species drop down selector
  selected_species <- server_speciesPicker("t2_speciesPick", selected_dataset)

  # Sample Rate list
  selected_sr <- reactive({
    sr_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset()) %>%
      distinct(Sampling_Rate_kHz) %>%
      pull(Sampling_Rate_kHz)
    sr_subset[1]
  })

  # Duration list
  selected_duration <- reactive({
    duration_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr()) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    duration_subset[1]
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
                  selected_sr(), selected_duration())
  })

  # Reactive: Index Picks
  df_indexPicks <- reactive({
    req(subset_df(), selected_index())
    subset_df() %>%
      select(start_time, end_time, all_of(selected_index())) %>%
      rename("index" = all_of(selected_index()))
  })

  # Reactive: Prep annotations data
  df_ann_spp <- reactive({
    req(selected_dataset(), selected_species())
    ann_spp <- df_fish %>%
      filter(species %in% selected_species(),
             Dataset == selected_dataset()) %>%
      arrange(start_time)
    temp <- get_species_presence(df_indexPicks(), ann_spp)
    temp$is_present <- ifelse(temp$is_present, "Present", "Absent")
    return(temp)
  })

  # Reactive: subset of annotations data where is_present == TRUE
  df_present <- reactive({
    req(df_ann_spp())
    df_ann_spp() %>% filter(is_present == "Present")
  })

  # PLOTTING

  # PLOT 1
  output$p2_plot_ts <- renderPlotly({
    req(df_indexPicks(), df_present(), selected_index())

    # Generate the plot using ggplot
    p1 <- ggplot(data = df_indexPicks(), aes(x = start_time, y = index)) +
      geom_line() +
      geom_point(data = df_present(), aes(color = species, shape = species), size = 1) +
      labs(title = paste0(selected_index(), " over Time with Species Presence"),
           x = "Time", y = "Index", ) +
      theme_minimal()

    # Convert to plotly
    ggplotly(p1)
  })

  # PLOT 2
  output$p2_plot_box <- renderPlot({
    req(df_ann_spp(), selected_index())

    # Create the plot
    p2 <- ggplot(df_ann_spp(), aes(x=species, y=index, fill=is_present)) +
      geom_boxplot() +
      labs(title = paste0(selected_index(), ": Species and Presence"),
           x = "Annotation", y = "Index", fill = NULL) +
      theme_minimal() +
      theme(text = element_text(size = 14))

    # Convert to an interactive plotly plot
    print(p2)
  })


}
