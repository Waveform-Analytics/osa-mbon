# Dropdown for picking index (multiples allowed)
ui_indexPicker <- function(id) {
  selectInput(
    NS(id, "selectedIndices"),
    "Select Indices:",
    choices = index_columns,
    multiple = TRUE
  )
}

# Server logic for index picker
server_indexPicker <- function(id) {
  moduleServer(id, function(input, output, session) {
    updateSelectInput(session, "selectedIndices",
                      choices = index_columns)
    return(input$selectedIndices)
  })
}
