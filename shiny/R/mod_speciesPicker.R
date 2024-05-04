# Dropdown for picking dataset (i.e., location)
ui_speciesPicker <- function(id, multiselect) {
  selectInput(
    NS(id, "speciesPick"),
    "Select Species",
    choices = unique_species,
    selected = unique_species[1],
    multiple = multiselect
  )
}

# Server logic for species picker
server_srPicker <- function(id, datasetPick) {
  moduleServer(id, function(input, output, session) {
    # Unique Sample Rates
    observe({
      current_dataset_pick <- datasetPick()

      # Filter and update choices
      unique_species_pick <- fish_codes %>%
        filter(Dataset == current_dataset_pick) %>%
        distinct(code) %>% pull(code)

      updateSelectInput(session, "speciesPick", choices = unique_species_pick)
    })

    return(reactive({input$speciesPick}))
  })
}
