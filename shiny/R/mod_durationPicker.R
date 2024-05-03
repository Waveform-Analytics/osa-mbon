
# Dropdown for picking duration
ui_durationPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("durationPick"),
    "Select Duration (s):",
    choices = unique_durations
  )
}

server_durationPicker <- function(id, dataset, datasetPick, srPick) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Reactive: Unique Sample Rates
    unique_duration_pick <- dataset %>%
      filter(Dataset == datasetPick, Sampling_Rate_kHz == srPick) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)

    # Observer: Update Sample Rate Dropdown
    observe({
      updateSelectInput(session, ns("durationPick"), choices = unique_duration_pick)
    })

    return(input$durationPick)
  })

}

