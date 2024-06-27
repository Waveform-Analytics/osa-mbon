ui_tab4 <- function() {
  
  tagList(
    
    br(),
    h2("Indices vs Hour of day"),
    p(
      "Plot 1: A heatmap displaying the diel trends within each dataset and the 
      relationship of those trends between 16 kHz and full bandwidth sampling 
      rates. Each acoustic index is summarized by hour of day across the month 
      of February at the native duration (or 5-min maximum duration for larger 
      audio files). Select the dataset and sampling rate to evaluate from the 
      drop-down menu to the left."
    ),
    p("Plot 2: A heatmap that shows the average index at each hour of day, 
      averaged over the month of February, for each location."),
    p(
      "Plot 3: A heatmap that focuses on a user-selected index to show
      hour of day vs date (all datasets show the month of February)."
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

        p(tags$b("Step 1")),
        p("Select a dataset. This will update Plots 1 and 3"),
        ui_datasetPicker("t4_datasetPick", unique_datasets, FALSE),
        
        br(),
        
        p(tags$b("Step 2")),
        p("Select a sample rate. This will update plots 1 and 3. Plot 2 is 
          fixed at 16 kHz."),
        ui_srPicker("t4_srPick"),
        
        br(),
        
        p(tags$b("Step 3")),
        p("Plots 2 and 3 show a single index at a time. Start by picking the 
          index category, and from the resulting subset, pick an index of 
          interest."),
        
        ui_catPicker("t4_catPick"),
        ui_subIndexPicker("t4_subIndexPick"),
        
      ),
      
      card(
        h4("Plot 1: Index values vs Hour of Day"),
        plotOutput("p4_plot_hour_heatmap", height = 600),
      ),
      
      card(
        h4("Plot 2: Index values: Location vs Hour of Day"),
        plotOutput("p4_plot_hour_location_heatmap", height = 600)
      ),
      
      card(
        h4("Plot 3: Index values: Days vs Hour of Day"),
        plotOutput("p4_plot_hour_day_heatmap", height = 550)
      ),
      
      card(
        h4("Description of indices in the selected category"),
        # Add text descriptions for selected subset
        uiOutput("text_output")
      )
      
    )
  )
  
  
}