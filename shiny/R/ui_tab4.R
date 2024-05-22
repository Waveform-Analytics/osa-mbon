ui_tab4 <- function() {
  
  tagList(
    
    br(),
    h2("Indices vs Hour of day"),
    p(
      "Heatmap displaying the diel trends within each dataset and the 
      relationship of those trends between 16 kHz and full bandwidth sampling 
      rates. Each acoustic index is summarized by hour of day across the month 
      of February at the native duration (or 5-min maximum duration for larger 
      audio files). Select the dataset and sampling rate to evaluate from the 
      drop-down menu to the left."
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