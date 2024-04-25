ui <- page_sidebar(
  
  tags$head(tags$style(HTML("
    .bslib-card, .tab-content, .tab-pane, .card-body {
      overflow: visible !important;
    }
  "))),
  
  title = "BioSound MBON Project Dashboard",
  theme = bs_theme(bootswatch = "sandstone"),
  fillable=FALSE,
  
  # SIDEBAR
  
  sidebar = sidebar(
    title="Dataset selection",
    "Select an index and date range to view a time series",
    
    selectInput("selectedIndices", "Choose acoustic indices to plot:",
                choices = index_columns,
                selected = index_columns[1],
                multiple = TRUE),
    
    dateRangeInput("dateRange",
                   label = "Select Date Range:",
                   start = date_range$MinDate,
                   end = date_range$MaxDate,
                   min = date_range$MinDate,
                   max = date_range$MaxDate)
  ),
  
  # MAIN PAGE AREA
  
  ## First Tab
  tabsetPanel(
    tabPanel("Annotated data",
             tags$br(),
             tags$h1("Acoustic Indices with correlates"),
             tags$p("The Dataset and index selected on the sidebar are used to 
                    determine the data shown here."),
             card(
               height=400,
               card_header("Line plot"),
               plotOutput("line_plot")
             ),
             
             layout_columns(
               card(
                 height=350,
                 card_header("Correlation matrix"),
                 plotOutput("corrPlot")
               ),
               card(
                 card_header("Placeholder")
               ))
    ),
    
    ## Second Tab
    tabPanel("Fish annotations",
             tags$br(),
             tags$h1("Acoustic indices and fish annotations"),
             
             layout_columns(col_widths = c(4,8),
                            card(
                              card_header("User selection"),
                              selectInput("selectedDataset", "Choose a dataset:",
                                          choices = unique_datasets$Dataset,
                                          selected = unique_datasets$Dataset[1],
                                          multiple = FALSE),
                            ),
                            card(
                              card_header("Plot visualization")
                            )
                            
             )
             
             
    ),
    
  )
  
)