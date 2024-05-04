# Dropdown for picking sample rate
ui_srPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("srPick"),
    "Select Sample Rate (kHz):",
    choices = unique_sr
  )
}

server_srPicker <- function(id, dataset, datasetPick) {
  moduleServer(id, function(input, output, session) {
    # Unique Sample Rates
    observe({
      current_dataset <- dataset()
      current_dataset_pick <- datasetPick()

      # Filter and update choices
      unique_sr_pick <- current_dataset %>%
        filter(Dataset == current_dataset_pick) %>%
        distinct(Sampling_Rate_kHz) %>%
        pull(Sampling_Rate_kHz)

      updateSelectInput(session, "srPick", choices = unique_sr_pick)
    })

    return(reactive({input$srPick}))
  })

}
