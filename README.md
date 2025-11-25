
<!-- README.md is generated from README.Rmd. Please edit that file -->

# UtilsDataRSV

<!-- badges: start -->

[![R-CMD-check](https://github.com/SATVILab/UtilsDataRSV/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SATVILab/UtilsDataRSV/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/SATVILab/UtilsDataRSV/graph/badge.svg)](https://codecov.io/gh/SATVILab/UtilsDataRSV)
<!-- badges: end -->

UtilsDataRSV is an R package that provides utility functions for common
data pre-processing tasks. It helps streamline workflows by offering
tools to quickly inspect data, fix common import errors, and perform
group-based data operations.

## Features

- **Data Inspection**: View unique column entries and group-based data
  slices
- **Data Cleaning**: Fix Excel decimal symbol errors from locale
  mismatches
- **Data Manipulation**: Safe list crossing and group-based filtering
  utilities

## Installation

You can install UtilsDataRSV from
[GitHub](https://github.com/SATVILab/UtilsDataRSV) with:

``` r
if (!require("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("SATVILab/UtilsDataRSV")
```

## Examples

``` r
library(UtilsDataRSV)
```

### View unique column entries

`view_cols()` displays a random sample of unique entries for each column
in a dataframe, useful for quickly understanding data structure and
content.

``` r
data("mtcars")
view_cols(mtcars)
#> [1] "mpg"
#> [1] 15.0 30.4 32.4 14.7 15.8
#> [1] "_____________________"
#> [1] "cyl"
#> [1] 4 8 6
#> [1] "_____________________"
#> [1] "disp"
#> [1] 318.0  95.1 400.0 440.0 301.0
#> [1] "_____________________"
#> [1] "hp"
#> [1]  66 110 245 230 175
#> [1] "_____________________"
#> [1] "drat"
#> [1] 3.23 3.73 4.22 3.00 3.70
#> [1] "_____________________"
#> [1] "wt"
#> [1] 5.424 2.320 3.845 2.620 3.570
#> [1] "_____________________"
#> [1] "qsec"
#> [1] 18.90 17.60 18.60 15.41 19.90
#> [1] "_____________________"
#> [1] "vs"
#> [1] 0 1
#> [1] "_____________________"
#> [1] "am"
#> [1] 0 1
#> [1] "_____________________"
#> [1] "gear"
#> [1] 4 5 3
#> [1] "_____________________"
#> [1] "carb"
#> [1] 6 3 1 2 4
#> [1] "_____________________"
```

### View data slices by group

`view_slice()` shows a subset of entries per group, a convenient wrapper
around `dplyr::group_by()` and `dplyr::slice()`.

``` r
data("cars")
cars[, "grp"] <- rep(letters[1:5], each = 10)
view_slice(cars, group = "grp", n_slice = 2)
#> # A tibble: 10 × 3
#> # Groups:   grp [5]
#>    speed  dist grp  
#>    <dbl> <dbl> <chr>
#>  1     4     2 a    
#>  2     4    10 a    
#>  3    11    28 b    
#>  4    12    14 b    
#>  5    14    36 c    
#>  6    14    60 c    
#>  7    17    50 d    
#>  8    18    42 d    
#>  9    20    52 e    
#> 10    20    56 e
```

### Fix Excel decimal symbol errors

`convert_character_to_number_correctly()` fixes errors when Excel
exports numbers using comma as the decimal separator but R expects a
period.

``` r
# vector of data (as if from Excel)
x <- c("1,32", "1", "0,23", "3,23E-2", NA)
x_corrected <- convert_character_to_number_correctly(x = x)
# original data alongside corrected data
tibble::tibble(original = x, corrected = x_corrected)
#> # A tibble: 5 × 2
#>   original corrected
#>   <chr>        <dbl>
#> 1 1,32        1.32  
#> 2 1           1     
#> 3 0,23        0.23  
#> 4 3,23E-2     0.0323
#> 5 <NA>       NA
```

## Additional Functions

- `cross_df_safe()`: Safely cross lists into a dataframe, handling
  multi-length elements without unexpected expansion
- `filter_based_on_mean_grp_value()`: Filter data to keep only groups
  with the smallest or largest mean value
