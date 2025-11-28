# Print slices per group of a dataframe

Wrapper around

Returns subsetted data invisibly.

## Usage

``` r
view_slice(
  data,
  group,
  select = NULL,
  n_print = 1000,
  n_slice = 1,
  seed = NULL,
  sample_within_group = FALSE,
  sample = FALSE,
  prop_sample = NULL,
  return = FALSE
)
```

## Arguments

- data:

  dataframe. Contains data to print.

- group:

  character. Name of column to group by before subsetting.

- select:

  character vector. Name(s) of columns to select before printing.

- n_print:

  numeric. Number of slices to print per group.

- n_slice:

  numeric. Number of slices to select per group.

- seed:

  numeric. If not `NULL`, then seed is set to this value. Default is
  `NULL`.

- sample_within_group:

  logical. If `TRUE` and sampling is selected, then sampling is
  performed within each group. Otherwise sampling is performed across
  the whole table. Default is `FALSE`.

- sample:

  logical. If `TRUE`, then rows are sampled. Unless `prop_sample` is
  specified, then `n_slice` rows are sampled.

- prop_sample:

  numeric. If not `NULL`, then proportion of rows to sample. Overrides
  `n_slice`. Default is `NULL`.

- return:

  logical. If `TRUE`, then the subsetted table is returned. Otherwise,
  `invisible(TRUE)` is returned. Default is `FALSE`.

## Examples

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
