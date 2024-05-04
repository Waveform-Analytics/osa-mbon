# Dropdown for picking dataset (i.e., location)
ui_datasetPicker <- function(id, multiselect) {
  selectInput(
    NS(id, "datasetPick"),
    "Select Dataset",
    choices = unique_datasets,
    selected = unique_datasets[1],
    multiple = multiselect
  )
}

# Server logic for dataset picker
server_datasetPicker <- function(id) {
  moduleServer(id, function(input, output, session) {
    updateSelectInput(session, "datasetPick",
                      choices = unique_datasets,
                      selected = unique_datasets[1]
                      )

    return(reactive({ input$datasetPick }))
  })
}
