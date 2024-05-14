ui_overview <- fluidPage(
  h1("Project overview"),
  p(
    "Overview contents here (interactive map, site descriptions, etc."
  ),
  layout_columns(
    card(
      leafletOutput("overviewMap")
    ),
    card(
      h3("BioSound Project"),
      p("A paragraph description of the biosound project"),
      p("Click locations on the map to see site-specific information."),
    )
  ),
  
)