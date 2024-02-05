#' @name carbonVisR
#' @docType package
#' @title Carbon-Intensity Visualization Package
#' @author Rui Mao
#' @seealso \code{\link{actual_and_forecast}}(RM)
#' @import jsonlite
#' @import tidyr
#' @import dplyr
#' @import lubridate
#' @import ggplot2
#' @import ggthemes
#' @import RColorBrewer
#' @import scales
#'
library(httr)
library(ggplot2)
library(lubridate)
library(usethis)


#' Title: actual_and_forecast carbon intensity
#'
#' @description
#' This function fetches the actual and forecasted carbon intensity data for electricity generation
#' in Great Britain for a specified date from the National Grid's Carbon Intensity API.
#' It then plots this data showing the trends over the course of the day.
#'
#' @param date A character string in the format 'YYYY-MM-DD' representing the date
#'
#' @return A ggplot object representing the trend of carbon intensity, both actual and forecasted.
#' @export
#'
#' @examples actual_and_forecast('2023-01-12')
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




