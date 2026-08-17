test_that("ingest_zipped_sav works", {
  # this fixture is real DANE microdata, too large to check into git (see
  # .gitignore), so it's only available locally: skip elsewhere (CI/CRAN)
  zipfile_path <- test_path("test_data", "Nac_2008_2011_SPSS.zip")
  skip_if_not(file.exists(zipfile_path), "local-only fixture not available")

  ingested <- ingest_zipped_sav(zipfile_path)

  expect_s3_class(ingested, "tbl_df")
  expect_equal(
    names(ingested),
    c("sav_file", "size", "date", "sav_data")
  )
  expect_equal(nrow(ingested), 4)
  expect_true(all(vapply(ingested$sav_data, tibble::is_tibble, logical(1))))
})
