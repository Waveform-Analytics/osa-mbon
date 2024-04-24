server <- function(input, output, session) {
  # bs_themer()
  
  # Filter data based on 
  filtered_data <- reactive({
    req(input$dateRange, input$selectedIndices, input$selectedDataset)
    df_subset <- data_subset[, c("Date", input$selectedIndices), drop = FALSE]
    pivot_longer(df_subset, cols = -Date, names_to = "Index", values_to = "Value")
  })
  
  # Generate data subset for the line plot
  df_line_sub <- reactive({
    # The following inputs are required
    req(input$dateRange, input$selectedIndices, input$selectedDataset)
    
    # Subset the dataframe to include only the Date column and selected indices
    df_subset_plot_lines <- data_subset[, c("Date", input$selectedIndices), drop = FALSE]
    
    # Convert the data to long format, excluding the Date column from the pivot
    long_df <- pivot_longer(df_subset_plot_lines, cols = -Date, names_to = "Index", values_to = "Value")
    
    # Filter the data based on the selected date range
    filtered_df <- long_df[long_df$Date >= input$dateRange[1] & long_df$Date <= input$dateRange[2], ]
    
    # Return the filtered dataframe
    filtered_df
  })
  
  output$line_plot <- renderPlot({
    req(df_line_sub()) 
    
    data <- df_line_sub()
    
    data_norm <- data %>%
      group_by(Index) %>%
      mutate(normValue = (Value - median(Value)) / abs(max(Value - median(Value))) ) %>%
      ungroup()
    
    ggplot(data_norm, 
           aes(x = Date, y = normValue, color = Index)) +
      geom_line() + 
      labs(title = "Time Series of Selected Indices", x = "Date", y = "Index Value") +
      theme_minimal() +
      scale_color_brewer(palette = "Dark2")
  })
  
  output$corrPlot <- renderPlot({
    
    cor_matrix <- cor(data_subset[index_columns])
    # Plot the correlation matrix
    corrplot(cor_matrix, type = 'lower', order = 'hclust', tl.col = 'black',
             cl.ratio = 0.2, tl.srt = 45, col = COL2('PuOr', 10))
  })
  
  
  # Cleanup on session end
  session$onSessionEnded(function() {
    dbDisconnect(con)
  })
}
