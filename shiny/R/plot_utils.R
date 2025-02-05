# R/plot_utils.R

# Utility function to handle plot downloads
download_plot <- function(plot_type, plot_object, file) {
  if (plot_type == "dygraph") {
    # For dygraphs, we need to convert to a static plot since they're interactive widgets
    message("Getting dygraph object...")
    dygraph_obj <- plot_object()
    message("Class of dygraph object: ", paste(class(dygraph_obj), collapse = ", "))
    
    # Extract data from the dygraph object
    message("Extracting data...")
    if (inherits(dygraph_obj$x, "xts")) {
      message("Found xts object, converting to data frame...")
      df_wide <- data.frame(
        start_time = index(dygraph_obj$x),
        coredata(dygraph_obj$x)
      )
    } else {
      message("Object is not xts, attempting direct conversion...")
      message("Structure of dygraph_obj: ")
      str(dygraph_obj)
      
      # Extract the time and data from the nested structure
      time_data <- as.POSIXct(dygraph_obj$x$data[[1]], format="%Y-%m-%dT%H:%M:%S", tz="UTC")
      value_data <- dygraph_obj$x$data[[2]]
      
      # Create data frame with proper time and values
      df_wide <- data.frame(
        start_time = time_data,
        value = value_data
      )
      
      # Get the column name from the labels if available
      if (!is.null(dygraph_obj$x$attrs$labels)) {
        colnames(df_wide)[2] <- dygraph_obj$x$attrs$labels[2]
      }
    }
    
    # Ensure we have valid data
    message("Checking data frame...")
    message("Dimensions of df_wide: ", paste(dim(df_wide), collapse = " x "))
    message("Column names: ", paste(colnames(df_wide), collapse = ", "))
    
    if (is.null(df_wide) || nrow(df_wide) == 0) {
      stop("No data available to plot")
    }
    
    # Reshape data from wide to long format for ggplot
    message("Reshaping data to long format...")
    df_long <- tidyr::pivot_longer(
      df_wide,
      cols = -start_time,
      names_to = "Index",
      values_to = "Value"
    )
    
    message("Dimensions of long data: ", paste(dim(df_long), collapse = " x "))
    message("Column names of long data: ", paste(colnames(df_long), collapse = ", "))
    
    # Create a static ggplot version of the dygraph
    message("Creating ggplot...")
    p <- ggplot(df_long, aes(x = start_time, y = Value, color = Index)) +
      geom_line() +
      labs(x = "Time", y = "Value") +
      theme_minimal() +
      theme(
        panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        legend.position = "bottom",
        legend.title = element_blank()
      )
    
    # Save the static version
    message("Saving plot...")
    ggsave(filename = file, plot = p, device = "png", width = 12, height = 6, bg = "white")
    message("Plot saved successfully")
  } else if (plot_type == "plotly") {
    plotly::export(plot_object, file = file)
  } else if (plot_type == "trellis") {
    # For lattice/trellis plots
    trellis_plot <- plot_object()
    png(filename = file, width = 1000, height = 700)
    print(trellis_plot)
    dev.off()
  } else if (plot_type == "ggplot") {
    # For ggplot objects, we need to evaluate the plot first
    plot <- try(ggplot2::ggplot_build(plot_object()))
    if (!inherits(plot, "try-error")) {
      # Add white background and save
      final_plot <- plot_object() + theme(panel.background = element_rect(fill = "white"),
                                        plot.background = element_rect(fill = "white"))
      ggplot2::ggsave(filename = file, plot = final_plot, 
                      device = "png", width = 10, height = 7, bg = "white")
    } else {
      # If plot_object is already a rendered plot, add white background
      final_plot <- plot_object + theme(panel.background = element_rect(fill = "white"),
                                      plot.background = element_rect(fill = "white"))
      ggplot2::ggsave(filename = file, plot = final_plot, 
                      device = "png", width = 10, height = 7, bg = "white")
    }
  } else {
    stop("Unsupported plot type")
  }
}

# Function to create a download handler
create_download_handler <- function(plot_type, plot_object, file_name) {
  downloadHandler(
    filename = function() {
      # Force PNG extension
      gsub("\\.html$", ".png", paste0(file_name, "_", Sys.Date(), ".png"))
    },
    content = function(file) {
      # Ensure we're using the user-selected file path
      tryCatch({
        message(paste("Attempting to save plot to:", file))
        download_plot(plot_type, plot_object, file)
        message(paste("Successfully saved plot to:", file))
      }, error = function(e) {
        message(paste("Error saving plot:", e$message))
      })
    }
  )
}