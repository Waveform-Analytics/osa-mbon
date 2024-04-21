library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(lubridate)
library(corrplot)
library(duckdb)
library(ggplot2)

server <- function(input, output, session) {
  
  indices_table <- read.csv("./shinydata/keywest-withfish.csv")
  indices_table <- indices_table %>%
    mutate(datetime = ymd_hms(datetime))
  
  # Selecting only relevant columns
  df_line_sub <- reactive({
    # The following inputs are required
    req(input$dateRange, input$selectedIndices)
    
    # Subset the dataframe to include only the Date column and selected indices
    df_subset_plot_lines <- data_subset[, c("Date", input$selectedIndices), drop = FALSE]
    
    # Convert the data to long format, excluding the Date column from the pivot
    long_df <- pivot_longer(df_subset_plot_lines, cols = -Date, names_to = "Variable", values_to = "Value")
    
    # Filter the data based on the selected date range
    filtered_df <- long_df[long_df$Date >= input$dateRange[1] & long_df$Date <= input$dateRange[2], ]
    
    # Return the filtered dataframe
    filtered_df

    })
  
  output$line_plot <- renderPlot({
    req(df_line_sub()) 
    
    ggplot(df_line_sub(), 
           aes(x = Date, y = Value, color = Variable)) +
      geom_line() + 
      labs(title = "Time Series of Selected Indices", x = "Date", y = "Index Value") +
      theme_minimal() +
      scale_color_brewer(palette = "Dark2")
  })
  
  output$corrPlot <- renderPlot({
    
    # Select only the acoustic index columns
    fixed_subset_index_columns <- names(indices_table)[3:15]
    # Calculate the correlation matrix
    cor_matrix <- cor(indices_table[fixed_subset_index_columns])
    # Plot the correlation matrix
    corrplot(cor_matrix, type = 'lower', order = 'hclust', tl.col = 'black',
             cl.ratio = 0.2, tl.srt = 45, col = COL2('PuOr', 10))
  })
  
  output$plot <- renderPlotly({
    fig <- plot_ly(data = indices_table)
    fig <- fig %>%
      add_trace(
        x = ~datetime,
        y = ~ACI,
        type = 'scatter',
        mode = 'lines',
        name = 'ACI'
      ) %>%
      add_trace(
        x = ~datetime,
        y = ~ACI,
        type = 'scatter',
        mode = 'markers',
        name = 'Presence',
        marker = list(size = ~Em * 7)
      ) %>%
      layout(
        title = "Acoustic Complexity Index Over Time",
        xaxis = list(title = "Datetime"),
        yaxis = list(title = "ACI")
      )
    
    fig
  })
  
  # Cleanup on session end
  session$onSessionEnded(function() {
    dbDisconnect(con)
  })
}
