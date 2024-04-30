ui <- page_navbar(
  tags$head(tags$style(
    HTML(
      "
    .bslib-card, .tab-content, .tab-pane, .card-body, .div  {
      overflow: visible !important;
    }
  "
    )
  )),
  
  title = "BioSound MBON Project Dashboard",
  theme = bs_theme(bootswatch = "minty"),
  fillable = FALSE,
  
  nav_panel(
    title = "Overview",
    h1("BioSound MBON Project overview"),
    p(
      "Overview contents here (interactive map, site descriptions, etc."
    )
    
  ),
  
  nav_panel(
    fillable=FALSE,
    title = "Data explorer",
    h1("BioSound MBON Data Explorer"),
    # Page contents
    navset_underline(
      nav_panel(
        br(),
        title = "All Datasets",
        h2("Overview of all datasets"),
        p(
          "This tab presents an overview of the acoustic indices
          and water class data for all datasets."
        ),

        layout_sidebar(
          sidebar = sidebar(
            title = "Options",
            
            selectInput(
              "selectedIndices",
              "Select indices:",
              choices = index_columns,
              selected = index_columns[1],
              multiple = TRUE
            ),
            selectInput(
              "p1DatasetPick",
              "Select Dataset",
              choices = unique_datasets$Dataset,
              selected = unique_datasets$Dataset[1],
            ),
            selectInput(
              "p1SampleRatePick",
              "Select Sample Rate (kHz)",
              choices = unique_sr$Sampling_Rate_kHz,
            ),
            selectInput(
              "p1DurationPick",
              "Select duration (seconds)",
              choices = unique_durations$Duration_sec,
            ),
            
            br(),
            
          ),
          card(
            dygraphOutput("p1_plot_ts"),
          ),
        ),
      ),
      
      nav_panel(title = "Annotations",
                h2("Acoustic indices with annotations"), ),
      
      nav_panel(title = "Recorded Durations",
                h2("Compare different durations"), )
      
    )
  ),
  
)