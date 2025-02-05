library(shiny)
library(bslib)
library(dygraphs)

# Helper function to create dygraph from data
create_dygraph <- function(df) {
  req(df)
  
  if (nrow(df) == 0) {
    return(NULL)
  }
  
  dygraph(df, x = "start_time") %>%
    dyRangeSelector(height = 30)
}

server_tab1 <- function(input, output, session) {
  
  # Function to select the appropriate dataset
  get_dataset <- reactive({
    if (input$normPick == "No") {df_aco} else {df_aco_norm}
  })
  
  # Index drop down selector
  selected_indices <- server_indexPicker("t1_indexPick")
  
  # Reactive datasets for each location
  df_subset_keywest <- df_selected("Key West, FL", get_dataset, selected_indices)
  df_subset_mayriver <- df_selected("May River, SC", get_dataset, selected_indices)
  df_subset_caesarcreek <- df_selected("Biscayne Bay, FL", get_dataset, selected_indices)
  df_subset_graysreef <- df_selected("Gray's Reef, GA", get_dataset, selected_indices)
  df_subset_onc <- df_selected("ONC-MEF", get_dataset, selected_indices)
  df_subset_chuckchi <- df_selected("Chukchi Sea, Hanna Shoal", get_dataset, selected_indices)
  df_subset_ooi <- df_selected("OOI-HYDBBA106", get_dataset, selected_indices)
  df_subset_sanctsound <- df_selected("Olowalu (Maui, HI)", get_dataset, selected_indices)
  
  # Plot generation functions
  generate_keywest_plot <- function() {
    req(df_subset_keywest())
    create_dygraph(df_subset_keywest())
  }
  
  generate_mayriver_plot <- function() {
    req(df_subset_mayriver())
    create_dygraph(df_subset_mayriver())
  }
  
  generate_caesarcreek_plot <- function() {
    req(df_subset_caesarcreek())
    create_dygraph(df_subset_caesarcreek())
  }
  
  generate_graysreef_plot <- function() {
    req(df_subset_graysreef())
    create_dygraph(df_subset_graysreef())
  }
  
  generate_onc_plot <- function() {
    req(df_subset_onc())
    create_dygraph(df_subset_onc())
  }
  
  generate_chuckchi_plot <- function() {
    req(df_subset_chuckchi())
    create_dygraph(df_subset_chuckchi())
  }
  
  generate_ooi_plot <- function() {
    req(df_subset_ooi())
    create_dygraph(df_subset_ooi())
  }
  
  generate_sanctsound_plot <- function() {
    req(df_subset_sanctsound())
    create_dygraph(df_subset_sanctsound())
  }
  
  # Plot outputs
  output$p1_plot_ts_keywest <- renderDygraph({
    generate_keywest_plot()
  })
  
  output$p1_plot_ts_mayriver <- renderDygraph({
    generate_mayriver_plot()
  })
  
  output$p1_plot_ts_caesarcreek <- renderDygraph({
    generate_caesarcreek_plot()
  })
  
  output$p1_plot_ts_graysreef <- renderDygraph({
    generate_graysreef_plot()
  })
  
  output$p1_plot_ts_onc <- renderDygraph({
    generate_onc_plot()
  })
  
  output$p1_plot_ts_chuckchi <- renderDygraph({
    generate_chuckchi_plot()
  })
  
  output$p1_plot_ts_ooi <- renderDygraph({
    generate_ooi_plot()
  })
  
  output$p1_plot_ts_sanctsound <- renderDygraph({
    generate_sanctsound_plot()
  })

  # Download handlers
  output$download_keywest <- create_download_handler("dygraph", generate_keywest_plot, "keywest_plot")
  output$download_mayriver <- create_download_handler("dygraph", generate_mayriver_plot, "mayriver_plot")
  output$download_caesarcreek <- create_download_handler("dygraph", generate_caesarcreek_plot, "caesarcreek_plot")
  output$download_graysreef <- create_download_handler("dygraph", generate_graysreef_plot, "graysreef_plot")
  output$download_onc <- create_download_handler("dygraph", generate_onc_plot, "onc_plot")
  output$download_chuckchi <- create_download_handler("dygraph", generate_chuckchi_plot, "chuckchi_plot")
  output$download_ooi <- create_download_handler("dygraph", generate_ooi_plot, "ooi_plot")
  output$download_sanctsound <- create_download_handler("dygraph", generate_sanctsound_plot, "sanctsound_plot")
}
