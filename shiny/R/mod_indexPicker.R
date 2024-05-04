# Dropdown for picking index
ui_indexPicker <- function(id, multiselect) {
  selectInput(
    NS(id, "selectedIndices"),
    "Select Indices:",
    choices = index_columns,
    selected = index_columns[1],
    multiple = multiselect
  )
}

# Server logic for index picker
server_indexPicker <- function(id) {
  moduleServer(id, function(input, output, session) {
    updateSelectInput(session, "selectedIndices",
                      choices = index_columns,
                      selected = index_columns[1])

    return(reactive({input$selectedIndices}))
  })
}
