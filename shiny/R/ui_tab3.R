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
      "Buffers of 0.55 squared degrees were created surrounding each ",
      "hydrophone's location resulting in approximately 60 km by 60 km ",
      "shapefiles. Additional information regarding the remotely sensed data is ",
      "available on the ",
      tags$a(
        "Data Processing and Management",
        href = "https://ocean-science-analytics.github.io/biosound-exploratory-project/data.html#environmental-data-using-seascaper",
        target = "_blank"
      ),
      " page of documentation."
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
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_heatmap", "Plot"),
          downloadButton("download_heatmap_data", "Data")
        )
      ),
      
      layout_column_wrap(
        width = 1/2,
        height = 550,
        
        layout_column_wrap(
          width = 1,
          heights_equal = "row",
          card(
            p(tags$b("Plot 2: Water class proportions over time")),
            plotOutput("t3_plot_waterclasses"),
            div(style = "display: flex; gap: 10px;",
              downloadButton("download_waterclasses", "Plot"),
              downloadButton("download_waterclasses_data", "Data")
            )
          ),
          card(
            p(tags$b("Plot 3: Boxplot - selected indices over time")),
            plotOutput("t3_plot_boxplot"),
            div(style = "display: flex; gap: 10px;",
              downloadButton("download_boxplot", "Plot"),
              downloadButton("download_boxplot_data", "Data")
            )
          )
        ),
        
        card(
          p(tags$b("Plot 4: Water class % vs mean index value")),
          plotOutput("t3_plot_corr"),
          div(style = "display: flex; gap: 10px;",
            downloadButton("download_corr", "Plot"),
            downloadButton("download_corr_data", "Data")
          )
        )
      )
    )
  )
}