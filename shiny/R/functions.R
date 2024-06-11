# Get a subset of acoustic indices based on location and indices
df_selected <- function(location_name, get_dataset, selected_indices) {
  reactive({
    req(get_dataset(), selected_indices())
    dataset <- get_dataset()
    sr <- 16
    duration <- get_max_duration(location_name, dataset, sr)
    filtered_data <- fcn_filterAco(dataset, location_name, sr, duration)
    
    # Select specific columns based on indices
    filtered_data %>% select(start_time, all_of(selected_indices()))
  })
}

# Get the first sample rate from a dataset
get_first_sr <- function(dataset_name, df) {
  sr_subset <- df %>%
    filter(Dataset == dataset_name) %>%
    distinct(Sampling_Rate_kHz) %>%
    pull(Sampling_Rate_kHz)
  sr_subset[1]
}

# Get first duration based on dataset and sample rate
get_max_duration <- function (dataset_name, df, sr) {
  duration_subset <- df %>%
    filter(Dataset == dataset_name,
           Sampling_Rate_kHz == sr) %>%
    distinct(Duration_sec) %>%
    pull(Duration_sec)

  max(duration_subset)
}

# Function to filter the acoustic indices dataset
fcn_filterAco <- function(data, selected_dataset, selected_sr,
                        selected_duration, fft=512) {
  data %>%
    filter(Dataset == selected_dataset,
           Sampling_Rate_kHz == selected_sr,
           Duration_sec == selected_duration,
           FFT == fft)
}


# Function to compute presence/absence for different species/annotations
get_species_presence <- function(df_A, df_spp) {

  df_spp <- df_spp %>% arrange(start_time)

  min_time <- min(df_spp$start_time)
  max_time <- max(df_spp$end_time)
  df_A <- df_A %>%
    filter(start_time >= min_time, end_time <= max_time) %>%
    arrange(start_time)

  # Local function to process each species
  process_species <- function(spec, A, B) {
    B_subset <- B[B$Labels == spec, ]

    # Apply condition and create a data frame marking each overlap
    overlaps <- sapply(1:nrow(A), function(i) {
      a_end <- A$end_time[i]
      a_start <- A$start_time[i]
      any(B_subset$start_time < a_end & B_subset$end_time > a_start)
    })

    # Return a dataframe marking overlaps with species and A's row index
    data.frame(row_id = 1:nrow(A), Labels = spec, is_present = overlaps)
  }

  # Process each species and combine results
  results <- map_df(unique(df_spp$Labels), ~process_species(.x, df_A, df_spp))

  # Add a row identifier to A for merging
  df_A$row_id <- 1:nrow(df_A)

  # Merge results into A and pivot data
  final_A <- df_A %>%
    left_join(results, by = "row_id") %>%
    select(-row_id, -end_time)

  # Return the final data frame
  return(final_A)
}


# Generate text descriptions of selected indices
index_description_text <- function(df) {
  # Ensure the dataframe has the required columns
  if (!all(c("index", "Description") %in% colnames(df))) {
    stop("The dataframe must contain 'index' and 'Description' columns.")
  }
  
  # Create the tagList
  text_list <- tagList(
    lapply(1:nrow(df), function(i) {
      p(tags$strong(df$index[i]), ": ", df$Description[i])
    })
  )
  
  return(text_list)
}




