#library(testthat)
#source("Get_CarbonStats.R")

test_that("Get_CarbonStats returns expected results", {
  mock_GET <- function(url) {
    sample_data <- list(
      data = list(
        list(
          intensity = list(
            date = "2022-01-01",
            max = 300,
            average = 150,
            min = 50,
            index = "moderate"
          )
        )
      )
    )
    structure(sample_data, class = "response")
  }


  assignInNamespace("GET", mock_GET, ns = asNamespace("httr"))
  result <- Get_CarbonStats("2023-01-20", "2023-01-30")
  expect_is(result, "list")
  expect_true("data" %in% names(result))
  expect_true("plot" %in% names(result))

  expect_is(result$data, "data.frame")
  expect_equal(ncol(result$data), 5)
  expect_equal(nrow(result$data), 10)
  expect_is(result$plot, "gg" )
})

test_that("Get_CarbonStats handles API request issues", {
  # Provide a date range that may cause an issue with the API request
  from_date_issue <- "2023-01-30"
  to_date_issue <- "2023-01-20"

  # Run the function and expect a custom error message
  expect_error({
    result <- Get_CarbonStats(from_date_issue, to_date_issue)
  }, class = "error", regexp = "Error in API request. Please check the date range and try again.")
})
