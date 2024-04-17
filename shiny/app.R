library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(lubridate)

ui <- page_sidebar(
  title = "BioSound MBON Project Dashboard",
  sidebar = sidebar(
    title="More info",
    "App sidebar - nothing here yet but maybe we could add selections for things like location or sample rate etc."
    ),
  card(
    card_header("Acoustic indices & fish annotations"),
    plotlyOutput("plot") 
  )
)

server <- function(input, output) {
  output$plot <- renderPlotly({
    # Load the initial sample data (this will eventually be updated based on user selection)
    indices_table <- read.csv("./data/keywest-withfish.csv")
    indices_table <- indices_table %>%
      mutate(datetime = ymd_hms(datetime))
    
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