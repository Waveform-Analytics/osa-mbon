ui_tab1 <- function(unq_datasets) {
  tagList(
    br(),
    h2("Overview of all datasets"),
    p(
      "This tab presents an overview of the acoustic indices
          and water class data for all datasets."
    ),
    
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_indexPicker("t1_indexPick", TRUE),
        radioButtons("normPick", "Normalize values?", c("Yes", "No")),
      ),
      card(
        h4("Key West"),
        dygraphOutput("p1_plot_ts_keywest"),
      ),
      card(
        h4("May River"),
        dygraphOutput("p1_plot_ts_mayriver"),
      ),
    ),
  )
}