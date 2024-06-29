# Dropdown for picking index category
ui_catPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("catPick"),
    "Select Index Category:",
    choices = unique_index_types
  )
}


# Server logic for dataset picker
server_catPicker <- function(id, unique_index_types) {
  moduleServer(id, function(input, output, session) {
    observe({
      current_unique_indices <- unique_index_types
      
      updateSelectInput(session, "catPick",
                        choices = current_unique_indices,
                        selected = current_unique_indices[1]
      )
      
    })
    
    return(reactive({ input$catPick }))
  })
}
