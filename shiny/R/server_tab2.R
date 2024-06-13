# Acoustic indices + annotations

server_tab2 <- function(input, output, session) {
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t2_datasetPick", unique_datasets_ann)
  
  # Index drop down selector
  selected_index <- server_indexPicker("t2_indexPick")
  
  # Species drop down selector
  selected_species <- server_speciesPicker("t2_speciesPick", selected_dataset)
  
  # Sample Rate list
  selected_sr <- reactive({
    req(selected_dataset())
    sr_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset()) %>%
      distinct(Sampling_Rate_kHz) %>%
      pull(Sampling_Rate_kHz)
    # sr_subset[1]
    max(sr_subset)
  })
  
  # Duration list
  selected_duration <- reactive({
    req(selected_dataset(), selected_sr())
    duration_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr()) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    # duration_subset[1]
    max(duration_subset)
  })
  
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

  # Prep annotations data
  df_ann_spp <- reactive({
    req(subset_df(), selected_index(), selected_species())
    
    spp <- selected_species()
    
    AA <- subset_df() %>%
      select(start_time, all_of(selected_index()), all_of(selected_species())) %>%
      rename("index" = all_of(selected_index())) %>%
      pivot_longer(cols = all_of(selected_species()), 
                   names_to = "Labels", 
                   values_to = "is_present")
    AA$is_present <- ifelse(AA$is_present == 1, "Present", "Absent")
    
    spp_n <- paste0(selected_species(), "_n")

    AB <- subset_df() %>%
      select(start_time, all_of(selected_index()), all_of(spp_n)) %>%
      pivot_longer(cols = all_of(spp_n),
                   names_to = "Labels",
                   values_to = "count")
    AA$count <- AB$count
    
    return(AA)
  })
  
  # Reactive: subset of annotations data where is_present == TRUE
  df_present <- reactive({
    req(df_ann_spp())
    df_ann_spp() %>% filter(is_present == "Present")
  })
  
  ########################################################################
  ########################################################################
  # Add Annotations Text info
  output$text_output_anno_kw <- renderUI({
    # Need to update column names to match what is expected by 
    # index_description_text
    fish_codes <- fish_codes %>% 
      filter(Dataset == "Key West, FL") %>%
      rename(index = code, Description = name)
    
    index_description_text(fish_codes)
  })
  
  output$text_output_anno_mr <- renderUI({
    # Need to update column names to match what is expected by 
    # index_description_text
    fish_codes <- fish_codes %>% 
      filter(Dataset == "May River, SC") %>%
      rename(index = code, Description = name)
    
    index_description_text(fish_codes)
  })
  
  ########################################################################
  ########################################################################
  # PLOTTING
  
  output$p2_plot_ts <- renderPlotly({
    req(df_indexPicks(), df_present(), selected_index())
    
    # Extract the necessary data
    index_data <- df_indexPicks() %>% arrange(start_time)
    present_data <- df_present() %>% arrange(start_time)
    
    # Start by plotting present data with species color
    p <- plot_ly()
    
    p <- p %>% add_trace(data=index_data, 
                         x=~start_time, y=~index,
                         type='scatter', mode='lines', 
                         line = list(color = 'gray'),
                         showlegend=FALSE)
    
    p <- p %>% add_markers(data=present_data, name=~Labels,
                           x=~start_time, y=~index, 
                           color=~Labels, size=~count,
                           showlegend=TRUE)
    
    custom_plotly(p)
  })
  
  # PLOT 2
  output$p2_plot_box <- renderPlot({
    req(df_ann_spp(), selected_index())
    
    df_spp <- df_ann_spp()
    
    # TODO: make this a user option. 
    # # With outliers:
    # min_scale <- 0
    # max_scale <- 1
    # outlier_shape <- 19
    
    # No outliers:
    outlier_shape <- NA
    min_scale <- 0.1
    max_scale <- 0.9
    
    # Create the plot
    p2 <- ggplot(df_spp, aes(x=Labels, y=index, fill=is_present)) +
      geom_boxplot(outlier.shape = outlier_shape) +
      scale_y_continuous(limits = quantile(df_spp$index, c(min_scale, max_scale)))
      labs(title = paste0(selected_index(), ": Species and Presence"),
           x = "Annotation", y = "Index", fill = NULL) +

    print(p2)
  })
  
  
}
