# library(httr)
# library(jsonlite)
# library(tidyr)
# library(dplyr)
# library(lubridate)
# library(ggplot2)
# library(ggthemes)
# library(RColorBrewer)
# library(scales)
# library(lubridate)

test_that("test valid input",{
  expected_from_date <- as.Date("2018-05-12")
  expected_to_date <- as.Date("2018-05-12")

  dates <- validate_date_range("2018-05-12", "2018-05-12")

  expect_true(all.equal(dates[[1]], expected_from_date))
  expect_true(all.equal(dates[[2]], expected_to_date))
})

test_that("invalid date range (earlier than allowed)", {
  result <- validate_date_range("2018-05-01", "2018-05-10")
  expect_identical(result, c(from_date = NULL, to_date = NULL))
  expect_message(validate_date_range("2018-05-01", "2018-05-10"), "Error converting dates: from_date and to_date cannot be earlier than May 11, 2018.")
})

test_that("invalid date range (to_date in the future)", {
  result <- validate_date_range("2025-05-01", "2025-05-10")
  expect_identical(result, c(from_date = NULL, to_date = NULL))
  expect_message(validate_date_range("2025-05-01", "2025-05-10"), "Error converting dates: from_date cannot be in the future.")
})

test_that("invalid date range (from_date > to_date)", {
  result <- validate_date_range("2022-05-10", "2022-05-01")
  expect_identical(result, c(from_date = NULL, to_date = NULL))
  expect_message(validate_date_range("2022-05-10", "2022-05-01"), "Error converting dates: to_date must be greater than or equal to from_date")
})

test_that("invalid date range (Date range exceeding 30 days)", {
  result <- validate_date_range("2022-03-10", "2022-05-01")
  expect_identical(result, c(from_date = NULL, to_date = NULL))
  expect_message(validate_date_range("2022-03-10", "2022-05-01"), "Error converting dates: Date range cannot exceed 30 days.")
})

# test carbon_generation function

test_that("test valid date dataframe", {
  df_generation <- carbon_generation("2023-5-11", "2023-5-12")
  expect_equal(dim(df_generation)[1],2)
  expect_equal(dim(df_generation)[2],10)
  expect_true(df_generation[1,"date"] == "2023-05-11")
  expect_true(df_generation[nrow(df_generation), "date"] == "2023-05-12")

})

test_that("test invalid dataframe", {
  df_out_30 <- carbon_generation("2023-5-11", "2023-6-12")
  expect_equal(df_out_30, NULL)

  df_earlier_allowed <- carbon_generation("2018-4-11", "2018-5-09")
  expect_equal(df_earlier_allowed, NULL)

  df_date_in_future <- carbon_generation("2024-5-11", "2024-6-12")
  expect_equal(df_date_in_future, NULL)

  df_from_larger_to <- carbon_generation("2023-6-13", "2023-6-12")
  expect_equal(df_from_larger_to, NULL)
})


# test carbon generation visualization

test_that("test line chart", {
  line_chart <- carbon_generation_visual("2023-6-12", "2023-6-21", "line")
  expect_that(line_chart, is_a("gg"))
})


test_that("test stack chart",{
  stack_chart <- carbon_generation_visual("2023-6-12", "2023-6-21", "stack")
  expect_that(stack_chart, is_a("gg"))
})

test_that("test pie chart",{
  # since we use pie function to create pie chart, the output chart is not suitable to be tested by testthat
  pie_chart <- carbon_generation_visual("2023-6-12", "2023-6-21", "pie")
  expect_equal(pie_chart, NULL)

})

test_that("Invalid chart type",{
  expect_error(carbon_generation_visual("2023-6-12", "2023-6-21", "bar"), "Invalid chart type")
})

test_that("Invalid type input",{
  expect_error(carbon_generation_visual("2023-6-12", "2023-6-21", "abc"), "Invalid chart type")
})
