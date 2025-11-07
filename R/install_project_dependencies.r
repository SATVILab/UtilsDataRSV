#' @title Install suggested packages only if missing
#'
#' @description Reads DESCRIPTION file and installs any
#' suggested packages that are missing.
#' Useful in R data packages, as this can be run in
#' a script to create the data to easily install packages
#' required for actually creating the data, but not required
#' for simply using the R package as an R package.
#'
#' Searches for DESCRIPTION file in working directory
#' and parent of working directory (useful for Rmd's).
#'
#' @param only_if_missing logical.
#' If \code{TRUE}, then only installs packages that
#' are not already installed.
#' Default is \code{FALSE}.
#'
#' @param dependencies character vector.
#' Types of dependencies to install (e.g., "Imports", "Suggests", "Depends").
#' Default is \code{c("Imports", "Suggests", "Depends")}.
#'
#' @param ... arguments passed to \code{install.packages}.
#'
#' @details
#' Still need/unclear how to do the following:
#' - install packages specifically off BioConductor (probably
#' just check if packages are on CRAN first).
#' - allow installation from remotes.
#' - allow update of packages
#' Should we rename function to install_project_dependencies?
#' - This is not meant for R packages, but rather packages using
#' `bookdown`, and others where you don't really install the output.
#' @return Invisibly returns character vector of installed packages.
#' @importFrom utils install.packages installed.packages
#' @importFrom stats setNames
install_project_dependencies <- function(only_if_missing = TRUE,
                                         dependencies = c("Imports", "Suggests", "Depends"), # nolint
                                         ...) {
  fn <- c("DESCRIPTION", file.path(dirname(getwd()), "DESCRIPTION"))
  fn <- fn[file.exists(fn)]
  if (length(fn) == 0) {
    msg <- "Could not find DESCRIPTION file in working directory or immediate parent." # nolint
    stop(msg, call. = FALSE)
  }
  fn <- fn[[1]]
  desc_mat <- read.dcf(fn)
  pkg_version_vec <- c("testthat (>= 3.0.0)", "dplyr")
  pkg_version_vec <- NULL
  for (x in dependencies) {
    if (!x %in% colnames(desc_mat)) next
    pkg_version_vec <- c(
      pkg_version_vec, strsplit(desc_mat[, x], split = ",\\n")[[1]]
      )
  }
  if (length(pkg_version_vec) == 0) return(invisible(character(0)))
  pkg_mat <- installed.packages()
  pkg_version_list <- strsplit(pkg_version_vec, " \\(|\\)")
  pkg_vec <- vapply(pkg_version_list, function(x) x[[1]], character(1))
  version_vec_number <- lapply(pkg_version_list, function(x) {
    if (length(x) == 1) return(NULL)
    strsplit(x[2], " ")[[1]][2]
  })
  version_vec_number <- setNames(version_vec_number, pkg_vec)
  version_vec_relation <- lapply(pkg_version_list, function(x) {
    if (length(x) == 1) return(NULL)
    strsplit(x[2], " ")[[1]][1]
  })
  version_vec_relation <- setNames(version_vec_relation, pkg_vec)
  pkg_vec_versioned <- names(Filter(Negate(is.null), version_vec_relation))
  pkg_vec_installed_n <- pkg_vec[!pkg_vec %in% pkg_mat[, "Package"]]
  pkg_vec_installed <- setdiff(pkg_vec, pkg_vec_installed_n)
  pkg_vec_versioned_installed <- setdiff(pkg_vec_versioned, pkg_vec_installed_n)

  # get packages that have versions that are different
  pkg_vec_installed_n_greater <- NULL
  pkg_vec_installed_n_exact <- NULL
  for (i in seq_along(pkg_vec_versioned_installed)) {
    pkg <- pkg_vec_versioned_installed[i]
    version_required <- version_vec_number[pkg][[1]]
    relation <- version_vec_relation[pkg][[1]]
    version_installed <- pkg_mat[pkg_mat[, "Package"] == pkg, "Version"]
    version_required_12 <- as.numeric(substr(version_required, 1, 3))
    version_installed_12 <- as.numeric(substr(version_installed, 1, 3))
    version_required_23 <- as.numeric(
      substr(version_required, 3, nchar(version_required))
      )
    version_installed_23 <- as.numeric(
      substr(version_installed,  3, nchar(version_installed))
      )
    installed_out_out_date_12 <- version_required_12 > version_installed_12
    installed_out_of_date_23 <- (version_required_12 == version_installed_12) &&
      (version_required_23 > version_installed_23)
    installed_out_of_date <- installed_out_out_date_12 ||
      installed_out_of_date_23
    installed_not_exact <- version_installed != version_required
    if (relation == ">=" && installed_out_of_date) {
      pkg_vec_installed_n <- c(pkg_vec_installed_n, pkg)
      pkg_vec_installed_n_greater <- c(pkg_vec_installed_n_greater, pkg)
    } else if (relation == "==" && installed_not_exact) {
      pkg_vec_installed_n_exact <- c(pkg_vec_installed_n_exact, pkg)
    } else {
      stop("relation not recognised")
    }
  }

  # install packages that need to be installed
  if (length(pkg_vec_installed_n) > 0) {
    install.packages(pkg_vec_installed_n, ...)
  }
  if (!is.null(pkg_vec_installed_n_exact)) {
    if (!requireNamespace("versions", quietly = TRUE)) {
      install.packages("versions", ...)
    }
    versions::install.versions(
      pkgs = pkg_vec_installed_n_exact,
      versions = as.character(version_vec_number[pkg_vec_installed_n_exact]),
      ...
    )
  }

  # check that packages have correct version
  pkg_vec_incorrect_version <- NULL
  for (i in seq_along(pkg_vec_installed_n_greater)) {
    if (i == 1) pkg_mat <- installed.packages()
    pkg <- pkg_vec_versioned_installed[i]
    version_required <- version_vec_number[pkg][[1]]
    relation <- version_vec_relation[pkg][[1]]
    version_installed <- pkg_mat[pkg_mat[, "Package"] == pkg, "Version"]
    version_required_12 <- as.numeric(substr(version_required, 1, 3))
    version_installed_12 <- as.numeric(substr(version_installed, 1, 3))
    version_required_23 <- as.numeric(
      substr(version_required, 3, nchar(version_required))
      )
    version_installed_23 <- as.numeric(
      substr(version_installed,  3, nchar(version_installed))
      )
    installed_out_out_date_12 <- version_required_12 > version_installed_12
    installed_out_of_date_23 <- (version_required_12 == version_installed_12) &&
      (version_required_23 > version_installed_23)
    installed_out_of_date <- installed_out_out_date_12 ||
      installed_out_of_date_23
    if (installed_out_of_date) pkg_vec_incorrect_version <- c(
      pkg_vec_incorrect_version, pkg
    )
  }

  if (!is.null(pkg_vec_incorrect_version)) stop(
    paste0("The following packages have out of date versions after installing from CRAN: ",
           paste0(pkg_vec_incorrect_version, collapse = ", "))
  )

  invisible(pkg_vec)
}
