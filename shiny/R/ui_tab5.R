ui_tab5 <- function() {
  tagList(
    br(),
    h2("Duration comparisons"),
    withMathJax(),
    p(
      "Comparisons of index calculations at varied durations to evaluate how 
      measurements are impacted by time interval. Available comparisons are the 
      Key West, FL dataset at 30-second and 10-second measurement intervals, and 
      the Olowalu (Maui, HI) dataset at 300-second and 150-second measurement 
      intervals. Both datasets are compared at the 16 kHz sampling rate, and 
      results are displayed per user-defined index."
    ),
    
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_datasetPicker("t5_datasetPick", unique_duration_datasets,FALSE),
        ui_indexPicker("t5_indexPick", FALSE),
        radioButtons("normPick", "Normalize values?", 
                     choices = c("Yes", "No"), selected = "No"),
      ),
      card(
        # A comparison of different durations for a single selected dataset
        dygraphOutput("t5_plot_duration"),
        downloadButton("download_duration", "Download Plot")
      ),
    ),
  )
}