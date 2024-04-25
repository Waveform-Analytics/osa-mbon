
dfA <- df_sub
dfB <- df_fish

# Calculate the time differences and find the median
time_diffs <- diff(dfA$datetime_aco)
median_diff <- median(time_diffs)

# Shift datetime_aco down by one row
dfA$end_time <- c(dfA$datetime_aco[-1], NA)
# Set the last row's end_time using median_diff
dfA$end_time[nrow(dfA)] <- dfA$datetime_aco[nrow(dfA)] + median_diff

# Sort the dataframe
dfA <- arrange(dfA, datetime_aco)


# Load data.table library
library(data.table)

# Convert dfA and dfB to data.table if they aren't already
setDT(dfA)
setDT(dfB)

# Perform the non-equi join
# This joins dfA with dfB where dfB's datetime_fish falls between dfA's datetime_aco and end_time
results <- dfA[, .(present = any(dfB$datetime_fish >= datetime_aco & 
                                   dfB$datetime_fish <= end_time)), 
               by = .(datetime_aco, end_time)]
dfA <- merge(dfA, results, by = c("datetime_aco", "end_time"), all.x = TRUE)


# If you want to keep all rows from dfA and mark those without matches
dfA[, present := FALSE]  # Add a default FALSE present column to dfA
dfA[results, on = .(datetime_aco, end_time), present := i.present]  # Update with TRUE where matches occur

# Convert back to data.frame if necessary
dfA <- as.data.frame(dfA)

# Print result
print(dfA)






#################
dfA <- df_sub
dfB <- df_fish
# Add an "end time" column to dfA
dfA$end_time <- c(dfA$datetime_aco[-1], NA)
median_diff <- median(diff(dfA$datetime_aco))
dfA$endTime[nrow(dfA)] <- dfA$datetime_aco[nrow(dfA)] + median_diff
dfA <- dfA %>%
  arrange(datetime_aco)

# Use rowwise() and mutate() to apply the function to each row
dfA <- dfA %>%
  rowwise() %>%
  mutate(present = 
           any(dfB$datetime_fish >= datetime_aco & 
                 dfB$datetime_fish <= end_time)) %>%
  ungroup() 





time_step_join <- function(dfA, dfB) {

  dfA$end_time <- c(dfA$datetime_aco[-1], NA)
  
  # Calculate median of time differences
  median_diff <- median(diff(dfA$datetime_aco))
  
  # Use median time difference to compute the final end time
  dfA$endTime[nrow(dfA)] <- dfA$datetime_aco[nrow(dfA)] + median_diff
  
  # Generate a new column in dfA called "presence"
  dfA <- dfA %>%
    rowwise() %>%
    mutate(presence = )
  

  
  # Return the modified dfA
  return(result)
}

