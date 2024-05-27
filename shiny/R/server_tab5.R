server_tab5 <- function(input, output, session) {
  
  # Function to select the appropriate dataset
  get_dataset <- reactive({
    if (input$normPick == "No") {df_aco} else {df_aco_norm}})
  
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t5_datasetPick", unique_datasets)
  
  # Index drop down selector
  selected_index <- server_indexPicker("t5_indexPick")
  
  # Sample rate set to 16kHz for all
  sr <- 16
  
  
  
  
}
  