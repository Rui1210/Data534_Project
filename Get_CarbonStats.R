library(httr)
library(tidyverse)

Get_CarbonStats <- function(from, to, block = FALSE) {
  stats_url <- 'https://api.carbonintensity.org.uk/intensity/stats'
  from <- as.Date(from)
  to <- as.Date(to)
  result_df <- data.frame(date = character(),
                          max = character(),
                          average = character(),
                          min = character(),
                          index = character(),
                          stringsAsFactors = FALSE)
  
  if (block == TRUE){
    for (day in seq(from, to - 1, by = '1 day')) {
      next_day <- day + 1
      url <- paste(stats_url, as.Date(day), as.Date(next_day), block, sep = '/')
      response <- GET(url)
      parsed_data <- content(response, "parsed")
      df <- parsed_data[["data"]][[1]][["intensity"]]
      result_row <- c(date = as.character(as.Date(day)),
                      max = as.character(df$max),
                      average = as.character(df$average),
                      min = as.character(df$min),
                      index = as.character(df$index))
      result_df <- bind_rows(result_df, result_row)
    }
  }else{
    for (day in seq(from, to - 1, by = '1 day')) {
      next_day <- day + 1
      url <- paste(stats_url, as.Date(day), as.Date(next_day), sep = '/')
      response <- GET(url)
      parsed_data <- content(response, "parsed")
      df <- parsed_data[["data"]][[1]][["intensity"]]
      result_row <- c(date = as.character(as.Date(day)),
                      max = as.character(df$max),
                      average = as.character(df$average),
                      min = as.character(df$min),
                      index = as.character(df$index))
      result_df <- bind_rows(result_df, result_row)
  }}
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
