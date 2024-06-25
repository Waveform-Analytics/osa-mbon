server_overview <- function(input, output, session) {
  
  output$overviewMap <- renderLeaflet({
    leaflet(data = df_site_info) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~lon, lat = ~lat, 
        radius = 6,
        color = '#007bff',
        fill = TRUE,
        fillOpacity = 0.8,
        layerId = ~site_id,
        group = "markers"
      )
  })
  
  
  observeEvent(input$overviewMap_marker_click, {
    click <- input$overviewMap_marker_click
    if(!is.null(click)) {
      # Find data for clicked marker
      clicked_marker <- df_site_info[df_site_info$site_id == click$id, ] 
      showModal(modalDialog(
        title = paste(clicked_marker$name),
        easyClose = TRUE,
        htmlOutput("info"),
        footer = modalButton("Close")
      ))
      output$info <- renderUI({
        
        HTML(paste0(
          "<p><strong>Source:</strong> ", clicked_marker$Source, "</p>",
          "<p><strong>Contact:</strong> ", clicked_marker$Contact, "</p>",
          "<p><strong>Sample rate (kHz):</strong> ", clicked_marker$`Sampling Rate (kHz)`, "</p>",
          "<p><strong>Recording Cycle:</strong> ", clicked_marker$`Recording Cycle`, "</p>",
          "<p><strong>Ecosystem Type:</strong> ", clicked_marker$`Ecosystem Type`, "</p>",
          "<p><strong>Instrument depth:</strong> ", clicked_marker$`Instrument Depth (m)`, " m</p>"

        ))
        
      })
    }
  })
  
  output$text_output_overviewtab <- renderUI({
    # req({selected_cat()})
    # this_selected_cat <- selected_cat()
    # df_index_cats_subset <- df_index_cats %>%
    #   filter(Category == this_selected_cat)
    index_description_text(df_index_cats)
  })
  
}