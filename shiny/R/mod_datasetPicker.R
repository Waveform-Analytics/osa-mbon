# Dropdown for picking dataset (i.e., location)
ui_datasetPicker <- function(id) {
  selectInput(
    NS(id, "datasetPick"),
    "Select Dataset",
    choices = unique_datasets,
  )
}

# Server logic for dataset picker
server_datasetPicker <- function(id) {
  moduleServer(id, function(input, output, session) {
    updateSelectInput(session, "datasetPick",
                      choices = unique_datasets)

    return(input$datasetPick)
  })
}
