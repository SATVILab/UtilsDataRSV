test_that("fixing excel decimal symbol errors works", {
  x <- c(
    "1,32",
    "1",
    "0,23",
    "3,23E-2",
    NA
  )
  expect_identical(
    convert_character_to_number_correctly(x[1]),
    1.32
  )
  expect_identical(
    convert_character_to_number_correctly(x[2]),
    1
  )
  expect_identical(
    convert_character_to_number_correctly(x[3]),
    0.23
  )
  expect_identical(
    convert_character_to_number_correctly(x[4]),
    0.0323
  )
  expect_identical(
    convert_character_to_number_correctly(x[5]),
    NA_real_
  )
  expect_identical(
    convert_character_to_number_correctly(x),
    c(1.32, 1, 0.23, 0.0323, NA_real_)
  )

  x_period <- c("1.32", "1", "0.23", "3.23E-2", NA)
  expect_identical(
    convert_character_to_number_correctly(x),
    c(1.32, 1, 0.23, 0.0323, NA_real_)
  )
})
