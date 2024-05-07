ui_tab1 <- function(unq_datasets){
  tagList(
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
        ui_datasetPicker("t1_datasetPick", unq_datasets, FALSE),
        ui_indexPicker("t1_indexPick", TRUE),
        ui_srPicker("t1_srPick"),
        ui_durationPicker("t1_durationPick"),
        radioButtons(
          "normPick",
          "Normalize values?",
          c("Yes", "No")
        ),
      ),
      layout_columns(
        card(
          h3("Indices vs Time"),
          dygraphOutput("p1_plot_ts"),
        ),
        card(
          h3("Indices vs hour of day")
          
        )
      ),
      
    ),
  )
}