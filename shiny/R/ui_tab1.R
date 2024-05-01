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
      
      selectInput(
        "selectedIndices",
        "Select Indices:",
        choices = index_columns,
        selected = index_columns[1],
        multiple = TRUE
      ),
      selectInput(
        "p1DatasetPick",
        "Select Dataset",
        choices = unique_datasets$Dataset,
        selected = unique_datasets$Dataset[1],
      ),
      selectInput(
        "p1SampleRatePick",
        "Select Sample Rate (kHz)",
        choices = unique_sr$Sampling_Rate_kHz,
      ),
      selectInput(
        "p1DurationPick",
        "Select Duration (seconds)",
        choices = unique_durations$Duration_sec,
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