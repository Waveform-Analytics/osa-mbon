ui_tab1 <- function() {
  tagList(
    br(),
    h2("Overview of all datasets"),
    withMathJax(),
    p(paste(
      "This series of datasets provides insights into the relationship between",
      "acoustic indices at each site, and the distribution of values across the",
      "dataset timeseries. Select one or more index variables in the 'Select",
      "Indices' section below, with the option to turn off normalization.",
      "Displayed data are in native duration and native sampling rate (see",
      "'Overview' tab for this information)."
    )),
    p("Data are reported at 16 kHz sampling rate and native duration."),
    p("The plots can optionally show normalized data, in which case index 
    values \\(s_i\\) are computed using:"),
    p("$$s_i = \\frac{ x_i - mean(\\bar{x}) }{ \\max | x_i - median ( \\bar{x} ) | } $$"),
    p("where \\(x_i\\) is the \\(i^{th}\\) index value and \\(\\bar{x}\\) is the vector of
      all values recorded for the current index."),
    
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        title = "Options",
        # User selections
        ui_indexPicker("t1_indexPick", TRUE),
        radioButtons("normPick", "Normalize values?", c("Yes", "No"))
      ),
      card(
        h4("Key West, FL"),
        dygraphOutput("p1_plot_ts_keywest"),
        downloadButton("download_keywest", "Download Plot")
      ),
      card(
        h4("May River, SC"),
        dygraphOutput("p1_plot_ts_mayriver"),
        downloadButton("download_mayriver", "Download Plot")
      ),
      card(
        h4("Biscayne Bay, FL"),
        dygraphOutput("p1_plot_ts_caesarcreek"),
        downloadButton("download_caesarcreek", "Download Plot")
      ),
      card(
        h4("Gray's Reef"),
        dygraphOutput("p1_plot_ts_graysreef"),
        downloadButton("download_graysreef", "Download Plot")
      ),
      card(
        h4("ONC-MEF"),
        dygraphOutput("p1_plot_ts_onc"),
        downloadButton("download_onc", "Download Plot")
      ),
      card(
        h4("Chukchi Sea, Hanna Shoal"),
        dygraphOutput("p1_plot_ts_chuckchi"),
        downloadButton("download_chuckchi", "Download Plot")
      ),
      card(
        h4("OOI-HYDBBA106"),
        dygraphOutput("p1_plot_ts_ooi"),
        downloadButton("download_ooi", "Download Plot")
      ),
      card(
        h4("Olowalu (Maui, HI)"),
        dygraphOutput("p1_plot_ts_sanctsound"),
        downloadButton("download_sanctsound", "Download Plot")
      )
    )
  )
}