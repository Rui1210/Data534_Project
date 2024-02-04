#' @name carbonVisR
#' @docType package
#' @title Carbon Visualization Package
#' @description This package provides functions for visualizing carbon generation data.
#'
#' @author Zheng Zhang
#' @import httr
#' @import jsonlite
#' @import tidyr
#' @import dplyr
#' @import lubridate
#' @import ggplot2
#' @import ggthemes
#' @import RColorBrewer
#' @import scales

library(httr)
library(jsonlite)
library(tidyr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggthemes)
library(RColorBrewer)
library(scales)


#' Get Carbon Intensity Statistics
#'
#' This function retrieves carbon intensity statistics from the Carbon Intensity API
#' for a specified date range. It returns a list containing two elements: 'data' (a
#' data frame) and 'plot' (a ggplot object) for visualizing the intensity trends.
#'
#' @param from Start date in "YYYY-MM-DD" format.
#' @param to   End date in "YYYY-MM-DD" format.
#' @return A list with two elements: 'data' (a data frame) and 'plot' (a ggplot object).
#'
#' @details
#' The function queries the Carbon Intensity API for each day within the specified
#' date range and retrieves maximum, average, and minimum intensity values. The result
#' is a data frame containing date-wise intensity statistics, and a ggplot object for
#' visualizing the intensity trends over time.
#'
#' @examples
#' \dontrun{
#' Get_CarbonStats("2023-01-20", "2023-01-30")
#' Get_CarbonStats("2023-01-20", "2023-01-30")$data
#' Get_CarbonStats("2023-01-20", "2023-01-30")$plot
#' }
#'
#'
#' @export
Get_CarbonStats <- function(from, to) {
  stats_url <- 'https://api.carbonintensity.org.uk/intensity/stats'
  from <- as.Date(from)
  to <- as.Date(to)
  result_df <- data.frame(date = character(),
                          max = character(),
                          average = character(),
                          min = character(),
                          index = character(),
                          stringsAsFactors = FALSE)

  for (day in seq(from, to - 1, by = '1 day')) {
      next_day <- day + 1
      url <- paste(stats_url, as.Date(day), as.Date(next_day), sep = '/')
      tryCatch({
        response <- GET(url)
        parsed_data <- content(response, "parsed")
        df <- parsed_data[["data"]][[1]][["intensity"]]
        result_row <- c(date = as.character(as.Date(day)),
                        max = as.character(df$max),
                        average = as.character(df$average),
                        min = as.character(df$min),
                        index = as.character(df$index))
        result_df <- bind_rows(result_df, result_row)
      }, error = function(e) {
        stop("Error in API request. Please check the date range and try again.")
      })
  }
  result_df$date <- as.Date(result_df$date, formate = "%y-%m-%d")
  result_df$max <- as.numeric(result_df$max)
  result_df$average <- as.numeric(result_df$average)
  result_df$min <- as.numeric(result_df$min)

  plot <- ggplot(result_df, aes(x = date)) +
    geom_ribbon(aes(ymin = min, ymax = max), fill = "skyblue", alpha = 0.5) +
    geom_line(aes(y = average), color = "red") +
    geom_point(aes(y = average, col = index, group = index)) +
    labs(title = "Intensity Range and Average Over Time",
         x = "Date",
         y = "Intensity")
  return(list(data = result_df, plot = plot))
}
