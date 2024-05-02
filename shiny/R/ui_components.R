# Dropdown for picking index (multiples allowed)
ui_indexPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("selectedIndices"),
    "Select Indices:",
    choices = index_columns,
    selected = index_columns[1],
    multiple = TRUE
  )
}

# Dropdown for picking dataset (i.e., location)
ui_datasetPicker <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("datasetPick"),
    "Select Dataset",
    choices = unique_datasets,
  )
}

# # Dropdown for picking sample rate
# ui_srPicker <- function(id) {
#   ns <- NS(id)
#   selectInput(
#     ns("srPick"),
#     "Select Sample Rate (kHz):",
#     choices = c("opt1", "opt2", "opt3")
#   )
# }
