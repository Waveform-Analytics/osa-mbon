server_tab6 <- function(input, output, session) {
  
  # Function to select the appropriate dataset
  the_dataset <- reactive({
    if (input$normPick == "No") {df_aco} else {df_aco_norm}})
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t6_datasetPick", unique_datasets)
  
  # Index drop down selector
  selected_index <- server_indexPicker("t6_indexPick")
  
  # Sample rate set to 16kHz for all
  sr <- 16
  
  # FFT length set to 512 for all
  fft <- 512
  
  
  # Get the required data subset 
  df_dat <- reactive({
    req(the_dataset(), selected_dataset())
    
    the_dataset() %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == sr,
             FFT == fft) 
  })
  
  
  # PLOT
  output$t6_plot_ships <- renderDygraph({
    req(df_durations())
    

  })
  
  
  
}
