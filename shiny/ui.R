library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(lubridate)
library(corrplot)
library(duckdb)


ui <- page_sidebar(
  title = "BioSound MBON Project Dashboard",
  fillable=FALSE,
  sidebar = sidebar(
    title="More info",
    "Select an index to and date range to view a time series",
    selectInput("selectedIndices", "Choose a Column:",
                choices = index_columns,
                selected = "ACI",
                multiple = TRUE),
    dateRangeInput("dateRange",
                   label = "Select Date Range:",
                   start = date_range$MinDate,
                   end = date_range$MaxDate,
                   min = date_range$MinDate,
                   max = date_range$MaxDate)

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
  ),
  card(
    height=500,
    card_header("Line plot"),
    plotOutput("line_plot")
  )
  
)