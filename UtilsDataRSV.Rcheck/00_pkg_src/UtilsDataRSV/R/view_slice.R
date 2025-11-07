#' @title Print slices per group of a dataframe
#'
#' @description Wrapper around
#'
#' @param data dataframe. Contains data to print.
#' @param col character. Name of column to group by
#' before subsetting.
#' @param select character vector. Name(s) of columns to
#' select before printing.
#' @param n_print numeric. Number of slices to print per group.
#' @param seed numeric. If not \code{NULL}, then seed is
#' set to this value. Default is \code{NULL}.
#' @param sample_within_group logical. If \code{TRUE}
#' and sampling is selected, then sampling is performed
#' within each group. Otherwise sampling is performed across
#' the whole table. Default is \code{FALSE}.
#' @param sample logical. If \code{TRUE}, then
#' rows are sampled. Unless \code{prop_sample} is specified,
#' then \code{n_slice} rows are sampled.
#' @param prop_sample numeric. If not \code{NULL}, then
#' proportion of rows to sample. Overrides \code{n_slice}.
#' Default is \code{NULL}.
#' @param return logical. If \code{TRUE}, then the subsetted
#' table is returned. Otherwise, \code{invisible(TRUE)} is
#' returned. Default is \code{FALSE}.
#'
#' @description Returns subsetted data invisibly.
#'
#' @importFrom rlang !! ensyms
#'
#' @export
#'
#' @examples
#' data("cars")
#' cars[, "grp"] <- rep(letters[1:5], each = 10)
#' view_slice(cars, group = "grp", n_slice = 2)
view_slice <- function(data, group, select = NULL, n_print = 1e3,
                       n_slice = 1, seed = NULL,
                       sample_within_group = FALSE,
                       sample = FALSE, prop_sample = NULL,
                       return = FALSE) {

  # checks
  # -----------------
  if (!is.data.frame(data)) {
    stop("data must be a dataframe",
      call. = FALSE
    )
  }

  if (!tibble::is_tibble(data)) {
    data %<>% tibble::as_tibble()
  }

  if (!is.character(group)) {
    stop("group must be a character vector")
  }

  if (!is.numeric(n_print)) {
    stop("n_print must be of class numeric")
  }

  if (!is.integer(n_print)) {
    n_print <- floor(n_print)
  }
  if (!is.null(prop_sample)) {
    if (prop_sample < 0 || prop_sample > 1) {
      stop("prop_sample must be be between 0 and 1 if not NULL")
    }
  }
  if (!is.logical(return)) stop("return must be logical")

  if (!is.null(seed)) set.seed(seed = seed)

  out_tbl <- data %>%
    dplyr::group_by(!!ensym(group))

  if (!is.null(select)) {
    if (!is.character(select)) {
      stop(
        "select must be character vector or NULL"
      )
    }
    out_tbl <- out_tbl[, unique(c(group, select))]
  }

  if (n_print == 0) {
    if (return) {
      out_tbl <- out_tbl[1, ]
      out_tbl <- out_tbl[-1, ]
      return(out_tbl)
    } else {
      return(invisible(TRUE))
    }
  }

  if (!sample) {
    out_tbl %<>%
      dplyr::slice(1:n_slice)
  } else {
    if (sample_within_group) {
      if (!is.null(prop_sample)) {
        out_tbl %<>%
          dplyr::slice_sample(prop = prop_sample)
      } else {
        out_tbl %<>%
          dplyr::slice_sample(n = n_slice)
      }
    } else {
      if (!is.null(prop_sample)) {
        n_slice <- floor(prop_sample * nrow(out_tbl))
      }
      sample_vec <- sample(
        1:nrow(out_tbl),
        size = max(min(nrow(out_tbl), n_slice), 1),
        replace = FALSE
      )
      out_tbl <- out_tbl[sample_vec, ]
    }
  }

  if (n_print > 0) {
    out_tbl %>%
      print(n = n_print)
  }

  if (!return) {
    return(invisible(TRUE))
  }

  out_tbl
}
