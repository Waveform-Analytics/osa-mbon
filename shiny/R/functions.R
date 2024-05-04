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
    B_subset <- B[B$species == spec, ]

    # Apply condition and create a data frame marking each overlap
    overlaps <- sapply(1:nrow(A), function(i) {
      a_end <- A$end_time[i]
      a_start <- A$start_time[i]
      any(B_subset$start_time < a_end & B_subset$end_time > a_start)
    })

    # Return a dataframe marking overlaps with species and A's row index
    data.frame(row_id = 1:nrow(A), species = spec, is_present = overlaps)
  }

  # Process each species and combine results
  results <- map_df(unique(df_spp$species), ~process_species(.x, df_A, df_spp))

  # Add a row identifier to A for merging
  df_A$row_id <- 1:nrow(df_A)

  # Merge results into A and pivot data
  final_A <- df_A %>%
    left_join(results, by = "row_id") %>%
    filter(is_present) %>%
    pivot_wider(names_from = species,
                values_from = is_present,
                values_fill = list(is_present = FALSE)) %>%
    select(-row_id)

  # Return the final data frame
  return(final_A)
}
