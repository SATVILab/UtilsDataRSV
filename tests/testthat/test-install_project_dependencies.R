test_that("install_project_dependencies works", {
  # This function is designed to work in a project directory with a DESCRIPTION file
  # Skip if not in such a directory
  skip_if_not(file.exists("DESCRIPTION") || file.exists(file.path("..", "DESCRIPTION")),
              "DESCRIPTION file not found")
  y <- install_project_dependencies()
})
