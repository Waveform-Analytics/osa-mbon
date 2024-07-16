
# Dropdown for picking duration
ui_durationPicker <- function(id) {
  selectInput(
    NS(id, "durationPick"),
    "Select Duration (s):",
    choices = unique_durations
  )
}

server_durationPicker <- function(id, dataset, datasetPick, srPick) {
  moduleServer(id, function(input, output, session) {
    # Unique Sample Rates
    observe({
      current_dataset <- dataset()
      current_datasetPick <- datasetPick()
      current_srPick <- srPick()

      unique_duration_pick <- current_dataset %>%
        filter(Dataset == current_datasetPick,
               Sampling_Rate_kHz == current_srPick) %>%
        distinct(Duration_sec) %>%
        pull(Duration_sec)

      updateSelectInput(session, "durationPick", 
                        choices = unique_duration_pick)
    })

    return(reactive({input$durationPick}))
  })

}

