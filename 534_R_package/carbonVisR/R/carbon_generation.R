#' @name carbonVisR
#' @docType package
#' @title Carbon-Intensity Visualization Package
#' @description This package provides functions for visualizing carbon generation data.
#' @author Yahan Cong
#' @seealso \code{\link{validate_date_range}}(YC), \code{\link{carbon_generation}}(YC), \code{\link{carbon_generation_visual}}(YC)
#' @import jsonlite
#' @import tidyr
#' @import dplyr
#' @import lubridate
#' @import ggplot2
#' @import ggthemes
#' @import RColorBrewer
#' @import scales
#' @import mockery
#' @import httr

library(mockery)
library(httr)
library(jsonlite)
library(tidyr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggthemes)
library(RColorBrewer)
library(scales)
library(lubridate)

#' Validate Date Range
#'
#' This function checks the validity of a given date range, ensuring it meets specific criteria.
#'
#' @param from_date The starting date of the range.
#' @param to_date The ending date of the range.
#'
#' @return A vector containing the validated from_date and to_date.
#'
#' @details
#' The input date range must not be earlier than May 11, 2018, and the date range
#' cannot exceed 30 days. Otherwise, an error message will be generated.
#'
#' @examples
#' validate_date_range("2022-01-01", "2022-01-15")
#'
#' @export
validate_date_range <- function(from_date, to_date){

  tryCatch({
    from_date = as.Date(from_date)
    to_date = as.Date(to_date)

    # input date cannot earlier than 20180511(API will not give response)
    min_allowed_date <- as.Date("2018-05-11")
    if (from_date < min_allowed_date || to_date < min_allowed_date) {
      stop("from_date and to_date cannot be earlier than May 11, 2018.")
    }

    days_difference <- as.numeric(difftime(to_date, from_date, units = "days"))

    if (to_date < from_date) {
      stop("to_date must be greater than or equal to from_date")
    } else if (from_date > Sys.Date()) {
      stop("from_date cannot be in the future.")
    } else if (to_date > Sys.Date()) {
      stop("to_date cannot be in the future.")
    } else if (days_difference > 30){
      stop("Date range cannot exceed 30 days.")
    }
    return(c(from_date = from_date, to_date = to_date))

  }, error = function(e) {
    message("Error converting dates: ", e$message)

  })

}

#' Get Dataframe of Carbon Generation Mix
#'
#' This function retrieves data on carbon generation mix from the specified date range
#' using the Carbon Intensity API.
#'
#' @param from_date The starting date of the range.
#' @param to_date The ending date of the range.
#'
#' @return A dataframe containing information about the carbon generation mix.
#'
#' @examples
#' carbon_generation("2022-01-01", "2022-01-15")
#'
#' @export
carbon_generation <- function(from_date, to_date){
  domain = 'https://api.carbonintensity.org.uk/generation'

  dates <- validate_date_range(from_date, to_date)
  if (!is.null(dates)) {
    from_date = dates[[1]]
    to_date = dates[[2]]
    cat("Valid date range. Proceeding with API request.\n")

    # transfer from_date and to_date
    from_date <- format(from_date, "%Y-%m-%dT%H:%M:00Z")
    from_date <- as.POSIXct(from_date, tz = "UTC") + minutes(30)
    from_date <- format(from_date, "%Y-%m-%dT%H:%M:00Z")

    to_date <- format(to_date, "%Y-%m-%dT%H:%M:00Z")
    to_date <- as.POSIXct(to_date, tz = "UTC") + days(1) - minutes(30)
    to_date <- format(to_date, "%Y-%m-%dT%H:%M:00Z")

    api_url <- paste0(domain, "/", from_date, "/", to_date)
    #cat(api_url)

    response = GET(api_url)
    json_content = content(response, "text",encoding = "UTF-8")
    data <- fromJSON(json_content)$data

    #translate json file into dataframe
    json_content = content(response, "text",encoding = "UTF-8")
    data <- fromJSON(json_content)$data
    data <- unnest(data, cols = generationmix)
    data <- spread(data, key = fuel, value = perc)

    # merge daily report together
    data$from <- as.POSIXct(data$from, format = "%Y-%m-%dT%H:%MZ")
    data$to <- as.POSIXct(data$to, format = "%Y-%m-%dT%H:%MZ")
    data$from <- floor_date(data$from, unit = "day")
    data$to <- floor_date(data$to, unit = "day")

    data <- select(data, -from)
    data <- rename(data, date = to)

    data_generation <- data %>%
      group_by(date) %>%
      summarize(
        biomass = sum(biomass),
        coal = sum(coal),
        gas = sum(gas),
        hydro = sum(hydro),
        imports = sum(imports),
        nuclear = sum(nuclear),
        other = sum(other),
        solar = sum(solar),
        wind = sum(wind)
      )
    data_generation
  }
}


#' Visualize Carbon Generation Data
#'
#' This function visualizes carbon generation data based on the specified date range
#' and chart type. Supported chart types include "line", "stack", and "pie".
#'
#' @param from_date The starting date of the range.
#' @param to_date The ending date of the range.
#' @param chart_type The type of chart to create ("line", "stack", or "pie").
#'
#' @return A ggplot object representing the requested chart (for "line" and "stack" types).
#' For "pie" type, the function directly plots and doesn't return a ggplot object.
#'
#' @examples
#' carbon_generation_visual("2022-01-01", "2022-01-15", "line")
#'
#' @export
carbon_generation_visual <- function(from_date, to_date, chart_type){

  data_generation <- carbon_generation(from_date, to_date)
  df_long <- data_generation %>%
    pivot_longer(cols = -date, names_to = "fuel", values_to = "value")

  chart_type <- tolower(chart_type)
  # valid chart type: "line", "stack", "pie"
  # create line, stack or pie chart
  if (chart_type == "line"){
    generation_line <- ggplot(df_long, aes(x = date, y = value,color = fuel)) + geom_line() + geom_point() + theme_stata()
    generation_line
  } else if (chart_type == "stack"){
    generation_stack <- ggplot(df_long, aes(x = date, y = value,fill = fuel)) +
      geom_area() +
      theme_stata() +
      scale_fill_brewer(palette="Greens")
    generation_stack
  } else if (chart_type == "pie"){
    df_colSum <- colSums(data_generation[, -1], na.rm = TRUE)
    df_colSum <- as.data.frame(t(df_colSum))
    df_colSum_long <- pivot_longer(df_colSum, everything(), names_to = "Fuel", values_to = "Sum")
    df_colSum_long <- df_colSum_long %>%
      mutate(Percentage = Sum / sum(Sum))


    brewer_palette <- "YlGnBu"
    palette_function <- brewer_pal(palette = brewer_palette)(length(df_colSum_long$Fuel))
    percentage <- sprintf("%s\n%.2f%%", df_colSum_long$Fuel, df_colSum_long$Percentage * 100)
    pie(df_colSum_long$Percentage, labels = percentage, col = palette_function)
  } else{
    stop("Error: Invalid chart type. Supported types are 'line', 'stack', and 'pie'.")
  }
}

