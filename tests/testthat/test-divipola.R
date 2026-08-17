test_that("fix_dept_cod pads to the canonical 2-character width", {
  expect_equal(fix_dept_cod(c(5, 25, "5")), c("05", "25", "05"))
  expect_equal(fix_dept_cod(99), "99")
})

test_that("fix_muni_cod pads to the canonical 5-character width", {
  expect_equal(fix_muni_cod(c(5001, "5002")), c("05001", "05002"))
  expect_equal(fix_muni_cod(76001), "76001")
})

test_that("join_divipola_dept_cod joins DIVIPOLA department data", {
  df <- data.frame(cod = c(5, 25, "11"))

  joined <- join_divipola_dept_cod(df, by = "cod")

  expect_equal(nrow(joined), nrow(df))
  expect_true(all(
    c("dept_cod", "dept_nom", "long", "lat", "dept_nom_corto") %in% names(joined)
  ))
  expect_equal(
    joined$dept_nom,
    c("ANTIOQUIA", "CUNDINAMARCA", "BOGOTÁ, D. C.")
  )
})

test_that("join_divipola_dept_cod leaves unmatched/NA codes as NA, without erroring", {
  df <- data.frame(cod = c(5, NA, "999"))

  joined <- join_divipola_dept_cod(df, by = "cod")

  expect_equal(nrow(joined), nrow(df))
  expect_equal(joined$dept_nom, c("ANTIOQUIA", NA, NA))
})

test_that("join_divipola_dept_cod lets dept_vars subset the joined columns", {
  df <- data.frame(cod = "05")

  joined <- join_divipola_dept_cod(df, by = "cod", dept_vars = "dept_nom")

  expect_equal(names(joined), c("cod", "dept_cod", "dept_nom"))
})

test_that("join_divipola_muni_cod joins DIVIPOLA municipality data", {
  df <- data.frame(cod = c("05001", "25001"))

  joined <- join_divipola_muni_cod(df, by = "cod")

  expect_equal(nrow(joined), nrow(df))
  expect_true(all(
    c("muni_cod", "dept_cod", "muni_nom", "dept_nom") %in% names(joined)
  ))
  expect_equal(joined$muni_nom, c("MEDELLÍN", "AGUA DE DIOS"))
  expect_equal(joined$dept_nom, c("ANTIOQUIA", "CUNDINAMARCA"))
})

test_that("join_divipola_muni_cod leaves unmatched/NA codes as NA, without erroring", {
  df <- data.frame(cod = c("05001", NA, "99999"))

  joined <- join_divipola_muni_cod(df, by = "cod")

  expect_equal(nrow(joined), nrow(df))
  expect_equal(joined$muni_nom, c("MEDELLÍN", NA, NA))
})
