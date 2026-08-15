#' Get a XML document, parsing the text received or the document in the URL
#'
#' This function attempts to retrieve a DDI (Data Documentation Initiative) XML
#' document from a provided source. It can handle:
#'
#' * A character vector containing a URL to an XML document.
#' * A character vector containing a XML document.
#' * An already parsed XML object of class `xml_document` or `xml_node`.
#'
#' It is used as a helper function to ensure a valid xml in other functions
#' This function is memoised (memoise::memoise) to prevent parsing every time
#' it's called with the same argument (or even worse, downloading every time)
#'
#' @param doc_url_txt A character vector containing a URL or XML text
#' (to be read by `xml2::read_xml`), or an already parsed XML object
#' (class `xml_document` or `xml_node`).
#'
#' @seealso `xml2::read_xml`, `xml2::xml_ns_strip`
#'
#' @return The parsed XML document as an object of class `xml_document`.
#'
#' @examples
#' \dontrun{
#' get_ddi_xml("http://microdatos.dane.gov.co/index.php/catalog/ddi/419")
#' }
#'
#' @export
get_ddi_xml <- function(doc_url_txt) {
  if (rlang::is_character(doc_url_txt)) {
    xml_doc <- xml2::read_xml(doc_url_txt) |> xml2::xml_ns_strip()
  } else if (any(c("xml_document", "xml_node") %in% class(doc_url_txt))) {
    xml_doc <- doc_url_txt
  } else {
    stop(paste0(
      "doc_url_txt should be either a character ",
      "vector that can be an url or xml as text (to be read by xml2::read_xml)",
      "or an already parsed XML object (class xml_document or xml_node)"
    ))
  }

  xml_doc
}

#' List all 'fileDscr' nodes in the ddi_xml
#'
#' DDI XML should include one 'fileDscr' node for each dataset in the study
#' and other nodes refer to the 'fileDscr' ID to link, for example, variables
#' to their respective dataset.
#' This function aims to help you find the ID of the file you are working with,
#' by listing the 'fileDscr' arguments, that include the URI (with the name at
#' the end) and the file ID.
#'
#' @inheritParams get_ddi_xml
#'
#' @return data.frame/tibble with two columns: id and uri of the file
#'
#' @examples
#' \dontrun{
#' list_ddi_files("http://microdatos.dane.gov.co/index.php/catalog/ddi/210")
#' }
#' @export
list_ddi_files <- function(doc_url_txt) {
  xml_doc <- get_ddi_xml(doc_url_txt)

  xml_files <- xml2::xml_find_all(xml_doc, "/codeBook/fileDscr")

  files_df <- purrr::map_dfr(xml_files, \(x) {
    tibble::tibble(
      id = xml2::xml_attr(x, "ID"),
      uri = xml2::xml_attr(x, "URI")
      # TODO: perhaps bring also fileTxt/fileName, and caseQnty and varQnty
    )
  })

  files_df
}


#' Get DDI Variables
#'
#' This function retrieves information about variables from a DDI
#' (Data Documentation Initiative) XML document.
#' It first uses `get_ddi_xml` to parse the XML document and then extracts
#' information for each variable node using XPath expressions.
#'
#' @param doc_url_txt A character vector containing a URL to an XML document or
#' XML text (to be read by `xml2::read_xml`), or an already parsed XML object
#' (class `xml_document` or `xml_node`).
#'
#' @return A data frame containing information about each variable in the
#' DDI document. The data frame includes columns for:
#'
#' * `name`: Variable name (from `name` attribute)
#' * `id`: Variable ID (from `ID` attribute)
#' * `files`: File name(s) associated with the variable (from `files` attribute)
#' * `intrvl`: Interval information (from `intrvl` attribute)
#' * `labl`: Variable label(s) (extracted from `labl` nodes and cleaned)
#' * `catgry`: List containing information (catValu, labl) for var categories
#'
#' @examples
#' \dontrun{
#' get_ddi_vars("http://microdatos.dane.gov.co/index.php/catalog/ddi/419")
#' }
#'
#' @export
get_ddi_vars <- function(doc_url_txt) {
  xml_doc <- get_ddi_xml(doc_url_txt)

  xml_vars <- xml2::xml_find_all(xml_doc, "/codeBook/dataDscr/var")

  vars_df <- purrr::map_dfr(xml_vars, \(x) {
    tibble::tibble(
      name = xml2::xml_attr(x, "name"),
      id = xml2::xml_attr(x, "ID"),
      files = xml2::xml_attr(x, "files"),
      intrvl = xml2::xml_attr(x, "intrvl"),
      labl = xml2::xml_find_all(x, "labl") |>
        xml2::xml_text(trim = TRUE) |>
        clean_ddi_text(),
      catgry = list(get_var_categories(x)) # want it embedded, hence list()
    )
  })

  vars_df
}

clean_ddi_text <- function(txt) {
  new_txt <- txt |>
    stringr::str_replace_all("\n", "") |>
    stringr::str_replace_all(" +", " ") |>
    stringr::str_trim() |>
    identity()

  new_txt
}

get_var_categories <- function(xml_node) {
  # TODO: defensive coding?, should we check here it's a node and complaint if not?
  category_nodes <- xml2::xml_find_all(xml_node, "catgry")

  tibble::tibble(
    catValu = xml2::xml_find_all(category_nodes, "catValu") |>
      xml2::xml_text(trim = TRUE),
    labl = xml2::xml_find_all(category_nodes, "labl") |>
      xml2::xml_text(trim = TRUE)
  ) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(x) clean_ddi_text(x)))
}
