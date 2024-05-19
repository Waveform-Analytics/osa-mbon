# Data Prep
source("data/prep_data.R")

# UI - Big Picture
ui <- page_navbar(

  title = "BioSound MBON Project Dashboard",
  theme = bs_theme(bootswatch = "minty"),
  fillable = FALSE,
  
  nav_panel(title = "Overview", ui_overview),
  
  nav_panel(
    fillable=FALSE,
    title = "Data explorer",
    # Page contents
    navset_underline(
      nav_panel(title = "All Datasets", ui_tab1()),
      nav_panel(title = "Annotations",ui_tab2(unique_datasets)),
      nav_panel(title = "Water Classes", ui_tab3()),
    )
  ),
)

# SERVER - Big Picture
server <- function(input, output, session) {
  server_overview(input, output, session)
  server_tab1(input, output, session)
  server_tab2(input, output, session)
  server_tab3(input, output, session)
}

# Run the App
shinyApp(ui = ui, server = server)

