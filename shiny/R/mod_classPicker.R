# Dropdown for picking water class
ui_classPicker <- function(id, multiselect) {
  selectInput(
    NS(id, "classPick"),
    "Select water class:",
    choices = unique_classes,
    selected = unique_classes[1],
    multiple = multiselect
  )
}

# Server logic for class picker
server_classPicker <- function(id, df_combo_temp) {
  moduleServer(id, function(input, output, session) {
    observe({
      req(df_combo_temp())
      
      unique_class_pick <- 
        df_combo_temp() %>% 
        distinct(class) %>% 
        pull()
      
      updateSelectInput(session, "classPick",
                        choices = unique_class_pick,
                        selected = unique_class_pick[1])
    })
    return(reactive({input$classPick})) 
  })
  
}
