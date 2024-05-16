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
        
      ),
      
      card(
        plotOutput("t3_plot_heatmap", height = 600),
      ),
      
      layout_column_wrap(
        width = 1/2,
        height = 350,
         
        layout_column_wrap(
          width = 1,
          heights_equal = "row",
          card(
            plotOutput("t3_plot_waterclasses")
          ),
          card(
            plotOutput("t3_plot_boxplot")
          )
        ),
        
        card(
          h4("The other card on the side"),
        ),

      )
      
    )
  )
}