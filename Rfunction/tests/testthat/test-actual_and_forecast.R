library(httr)
library(ggplot2)
library(lubridate)
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
