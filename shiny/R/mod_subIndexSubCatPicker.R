# Dropdown for picking index subcategory
ui_subIndexSubCatPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("subIndexSubCatPick"),
    "Select Index:",
    choices = unique_subIndex_subCats
  )
}


server_subIndexSubCatPicker <- function(id, catPick) {
  moduleServer(id, function(input, output, session) {
    # Unique Sample Rates
    observe({
      current_cat_pick <- catPick()
      
      # Filter and update choices
      unique_subIndexSubCat_picks <- df_index_cats %>% 
        filter(Subcategory == current_cat_pick) %>% 
        pull(index)
      
      updateSelectInput(session, "subIndexSubCatPick", 
                        choices = unique_subIndexSubCat_picks)
    })
    
    return(reactive({input$subIndexSubCatPick}))
  })
  
}
