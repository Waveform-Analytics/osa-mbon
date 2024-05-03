# Server logic for dataset picker
server_datasetPicker <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    updateSelectInput(session, ns("datasetPick"),
                      choices = unique_datasets,
                      selected = unique_datasets[1])

    return(reactive({ input$datasetPick }))
  })
}

# Server logic for index picker
server_indexPicker <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # print("Indices loaded: ")
    # print(index_columns)
    updateSelectInput(session, ns("selectedIndices"),
                      choices = index_columns)

    # return(reactive({ input$selectedIndices}))
    return(reactive({
      # print("Indices selected: ")
      # print(input$selectedIndices)
      input$selectedIndices
    }))
  })
}
