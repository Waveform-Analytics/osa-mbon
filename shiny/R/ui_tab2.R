ui_tab2 <- fluidPage(
  br(),
  h2("Acoustic indices with annotations"),
  p(
    "In this tab, we're exploring environmental correlates. Some of the datasets
    have accompanying annotations which may be related to the acoustic indices."
  ),

  layout_sidebar(
    fillable=FALSE,
    sidebar = sidebar(
      title = "Options",
      # User selections
      ui_datasetPicker("t2_datasetPick", unique_datasets_ann, FALSE),
      ui_indexPicker("t2_indexPick", FALSE),
      ui_speciesPicker("t2_speciesPick", TRUE),
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
