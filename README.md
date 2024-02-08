# DATA 534 R Project

# carbonVis
[![R Package Build carbonVisR](https://github.com/Rui1210/Data534_Project/actions/workflows/r.yml/badge.svg)](https://github.com/Rui1210/Data534_Project/actions/workflows/r.yml)


## Overview
The `carbonVisR` package is designed to empower users with the tools to analyze and visualize the dynamics of carbon intensity across the United Kingdom. Leveraging real-time data and forecasts from the Carbon Intensity API, our package meticulously compiles carbon emission statistics from various UK regions, enabling a detailed examination of environmental impacts.

## Installation 
You can install the package from GitHub using the `devtools` package: 

```r 
devtools::install_github("Rui1210/Data534_Project/534_R_package/carbonVisR")
```

## Function

### validate_date_range()

This function checks the validity of a given date range, ensuring it meets specific criteria. 
Return a vector containing the validated from_date and to_date.

```r
validate_date_range(from_date, to_date)
```
`from_date`: The starting date of the range.

`to_date`: The ending date of the range.

The input date range must not be earlier than May 11, 2018, and the date range cannot exceed 30 days. Otherwise, an error message will be generated.

#### Example
```r
validate_date_range("2022-01-01", "2022-01-15")
```


### carbon_generation()

This function retrieves data on carbon emissions caused by the UK's power generation system from the specified date range using the Carbon Intensity API.
Return a dataframe containing information about the carbon generation mix.

```r
carbon_generation(from_date, to_date)
```
`from_date`: The starting date of the range.

`to_date`: The ending date of the range.

#### Example
```r
carbon_generation("2022-01-01", "2022-01-15")
```

### carbon_generation_visual()

This function visualizes carbon generation data based on the specified date range and chart type. Supported chart types include "line", "stack", and "pie".
A ggplot object representing the requested chart (for "line" and "stack" types). For "pie" type, the function directly plots and doesn't return a ggplot object.

```r
carbon_generation_visual(from_date, to_date, chart_type)
```
`from_date`: The starting date of the range.

`to_date`: The ending date of the range.

`chart_type`: The type of chart to create ("line", "stack", or "pie").

#### Example
```r
carbon_generation_visual("2022-01-01", "2022-01-15", "line")
```

### actual_and_forecast()

This function fetches the actual and forecasted carbon intensity data for electricity generation in Great Britain for a specified date from the National Grid's Carbon Intensity API. It then plots this data showing the trends over the course of the day.
Return a ggplot object representing the trend of carbon intensity, both actual and forecasted.

```r
actual_and_forecast(date)
```
`date`: A character string in the format 'YYYY-MM-DD' representing the date

#### Example
```r
actual_and_forecast('2023-01-12')
```

### Get_CarbonStats

The function queries the Carbon Intensity API for each day within the specified date range and retrieves maximum, average, and minimum intensity values. The result is a data frame containing date-wise intensity statistics, and a ggplot object for visualizing the intensity trends over time.

```r
Get_CarbonStats(from, to)
```
`from`: Start date in "YYYY-MM-DD" format.

`to`: End date in "YYYY-MM-DD" format.

#### Example:
```r
Get_CarbonStats("2023-01-20", "2023-01-30")
Get_CarbonStats("2023-01-20", "2023-01-30")$data
Get_CarbonStats("2023-01-20", "2023-01-30")$plot
```

## References
[Carbon Intensity API](https://carbon-intensity.github.io/api-definitions/#carbon-intensity-api-v2-0-0)

