ui_tab2 <- function(unq_datasets_ann) {
  fluidPage(
    br(),
    h2("Acoustic indices with annotations"),
    p(paste(
      "Annotations were available for the Key West and May River datasets,",
      "allowing for further exploration of how acoustic-based indices varied in",
      "relation to these biological and anthropogenic sounds. Select the dataset",
      "to explore as well as an acoustic index and sampling rate. From the",
      "'Select Annotation Type', select one or more annotations by typing in the",
      "value or selecting from the dropdown. To delete an annotation from view,",
      "place your cursor ahead of the annotation value and press the backspace",
      "button."
    )),
    p(paste(
      "Data are reported at their native sampling rate (Key West = 48 kHz, May",
      "River = 80 kHz) and native duration (Key West = 30 second, May River =",
      "2-min)."
    )),
    
    layout_sidebar(
      fillable=FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_datasetPicker("t2_datasetPick", unq_datasets_ann, FALSE),
        ui_srPicker("t2_srPick"),
        ui_indexPicker("t2_indexPick", FALSE),
        ui_speciesPicker("t2_speciesPick", TRUE),
        br(),
        p("ANNOTATION KEY"),
        
        strong("Key West"),
        uiOutput("text_output_anno_kw"),
        
        strong("May River"),
        uiOutput("text_output_anno_mr"),
        
        strong("Vessels"),
        tags$p("Vessels at any site are indicated by 'Vs'.")
      ),
      layout_columns(
        card(
          p(tags$b("Plot 1: Time series with annotations")),
          plotlyOutput("p2_plot_ts"),
          downloadButton("download_ts", "Plot")
        ),
        card(
          p(tags$b("Plot 2: Index values by species")),
          plotOutput("p2_plot_box"),
          downloadButton("download_box", "Plot")
        )
      )
    )
  )
}

