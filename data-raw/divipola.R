## code to prepare `divipola` datasets goes here

#' Updates Divipola
#'
#' Codificación de la División Político-Administrativa de Colombia (Divipola)
#' www.dane.gov.co/Divipola/
#' http://geoportal.dane.gov.co:8084/Divipola/
#' This function downloads the latest version of Divipola from Dane web site
#' read it into R and save it as RData
#' @return character string with the path to the downloaded file
#' @seealso httr
#' @keywords shape file, rgdal
#' @import httr
#' @internal
#' @exampless
update_divipola <- function(){

	# Download the file using system date (another alternative would be to
	# load the page www.dane.gov.co/Divipola/ to obtain the date of the
	# latest update, but it seems to work with tha current date and it downloads
	# the latest update to Divipola)
	divipola_httr <- httr::GET(
		url = paste0("http://geoportal.dane.gov.co:8084/",
					 "Divipola/ServletReporte?fechaVigencia=", Sys.Date())
	)

	# Locate the directory to save the data (external data in the package)
	divipola_dir <- here::here("data-raw/DIVIPOLA")
	divipola_file <- paste0("divipola_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
	divipola_xlsx <- paste0(divipola_dir, "/", divipola_file)

	# write the content of the download to a file in the divipola_dir
	writeBin(
		object = httr::content(divipola_httr, "raw"),
		con = divipola_xlsx
	)

	divipola_xlsx
}

#' Reads Divipola in a data.frame (in three different levels, department,
#' municipality and centro poblado)
#'
#' Reads the .xlsx file downloaded from DANE into a data.frame and returns it.
#' It also saves it as data of the package, to make it readilly available
#'
#' @param update if TRUE it calls update_divipola that updates the Divipola to
#' the latest version available in DANE's web site
#'
#' @return data.frame with Divipola
#' @import magrittr
#' @export
#'
#' @examples

get_divipola <- function(update = FALSE){

	# Get the path to the divipola file ########################################
	# (downloading a new one if update==TRUE)
	if(update){
		divipola_xlsx <- update_divipola()
	} else {
		# Locate the directory where divipola extdata is located
		divipola_dir <- here::here("data-raw/DIVIPOLA")
		# Get the latest file
		divipola_xlsx <- sort(dir(divipola_dir, pattern = "divipola*"), decreasing = TRUE)[[1]]
		# Set the full path to the latest file
		divipola_xlsx <- paste0(divipola_dir, "/", divipola_xlsx)
	}

	# Read, fix and save the data ##############################################
	col_names <- c("dept_cod", "muni_cod", "centro_poblado_cod",
				   "dept_nom", "muni_nom", "centro_poblado_nom",
				   "tipo_centro_poblado",
				   "long", "blanco", "lat",
				   "distrito", "tipo_muni", "area_metropolitana")
	# col_names <- c("cod_dept", "cod_muni", "cod_centro_poblado",
	# 			   "dept_nom", "muni_nom", "centro_poblado_nom",
	# 			   "tipo_centro_poblado",
	# 			   "long", "blanco", "lat",
	# 			   "distrito", "tipo_muni", "area_metropolitana")
	col_types <- c("text", "text", "text", "text", "text",
				   "text", "text",
				   "text", "skip", "text",
				   "text", "text", "text")
	divipola_centropob <- readxl::read_excel(
		path = divipola_xlsx, sheet = "reportExcel",
		col_names = col_names, skip = 5,
		col_types = col_types
	)

	# Make latitude and longitude numeric
	divipola_centropob$long <- gsub(x = divipola_centropob$long,
									pattern = ",", replacement = ".")
	divipola_centropob$long <- as.numeric(divipola_centropob$long)
	divipola_centropob$lat <- gsub(x = divipola_centropob$lat,
								   pattern = ",", replacement = ".")
	divipola_centropob$lat <- as.numeric(divipola_centropob$lat)

	# Fix the name of San Andres
	divipola_centropob$dept_nom <- dplyr::case_when(
		stringr::str_detect(
			string = divipola_centropob$dept_nom,
			pattern = "ARCHIPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA*") ~
			"ARCHIPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA Y SANTA CATALINA",
		TRUE ~ as.character(divipola_centropob$dept_nom)
	)

	# Create region variable, del Plan Nacional de Desarrollo de Santos
	# caribe_depts <- c("ARCHIPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA Y SANTA CATALINA",
	# 				  "ATLÁNTICO", "BOLÍVAR", "CESAR", "CÓRDOBA", "LA GUAJIRA",
	# 				  "SUCRE", "MAGDALENA")
	#
	# ejecafetero_depts <- c("CALDAS", "QUINDÍO", "RISARALDA", "ANTIOQUIA")
	#
	# centrooriente_depts <- c("BOYACÁ", "CUNDINAMARCA", "NORTE DE SANTANDER",
	# 						 "SANTANDER", "BOGOTÁ, D. C.")
	#
	# pacifica_depts <- c("CAUCA", "CHOCÓ", "NARIÑO", "VALLE DEL CAUCA")
	#
	# llanos_depts <- c("ARAUCA", "CASANARE", "GUAINÍA", "GUAVIARE",
	# 				  "META", "VICHADA", "VAUPÉS")
	#
	# centrosuramazonas_depts <- c("TOLIMA", "HUILA", "CAQUETÁ", "PUTUMAYO",
	# 							 "AMAZONAS")
	#
	# divipola_centropob <- divipola_centropob %>%
	# 	dplyr::mutate(region_cod = dplyr::case_when(
	# 		dept_nom %in% caribe_depts ~ 1,#"Caribe",
	# 		dept_nom %in% ejecafetero_depts ~ 2,#"Eje Cafetero",
	# 		dept_nom %in% centrooriente_depts ~ 3,#"Centro Oriente",
	# 		dept_nom %in% pacifica_depts ~ 4,#"Pacífica",
	# 		dept_nom %in% llanos_depts ~ 5,#"Llanos",
	# 		dept_nom %in% centrosuramazonas_depts ~ 6#"Centro-Sur-Amazonía"
	# 	))
	# divipola_centropob <- divipola_centropob %>%
	# 	dplyr::mutate(region_nom = dplyr::case_when(
	# 		dept_nom %in% caribe_depts ~ "Caribe",
	# 		dept_nom %in% ejecafetero_depts ~ "Eje Cafetero",
	# 		dept_nom %in% centrooriente_depts ~ "Centro Oriente",
	# 		dept_nom %in% pacifica_depts ~ "Pacífica",
	# 		dept_nom %in% llanos_depts ~ "Llanos",
	# 		dept_nom %in% centrosuramazonas_depts ~ "Centro-Sur-Amazonía"
	# 	))


	# https://www.minsalud.gov.co/Documentos%20y%20Publicaciones/An%C3%A1lisis%20de%20situaci%C3%B3n%20de%20salud%20por%20regiones.pdf
	regiones <- dplyr::bind_rows(
		dplyr::tibble(
			region_nom = "Amazonía-Orinoquía", region_cod = 1,
			dept_nom = c("PUTUMAYO", "AMAZONAS", "GUAINÍA", "GUAVIARE", "VAUPÉS")
		),
		dplyr::tibble(
			region_nom = "Pacífica", region_cod = 2,
			dept_nom = c("CAUCA", "CHOCÓ", "NARIÑO", "VALLE DEL CAUCA")
		),
		dplyr::tibble(
			region_nom = "Oriental", region_cod = 3,
			dept_nom = c("ARAUCA", "BOYACÁ", "CASANARE", "META", "NORTE DE SANTANDER",
						 "SANTANDER", "VICHADA")
		),
		dplyr::tibble(
			region_nom = "Central", region_cod = 4,
			dept_nom = c("CALDAS", "QUINDÍO", "RISARALDA", "ANTIOQUIA", "HUILA",
						 "TOLIMA", "CAQUETÁ", "CUNDINAMARCA")
		),
		dplyr::tibble(
			region_nom = "Caribe", region_cod = 5,
			dept_nom = c("ARCHIPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA Y SANTA CATALINA",
						 "ATLÁNTICO", "BOLÍVAR", "CESAR", "CÓRDOBA", "LA GUAJIRA",
						 "SUCRE", "MAGDALENA")
		),
		dplyr::tibble(
			region_nom = "Bogotá D.C.", region_cod = 0,
			dept_nom = c("BOGOTÁ, D. C.")
		),
	)

	divipola_centropob <- divipola_centropob %>%
		dplyr::left_join(regiones, by = "dept_nom")
	assertthat::assert_that(
		sum(is.na(divipola_centropob$region_nom)) == 0,
		msg = "For some reason, not all rows got a region assigned"
	)

	# Want to create a short name, to keep depatment names as short as possible
	divipola_centropob <- divipola_centropob %>%
		dplyr::mutate(dept_nom_corto = dplyr::case_when(
			dept_nom == "ARCHIPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA Y SANTA CATALINA" ~ "San Andrés",
			dept_nom == "BOGOTÁ, D. C." ~ "Bogotá",
			dept_nom == "NORTE DE SANTANDER" ~ "Norte de Santander",
			dept_nom == "VALLE DEL CAUCA" ~ "Valle del Cauca",
			TRUE ~ stringr::str_to_title(dept_nom)
		))

	# Now merge provinces, downloaded from:
	# https://www.dane.gov.co/files/censo2005/provincias/subregiones.xls

	provins <- ingest_provins() %>%
		select(-nombre_mpio, -nombre_depto) %>%
		rename(muni_nom_corto = nombre)
	divipola_centropob <- divipola_centropob %>%
		left_join(provins, by = c("muni_cod" = "codigo_municipio"))

	# Save as data available for the package
	usethis::use_data(divipola_centropob, overwrite = TRUE)

	# Divipola at municipality level ###########################################
	# Then we need to keep only department and municipality data
	# But what long and latitude to keep for the municipality?
	# Should we keep the data for "cabecera" only?
	# Or should we rather keep the data where the centro poblado code is "000"

	# Check if all municipalities have one and only one cabecera
	divipola_check <- divipola_centropob %>%
		dplyr::group_by(region_cod, dept_cod, muni_cod,
						region_nom, dept_nom, muni_nom, tipo_centro_poblado) %>%
		dplyr::summarize(n = n()) %>%
		tidyr::spread(key = tipo_centro_poblado, value = n)
	# Number of municipalities ok
	num_munis <- divipola_centropob$muni_cod %>% unique() %>% length()
	num_munis - nrow(divipola_check)
	# There are max one cabecera per municipality
	# But there are NAs (municipalities without cabecera)
	summary(divipola_check$`CABECERA MUNICIPAL (CM)`)

	# Check if taking the last three digits of the code works (centro pob code)
	divipola_centropob$centro_poblado_digitos <-
		substr(divipola_centropob$centro_poblado_cod, start = 6, stop = 9)
	divipola_check <- divipola_centropob %>%
		dplyr::group_by(dept_cod, muni_cod, dept_nom, muni_nom, centro_poblado_digitos) %>%
		dplyr::summarize(n = n()) %>%
		tidyr::spread(key = centro_poblado_digitos, value = n)
	# Number of municipalities ok
	num_munis <- divipola_centropob$muni_cod %>% unique() %>% length()
	num_munis - nrow(divipola_check)
	# Ok, there are exactly one row with last three digits == 000
	summary(divipola_check$`000`)
	sum(divipola_check$`000`) == num_munis

	# So, keep only those for the municipalities divipola
	divipola_muni <- divipola_centropob %>%
		dplyr::filter(centro_poblado_digitos=="000") %>%
		dplyr::select(-centro_poblado_digitos)

	# Save as data available for the package
	usethis::use_data(divipola_muni, overwrite = TRUE)


	# Divipola at department province ##########################################
	# Then we need to keep only department data
	# But what long and latitude to keep for the municipality?
	# That of the capital, whose municipality code typically end in 001
	# For provinces it may not work good, 'cause the capital would only be in
	# one of them
	# So perhaps just the average

	divipola_provins <- divipola_centropob %>%
		group_by(provincia) %>%
		summarise(
			# dept_cod = efunc::most_frequent(dept_cod),
			# dept_nom = efunc::most_frequent(dept_nom),
			# long = mean(long, na.rm = TRUE),
			# lat = mean(lat, na.rm = TRUE),
			# region_nom = efunc::most_frequent(region_nom),
			# region_cod = efunc::most_frequent(region_cod),
			# dept_nom_corto = efunc::most_frequent(dept_nom_corto),
			# muni_nom_corto = efunc::most_frequent(muni_nom_corto),
			# # And a bunch of auxiliary test variables
			# nunique_dept_cod = dplyr::n_distinct(dept_cod),
			# nunique_dept_nom = dplyr::n_distinct(dept_nom),
			# nunique_long = dplyr::n_distinct(long, na.rm = TRUE),
			# nunique_lat = dplyr::n_distinct(lat, na.rm = TRUE),
			# nunique_region_nom = dplyr::n_distinct(region_nom),
			# nunique_region_cod = dplyr::n_distinct(region_cod),
			# nunique_dept_nom_corto = dplyr::n_distinct(dept_nom_corto),
			# nunique_muni_nom_corto = dplyr::n_distinct(muni_nom_corto),
		)

	assertthat::assert_that(
		divipola_provins %>% select(starts_with("nunique_")) %>% max() == 1,
		msg = "There are distinct values within provincia groups"
	)

	usethis::use_data(divipola_provins, overwrite = TRUE)



	# Divipola at department level #############################################
	# Then we need to keep only department data
	# But what long and latitude to keep for the municipality?
	# That of the capital, whose municipality code typically end in 001

	# Check if taking the last three digits of the code works (centro pob code)
	divipola_muni$muni_digitos <-
		substr(divipola_muni$muni_cod, start = 3, stop = 5)

	divipola_check <- divipola_muni %>%
		dplyr::group_by(dept_cod, dept_nom, muni_digitos) %>%
		dplyr::summarize(n = n()) %>%
		tidyr::spread(key = muni_digitos, value = n)
	# Number of departments ok
	num_depts <- divipola_muni$dept_cod %>% unique() %>% length()
	num_depts - nrow(divipola_check)
	# Ok, there are exactly one row with last three digits == 001,
	# so one capital per department
	summary(divipola_check$`001`)
	sum(divipola_check$`001`) == num_depts

	# So, keep only capitals for the departments
	divipola_dept <- divipola_muni %>%
		dplyr::filter(muni_digitos == "001") %>%
		dplyr::select(dept_cod, dept_nom, long, lat, dept_nom_corto)

	# Save as data available for the package
	usethis::use_data(divipola_dept, overwrite = TRUE)

	divipola_dept
}


ingest_provins <- function() {

	# Now merge provinces, downloaded from:
	# https://www.dane.gov.co/files/censo2005/provincias/subregiones.xls
	provins <- readxl::read_excel(
		path = here::here("data-raw/DIVIPOLA/subregiones.xls")
	)

	provins <- provins %>%
		#efunc::fix_var_names() %>%
		filter(!is.na(codigo_municipio)) %>%
		tidyr::fill(nombre_depto, provincia, .direction = "down") %>%
		select(-total)

	assertthat::assert_that(
		length(unique(provins$codigo_municipio)) == nrow(provins),
		msg = "Municipality code is not unique"
	)

	usethis::use_data(provins, overwrite = TRUE)

	provins
}

get_divipola()











