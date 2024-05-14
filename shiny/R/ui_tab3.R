ui_tab3 <- function() {
  
  tagList(
    
    br(),
    h2("Water Classes"),
    p(
      "The plots on this tab present acoustic index and water class data together."
    ),
    
    layout_sidebar(
      fillable=FALSE,
      sidebar = sidebar(
        title = "Options",
        ui_datasetPicker("t3_datasetPick", unique_datasets, FALSE),
        ui_indexPicker("t3_indexPick", FALSE),
        ui_classPicker("t3_classPick", FALSE)
        
      )
    )
  )
}