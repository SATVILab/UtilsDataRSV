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
