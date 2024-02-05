## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----include=FALSE------------------------------------------------------------
if (!requireNamespace("htmltools", "0.5.7")) {
  install.packages("htmltools")
}

## ----setup--------------------------------------------------------------------
library(carbonVisR)

## ----validate_date_range------------------------------------------------------
# Example Usage
validate_date_range("2022-01-01", "2022-01-15")

## ----carbon_generation--------------------------------------------------------
# Example Usage
df_carbon_generation <- carbon_generation("2022-01-01", "2022-01-15")
head(df_carbon_generation)

## ----line---------------------------------------------------------------------
# Example Usage for Line Chart
line_chart <- carbon_generation_visual("2022-01-01", "2022-01-15", "line")
print(line_chart)


## ----stack--------------------------------------------------------------------
# Example Usage for Stack Chart
stack_chart <- carbon_generation_visual("2022-01-01", "2022-01-15", "stack")
print(stack_chart)


## ----pie----------------------------------------------------------------------
# Example Usage for Pie Chart
carbon_generation_visual("2022-01-01", "2022-01-15", "pie")


