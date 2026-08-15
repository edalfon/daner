test_that("get_ddi_xml works", {
  xml_local_url <- test_path("test_data", "DANE-DIMPE-ECV-2015.xml")
  xml_remote_url <- "http://microdatos.dane.gov.co/index.php/catalog/ddi/419"

  # testing that both local and remote works
  expect_equal(get_ddi_xml(xml_local_url), get_ddi_xml(xml_remote_url))

  # testing that passing an already parsed doc works as well
  xml_doc <- get_ddi_xml(xml_local_url)
  expect_equal(xml_doc, get_ddi_xml(xml_doc))
})


test_that("get_ddi_vars works", {
  xml_local_url <- test_path("test_data", "DANE-DIMPE-ECV-2015.xml")
  xml_remote_url <- "http://microdatos.dane.gov.co/index.php/catalog/ddi/419"

  # testing that both local and remote works
  expect_equal(get_ddi_vars(xml_local_url), get_ddi_vars(xml_remote_url))

  # testing that passing an already parsed doc works as well
  xml_doc <- get_ddi_xml(xml_local_url)
  expect_equal(get_ddi_vars(xml_doc), get_ddi_vars(xml_local_url))

  xml_url <- "https://microdatos.dane.gov.co/index.php/metadata/export/807/ddi"
  expect_snapshot(get_ddi_vars(xml_url))

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

  # let's dx why 2018 does not show categories for the variables in nacimientos
  # ok, it's seems to be that simply they did not include them in the xml
  # so, a bit of an inconsistency. Probably they expect you to use those
  # from 2017 that are indeed included in the xml
  xml_local_url <- test_path("test_data", "DANE-DCD-EEVV-2017-2018.xml")
  get_ddi_vars(xml_local_url)
  list_ddi_files(xml_local_url)
  get_ddi_vars(xml_local_url) |>
    dplyr::filter(files == "F8") |>
    dplyr::filter(name == "AREA_RES")
})

test_that("list_ddi_files works", {
  xml_local_url <- test_path("test_data", "DANE-DIMPE-ECV-2015.xml")
  xml_remote_url <- "http://microdatos.dane.gov.co/index.php/catalog/ddi/419"

  # testing that both local and remote works
  expect_equal(list_ddi_files(xml_local_url), list_ddi_files(xml_remote_url))

  xml_url <- "https://microdatos.dane.gov.co/index.php/metadata/export/807/ddi"
  expect_snapshot(list_ddi_files(xml_url))
})
