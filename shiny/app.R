source("globalvars.R")
# UI files
source("R/ui_overview.R")
source("R/ui_tab1.R")
source("R/ui_tab2.R")
source("R/ui_tab3.R")
# Server files
source("R/server_overview.R")
source("R/server_tab1.R")
source("R/server_tab2.R")
source("R/server_tab3.R")
# Modules
source("R/mod_durationPicker.R")
source("R/mod_indexPicker.R")
source("R/mod_srPicker.R")
source("R/mod_datasetPicker.R")
source("R/mod_speciesPicker.R")

# UI - Big Picture
ui <- page_navbar(
  tags$head(tags$style(
    HTML(
      "
    .bslib-card, .tab-content, .tab-pane, .card-body, .div  {
      overflow: visible !important;
    }
  "
    )
  )),

  title = "BioSound MBON Project Dashboard",
  theme = bs_theme(bootswatch = "minty"),
  fillable = FALSE,

  nav_panel(title = "Overview", ui_overview),

  nav_panel(
    fillable=FALSE,
    title = "Data explorer",
    # Page contents
    navset_underline(
      nav_panel(title = "All Datasets", ui_tab1),
      nav_panel(title = "Annotations",ui_tab2),
      nav_panel(title = "Recorded Durations", ui_tab3)

    )
  ),
)

# SERVER - Big Picture
server <- function(input, output, session) {
  server_tab1(input, output, session)
  server_tab2(input, output, session)
}

# Run the App
shinyApp(ui = ui, server = server)

