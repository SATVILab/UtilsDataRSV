#' @title View random sample of unique column entries
#'
#' @description Displays up to \code{n_entry} unique entries for the first
#' \code{n_col} columns. Note that \code{NA} is always included amongst
#' displayed entries if present.
#'
#' @param x dataframe. Dataframe for which unique column entries should be displayed.
#' @param n_entry integer. Maximum of unique entries to display per
#' column. Set equal to \code{Inf} if you want to
#' see all unique column entries. Default is 20.
#' @param n_entry_num Maximum number of unique entries to display for numeric columns.
#' Set equal to \code{Inf} if you want to see all unique entries. If \code{NULL},
#' then \code{n_entry} is used for numeric columns as well. Default is 5.
#' @param n_col integer. Maximum number of columns to display unique entries for.
#' A message is by default displayed if fewer than all the columns
#' have their data data displayed. Set equal
#' to \code{Inf} if all columns should be displayed. If not an integer but still a number,
#' then the integer component number of columns is displayed.  Default for \code{n_col} is 1e2.
#' @param silent logical. If \code{TRUE}, then a message about there
#' being fewer columns displayed than total columns available is not printed.
#' Default is \code{FALSE}.
#'
#' @export
#'
#' @examples
#' test_df <- data.frame(x = rnorm(1e3), y = sample(c("a", "b"),
#'   size = 1e3,
#'   replace = TRUE
#' ))
#' view_cols(test_df)
view_cols <- function(x, n_entry = 20, n_entry_num = 5, n_col = 1e2,
                      silent = FALSE) {

  # check inputs
  # ---------------
  if (!is.data.frame(x)) stop(paste0("x should be a dataframe"))
  if (!is.numeric(n_entry)) {
    stop(paste0(
      "n_entry has class ", paste0(class(n_entry), collapse = " "),
      " when it should have class integer (or at least numeric"
    ))
  }
  if (!is.numeric(n_col)) {
    stop(paste0(
      "n_col has class ", paste0(class(n_col), collapse = " "),
      " when it should have class integer (or at least numeric"
    ))
  }
  if (!is.logical(silent)) {
    stop(paste0(
      "silent has class ", paste0(class(silent), collapse = " "),
      " when it should have class logical"
    ))
  }

  # get number of columns to display
  # ----------------
  n_col <- min(max(floor(n_col), 1), ncol(x))
  if (n_col == 0) {
    warning("No columns in x")
    return(invisible(FALSE))
  }

  # print output for first n_col columns
  # --------------------
  warn_col <- NULL
  for (i in seq.int(1, n_col)) {
    print(colnames(x)[i])
    # print(paste0(colnames(x)[i], " (", i, ")")) # print column name
    # select and print unique entries
    # ----------------

    # get unique entries
    uni_vec <- unique(x[[i]])

    # get max number
    n_entry_curr <- ifelse(!is.numeric(uni_vec) || is.null(n_entry_num),
      n_entry,
      n_entry_num
    )

    # if some are NA, then choose as many
    # non-NA unique entries up until n_entry -1,
    # and then add NA to end
    if (any(is.na(uni_vec))) {
      # get non-NA entries
      uni_vec_non_na <- uni_vec[!is.na(uni_vec)]
      # if there are non-NA entries
      if (length(uni_vec_non_na) > 0) {
        disp_sample_vec_non_na <- sample(uni_vec_non_na, min(n_entry_curr - 1, length(uni_vec_non_na)), replace = FALSE)
        disp_sample_vec <- c(disp_sample_vec_non_na, uni_vec[is.na(uni_vec)][1])
        # if there are no non-NA entries, then just display NA
      } else {
        disp_sample_vec <- uni_vec[1]
      }
      # if none are NA, then display a random sample
    } else {
      disp_sample_vec <- sample(uni_vec, min(n_entry_curr, length(uni_vec)), replace = FALSE)
    }

    if (is.factor(disp_sample_vec)) disp_sample_vec <- as.character(disp_sample_vec)
    print(disp_sample_vec)
    n_missing <- length(uni_vec) - length(disp_sample_vec)
    if (n_missing > 0 && !is.numeric(uni_vec)) {
      warn_col <- c(warn_col, colnames(x)[i])
      if (n_missing == 1) {
        print(paste0(n_missing, " unique entry not displayed"))
      } else {
        print(paste0(n_missing, " unique entries not displayed"))
      }
    }

    # print underscore separator for visual clarity
    print("_____________________")
  }

  if (length(warn_col) > 0 && !silent) {
    warning(paste0("Not all unique entries displayed for these non-numeric cols: ", paste0(warn_col, collapse = ", ")),
      call. = FALSE
    )
  }

  # print message if fewer than all columns have data displayed
  if (!silent && n_col < ncol(x)) {
    warning(paste0(
      "Unique entries from only ", n_col, " of ", ncol(x),
      " columns displayed"
    ),
    call. = FALSE
    )
  }

  return(invisible(TRUE))
}
