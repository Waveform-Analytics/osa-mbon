ui_tab1 <- function() {
  tagList(
    br(),
    h2("Overview of all datasets"),
    p(
      "This series of datasets provides insights into the relationship between 
      acoustic indices at each site, and the distribution of values across the 
      dataset timeseries. Select one or more index variables in the “Select 
      Indices” section below, with the option to turn off normalization. 
      Displayed data are in native duration and native sampling rate (see 
      “Overview” tab for this information). "
    ),
    
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_indexPicker("t1_indexPick", TRUE),
        radioButtons("normPick", "Normalize values?", c("Yes", "No")),
      ),
      card(
        h4("Key West"),
        dygraphOutput("p1_plot_ts_keywest"),
      ),
      card(
        h4("May River"),
        dygraphOutput("p1_plot_ts_mayriver"),
      ),
      card(
        h4("Caesar Creek"),
        dygraphOutput("p1_plot_ts_caesarcreek"),
      ),
      card(
        h4("Gray's Reef"),
        dygraphOutput("p1_plot_ts_graysreef"),
      ),
      card(
        h4("ONC"),
        dygraphOutput("p1_plot_ts_onc"),
      ),
      card(
        h4("Chuckchi Sea"),
        dygraphOutput("p1_plot_ts_chuckchi"),
      ),
      card(
        h4("OOI"),
        dygraphOutput("p1_plot_ts_ooi"),
      ),
      card(
        h4("SanctSound"),
        dygraphOutput("p1_plot_ts_sanctsound"),
      ),
    ),
  )
}