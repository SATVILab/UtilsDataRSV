#' @title Fix Excel decimal symbol errors
#'
#' @description Occasionally numbers are read in from Excel as characters
#' and R does not correctly convert these characters to numbers. This function
#' splits each number-as-character into integer and fraction parts
#' (around whatever decimal indicator is present) and adds them. NOTE: Please do
#' check output.
#'
#' @details This function corrects (most) errors arising from
#' importing an Excel/CSV file that was created on a system
#' that uses a period (or full stop, ie. ".") as the decimal separator.
#'
#' @param x character vector. Column of data.
#' @param decimal_symbol_orig "." or ",".
#'
#' @details Note that it appears that if an entire column was
#' read in from Excel where each entry has the same number of numbers
#' and has the decimal in the same place, then readr::read_csv (at least)
#' will for some reason read in the column without the comma at all. This function
#' will not fix that.
#'
#' @export
#' @examples
#' # vector of data (as if from Excel)
#' x <- c("1,32", "1", "0,23", "3,23E-2", NA)
#' x_period <- c("1.32", "1", "0.23", "3.23E-2", NA)
#' # original data alongside corrected data
#' data.frame(orig = x, replacement = convert_character_to_number_correctly(x = x))
convert_character_to_number_correctly <- function(x) {
  x_rep_vec <- rep(NA_real_, length(x))

  # loop over elements (so fn is vectorised by default)
  for (i in seq_along(x)) {
    # get current element
    elem_curr <- x[i]
    # replacement element is NA if current element is NA
    if (is.na(elem_curr)) next

    # get exponent (if not present, set to 0)
    # ---------------
    if (stringr::str_detect(elem_curr, "E")) {
      e_loc <- stringr::str_locate(elem_curr, "E")[1, "end"][[1]]
      exp_chr_as_num <- as.numeric(stringr::str_sub(elem_curr, start = e_loc + 1))
      elem_curr <- stringr::str_sub(elem_curr, end = e_loc - 1)
    } else {
      exp_chr_as_num <- 0
    }

    # split into integer and fraction components
    # ---------------
    dec_symbol_loc <- stringr::str_locate(elem_curr, ",|\\.")[1, "end"][[1]]

    # if no comma found, then return original value (after applying exponent)
    if (is.na(dec_symbol_loc)) {
      x_rep_vec[i] <- as.numeric(elem_curr) * 10^exp_chr_as_num
      next
    }

    # if a comma found, then split and sum
    int <- as.numeric(stringr::str_sub(elem_curr, end = dec_symbol_loc - 1))
    frac_chr <- stringr::str_sub(elem_curr, start = dec_symbol_loc + 1)
    frac <- as.numeric(frac_chr) / (10^stringr::str_length(frac_chr))
    val <- int + frac

    # return, applying
    x_rep_vec[i] <- val * 10^exp_chr_as_num
  }
  x_rep_vec
}
