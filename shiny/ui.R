ui <- page_navbar(
  
  tags$head(tags$style(HTML("
    .bslib-card, .tab-content, .tab-pane, .card-body {
      overflow: visible !important;
    }
  "))),
  
  title = "BioSound MBON Project Dashboard",
  theme = bs_theme(bootswatch = "minty"),
  fillable=FALSE,
  
  nav_panel(title = "Overview", 
            h1("BioSound MBON Project overview"),
            p("Overview contents here (interactive map, site descriptions, etc.")
            
            ),
  
  nav_panel(title = "Data explorer", 
            h1("BioSound MBON Data Explorer"),
            # Page contents
            navset_underline(
              nav_panel(title = "All Datasets", 
                        h2("Overview of all datasets"),
                        p("This tab will present an overview of the acoustic indices
                          and water class data for all datasets. The user may 
                          select a dataset, a year (if more than one year is 
                          available) and an acoustic index."),
                        p("One plot will show time series data overlaid on the
                          water class data. A second plot will show the water
                          class data reduced to the same time resolution as
                          the satellite/water class data, and they will be 
                          plotted against each other to visualize any possible
                          correlations.")
                        ),
              
              nav_panel(title = "Annotations", 
                        h2("Acoustic indices with annotations"),
                        
                        ),
              
              nav_panel(title = "Recorded Durations", 
                        h2("Compare different durations"),
                        
                        )
              
            )
            ),

)