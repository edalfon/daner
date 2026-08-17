#' DIVIPOLA department-level codes
#'
#' Colombia's official political-administrative division codes (DIVIPOLA) at
#' the department level: one row per department, with its capital's
#' coordinates.
#'
#' @format A tibble with 33 rows and 5 variables:
#' \describe{
#'   \item{dept_cod}{2-digit DANE department code}
#'   \item{dept_nom}{Department name, upper case}
#'   \item{long}{Longitude of the department capital}
#'   \item{lat}{Latitude of the department capital}
#'   \item{dept_nom_corto}{Department name, title case, shortened for display}
#' }
#' @source \url{http://geoportal.dane.gov.co:8084/Divipola/}
"divipola_dept"

#' DIVIPOLA municipality-level codes
#'
#' Colombia's official political-administrative division codes (DIVIPOLA) at
#' the municipality level: one row per municipality, with department,
#' region, province and short-name variants for display.
#'
#' @format A tibble with 1,123 rows and 17 variables:
#' \describe{
#'   \item{dept_cod}{2-digit DANE department code}
#'   \item{muni_cod}{5-digit DANE municipality code}
#'   \item{centro_poblado_cod}{8-digit DANE populated-place code of the
#'     municipality's "cabecera municipal"}
#'   \item{dept_nom}{Department name, upper case}
#'   \item{muni_nom}{Municipality name, upper case}
#'   \item{centro_poblado_nom}{Populated-place name, upper case}
#'   \item{tipo_centro_poblado}{Populated-place type}
#'   \item{long}{Longitude}
#'   \item{lat}{Latitude}
#'   \item{distrito}{District, when the municipality is one}
#'   \item{tipo_muni}{Municipality type}
#'   \item{area_metropolitana}{Metropolitan area name, when applicable}
#'   \item{region_nom}{Region name}
#'   \item{region_cod}{Region code}
#'   \item{dept_nom_corto}{Department name, title case, shortened for display}
#'   \item{provincia}{Province name}
#'   \item{muni_nom_corto}{Municipality name, title case, shortened for display}
#' }
#' @source \url{http://geoportal.dane.gov.co:8084/Divipola/}
"divipola_muni"

#' DIVIPOLA populated-place ("centro poblado") level codes
#'
#' Colombia's official political-administrative division codes (DIVIPOLA) at
#' the populated-place level, the finest granularity DIVIPOLA offers: one row
#' per "centro poblado" (which can be a municipality's "cabecera", a
#' "corregimiento" or a rural settlement). [divipola_muni] is derived from
#' this data set by keeping only each municipality's "cabecera municipal".
#'
#' @format A tibble with 8,062 rows and 17 variables, with the same columns
#' as [divipola_muni].
#' @source \url{http://geoportal.dane.gov.co:8084/Divipola/}
"divipola_centropob"

#' DIVIPOLA province-level codes
#'
#' Colombia's official political-administrative division codes (DIVIPOLA)
#' aggregated at the province ("provincia") level, a grouping of
#' municipalities used mainly in Cundinamarca and a few other departments.
#'
#' @format A tibble with 97 rows and 17 variables:
#' \describe{
#'   \item{provincia}{Province name}
#'   \item{dept_cod}{2-digit DANE department code}
#'   \item{dept_nom}{Department name, upper case}
#'   \item{long}{Longitude}
#'   \item{lat}{Latitude}
#'   \item{region_nom}{Region name}
#'   \item{region_cod}{Region code}
#'   \item{dept_nom_corto}{Department name, title case, shortened for display}
#'   \item{muni_nom_corto}{Municipality name, title case, shortened for display}
#'   \item{nunique_dept_cod, nunique_dept_nom, nunique_long, nunique_lat,
#'     nunique_region_nom, nunique_region_cod, nunique_dept_nom_corto,
#'     nunique_muni_nom_corto}{Diagnostic counts, from `data-raw/divipola.R`,
#'     of how many distinct values of each variable exist within a province
#'     (all should be 1, i.e. these variables are constant within a
#'     province)}
#' }
#' @source \url{http://geoportal.dane.gov.co:8084/Divipola/}
"divipola_provins"

