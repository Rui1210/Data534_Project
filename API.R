library(httr)
library(ggplot2)
library(lubridate)

actual_and_forecast <- function(date) {
  url <- paste0('https://api.carbonintensity.org.uk/intensity/date/', date)
  
  response <- GET(url)
  
  if (status_code(response) == 200) {
    data <- content(response, "parsed")
    
    intensities <- data$data
    times <- sapply(intensities, function(x) x$from)
    actual <- sapply(intensities, function(x) x$intensity$actual)
    forecast <- sapply(intensities, function(x) x$intensity$forecast)
    
    # Creating a data frame
    df <- data.frame(Time = as.POSIXct(times, format="%Y-%m-%dT%H:%MZ", tz="UTC"),
                     Actual = actual,
                     Forecast = forecast)
    
    # Plot
    gg <- ggplot(df, aes(x = Time)) +
      geom_line(aes(y = Actual, colour = "Actual")) +
      geom_line(aes(y = Forecast, colour = "Forecast")) +
      labs(title = paste('Actual vs. Forecast Carbon Intensity on', date),
           x = 'Time', y = 'Carbon Intensity (gCO2/kWh)') +
      scale_colour_manual("",
                          breaks = c("Actual", "Forecast"),
                          values = c("Actual" = "blue", "Forecast" = "red")) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

    print(gg)

  } else {
    print(paste("Failed to fetch data:", status_code(response)))
  }
}

actual_and_forecast('2023-01-12')


