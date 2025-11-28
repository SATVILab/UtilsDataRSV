# View random sample of unique column entries

Displays up to `n_entry` unique entries for the first `n_col` columns.
Note that `NA` is always included amongst displayed entries if present.

## Usage

``` r
view_cols(x, n_entry = 20, n_entry_num = 5, n_col = 100, silent = FALSE)
```

## Arguments

- x:

  dataframe. Dataframe for which unique column entries should be
  displayed.

- n_entry:

  integer. Maximum of unique entries to display per column. Set equal to
  `Inf` if you want to see all unique column entries. Default is 20.

- n_entry_num:

  Maximum number of unique entries to display for numeric columns. Set
  equal to `Inf` if you want to see all unique entries. If `NULL`, then
  `n_entry` is used for numeric columns as well. Default is 5.

- n_col:

  integer. Maximum number of columns to display unique entries for. A
  message is by default displayed if fewer than all the columns have
  their data data displayed. Set equal to `Inf` if all columns should be
  displayed. If not an integer but still a number, then the integer
  component number of columns is displayed. Default for `n_col` is 1e2.

- silent:

  logical. If `TRUE`, then a message about there being fewer columns
  displayed than total columns available is not printed. Default is
  `FALSE`.

## Examples

``` r
test_df <- data.frame(x = rnorm(1e3), y = sample(c("a", "b"),
  size = 1e3,
  replace = TRUE
))
view_cols(test_df)
#> [1] "x"
#> [1] 0.1704266 1.6025593 0.2664109 1.4066223 0.3140215
#> [1] "_____________________"
#> [1] "y"
#> [1] "a" "b"
#> [1] "_____________________"
```
