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
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_keywest", "Plot"),
          downloadButton("download_keywest_data", "Data")
        )
      ),
      card(
        h4("May River, SC"),
        dygraphOutput("p1_plot_ts_mayriver"),
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_mayriver", "Plot"),
          downloadButton("download_mayriver_data", "Data")
        )
      ),
      card(
        h4("Biscayne Bay, FL"),
        dygraphOutput("p1_plot_ts_caesarcreek"),
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_caesarcreek", "Plot"),
          downloadButton("download_caesarcreek_data", "Data")
        )
      ),
      card(
        h4("Gray's Reef"),
        dygraphOutput("p1_plot_ts_graysreef"),
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_graysreef", "Plot"),
          downloadButton("download_graysreef_data", "Data")
        )
      ),
      card(
        h4("ONC-MEF"),
        dygraphOutput("p1_plot_ts_onc"),
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_onc", "Plot"),
          downloadButton("download_onc_data", "Data")
        )
      ),
      card(
        h4("Chukchi Sea, Hanna Shoal"),
        dygraphOutput("p1_plot_ts_chuckchi"),
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_chuckchi", "Plot"),
          downloadButton("download_chuckchi_data", "Data")
        )
      ),
      card(
        h4("OOI-HYDBBA106"),
        dygraphOutput("p1_plot_ts_ooi"),
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_ooi", "Plot"),
          downloadButton("download_ooi_data", "Data")
        )
      ),
      card(
        h4("Olowalu (Maui, HI)"),
        dygraphOutput("p1_plot_ts_sanctsound"),
        div(style = "display: flex; gap: 10px;",
          downloadButton("download_sanctsound", "Plot"),
          downloadButton("download_sanctsound_data", "Data")
        )
      )
    )
  )
}