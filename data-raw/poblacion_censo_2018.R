
ingest_poblacion_censo_2018 <- function() {

  pob_2018_dept <- readxl::read_xls(
    path = here::here("data-raw/poblacion_censo_2018/CNPV-2018-Poblacion-Ajustada-por-Cobertura.xls"),
    sheet = "Ajuste por Cobertura CNPV 2018",
    range = "A10:H43",
    col_names = c("dept_cod", "dept_nom", "pob_total", "pob_cabecera",
                  "pob_rural", "omision_total", "omision_cabecera",
                  "omision_rural")
  )

  usethis::use_data(pob_2018_dept, overwrite = TRUE)

  pob_2018_muni <- readxl::read_xls(
    path = here::here("data-raw/poblacion_censo_2018/CNPV-2018-Poblacion-Ajustada-por-Cobertura.xls"),
    sheet = "Ajuste por Cobertura CNPV Mpios",
    range = "A10:I1131",
    col_names = c("muni_cod", "dept_nom", "muni_nom", "pob_total", "pob_cabecera",
                  "pob_rural", "omision_total", "omision_cabecera",
                  "omision_rural")
  )

  usethis::use_data(pob_2018_muni, overwrite = TRUE)

}
