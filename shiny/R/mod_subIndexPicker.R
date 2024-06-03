# Dropdown for picking index category
ui_subIndexPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("subIndexPick"),
    "Select Index:",
    choices = unique_subIndex_types_init
  )
}


server_subIndexPicker <- function(id, catPick) {
  moduleServer(id, function(input, output, session) {
    # Unique Sample Rates
    observe({
      current_cat_pick <- catPick()
      
      # Filter and update choices
      unique_subIndex_picks <- df_index_cats %>% 
        filter(Category == current_cat_pick) %>% 
        pull(index)
      
      updateSelectInput(session, "subIndexPick", choices = unique_subIndex_picks)
    })
    
    return(reactive({input$subIndexPick}))
  })
  
}
