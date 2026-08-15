#' Ingest .sav files from within a .zip file
#'
#' This is a common format for microdato DANE.
#' Why bother?, you could simply call haven::read_sav passing the path to the
#' zip file and haven is smart enough to decompress it for you.
#' Well, yeah, in theory. But there are a few glitches that end up breaking
#' that approach. First, Microdato Dane sometimes bundles several different
#' files in a single .zip file (e.g. a .sav, along plain-text -csv, txt- and
#' sometimes also .dta files). This creates trouble for haven
#' (haven usually can decompress the file and warn you there are several files,
#' but frequently end up failing). In addition, sometimes the name of the .sav
#' file does not match that of the .zip file, also creating issues. Finally, in
#' a few cases, several .sav files are bundled in the .zip file, and this
#' function allows you to ingest them all at once.
#'
#' So this function unzip the .sav files contained in the zip
#'
#' @param zipfile_path path to the .zip file
#' @param ... further arguments passed to haven::read_sav
#'
#' @return a tibble with columns
#' - sav_file (character): path of the sav file within the zip file
#' - size (numeric): size of the uncompressed sav file
#' - date (of class "POSIXct"): date of the sav file
#' - sav_data (tibble): the data in sav_file, ingested via haven::read_sav
#' @md
#' @export
ingest_zipped_sav <- function(zipfile_path, ...) {
  NULL -> Name -> Length -> Date -> sav_file -> sav_path_unzipped
  if (tools::file_ext(zipfile_path) != "zip") { # TODO: case-insensitive
    usethis::ui_warn("zipfile_path does not have .zip extension. Trying anyway")
  }

  # Need to identify .sav files within the zip, 'cause there might be n files
  sav_files <- utils::unzip(zipfile = zipfile_path, list = TRUE) |>
    dplyr::filter(stringr::str_ends(Name, ".sav")) |>
    dplyr::rename(sav_file = Name, size = Length, date = Date) |>
    tibble::as_tibble()

  # Now unzip only the .sav files to a temporary directory
  unzipped_dir <- tempdir(check = TRUE)
  utils::unzip(
    zipfile = zipfile_path,
    files = sav_files$sav_file,
    overwrite = TRUE,
    exdir = unzipped_dir
  )

  ingested_data <- sav_files |>
    dplyr::mutate(sav_path_unzipped = paste0(unzipped_dir, "/", sav_file)) |>
    dplyr::mutate(
      sav_data = purrr::map(.x = sav_path_unzipped, .f = haven::read_sav)
    ) |>
    dplyr::select(-sav_path_unzipped)

  ingested_data
}