#' Municipality-to-province lookup
#'
#' A lookup table mapping municipalities to the province ("provincia") they
#' belong to. Used to build [divipola_centropob] and [divipola_provins].
#'
#' @format A tibble with 1,123 rows and 5 variables:
#' \describe{
#'   \item{nombre_depto}{Department name, upper case}
#'   \item{provincia}{Province name}
#'   \item{codigo_municipio}{5-digit DANE municipality code}
#'   \item{nombre_mpio}{Municipality name, upper case}
#'   \item{nombre}{Municipality name, title case}
#' }
#' @source \url{https://www.dane.gov.co/files/censo2005/provincias/subregiones.xls}
"provins"

#' 2018 census population, department level
#'
#' Population counts and coverage-omission rates from DANE's 2018 National
#' Population and Housing Census (CNPV), adjusted for coverage, at the
#' department level.
#'
#' @format A tibble with 34 rows (33 departments plus a national total) and
#' 8 variables:
#' \describe{
#'   \item{dept_cod}{2-digit DANE department code ("00" for the national total)}
#'   \item{dept_nom}{Department name}
#'   \item{pob_total}{Total population}
#'   \item{pob_cabecera}{Population in the urban "cabecera"}
#'   \item{pob_rural}{Rural population}
#'   \item{omision_total}{Total coverage-omission rate}
#'   \item{omision_cabecera}{Coverage-omission rate, "cabecera"}
#'   \item{omision_rural}{Coverage-omission rate, rural}
#' }
#' @source DANE, CNPV 2018, "Poblacion Ajustada por Cobertura"
#'   \url{https://www.dane.gov.co}
"pob_2018_dept"

#' 2018 census population, municipality level
#'
#' Population counts and coverage-omission rates from DANE's 2018 National
#' Population and Housing Census (CNPV), adjusted for coverage, at the
#' municipality level.
#'
#' @format A tibble with 1,122 rows and 9 variables:
#' \describe{
#'   \item{muni_cod}{5-digit DANE municipality code}
#'   \item{dept_nom}{Department name}
#'   \item{muni_nom}{Municipality name}
#'   \item{pob_total}{Total population}
#'   \item{pob_cabecera}{Population in the urban "cabecera"}
#'   \item{pob_rural}{Rural population}
#'   \item{omision_total}{Total coverage-omission rate}
#'   \item{omision_cabecera}{Coverage-omission rate, "cabecera"}
#'   \item{omision_rural}{Coverage-omission rate, rural}
#' }
#' @source DANE, CNPV 2018, "Poblacion Ajustada por Cobertura"
#'   \url{https://www.dane.gov.co}
"pob_2018_muni"

#' Department population projections by age and sex, 2005-2020
#'
#' DANE's national and department-level population projections, broken down
#' by single year of age (0 to 80+) and sex, for each year 2005-2020. Wide
#' format: one row per department/year, with one column per age for each of
#' the total, "hombres" (male) and "mujeres" (female) populations.
#'
#' @format A data frame with 544 rows and 251 variables. The first five
#' columns identify the row: `dp` (2-digit DANE department code, "00" for
#' the national total), `dpnom` (department name), `dpmp` and `mpio`
#' (repeats of `dp`/`dpnom`, a source-file artifact), and `ano` (year,
#' 2005-2020). The remaining 246 columns are population counts, one per
#' combination of group (`total`, `hombres` i.e. male, `mujeres` i.e.
#' female) and age (`_total` for all ages, then `_0`, `_1`, ..., `_79`,
#' `_80` for single years of age up to 80 and older), e.g. `total_total`,
#' `total_0`, ..., `hombres_total`, `hombres_0`, ..., `mujeres_total`,
#' `mujeres_0`, ....
#' @source DANE, "Proyecciones de poblacion nacional y departamental por
#'   sexo y edades simples hasta los 80 y mas anos"
#'   \url{https://www.dane.gov.co}
"proypob_dpto_edad"
