# Choose subset of data with larger/smaller mean value

Choose subset of data with larger/smaller mean value

## Usage

``` r
filter_based_on_mean_grp_value(data, val, grp_outer, grp_inner, sel)
```

## Arguments

- data:

  dataframe. Dataframe for which subset(s) should be chosen.

- val:

  character. Name of column in `data` containing the data whose mean
  determines which group in `group_inner` to choose.

- grp_outer:

  character. Name of column in `data` indicating a group of entries for
  which only one level in `grp_inner` should be chosen.

- grp_inner:

  character. Name of of column in `data` indicating the sub-groups in
  grp_outer. Only one level of grp_inner will be chosen per level of
  grp_outer.

- sel:

  'smaller' or 'larger'. Level of `grp_inner` will be chosen per level
  of `grp_outer` such that it has the smallest mean of all groups (as
  defined by `grp_inner`) for that level of `grp_outer`, if
  `sel == 'smaller'`. Opposite if `sel == 'larger'`. No default.

## Value

A dataframe with only one level of `grp_inner` for each level of
`grp_outer`.

## Details

This was written for the situation where the abundance of various types
of cells are available (e.g. CD4 T cells expressing IFNg+), and where
both frequencies and counts are available but it is not indicated which
column pertains to frequencies and which to counts. Note that this
function will not work reliably when the response is a frequency (rather
than a proportion) and the denominator cell count is not consistently
much higher than 100.

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
library(tibble)
library(purrr)
library(stringr)
set.seed(3)
test_tbl <- tibble(
  pid = rep(c("id1", "id2", "id1", "id2"), each = 2),
  type = c(paste0(rep(c("a", "b"), each = 4), rep(c("", "_1"), 4)))
) %>%
  mutate(type_base = stringr::str_remove(type, "_1")) %>%
  group_by(pid, type_base) %>%
  mutate(resp = purrr::map_dbl(type_base, function(x) {
    round(rnorm(1, 5 + stringr::str_detect(x, "b") * 3), 2)
  })[1]) %>%
  ungroup() %>%
  mutate(resp = ifelse(str_detect(type, "_1"), rep(runif(4, 1e4, 1e5), each = 2), 1) * resp)

test_tbl
#> # A tibble: 8 × 4
#>   pid   type  type_base      resp
#>   <chr> <chr> <chr>         <dbl>
#> 1 id1   a     a              4.04
#> 2 id1   a_1   a          80923.  
#> 3 id2   a     a              5.2 
#> 4 id2   a_1   a         381326.  
#> 5 id1   b     b              8.26
#> 6 id1   b_1   b         749793.  
#> 7 id2   b     b              8.09
#> 8 id2   b_1   b         284573.  

filter_based_on_mean_grp_value(
  data = test_tbl, val = "resp", grp_outer = "type_base",
  grp_inner = "type", sel = "smaller"
)
#> # A tibble: 4 × 4
#>   pid   type  type_base  resp
#>   <chr> <chr> <chr>     <dbl>
#> 1 id1   a     a          4.04
#> 2 id2   a     a          5.2 
#> 3 id1   b     b          8.26
#> 4 id2   b     b          8.09
```
