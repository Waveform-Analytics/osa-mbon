# WATER CLASSES
server_tab3 <- function(input, output, session) {
  
  # Dataset drop down selector
  selected_dataset <- server_datasetPicker("t3_datasetPick", unique_datasets)
  
  # # Index drop down selector
  # selected_index <- server_indexPicker("t3_indexPick")
  
  # Index category selector
  selected_cat <- server_catPicker("t3_catPick", unique_index_types)
  selected_index <- server_subIndexPicker("t3_subIndexPick", selected_cat)
  
  index_cats_subset <- reactive({
    req({selected_cat()})
    this_selected_cat <- selected_cat()
    df_index_cats %>%
      filter(Category == this_selected_cat) %>%
      pull(index)
  })
  
  # # Class drop down selector
  selected_class <- server_classPicker("t3_classPick", df_combo)

  # Selected sample rate (not a user choice)
  selected_sr <- reactive({
    req(selected_dataset())
    
    sr_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset()) %>%
      distinct(Sampling_Rate_kHz) %>%
      pull(Sampling_Rate_kHz)
    max(sr_subset)
    # sr_subset[1]
  })
  
  # Selected duration (not a user choice)
  selected_duration <- reactive({
    req(selected_dataset(), selected_sr())
    
    duration_subset <- df_aco_norm %>%
      filter(Dataset == selected_dataset(),
             Sampling_Rate_kHz == selected_sr()) %>%
      distinct(Duration_sec) %>%
      pull(Duration_sec)
    # duration_subset[1]
    max(duration_subset)
  })
  
  # Get the selected water class dataframe
  df_seascaper_sub <- reactive({
    req(selected_dataset())
    
    df_seascaper %>%
      filter(Dataset == selected_dataset(), !is.na(cellvalue))
  })
  
  unique_classes <- reactive({
    req(df_seascaper_sub())
    as.character(df_seascaper_sub() %>%
                   distinct(cellvalue) %>%
                   pull())
  })
  
  unique_classes_numeric <-  reactive({
    req(df_seascaper_sub())
    
    df_seascaper_sub() %>%
      distinct(cellvalue) %>%
      arrange(cellvalue) %>%
      pull()
  })
  
  # Prepare water class data
  # water class percentages
  df_water <- reactive({
    req(df_seascaper_sub(), unique_classes())
    
    df_temp<- 
      df_seascaper_sub() %>%
      group_by(date) %>%
      mutate(
        total_cells = sum(n_cells), 
        pct = n_cells / total_cells *100) %>%
      pivot_wider(
        id_cols     = date,
        names_from  = cellvalue,
        values_from = pct, values_fill = 0) %>%
      pivot_longer(
        cols = unique_classes(),
        names_to = "class",
        values_to = "pct"
      ) %>%
      mutate(
        class_num = as.numeric(class)
      ) %>%
      arrange(date, class_num) 
    df_temp$class <- as.factor(df_temp$class)
    # df_temp$date <- as.factor(df_temp$date) 
    return(df_temp)
  })
  
  # Get the list of dates from the water column subset
  dates_list <- reactive({
    df_seascaper_sub() %>% 
      distinct(date) %>% 
      pull()
  })
  
  # Reactive: Filtered Data Subset
  # Note that for now we're just grabbing the first available sample
  # rate and duration, but these can be specified later as needed.
  df_filt <- reactive({
    req(selected_dataset(), selected_sr(), selected_duration())
    fcn_filterAco(df_aco_norm, selected_dataset(),
                  selected_sr(), selected_duration())
  })
  
  # 
  df_idx <- reactive({
    req(selected_index(), df_filt(), dates_list())
    
    df_idx_temp <- 
      df_filt() %>% 
      select(start_time, all_of(selected_index())) %>%
      mutate(date = cut(start_time, 
                        breaks = dates_list(), 
                        include.lowest = TRUE, 
                        right = FALSE),
             date = as.POSIXct(date)) %>%
      rename(index = all_of(selected_index()))
    df_idx_temp$date_plain <- df_idx_temp$date
    df_idx_temp$date <- as.factor(df_idx_temp$date)
    
    return(df_idx_temp)
  })
  
  
  df_combo <- reactive({
    req(df_idx(), df_water())
    
    water_data <- df_water()
    water_data$date <- as.factor(water_data$date)
    
    df_idx_summ <- df_idx() %>%
      group_by(date) %>%
      summarise(mean = mean(index))
    df_idx_summ_temp <- left_join(df_idx_summ, water_data, by = "date")
    return(df_idx_summ_temp)
  })
  
  this_df_combo <- reactive({
    req(df_combo(), selected_class())
    
    this_combo <- this_df_combo()
    this_class <- selected
    
    temp_combo <-  this_combo %>%
      filter(class == this_class)
    
    return(temp_combo)
  })
  
  # Class drop down selector
  selected_class <- server_classPicker("t3_classPick", df_combo)
  
  
  this_df_combo <- reactive({
    req(df_combo(), selected_class())
    
    df_combo() %>%
      filter(class == selected_class())
  })
  
  df_idx_big <- reactive({
    req(df_filt(), dates_list())
    
    df_temp <- 
      df_filt() %>% 
      select(start_time, all_of(index_columns)) %>%
      mutate(date = cut(start_time, 
                        breaks = dates_list(), 
                        include.lowest = TRUE, 
                        right = FALSE),
             date = as.POSIXct(date)
             # date = with_tz(date, "UTC")
      ) %>%
      pivot_longer(
        cols = all_of(index_columns),
        names_to = "index",
        values_to = "value"
      ) %>%
      group_by(date, index) %>%
      summarise(
        mean_val = mean(value),
        .groups = "keep"
      ) %>%
      mutate(
        date = force_tz(date, "UTC")
      )
    df_temp$date <- as.factor(df_temp$date)
    return(df_temp)
  })
  
  # Function to compute correlations for heatmap
  get_cor_value <- 
    function(df_index, 
             df_water_class, 
             this_class, 
             this_index) {
      
      this_pct <- df_water_class %>%
        filter(class_num == this_class)
      
      this_value <- df_index %>%
        filter(index == this_index)
      
      df_join <- inner_join(this_pct, this_value, by = "date")
      
      return(cor(df_join$pct, df_join$mean_val))
    }
  
  # Initialize and populate heatmap dataframe
  df_heatmap <- reactive({
    req(unique_classes(), 
        unique_classes_numeric(), 
        df_idx_big(), 
        df_water(),
        index_cats_subset())
    
    water_data <- df_water()
    water_data$date <- as.factor(water_data$date)
    index_subset <- index_cats_subset()
    
    df_temp <- setNames(
      data.frame(
        matrix(ncol = length(unique_classes()), 
               nrow = length(index_subset))), 
      unique_classes_numeric())
    rownames(df_temp) <- index_subset
    
    # Populate the dataframe
    for (index in index_subset) {
      for (class in unique_classes_numeric()) {
        cor_value <- get_cor_value(df_idx_big(), water_data, class, index)
        
        df_temp[index, as.character(class)] <- cor_value
        
      }
    }

    return(df_temp)
  })
  
  #######################################################################
  ##### PLOTS

  # Plot generation functions
  generate_heatmap <- function() {
    req(df_heatmap())
    df_heat <- df_heatmap()
    df_heat_long <- reshape2::melt(as.matrix(df_heat))
    diverging_colors <- colorRampPalette(c("blue", "white", "red"))
    levelplot(
      value ~ factor(Var2) * factor(Var1), 
      data = df_heat_long,
      col.regions = diverging_colors,
      at = seq(min(df_heat_long$value, na.rm = TRUE), max(df_heat_long$value, na.rm = TRUE), length = 100),
      ylab = list(label = "Index", cex = 1.4),
      xlab = list(label = "Water Class", cex = 1.4),
      scales = list(x = list(cex = 1.3), y = list(cex = 1.3)),
      colorkey = list(labels = list(cex = 1.3))
    )
  }

  generate_waterclasses <- function() {
    req(df_water())
    ggplot(df_water(), aes(x = date, y=pct, fill=class)) +
      geom_area(alpha = 0.5) +
      geom_area(aes(color = class), fill = NA, linewidth = .7) +
      labs(y="Percentage (%)", x=NULL)
  }

  generate_boxplot <- function() {
    req(df_idx())
    ggplot(df_idx(), aes(x=date, y=index)) +
      geom_boxplot(outlier.shape = NA) +
      scale_y_continuous(
        limits = quantile(df_idx()$index, c(0.1, 0.9))
      ) +
      labs(y="Index", x=NULL) +
      theme(axis.text.x = element_text(angle = 25, hjust = 1))
  }

  generate_corrplot <- function() {
    req(this_df_combo())
    this_combo <- this_df_combo()
    model <- lm(pct ~ mean, data = this_combo)
    ggplot(this_combo, aes(x=mean, y=pct, color=class)) + 
      geom_smooth(method = "lm", se = TRUE) +
      geom_point(shape = 21, size = 3, fill = NA, stroke = 1.5) +  
      labs(y="Water class percentage", x="Mean index value") +    
      theme(legend.position = "none") +
      annotate("text", x = Inf, y = Inf, 
               label = sprintf("y = %.1fx + %.1f\nR² = %.2f",
                             coef(model)[2], coef(model)[1], 
                             summary(model)$r.squared),
               hjust = 1.1, vjust = 1.1, size = 5)
  }

  # Plot outputs
  output$t3_plot_heatmap <- renderPlot({
    generate_heatmap()
  })

  output$t3_plot_waterclasses <- renderPlot({
    generate_waterclasses()
  })

  output$t3_plot_boxplot <- renderPlot({
    generate_boxplot()
  })

  output$t3_plot_corr <- renderPlot({
    generate_corrplot()
  })
    
  # Download handlers
  output$download_heatmap <- create_download_handler("trellis", generate_heatmap, "heatmap_plot")
  output$download_waterclasses <- create_download_handler("ggplot", generate_waterclasses, "waterclasses_plot")
  output$download_boxplot <- create_download_handler("ggplot", generate_boxplot, "boxplot_plot")
  output$download_corr <- create_download_handler("ggplot", generate_corrplot, "correlation_plot")
  
  # Data download handlers
  output$download_heatmap_data <- downloadHandler(
    filename = function() {
      paste0("heatmap_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_heatmap(), file, row.names = FALSE)
    }
  )
  
  output$download_waterclasses_data <- downloadHandler(
    filename = function() {
      paste0("waterclasses_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_water(), file, row.names = FALSE)
    }
  )
  
  output$download_boxplot_data <- downloadHandler(
    filename = function() {
      paste0("boxplot_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(df_idx(), file, row.names = FALSE)
    }
  )
  
  output$download_corr_data <- downloadHandler(
    filename = function() {
      paste0("correlation_data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(this_df_combo(), file, row.names = FALSE)
    }
  )
}