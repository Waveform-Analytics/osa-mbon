ui_tab2 <- function(unq_datasets_ann) {
  fluidPage(
    br(),
    h2("Acoustic indices with annotations"),
    p(
      "Annotations were available for the Key West and May River datasets, 
      allowing for further exploration of how acoustic-based indices varied in 
      relation to these biological and anthropogenic sounds. Select the dataset 
      to explore as well as an acoustic index and sampling rate. From the 
      “Select Annotation Type,” select one or more annotations by typing in the 
      value or selecting from the dropdown. To delete an annotation from view, 
      place your cursor ahead of the annotation value and press the backspace 
      button."
    ),
    p("Data are reported at their native sampling rate (Key West = 48 kHz, May 
      River = 80 kHz) and native duration (Key West = 30 second, May River = 
      2-min)."),
    
    layout_sidebar(
      fillable=FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_datasetPicker("t2_datasetPick", unq_datasets_ann, FALSE),
        ui_indexPicker("t2_indexPick", FALSE),
        ui_speciesPicker("t2_speciesPick", TRUE),
        br(),
        p("ANNOTATION KEY"),
        strong("Key West"),
        tags$ul(
          tags$li("Em: red grouper (Epinephelus morio)"),
          tags$li("Es: Nassau grouper (Epinephelus striatus)"),
          tags$li("Mb: black grouper (Mycteroperca bonaci)"),
          tags$li("Uk: unknown"),
          tags$li("Vs: vessel"),
        ),
        strong("May River"),
        tags$ul(
          tags$li("Sp: Silver perch"),
          tags$li("Oy: Oyster toadfish"),
          tags$li("Bd: Black drum"),
          tags$li("Ss: Spotted seatrout"),
          tags$li("Rd: Red drum"),
          tags$li("Ac: Atlantic croaker"),
          tags$li("Wf: Weakfish"),
          tags$li("Bo: Bottlenose dolphin"),
          tags$li("Vs: Vessel"),
          
        )
       
        
        
      ),
      layout_columns(
        card(
          plotlyOutput("p2_plot_ts"),
        ),
        card(
          plotOutput("p2_plot_box"),
        )
      ),
    )
  )
  
  
}

