ui_tab3 <- function() {
  
  tagList(
    
    br(),
    h2("Water Classes"),
    p(
      "Water class data were obtained using the MBON SeascapeR tool and custom 
      shapefiles for each site. For information on the underlying remotely 
      sensed environmental data contributing to each class, visit the ",
      tags$a("Seascapes site",
             href="https://shiny.marinebon.app/seascapes/classes.html",
             target="_blank"),
       ". Select a dataset and water class data will automatically update in the 
      correlation matrix. To further evaluate the relationships, select and 
      index and water class to observe the relationship between mean index value 
      and water class percentage. The plots below the matrix consist of the 
      distribution of water class percentages for each 8-day composite of 
      remotely sensed data (null values excluded), 8-days distribution summaries 
      for the selected index, and a regression plot between the two variables."
    ),
    p("Data are reported at their native sampling rate and duration."),
    
    layout_sidebar(
      fillable=FALSE,
      sidebar = sidebar(
        title = "Options",
        
        ui_datasetPicker("t3_datasetPick", unique_datasets, FALSE),
        
        br(),
        
        strong("Lower figures:"),
        
        # ui_indexPicker("t3_indexPick", FALSE),
        
        ui_catPicker("t3_catPick"),
        ui_subIndexPicker("t3_subIndexPick"),
        
        ui_classPicker("t3_classPick", FALSE)
        
      ),
      
      card(
        plotOutput("t3_plot_heatmap", height = 600),
      ),
      
      layout_column_wrap(
        width = 1/2,
        height = 500,
         
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
          plotOutput("t3_plot_corr"),
        ),

      )
      
    )
  )
}