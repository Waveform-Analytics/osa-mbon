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