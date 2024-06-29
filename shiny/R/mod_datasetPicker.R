# Dropdown for picking dataset (i.e., location)
ui_datasetPicker <- function(id, unique_datasets_sub, multiselect) {
  selectInput(
    NS(id, "datasetPick"),
    "Select Dataset:",
    choices = unique_datasets_sub,
    selected = unique_datasets_sub[1],
    multiple = multiselect
  )
}

# Server logic for dataset picker
server_datasetPicker <- function(id, unique_datasets_sub) {
  moduleServer(id, function(input, output, session) {
    observe({
      current_unique_datasets <- unique_datasets_sub

      updateSelectInput(session, "datasetPick",
                        choices = current_unique_datasets,
                        selected = current_unique_datasets[1]
      )

    })

    return(reactive({ input$datasetPick }))
  })
}
