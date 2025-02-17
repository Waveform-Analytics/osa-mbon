ui_tab3 <- function() {
  tagList(
    br(),
    h2("Water Classes"),
    p(
      "The objective of this analysis is to relate acoustic indices to ",
      "available, remotely sensed environmental data from each region to evaluate ",
      "any relationships with indices"
    ),
    p(
      "Water class data were obtained using the MBON SeascapeR tool and custom ",
      "shapefiles for each site. For information on the underlying remotely ",
      "sensed environmental data contributing to each class, visit the ",
      tags$a(
        "Seascapes site",
        href = "https://shiny.marinebon.app/seascapes/classes.html",
        target = "_blank"
      ),
      ". Select a dataset and water class data will automatically update in the ",
      "correlation matrix. To further evaluate the relationships, select and ",
      "index and water class to observe the relationship between mean index value ",
      "and water class percentage. The plots below the matrix consist of the ",
      "distribution of water class percentages for each 8-day composite of ",
      "remotely sensed data (null values excluded), 8-days distribution summaries ",
      "for the selected index, and a regression plot between the two variables."
    ),
    p(
      "Buffers of 0.55 squared degrees were created surrounding each hydrophone's ",
      "location. The resulting study area was described by a grid of 60 km × 60 km ",
      "spatial cells, each covering an area of 3,600 km². Shapefiles of this extent ",
      "were generated for each area, ensuring a consistent spatial framework. Within ",
      "each 60 km × 60 km spatial block, the tool outputs values on a finer grid ",
      "resolution of 0.05° × 0.05° in a geographic coordinate system, producing water ", 
      "class values in approximately 5.6 km × 5.6 km cells"
    ),
    p(
      "Data are reported at their native sampling rate and duration. Data for ",
      "the correlation Plot 1 correspond to all data processed (1-3 months) ",
      "NOTE: If correlation values are blank, this is because data from that ",
      "water class do not occur during the period that overlaps with index ",
      "information."
    ),
    
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        title = "Options",
        
        p(tags$b("Step 1")),
        p("Select a dataset. This will update all plots."),
        ui_datasetPicker("t3_datasetPick", unique_datasets, FALSE),
        
        br(),
        p(tags$b("Step 2")),
        p(
          "Select an index category. You'll see Plot 1 update to show the ",
          "selected subset."
        ),
        ui_catPicker("t3_catPick"),
        
        br(),
        p(tags$b("Step 3")),
        p("Choose a single index to focus on. This will update Plots 3 and 4."),
        ui_subIndexPicker("t3_subIndexPick"),
        
        br(),
        p(tags$b("Step 4")),
        p("Select a water class option. This will update Plot 4."),
        ui_classPicker("t3_classPick", FALSE)
      ),
      
      card(
        p(tags$b("Plot 1: Correlations - Index vs Water Class")),
        plotOutput("t3_plot_heatmap", height = 600),
        downloadButton("download_heatmap", "Plot")
      ),
      
      layout_column_wrap(
        width = 1/2,
        height = 700,
        
        layout_column_wrap(
          width = 1,
          heights_equal = "row",
          card(
            p(tags$b("Plot 2: Water class proportions over time")),
            plotOutput("t3_plot_waterclasses", height = "400px"),
            downloadButton("download_waterclasses", "Plot")
          ),
          card(
            p(tags$b("Plot 3: Boxplot - selected indices over time")),
            plotOutput("t3_plot_boxplot", height = "400px"),
            downloadButton("download_boxplot", "Plot")
          )
        ),
        
        card(
          p(tags$b("Plot 4: Water class % vs mean index value")),
          plotOutput("t3_plot_corr"),
          downloadButton("download_corr", "Plot")
        )
      )
    )
  )
}