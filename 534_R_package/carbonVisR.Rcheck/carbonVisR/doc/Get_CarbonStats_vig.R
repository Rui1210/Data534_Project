## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(carbonVisR)

## -----------------------------------------------------------------------------
# Query the Carbon Intensity API
result <- Get_CarbonStats("2023-01-20", "2023-01-30")

# Access the resulting data frame
data <- result$data

# Access the ggplot object for visualization
plot <- result$plot

# Print the data frame
print(data)

# Plot the ggplot object
print(plot)

