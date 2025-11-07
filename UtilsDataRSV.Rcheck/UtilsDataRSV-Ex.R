pkgname <- "UtilsDataRSV"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('UtilsDataRSV')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("convert_character_to_number_correctly")
### * convert_character_to_number_correctly

flush(stderr()); flush(stdout())

### Name: convert_character_to_number_correctly
### Title: Fix Excel decimal symbol errors
### Aliases: convert_character_to_number_correctly

### ** Examples

# vector of data (as if from Excel)
x <- c("1,32", "1", "0,23", "3,23E-2", NA)
x_period <- c("1.32", "1", "0.23", "3.23E-2", NA)
# original data alongside corrected data
data.frame(orig = x, replacement = convert_character_to_number_correctly(x = x))



cleanEx()
nameEx("cross_df_safe")
### * cross_df_safe

flush(stderr()); flush(stdout())

### Name: cross_df_safe
### Title: Safely cross lists
### Aliases: cross_df_safe

### ** Examples


# cross_df_safe automatically
# "protects" non-list list elements
to_cross_list <- list(
  V1 = c("a", "b"),
  V2 = list(3, 4:5)
)
# returns an error
try(purrr::cross_df(to_cross_list))
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
# returns a four-row dataframe, where
# second column has elements of lengths 1, 1, 2 and 2
# that are not lists
cross_df_sf <- cross_df_safe(to_cross_list)
cross_df_sf$V2
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
# the above means that to refer to the element, you need to
# add an extra set of brackets:
# cross_df_std$V2[[1]][[1]]
# in this case, however,cross_df_safe flattens the list by one level:
cross_df_sf$V2
# so that you can refer to individual elements more succinctly:
cross_df_sf$V2[[1]]



cleanEx()
nameEx("filter_based_on_mean_grp_value")
### * filter_based_on_mean_grp_value

flush(stderr()); flush(stdout())

### Name: filter_based_on_mean_grp_value
### Title: Choose subset of data with larger/smaller mean value
### Aliases: filter_based_on_mean_grp_value

### ** Examples

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

filter_based_on_mean_grp_value(
  data = test_tbl, val = "resp", grp_outer = "type_base",
  grp_inner = "type", sel = "smaller"
)



cleanEx()
nameEx("view_cols")
### * view_cols

flush(stderr()); flush(stdout())

### Name: view_cols
### Title: View random sample of unique column entries
### Aliases: view_cols

### ** Examples

test_df <- data.frame(x = rnorm(1e3), y = sample(c("a", "b"),
  size = 1e3,
  replace = TRUE
))
view_cols(test_df)



cleanEx()
nameEx("view_slice")
### * view_slice

flush(stderr()); flush(stdout())

### Name: view_slice
### Title: Print slices per group of a dataframe
### Aliases: view_slice

### ** Examples

data("cars")
cars[, "grp"] <- rep(letters[1:5], each = 10)
view_slice(cars, group = "grp", n_slice = 2)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
