library(shiny)
library(bslib)

server_tab1 <- function(input, output, session) {
  
  # Function to select the appropriate dataset
  get_dataset <- reactive({
    if (input$normPick == "No") {df_aco} else {df_aco_norm}})
  
  # Index drop down selector
  selected_indices <- server_indexPicker("t1_indexPick")
  
  df_subset_keywest <- df_selected("Key West", get_dataset, selected_indices)
  df_subset_mayriver <- df_selected("May River", get_dataset, selected_indices)
  df_subset_caesarcreek <- df_selected("Caesar Creek", get_dataset, selected_indices)
  df_subset_graysreef <- df_selected("Gray's Reef", get_dataset, selected_indices)
  
  create_ts_plot("p1_plot_ts_keywest", df_subset_keywest, output)
  create_ts_plot("p1_plot_ts_mayriver", df_subset_mayriver, output)
  create_ts_plot("p1_plot_ts_caesarcreek", df_subset_caesarcreek, output)
  create_ts_plot("p1_plot_ts_graysreef", df_subset_graysreef, output)

}
