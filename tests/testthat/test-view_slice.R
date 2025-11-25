test_that("view_slice works", {
  data("cars", package = "datasets")
  cars[, "grp"] <- rep(letters[1:5], each = 10)
  path_sink <- file.path(tempdir(), "test-view_slice.txt")
  file.create(path_sink)
  sink(file = path_sink)
  on.exit(sink())

  # output
  # ----------------------

  expect_identical(
    class(
      view_slice(cars, group = "grp")
    ),
    "logical"
  )
  expect_identical(
    class(
      view_slice(cars, group = "grp", return = TRUE)
    ),
    c("grouped_df", "tbl_df", "tbl", "data.frame")
  )

  # sampling functions
  # ----------------------
  expect_identical(
    attributes(
      view_slice(cars,
        group = "grp",
        n_slice = 1, sample = TRUE,
        sample_within_group = TRUE,
        return = TRUE
      )
    )$groups[["grp"]] %>%
      unlist(),
    letters[1:5]
  )

  expect_identical(
    attributes(
      view_slice(cars,
        group = "grp",
        n_slice = 1, sample = TRUE,
        sample_within_group = FALSE,
        seed = 210,
        return = TRUE
      )
    )$groups[["grp"]] %>%
      unlist(),
    "b"
  )

  expect_identical(
    attributes(
      view_slice(cars,
        group = "grp",
        prop_sample = 0.05,
        sample = TRUE,
        sample_within_group = FALSE,
        seed = 2,
        return = TRUE
      )
    )$groups[["grp"]] %>%
      unlist(),
    c("b", "c")
  )

  # n_slice size
  # -----------------
  expect_identical(
    view_slice(cars,
      group = "grp",
      n_slice = 1,
      return = TRUE
    ) %>%
      nrow(),
    5L
  )
  expect_identical(
    view_slice(cars,
      group = "grp",
      n_slice = 3,
      return = TRUE
    ) %>%
      nrow(),
    15L
  )

  # select
  expect_identical(
    view_slice(cars,
      group = "grp",
      n_slice = 1,
      select = "speed",
      return = TRUE
    ) %>%
      colnames(),
    c("grp", "speed")
  )
})

test_that("view_slice handles input validation errors", {
  path_sink <- file.path(tempdir(), "test-view_slice2.txt")
  file.create(path_sink)
  sink(file = path_sink)
  on.exit(sink())

  # Test non-dataframe input
  expect_error(view_slice("not a dataframe", group = "grp"), "data must be a dataframe")

  # Test invalid group argument
  data("cars", package = "datasets")
  cars[, "grp"] <- rep(letters[1:5], each = 10)
  expect_error(view_slice(cars, group = 123), "group must be a character vector")

  # Test invalid n_print argument
  expect_error(view_slice(cars, group = "grp", n_print = "abc"), "n_print must be of class numeric")

  # Test invalid prop_sample argument
  expect_error(view_slice(cars, group = "grp", prop_sample = 1.5), "prop_sample must be be between 0 and 1")
  expect_error(view_slice(cars, group = "grp", prop_sample = -0.5), "prop_sample must be be between 0 and 1")

  # Test invalid return argument
  expect_error(view_slice(cars, group = "grp", return = "yes"), "return must be logical")

  # Test invalid select argument
  expect_error(view_slice(cars, group = "grp", select = 123), "select must be character vector or NULL")
})

test_that("view_slice handles edge cases", {
  path_sink <- file.path(tempdir(), "test-view_slice3.txt")
  file.create(path_sink)
  sink(file = path_sink)
  on.exit(sink())

  data("cars", package = "datasets")
  cars[, "grp"] <- rep(letters[1:5], each = 10)

  # Test n_print = 0 with return = FALSE
  result <- view_slice(cars, group = "grp", n_print = 0, return = FALSE)
  expect_identical(result, invisible(TRUE))

  # Test n_print = 0 with return = TRUE (returns empty tibble)
  result <- view_slice(cars, group = "grp", n_print = 0, return = TRUE)
  expect_equal(nrow(result), 0)

  # Test with non-tibble input (gets converted)
  cars_df <- as.data.frame(cars)
  result <- view_slice(cars_df, group = "grp", return = TRUE)
  expect_s3_class(result, "tbl_df")

  # Test sampling within group with prop_sample
  result <- view_slice(cars, group = "grp", sample = TRUE,
    sample_within_group = TRUE, prop_sample = 0.5, return = TRUE)
  expect_true(nrow(result) > 0)
})
