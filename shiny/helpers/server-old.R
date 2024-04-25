server <- function(input, output, session) {
  # Filter data based on selected dataset
  data_subset <- reactive({
    req(input$selectedDataset, acoustic_indices)
    df_aco %>%
      filter((Dataset == input$selectedDataset) & (FFT == 512)) %>%
      collect()
  })
  
  # Filter data based on selected indices
  filtered_data <- reactive({
    req(input$dateRange,
        input$selectedIndices,
        input$selectedDataset)
    df_subset <-
      data_subset()[, c("Date", input$selectedIndices), drop = FALSE]
    pivot_longer(
      df_subset,
      cols = -Date,
      names_to = "Index",
      values_to = "Value"
    )
  })
  
  # Filter data based on selected date range
  df_line_sub <- reactive({
    data <- filtered_data()
    data[data$Date >= input$dateRange[1] &
           data$Date <= input$dateRange[2],]
  })
  
  # Generate the acoustic indices line plot
  output$line_plot <- renderPlot({
    req(df_line_sub())
    data <- df_line_sub()
    
    data_norm <- data %>%
      group_by(Index) %>%
      mutate(normValue = (Value - median(Value)) / abs(max(Value - median(Value)))) %>%
      ungroup()
    
    ggplot(data_norm,
           aes(x = Date, y = normValue, color = Index)) +
      geom_line() +
      labs(title = "Time Series of Selected Indices", x = "Date", y = "Index Value") +
      theme_minimal() +
      scale_color_brewer(palette = "Dark2")
  })
  
  # Generate the correlation plot
  output$corrPlot <- renderPlot({
    cor_matrix <- cor(data_subset()[index_columns])
    # Plot the correlation matrix
    corrplot(
      cor_matrix,
      type = 'lower',
      order = 'hclust',
      tl.col = 'black',
      cl.ratio = 0.2,
      tl.srt = 45,
      col = COL2('PuOr', 10)
    )
  })
  
  
  # Cleanup on session end
  session$onSessionEnded(function() {
    dbDisconnect(con)
  })
}