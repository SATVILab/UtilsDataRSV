test_that("install_project_dependencies works", {
  # This function is designed to work in a project directory with a DESCRIPTION file
  # Skip if not in such a directory
  skip_if_not(file.exists("DESCRIPTION") || file.exists(file.path("..", "DESCRIPTION")),
              "DESCRIPTION file not found")
  y <- install_project_dependencies()
})

test_that("install_project_dependencies errors without DESCRIPTION", {
  # Test that function errors when no DESCRIPTION file is found
  tmp_dir <- tempdir()
  old_wd <- getwd()
  test_dir <- file.path(tmp_dir, "test_no_desc")
  dir.create(test_dir, showWarnings = FALSE, recursive = TRUE)
  setwd(test_dir)
  on.exit(setwd(old_wd), add = TRUE)
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

  expect_error(
    install_project_dependencies(),
    "Could not find DESCRIPTION file"
  )
})

test_that("install_project_dependencies handles minimal DESCRIPTION", {
  # Create a minimal DESCRIPTION file in a temp directory
  tmp_dir <- tempdir()
  old_wd <- getwd()
  test_dir <- file.path(tmp_dir, "test_min_desc")
  dir.create(test_dir, showWarnings = FALSE, recursive = TRUE)

  # Create minimal DESCRIPTION with no dependencies
  desc_content <- c(
    "Package: TestPkg",
    "Title: Test Package",
    "Version: 0.1.0",
    "Description: A test package"
  )
  writeLines(desc_content, file.path(test_dir, "DESCRIPTION"))

  setwd(test_dir)
  on.exit(setwd(old_wd), add = TRUE)
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

  # Should return empty character vector when no dependencies
  result <- install_project_dependencies()
  expect_identical(result, character(0))
})
