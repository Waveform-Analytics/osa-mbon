source("R/mod_datasetPicker.R")
source("R/mod_indexPicker.R")
source("R/mod_srPicker.R")
source("R/mod_durationPicker.R")

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
      ui_indexPicker("t1_indexPick", TRUE),
      ui_datasetPicker("t1_datasetPick", unique_datasets, FALSE),
      ui_srPicker("t1_srPick"),
      ui_durationPicker("t1_durationPick"),
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
