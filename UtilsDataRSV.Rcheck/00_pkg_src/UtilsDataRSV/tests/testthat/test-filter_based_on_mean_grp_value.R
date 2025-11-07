test_that("filter_based_on_mean_grp_value works", {
  set.seed(3)
  test_tbl <- tibble::tibble(
    pid = rep(c("id1", "id2", "id1", "id2"), each = 2),
    type = c(paste0(rep(c("a", "b"), each = 4), rep(c("", "_1"), 4)))
  ) %>%
    dplyr::mutate(type_base = stringr::str_remove(type, "_1")) %>%
    dplyr::group_by(pid, type_base) %>%
    dplyr::mutate(resp = purrr::map_dbl(type_base, function(x) {
      round(rnorm(1, 5 + stringr::str_detect(x, "b") * 3), 2)
    })[1]) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(resp = ifelse(stringr::str_detect(type, "_1"), rep(round(runif(4, 1e4, 1e5), 0), each = 2), 1) * resp)

  filter_tbl <- filter_based_on_mean_grp_value(
    data = test_tbl, val = "resp", grp_outer = "type_base",
    grp_inner = "type", sel = "smaller"
  )

  correct_tbl <- tibble::tibble(
    pid = rep(c("id1", "id2"), 2),
    type = rep(c("a", "b"), each = 2),
    type_base = rep(c("a", "b"), each = 2),
    resp = c(4.04, 5.2, 8.26, 8.09)
  )

  expect_identical(filter_tbl, correct_tbl)

  filter_tbl <- filter_based_on_mean_grp_value(
    data = test_tbl, val = "resp", grp_outer = "type_base",
    grp_inner = "type", sel = "larger"
  )

  expect_identical(round(filter_tbl$resp, 0), c(80921, 381326, 749793, 284574))
})
