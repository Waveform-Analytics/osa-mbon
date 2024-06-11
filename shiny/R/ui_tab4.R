ui_tab4 <- function() {
  
  tagList(
    
    br(),
    h2("Indices vs Hour of day"),
    p(
      "Plot 1: Heatmap displaying the diel trends within each dataset and the 
      relationship of those trends between 16 kHz and full bandwidth sampling 
      rates. Each acoustic index is summarized by hour of day across the month 
      of February at the native duration (or 5-min maximum duration for larger 
      audio files). Select the dataset and sampling rate to evaluate from the 
      drop-down menu to the left."
    ),
    p(
      "Plot 2: A second heatmap that focuses on a user-selected index to show
      day (in February) vs hour of day."
    ),
    withMathJax(),
    p(
      "Note that the heatmap values are scaled so that they all range from 0 to 
      1. Scaled indices \\(s_i\\) are calculated using the following equation: "
    ),
    p("$$s_i=\\frac{x_i - min(\\bar{x})}{max(\\bar{x}) - min(\\bar{x})},$$"),
    p("where \\(x_i\\) is the \\(i^{th}\\) index value and \\(\\bar{x}\\) is the vector of
      all values recorded for the current index."),

    layout_sidebar(
      fillable=FALSE,
      sidebar = sidebar(
        title = "Options",
        ui_datasetPicker("t4_datasetPick", unique_datasets, FALSE),
        ui_srPicker("t4_srPick"),
        
        h4("Select an index for the lower plot:"),

        # ui_catPicker("t4_catPick"),
        # ui_subIndexPicker("t4_subIndexPick"),
        
        ui_subCatPicker("t4_subCatPick"),
        ui_subIndexSubCatPicker("t4_subIndexSubCatPick"),
        
        # Add text descriptions for selected subset
        uiOutput("text_output")
        
      ),
      
      card(
        plotOutput("p4_plot_hour_heatmap", height = 600),
      ),
      
      card(
        plotOutput("p4_plot_hour_day_heatmap")
      ),
      
      # card(
      #   # Add text descriptions for selected subset
      #   uiOutput("text_output")
      # )
      
    )
  )
  
  
}