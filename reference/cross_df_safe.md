# Safely cross lists

Returns the cartesian of all its elements in a list as a dataframe, with
one combination per row.

## Usage

``` r
cross_df_safe(.l, .filter = NULL)
```

## Arguments

- .l:

  A list of lists or atomic vectors (or, a dataframe).

- .filter:

  function. A predicate function that takes the same number of arguments
  as the number of variables to be combined.

## Value

A dataframe with the same number of rows as

## Details

Elements in the list to be crossed such as `list(1, 2:3)` keep their
multi-length elements in one combination (i.e. one dataframe row). That
is the sense in which is "safe", as it behaves as expected in that not
only lists are "guarded", i.e. not joined together.

The function \`purrr::cross\` returns an error in this case, whilst
\`purrr::cross\` piped \`purrr::map_df(tibble::as_tibble)\` w creates
two combinations (two dataframe rows) from the second list element
above. One could wrap the second element in a list, but that adds an
extra layer when accessing the element in the combination.

Another advantage

See examples for a demonstration.

## Examples

``` r
# cross_df_safe automatically
# "protects" non-list list elements
to_cross_list <- list(
  V1 = c("a", "b"),
  V2 = list(3, 4:5)
)
# returns an error
try(purrr::cross_df(to_cross_list))
#> Warning: `cross_df()` was deprecated in purrr 1.0.0.
#> ℹ Please use `tidyr::expand_grid()` instead.
#> ℹ See <https://github.com/tidyverse/purrr/issues/768>.
#> Warning: `cross()` was deprecated in purrr 1.0.0.
#> ℹ Please use `tidyr::expand_grid()` instead.
#> ℹ See <https://github.com/tidyverse/purrr/issues/768>.
#> ℹ The deprecated feature was likely used in the purrr package.
#>   Please report the issue at <https://github.com/tidyverse/purrr/issues>.
#> Error in recycle_columns(x, .rows, lengths) : 
#>   Tibble columns must have compatible sizes.
#> • Size 4: Column `V1`.
#> • Size 6: Column `V2`.
#> ℹ Only values of size one are recycled.
# can avoid this by wrapping each to-cross
# element's elements in lists,
# but then the crossed dataframe
# has second column's elements
# each be lists
to_cross_list_list <- list(
  V1 = c("a", "b"),
  V2 = list(list(3), list(4:5))
)
cross_df_purrr <- purrr::cross_df(to_cross_list_list)
cross_df_purrr$V2
#> [[1]]
#> [[1]][[1]]
#> [1] 3
#> 
#> 
#> [[2]]
#> [[2]][[1]]
#> [1] 3
#> 
#> 
#> [[3]]
#> [[3]][[1]]
#> [1] 4 5
#> 
#> 
#> [[4]]
#> [[4]][[1]]
#> [1] 4 5
#> 
#> 
# returns a four-row dataframe, where
# second column has elements of lengths 1, 1, 2 and 2
# that are not lists
cross_df_sf <- cross_df_safe(to_cross_list)
cross_df_sf$V2
#> [[1]]
#> [1] 3
#> 
#> [[2]]
#> [1] 3
#> 
#> [[3]]
#> [1] 4 5
#> 
#> [[4]]
#> [1] 4 5
#> 
# the above is more natural to work with
# no element in a combination
# is needlessly wrapped inside an unnamed list of length 1

#
to_cross_list_list <- list(
  V1 = c(list("a"), list("b")),
  V2 = list(
    c("a" = "c"),
    c("b" = "d")
  )
)

cross_df_std <- purrr::cross_df(to_cross_list_list)
cross_df_sf <- cross_df_safe(to_cross_list_list)
# purr:cross_df needlessly places each element of V2
# (e.g. list("a" = "c")) in its own list:
cross_df_std$V2
#>   a   a   b   b 
#> "c" "c" "d" "d" 
# the above means that to refer to the element, you need to
# add an extra set of brackets:
# cross_df_std$V2[[1]][[1]]
# in this case, however,cross_df_safe flattens the list by one level:
cross_df_sf$V2
#> [[1]]
#>   a 
#> "c" 
#> 
#> [[2]]
#>   a 
#> "c" 
#> 
#> [[3]]
#>   b 
#> "d" 
#> 
#> [[4]]
#>   b 
#> "d" 
#> 
# so that you can refer to individual elements more succinctly:
cross_df_sf$V2[[1]]
#>   a 
#> "c" 
```
