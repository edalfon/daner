#' Join DIVIPOLA department variables into lhs
#'
#' Left join lhs and DIVIPOLA at the department level. Useful to quickly bring
#' basic data from departments (name, long, lat) to a dataset that contains
#' only department code.
#'
#' @param lhs A data.frame-like
#' @param by A character vector indicating the column in `lhs` that contains
#' department code
#' @param dept_vars A character vector to customize which variables from
#' DIVIPOLA to bring into `lhs`
#'
#' @return lhs with additional DIVIPOLA variables
#' @export
#' @examples
join_divipola_dept_cod <- function(lhs, by, dept_vars = c(
  "dept_cod", "dept_nom", "long", "lat", "dept_nom_corto")) {

  # check and warn for potential issues ####
  lhs_by_nas <- sum(is.na(lhs[[by]]))
  if (lhs_by_nas > 0) {
    usethis::ui_oops(paste0(
      "Join variable [", by, "] contains ", scales::comma(lhs_by_nas), " NAs"
    ))
  }

  # join ####
  lhs_fin <- lhs %>%
    dplyr::mutate(dept_cod = fix_dept_cod(.data[[by]])) %>%
    dplyr::left_join(
      y = daner::divipola_dept %>%
        dplyr::select(c("dept_cod", dept_vars)) %>%
        dplyr::mutate(.merge = 1), # TODO: check if .merge exists
      by = c("dept_cod" = "dept_cod")
    )

  # verify the merge and inform the user the results ####
  stopifnot(nrow(lhs) == nrow(lhs_fin))
  n_both <- sum(lhs_fin$.merge, na.rm = TRUE)
  n_left <- nrow(lhs_fin) - n_both
  n_left_uniq <- length(unique(lhs_fin[lhs_fin$.merge != 1, by]))

  usethis::ui_done(paste0(
    scales::comma(n_both), " rows",
    " [", scales::percent(n_both / nrow(lhs), accuracy = 0.1), "]",
    " successfully joined"
  ))

  if (n_left > 0) {
    usethis::ui_oops(paste0(
      scales::comma(n_left), " rows",
      " [", scales::percent(n_left / nrow(lhs), accuracy = 0.1), "]",
      " could not be joined, which contain ",
      scales::comma(n_left_uniq), " unique codes"
    ))
  }

  # return joined lhs, keeping original indices broken by join ####
  lhs_fin <- lhs_fin %>% dplyr::select(-.merge)
  #row.names(lhs_fin) <-  row.names(lhs)
  # why did I want to keep original indices?
  lhs_fin
}




#' Join DIVIPOLA department variables into lhs
#'
#' Left join lhs and DIVIPOLA at the department level. Useful to quickly bring
#' basic data from departments (name, long, lat) to a dataset that contains
#' only department code.
#'
#' @param lhs A data.frame-like
#' @param by A character vector indicating the column in `lhs` that contains
#' municipality code
#' @param muni_vars A character vector to customize which variables from
#' DIVIPOLA to bring into `lhs`
#'
#' @return lhs with additional DIVIPOLA variables
#' @export
#' @examples
join_divipola_muni_cod <- function(lhs, by, muni_vars = c(
	"dept_cod", "centro_poblado_cod", "dept_nom", "muni_nom",
	"centro_poblado_nom", "tipo_centro_poblado", "long", "lat", "distrito",
	"tipo_muni", "area_metropolitana", "region_nom", "region_cod",
	"dept_nom_corto", "provincia", "muni_nom_corto")) {

  # check and warn for potential issues ####
	lhs_by_nas <- sum(is.na(lhs[[by]]))
	if (lhs_by_nas > 0) {
	  usethis::ui_oops(paste0(
	    "Join variable [", by, "] contains ",
	    scales::comma(lhs_by_nas), " NAs"
	  ))
	}

	# join ####
	lhs_fin <- lhs %>%
		dplyr::mutate(muni_cod = fix_muni_cod(lhs[[by]])) %>%
		dplyr::left_join(
			y = daner::divipola_muni %>%
				dplyr::select(c("muni_cod", muni_vars)) %>%
				dplyr::mutate(.merge = 1),
			by = c("muni_cod" = "muni_cod")
		)

	# verify the merge and inform ####
	stopifnot(nrow(lhs) == nrow(lhs_fin))
	n_both <- sum(lhs_fin$.merge, na.rm = TRUE)
	n_left <- nrow(lhs_fin) - n_both
	n_left_uniq <- length(unique(lhs_fin[lhs_fin$.merge != 1, by]))

	usethis::ui_done(paste0(
		scales::comma(n_both), " rows",
		" [", scales::percent(n_both / nrow(lhs_fin), accuracy = 0.1), "]",
		" successfully joined"
	))

	if (n_left > 0) {
		usethis::ui_oops(paste0(
			scales::comma(n_left), " rows",
			" [", scales::percent(n_left / nrow(lhs_fin), accuracy = 0.1), "]",
			" could not be joined, which contain ",
			scales::comma(n_left_uniq), " unique codes"
		))
	}

  # return joined lhs, keeping original indices ####
	lhs_fin <- lhs_fin %>% dplyr::select(-.merge)
	#row.names(lhs_fin) <-  row.names(lhs)
	#TODO: why did I want to keep original indices?
	lhs_fin
}






#' Make DANE-code a character and the 5-length format
#'
#' Sometimes useful, when you get the code as numeric and for any reason want to
#' have it in its canonical format (string of length 5)
#'
#' @param muni_cod dane code for munincipality
#'
#' @return a character vector
#' @export
fix_muni_cod <- function(muni_cod) {
  muni_cod %>%
    as.character() %>%
    # TODO: either warning or error if at this point the length > 5
    stringr::str_pad(width = 5, side = "left", pad = "0")
}

#' Make DANE-code a character and the 2-length format
#'
#' Sometimes useful, when you get the code as numeric and for any reason want to
#' have it in its canonical format (string of length 2)
#'
#' @param dept_cod dane code for department
#'
#' @return a character vector
#' @export
fix_dept_cod <- function(dept_cod) {
  dept_cod %>%
    as.character() %>%
    # TODO: warning if at this point length > 2
    stringr::str_pad(width = 2, side = "left", pad = "0")
  # important to deal with cases like NN region in polygons data, with code
  # 999 and should never be matched, so prepend and truncate would not work
  # properly (ends up matching vichada, whose code is 99). Better to use pad
}





