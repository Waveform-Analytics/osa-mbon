# Dropdown for picking index sub-category
ui_subCatPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("subCatPick"),
    "Select Index Sub-Cateogry:",
    choices = unique_subindex_types
  )
}


# Server logic for dataset picker
server_subCatPicker <- function(id, unique_subindex_types) {
  moduleServer(id, function(input, output, session) {
    observe({
      current_unique_indices <- unique_subindex_types
      
      print(unique_subindex_types)
      
      updateSelectInput(session, "subCatPick",
                        choices = current_unique_indices,
                        selected = current_unique_indices[1]
      )
      
    })
    
    return(reactive({ input$subCatPick }))
  })
}
