# Sample rate comparison

# First, filter the data to only look at a single location and duration


# Biscayne Bay example

df_sub <- 
  df_aco %>%
  filter(Dataset == "Biscayne Bay, FL",
         FFT == 512)

# Plot
p <- ggplot(df_sub, aes(x = start_time, y = ZCR, color = as.factor(Sampling_Rate_kHz))) +
  geom_line() +
  labs(title = "Signal Comparison by Sample Rate",
       x = "start_time",
       y = "ZCR",
       color = "Sample Rate") +
  theme_minimal()

p <- ggplotly(p)

p
