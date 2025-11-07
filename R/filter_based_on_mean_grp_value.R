#' @title Choose subset of data with larger/smaller mean value
#'
#' @param data dataframe. Dataframe for which subset(s) should be chosen.
#' @param val character. Name of column in \code{data} containing the data
#' whose mean determines which group in \code{group_inner} to choose.
#' @param grp_outer character. Name of column in \code{data} indicating
#' a group of entries for which only one level in \code{grp_inner} should be chosen.
#' @param grp_inner character. Name of of column in \code{data} indicating
#' the sub-groups in grp_outer. Only one level of grp_inner will be chosen per
#' level of grp_outer.
#' @param sel 'smaller' or 'larger'. Level of \code{grp_inner} will be
#' chosen per level of \code{grp_outer} such that it has the smallest mean
#' of all groups (as defined by \code{grp_inner}) for that level of \code{grp_outer},
#' if \code{sel == 'smaller'}. Opposite if \code{sel == 'larger'}. No default.
#'
#' @details This was written for the situation where the abundance of various types of cells
#' are available (e.g. CD4 T cells expressing IFNg+), and where both frequencies and counts are available
#' but it is not indicated which column pertains to frequencies and which to counts. Note that
#' this function will not work reliably when the response is a frequncy (rather than a proportion)
#' and the denominator cell count is not consistently much higher than 100.
#'
#' @return A dataframe with only one level of \code{grp_inner} for
#' each level of \code{grp_outer}.
#'
#' @importFrom rlang !! ensym .data
#' @export
#'
#' @examples
#' library(dplyr)
#' library(tibble)
#' library(purrr)
#' library(stringr)
#' set.seed(3)
#' test_tbl <- tibble(
#'   pid = rep(c("id1", "id2", "id1", "id2"), each = 2),
#'   type = c(paste0(rep(c("a", "b"), each = 4), rep(c("", "_1"), 4)))
#' ) %>%
#'   mutate(type_base = stringr::str_remove(type, "_1")) %>%
#'   group_by(pid, type_base) %>%
#'   mutate(resp = purrr::map_dbl(type_base, function(x) {
#'     round(rnorm(1, 5 + stringr::str_detect(x, "b") * 3), 2)
#'   })[1]) %>%
#'   ungroup() %>%
#'   mutate(resp = ifelse(str_detect(type, "_1"), rep(runif(4, 1e4, 1e5), each = 2), 1) * resp)
#'
#' test_tbl
#'
#' filter_based_on_mean_grp_value(
#'   data = test_tbl, val = "resp", grp_outer = "type_base",
#'   grp_inner = "type", sel = "smaller"
#' )
filter_based_on_mean_grp_value <- function(data,
                                           val,
                                           grp_outer,
                                           grp_inner,
                                           sel) {
  mean_tbl <- data %>%
    dplyr::group_by(!!ensym(grp_outer), !!ensym(grp_inner)) %>%
    dplyr::summarise(
      val_mean = mean(!!ensym(val)),
      .groups = "drop"
    )

  sel_fn <- switch(sel,
    "smaller" = base::min,
    "larger" = base::max,
    stop(paste0("sel is ", sel, " when it should be on of 'smaller' or 'larger'"))
  )

  sel_vec <- mean_tbl %>%
    dplyr::group_by(!!ensym(grp_outer)) %>%
    dplyr::filter(.data$val_mean == sel_fn(.data$val_mean)) %>%
    dplyr::ungroup() %>%
    magrittr::extract2(grp_inner)

  data %>%
    dplyr::filter(!!ensym(grp_inner) %in% sel_vec)
}
