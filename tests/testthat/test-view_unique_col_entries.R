test_that("view_cols works", {
  test_df <- data.frame(x = rnorm(1e3), y = sample(c("a", "b"),
    size = 1e3,
    replace = TRUE
  ))
  sink(file = file.path(tempdir(), "test.txt"))
  expect_true(view_cols(test_df))
  expect_invisible(view_cols(test_df))
  expect_true(!identical(class(try(view_cols(test_df))), "try-error"))
  sink()
  suppressWarnings(try(
    invisible(
      file.remove(file.path(tempdir(), "test.txt"))
    ),
    silent = TRUE
  ))
})

test_that("view_cols handles input validation", {
  # Test non-dataframe input
  expect_error(view_cols("not a dataframe"), "x should be a dataframe")

  # Test invalid n_entry
  test_df <- data.frame(x = 1:10)
  expect_error(view_cols(test_df, n_entry = "abc"), "n_entry has class")

  # Test invalid n_col
  expect_error(view_cols(test_df, n_col = "abc"), "n_col has class")

  # Test invalid silent
  expect_error(view_cols(test_df, silent = "not logical"), "silent has class")
})

test_that("view_cols handles empty and special data", {
  path_sink <- file.path(tempdir(), "test-view_cols2.txt")
  file.create(path_sink)
  sink(file = path_sink)
  on.exit({
    sink()
    suppressWarnings(try(file.remove(path_sink), silent = TRUE))
  })

  # Test with zero columns - creates warning
  zero_col_df <- data.frame()
  expect_warning(view_cols(zero_col_df), "No columns in x")

  # Test with NA values in data
  na_df <- data.frame(x = c(1, 2, NA, 3), y = c("a", NA, "b", "c"))
  expect_true(view_cols(na_df))

  # Test with factor columns
  factor_df <- data.frame(x = factor(c("a", "b", "c")))
  expect_true(view_cols(factor_df))

  # Test n_col parameter (fewer columns displayed than total)
  many_col_df <- data.frame(a = 1:5, b = 1:5, c = 1:5, d = 1:5)
  expect_warning(view_cols(many_col_df, n_col = 2), "Unique entries from only 2")

  # Test silent parameter suppresses warning (but still produces output)
  expect_warning(view_cols(many_col_df, n_col = 2, silent = TRUE), regexp = NA)

  # Test n_entry_num parameter
  num_df <- data.frame(x = 1:100)
  expect_true(view_cols(num_df, n_entry_num = 3))

  # Test with many unique entries (triggers not displayed message)
  many_unique_df <- data.frame(x = letters[1:26])
  expect_warning(view_cols(many_unique_df, n_entry = 5), "Not all unique entries")
})
