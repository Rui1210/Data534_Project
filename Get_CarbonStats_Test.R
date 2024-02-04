library(testthat)
source("Get_CarbonStats.R")

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