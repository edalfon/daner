test_that("get_ddi_xml works", {
  skip_if_offline()

  xml_local_url <- test_path("test_data", "DANE-DIMPE-ECV-2015.xml")
  xml_remote_url <- "http://microdatos.dane.gov.co/index.php/catalog/ddi/419"

  # testing that both local and remote works
  expect_equal(get_ddi_xml(xml_local_url), get_ddi_xml(xml_remote_url))

  # testing that passing an already parsed doc works as well
  xml_doc <- get_ddi_xml(xml_local_url)
  expect_equal(xml_doc, get_ddi_xml(xml_doc))
})


test_that("get_ddi_vars works", {
  skip_if_offline()

  xml_local_url <- test_path("test_data", "DANE-DIMPE-ECV-2015.xml")
  xml_remote_url <- "http://microdatos.dane.gov.co/index.php/catalog/ddi/419"

  # testing that both local and remote works
  expect_equal(get_ddi_vars(xml_local_url), get_ddi_vars(xml_remote_url))

  # testing that passing an already parsed doc works as well
  xml_doc <- get_ddi_xml(xml_local_url)
  expect_equal(get_ddi_vars(xml_doc), get_ddi_vars(xml_local_url))

  xml_url <- "https://microdatos.dane.gov.co/index.php/metadata/export/807/ddi"
  expect_snapshot(get_ddi_vars(xml_url))
})

test_that("get_ddi_vars cleans up messy label text", {
  # here we found some values where the clean text was not working properly
  # leading to super long lines. Now we expect properly cleaned, hence, shorter
  xml_local_url <- test_path("test_data", "DANE-DCD-EEVV-2014.xml")
  get_ddi_vars(xml_local_url) |>
    dplyr::filter(name == "apgar1") |>
    dplyr::pull(catgry) |>
    dplyr::first() |>
    dplyr::pull(labl) |>
    stringr::str_length() |>
    expect_equal(c(30, 15))
})

test_that("get_ddi_vars returns an empty catgry tibble when the DDI omits categories", {
  # DANE's 2017-2018 nacimientos DDI does not include catgry/labl nodes for
  # some variables (e.g. AREA_RES), unlike the standalone 2017 DDI where they
  # are present. get_ddi_vars should not error in that case, just report no
  # categories for that variable.
  xml_local_url <- test_path("test_data", "DANE-DCD-EEVV-2017-2018.xml")

  area_res <- get_ddi_vars(xml_local_url) |>
    dplyr::filter(files == "F8", name == "AREA_RES")

  expect_equal(nrow(area_res$catgry[[1]]), 0)
})

test_that("list_ddi_files works", {
  skip_if_offline()

  xml_local_url <- test_path("test_data", "DANE-DIMPE-ECV-2015.xml")
  xml_remote_url <- "http://microdatos.dane.gov.co/index.php/catalog/ddi/419"

  # testing that both local and remote works
  expect_equal(list_ddi_files(xml_local_url), list_ddi_files(xml_remote_url))

  xml_url <- "https://microdatos.dane.gov.co/index.php/metadata/export/807/ddi"
  expect_snapshot(list_ddi_files(xml_url))
})
