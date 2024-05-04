# Function to filter the acoustic indices dataset
fcn_filterAco <- function(data, selected_dataset, selected_sr,
                        selected_duration, fft=512) {
  data %>%
    filter(Dataset == selected_dataset,
           Sampling_Rate_kHz == selected_sr,
           Duration_sec == selected_duration,
           FFT == fft)
}

# Function to find presence/absence by getting the overlap between two dataframes
# that both contain "start_time" and "end_time" columns.
add_overlap_indicator <-
  function(df_A, df_B, start_time_col = "start_time", end_time_col = "end_time") {
  # Convert dataframes to data.tables
  setDT(df_A)
  setDT(df_B)

  # Create an interval object for each row in data.tables A and B
  A_intervals <- df_A[, .(start = start_time, end = end_time)]
  B_intervals <- df_B[, .(start = start_time, end = end_time)]

  # Set keys for joining
  setkey(A_intervals, start, end)
  setkey(B_intervals, start, end)

  # Perform overlap join
  overlap <- foverlaps(A_intervals, B_intervals, which = TRUE)

  # If any overlap is found, mark the corresponding row in A as present
  df_A[unique(overlap$yid), is_present := TRUE]

  # Fill NA with FALSE
  df_A[is.na(is_present), is_present := FALSE]

  return(df_A)
}

