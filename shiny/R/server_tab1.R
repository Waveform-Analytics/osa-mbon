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
  df_subset_onc <- df_selected("ONC-MEF", get_dataset, selected_indices)
  df_subset_chuckchi <- df_selected("Chuckchi Sea", get_dataset, selected_indices)
  df_subset_ooi <- df_selected("OOI-HYDBBA106", get_dataset, selected_indices)
  df_subset_sanctsound <- df_selected("SanctSound-HI01", get_dataset, selected_indices)
  
  create_ts_plot("p1_plot_ts_keywest", df_subset_keywest, output)
  create_ts_plot("p1_plot_ts_mayriver", df_subset_mayriver, output)
  create_ts_plot("p1_plot_ts_caesarcreek", df_subset_caesarcreek, output)
  create_ts_plot("p1_plot_ts_graysreef", df_subset_graysreef, output)
  create_ts_plot("p1_plot_ts_onc", df_subset_onc, output)
  create_ts_plot("p1_plot_ts_chuckchi", df_subset_chuckchi, output)
  create_ts_plot("p1_plot_ts_ooi", df_subset_ooi, output)
  create_ts_plot("p1_plot_ts_sanctsound", df_subset_sanctsound, output)
  
}
