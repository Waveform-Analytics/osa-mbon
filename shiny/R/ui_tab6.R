ui_tab6 <- function() {
  tagList(
    br(),
    h2("Ship Annotations"),
    withMathJax(),
    p(
      "Replace with text from Liz."
    ),
    
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_datasetPicker("t6_datasetPick", unique_datasets, FALSE),
        ui_indexPicker("t6_indexPick", FALSE),
        radioButtons("normPick", "Normalize values?", c("Yes", "No")),
      ),
      card(
        # A comparison of different durations for a single selected dataset
        dygraphOutput("t6_plot_ships"),
      ),
    ),
  )
}