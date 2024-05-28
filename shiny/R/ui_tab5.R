ui_tab5 <- function() {
  tagList(
    br(),
    h2("Duration comparisons"),
    withMathJax(),
    p(
      "Replace with text from Liz."
    ),
    
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_datasetPicker("t5_datasetPick", unique_datasets,FALSE),
        ui_indexPicker("t5_indexPick", FALSE),
        radioButtons("normPick", "Normalize values?", c("Yes", "No")),
      ),
      card(
        # A comparison of different durations for a single selected dataset
        dygraphOutput("t5_plot_duration"),
      ),
    ),
  )
}