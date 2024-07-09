ui_overview <- fluidPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  tags$div(
    
    class = "responsive-container",
    
    style = "display: flex; align-items: center; margin-bottom: 10px;",
    # Logo to the left
    tags$img(src = "MBON-logo.png", height = "30px", style = "margin-right: 10px;"),
    # Info text in italic
    tags$em(
      "This work was supported by the U.S. Marine Biodiversity Observation Network 
    (MBON) co-organized by NOAA, NASA, BOEM, and ONR through the National 
    Oceanographic Partnership Program (NOPP)."
    )
  ),

  # Light horizontal line
  tags$hr(style = "border-color: gray;"),
  
  br(),
  
  h1("Project overview"),
  p(
    "The passive acoustic data used for this exploratory project are derived 
    from the locations and projects indicated below. Selecting a location opens 
    information regarding the dataset origin and point of contact. Below the map 
    is a description of all acoustic indices calculated for this exploratory 
    analysis."
  ),
  layout_columns(
    card(
      leafletOutput("overviewMap")
    ),
    card(
      h3("BioSound Project"),
      p(
        "The BioSound Working Group initiated the exploratory study responsible 
        for this dashboard. The intent of this analysis is to identify trends in 
        several soundscape ecology metrics across different ocean environments. 
        To enable accessible exploration of the data products resulting from this 
        analysis, this dashboard provides a series of interactive figures for 
        assessing these acoustic-based biodiversity indices. The following 
        explorations are available from each of the sub-tabs accessed by the 
        “Data Explorer” tab above: "
      ),
      tags$ul(
        tags$li(tags$strong("Diel Relationships"), ": acoustic-based indices are plotted by 
        hour to evaluate diurnal potential trends."),
        tags$li(tags$strong("Annotations"), ": biological and anthropogenic noise
        annotations provided by the May River and Key West datasets are
        highlighted on this tab."),
        tags$li(tags$strong("Water Classes"), ": correlations between water class type
        and acoustic-based indices are explored by dataset, along with water
        mass percentage and mean index values summed over 8-day intervals."),
        tags$li(tags$strong("All Datasets"), ": explore acoustic-based indices
                and their relationships per dataset."),
        tags$li(tags$strong("Recording Durations"), ": Recording Durations: 
                comparison of select datasets at varied measurement duration 
                intervals")
      ),
      p(
        "Click locations on the map to see site-specific information."
      ),
      p(
        "For a full description of the methods and analytical processes involved
        in this project, please visit",
        tags$a("BioSound Project Documentation Site",
               href="https://ocean-science-analytics.github.io/biosound-exploratory-project/overview.html",
               target="_blank")
      )
    )
  ),
  card(
    h3("Description of Indices"),
    p(
      "For a full description of indices, visit the ",
      tags$a("documentation site",
             href="https://ocean-science-analytics.github.io/biosound-exploratory-project/overview.html",
             target="_blank")
    ),
    
    uiOutput("text_output_overviewtab")

  )
  
)