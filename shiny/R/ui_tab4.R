ui_tab4 <- function() {
  
  tagList(
    
    br(),
    h2("Indices vs Hour of day"),
    p(
      "The heatmap on this tab illustrates how indices vary with time of day"
    ),
    
    layout_sidebar(
      fillable=FALSE,
      sidebar = sidebar(
        title = "Options",
        ui_datasetPicker("t4_datasetPick", unique_datasets, FALSE),
        ui_srPicker("t4_srPick"),
        
      ),
      
      card(
        plotOutput("p4_plot_hour_heatmap", height = 600),
      )
      
      
    )
  )
  
  
}