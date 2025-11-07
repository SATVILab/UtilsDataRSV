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
