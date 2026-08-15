
<!-- README.md is generated from README.Rmd. Please edit that file -->

# daner

<!-- badges: start -->
<!-- badges: end -->

daner provides helpers for working with data published by
[DANE](https://www.dane.gov.co) (Departamento Administrativo Nacional de
Estadística). It’s just a bunch of functions accumulated over time, for
tasks that come up repeatedly when working with DANE’s microdata and
metadata:

- **DIVIPOLA codes**: standardize and join Colombia’s official
  political-administrative division codes (departments and
  municipalities).
- **DDI metadata**: parse the DDI (Data Documentation Initiative) XML
  files DANE publishes alongside its microdata catalogs, to list a
  study’s files and variables and their labels.
- **Microdata ingestion**: read the zipped SPSS (`.sav`) files DANE
  distributes, handling the quirks of how they’re bundled (several files
  per zip, file names that don’t match the zip name).

## Installation

daner is not on CRAN. Install the development version from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("edalfon/daner")
```

## Example

### DIVIPOLA codes

`fix_dept_cod()` and `fix_muni_cod()` normalize department/municipality
codes to their canonical, zero-padded format:

``` r
library(daner)

fix_dept_cod(c(5, 25, "5"))
#> [1] "05" "25" "05"
fix_muni_cod(c(5001, "5002"))
#> [1] "05001" "05002"
```

`join_divipola_muni_cod()` left-joins municipality names, department,
coordinates and other DIVIPOLA fields onto any data frame that has a
municipality-code column:

``` r
muni_df <- data.frame(cod = c("05001", "25001"))

join_divipola_muni_cod(muni_df, by = "cod")
#> ✔ 2 rows [100.0%] successfully joined
#>     cod muni_cod dept_cod centro_poblado_cod     dept_nom     muni_nom
#> 1 05001    05001       05           05001000    ANTIOQUIA     MEDELLÍN
#> 2 25001    25001       25           25001000 CUNDINAMARCA AGUA DE DIOS
#>   centro_poblado_nom     tipo_centro_poblado      long      lat distrito
#> 1           MEDELLÍN CABECERA MUNICIPAL (CM) -75.57600 6.248586     <NA>
#> 2       AGUA DE DIOS CABECERA MUNICIPAL (CM) -74.66922 4.375315     <NA>
#>   tipo_muni                     area_metropolitana region_nom region_cod
#> 1 MUNICIPIO AREA METROPOLITANA DEL VALLE DE ABURRÁ    Central          4
#> 2 MUNICIPIO                                   <NA>    Central          4
#>   dept_nom_corto        provincia muni_nom_corto
#> 1      Antioquia VALLE DEL ABURRA       Medellín
#> 2   Cundinamarca   ALTO MAGDALENA   Agua De Dios
```

### DDI metadata

`list_ddi_files()` and `get_ddi_vars()` read a DDI XML document (from a
URL or a local file) and return the files/variables it describes as tidy
data frames:

``` r
ddi_url <- "http://microdatos.dane.gov.co/index.php/catalog/ddi/419"

list_ddi_files(ddi_url)
get_ddi_vars(ddi_url)
```

### Ingesting zipped microdata

`ingest_zipped_sav()` unzips and reads the `.sav` file(s) bundled in a
DANE microdata zip file:

``` r
ingest_zipped_sav("path/to/microdata.zip")
```
