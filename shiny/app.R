library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(lubridate)
library(corrplot)

ui <- page_sidebar(
  title = "BioSound MBON Project Dashboard",
  fillable=FALSE,
  sidebar = sidebar(
    title="More info",
    "App sidebar - nothing here yet but maybe we could add selections for things like location or sample rate etc."
    ),
  card(
    height=400,
    card_header("Acoustic indices & fish annotations"),
    plotlyOutput("plot")
  ),
  card(
    height=500,
    card_header("Correlation matrix"),
    plotOutput("corrPlot")
  )
)

server <- function(input, output) {
  
  indices_table <- read.csv("./shinydata/keywest-withfish.csv")
  indices_table <- indices_table %>%
    mutate(datetime = ymd_hms(datetime))
  
  output$corrPlot <- renderPlot({
    
    # Select only the acoustic index columns
    index_columns <- names(indices_table)[3:15]
    # Calculate the correlation matrix
    cor_matrix <- cor(indices_table[index_columns])
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
}


# Run the app ----
shinyApp(ui = ui, server = server)
