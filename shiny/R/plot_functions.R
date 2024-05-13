create_ts_plot <- function(id, df_in, output){
  output[[id]] <- renderDygraph({
    req(df_in())
    df_idxPicks <- df_in()
    if (nrow(df_idxPicks) == 0) {
      return(NULL)
    }
    dygraph(df_idxPicks, x = "start_time") %>%
      dyRangeSelector(height = 30)
  })
}

create_hour_plot <- function(id, df_in, output){
  # Extract hour of day to a new column
  df_in$hour <- hour(df_in$start_time)
  output[[id]] <- ggplot(df_in, aes(x=hour, y=ZCR)) +
    geom_boxplot(fill = "salmon", outlier.shape = NA) +
    labs(x="Hour of day") +
    theme_minimal() +
    theme(legend.position = "none",
          panel.grid.major.y = element_blank(),
          panel.grid.minor.y = element_blank())
}