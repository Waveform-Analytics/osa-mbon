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
  output$download_keywest <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_Key_West_FL_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_keywest_plot())
      dev.off()
    }
  )
  
  output$download_mayriver <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_May_River_SC_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_mayriver_plot())
      dev.off()
    }
  )
  
  output$download_caesarcreek <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_Biscayne_Bay_FL_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_caesarcreek_plot())
      dev.off()
    }
  )
  
  output$download_graysreef <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_Grays_Reef_GA_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_graysreef_plot())
      dev.off()
    }
  )
  
  output$download_onc <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_ONC_MEF_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_onc_plot())
      dev.off()
    }
  )
  
  output$download_chuckchi <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_Chukchi_Sea_Hanna_Shoal_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_chuckchi_plot())
      dev.off()
    }
  )
  
  output$download_ooi <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_OOI_HYDBBA106_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_ooi_plot())
      dev.off()
    }
  )
  
  output$download_sanctsound <- downloadHandler(
    filename = function() {
      indices <- paste(sort(selected_indices()), collapse = "_")
      indices <- gsub("[^[:alnum:]]", "_", indices)
      paste0("timeseries_Olowalu_Maui_HI_", indices, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      print(generate_sanctsound_plot())
      dev.off()
    }
  )
  
  # Data download handlers
  output$download_keywest_data <- downloadHandler(
    filename = function() {
      paste0("keywest_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_keywest(), file, row.names = FALSE)
    }
  )
  
  output$download_mayriver_data <- downloadHandler(
    filename = function() {
      paste0("mayriver_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_mayriver(), file, row.names = FALSE)
    }
  )
  
  output$download_caesarcreek_data <- downloadHandler(
    filename = function() {
      paste0("caesarcreek_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_caesarcreek(), file, row.names = FALSE)
    }
  )
  
  output$download_graysreef_data <- downloadHandler(
    filename = function() {
      paste0("graysreef_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_graysreef(), file, row.names = FALSE)
    }
  )
  
  output$download_onc_data <- downloadHandler(
    filename = function() {
      paste0("onc_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_onc(), file, row.names = FALSE)
    }
  )
  
  output$download_chuckchi_data <- downloadHandler(
    filename = function() {
      paste0("chuckchi_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_chuckchi(), file, row.names = FALSE)
    }
  )
  
  output$download_ooi_data <- downloadHandler(
    filename = function() {
      paste0("ooi_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_ooi(), file, row.names = FALSE)
    }
  )
  
  output$download_sanctsound_data <- downloadHandler(
    filename = function() {
      paste0("sanctsound_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_subset_sanctsound(), file, row.names = FALSE)
    }
  )
}
