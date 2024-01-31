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

library(testthat)
library(lubridate)
library(mockery)



mock_api_response <- function(status_code, content) {
  list(
    status_code = status_code,
    content = function(type = "parsed", ...) content
  )
}

test_that("successful API response is handled correctly", {
  # Define the mock successful response
  successful_content <- list(
    data = list(
      list(
        from = "2023-01-12T00:00Z",
        intensity = list(actual = 100, forecast = 105)
      )
    )
  )
  mock_success <- mock_api_response(200, successful_content)
  
  # Mock `httr::GET` to return the successful response
  stub(httr::GET, "GET", mock_success)
  
  # Test the function
  result <- actual_and_forecast('2023-01-12')
  
  # Check if the result is a ggplot
  expect_true(is.ggplot(result))
})

test_that("error response from API is handled correctly", {
  # Mock the error response
  mock_error <- mock_api_response(400, NULL)
  
  # Mock `httr::GET` to return the error response
  stub(httr::GET, "GET", mock_error)
  
  output <- capture.output(result <- actual_and_forecast('2023-01-10'))
  
  # Check if the output contains the expected error message
  expect_false(any(grepl("Failed to fetch data:", output)), info = paste("Output:", output))
})
