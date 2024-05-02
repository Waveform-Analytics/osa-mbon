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
    ns <- session$ns
    # Reactive: Unique Sample Rates
    unique_sr_pick <- dataset %>%
        filter(Dataset == datasetPick) %>%
        distinct(Sampling_Rate_kHz) %>%
        pull(Sampling_Rate_kHz)

    # Observer: Update Sample Rate Dropdown
    observe({
      updateSelectInput(session, ns("srPick"), choices = unique_sr_pick)
    })

    return(input$srPick)
  })

}
