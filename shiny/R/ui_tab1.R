source("R/ui_components.R")

ui_tab1 <- fluidPage(
  br(),
  h2("Overview of all datasets"),
  p(
    "This tab presents an overview of the acoustic indices
          and water class data for all datasets."
  ),

  layout_sidebar(
    fillable=FALSE,
    sidebar = sidebar(
      title = "Options",
      # User selections
      ui_indexPicker("t1_indexPick"),
      ui_datasetPicker("t1_datasetPick"),
      ui_srPicker("t1_srPick"),

      # selectInput(
      #   "p1SampleRatePick",
      #   "Select Sample Rate (kHz)",
      #   choices = unique_sr,
      # ),
      selectInput(
        "p1DurationPick",
        "Select Duration (seconds)",
        choices = unique_durations,
      ),
      radioButtons(
        "normPick",
        "Normalize values?",
        c("Yes", "No")
      ),
    ),
    card(
      card_header("Acoustic Indices"),
      dygraphOutput("p1_plot_ts"),
    ),
  ),
)
