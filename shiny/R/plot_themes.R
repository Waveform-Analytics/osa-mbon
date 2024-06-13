library(ggplot2)
library(lattice)
library(dygraphs)
library(plotly)

# Set ggplot2 theme globally
custom_theme <- theme_minimal(base_size = 16) +
  theme(
    text = element_text(size = 16),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 14),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16)
  )
theme_set(custom_theme)


# Custom lattice theme
custom_lattice_font_theme <- list(
  axis.text = list(cex = 1.4),
  par.main.text = list(cex = 1.8),
  par.xlab.text = list(cex = 1.6),
  par.ylab.text = list(cex = 1.6),
  par.strip.text = list(cex = 1.4)  
)


# Custom function for dygraphs
custom_dygraph <- function(data) {
  dygraph(data) %>%
    dyOptions(axisLabelFontSize = 16)
}

# Custom function for plotly
custom_plotly <- function(p) {
  p %>%
    layout(
      title = list(font = list(size = 20)),
      xaxis = list(titlefont = list(size = 16), tickfont = list(size = 13)),
      yaxis = list(titlefont = list(size = 16), tickfont = list(size = 13)),
      legend = list(font = list(size = 13))
    )
}