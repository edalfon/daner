# daner 0.0.2

Initial release.

## DIVIPOLA

* `fix_dept_cod()` and `fix_muni_cod()` normalize department/municipality
  codes to their canonical, zero-padded format.
* `join_divipola_dept_cod()` and `join_divipola_muni_cod()` left-join
  DIVIPOLA department/municipality variables (name, coordinates, region,
  province, ...) onto a data frame that has a code column.
* Bundled DIVIPOLA and population data sets: `divipola_dept`,
  `divipola_muni`, `divipola_centropob`, `divipola_provins`, `provins`,
  `pob_2018_dept`, `pob_2018_muni`, `proypob_dpto_edad`.

## DDI metadata

* `get_ddi_xml()`, `list_ddi_files()` and `get_ddi_vars()` parse DDI (Data
  Documentation Initiative) XML files published alongside DANE's microdata
  catalogs, to list a study's files and variables and their labels.
* `get_ddi_vars()` now handles DDI files where some `catgry` nodes have no
  `labl` child (e.g. large code lists such as municipality codes), instead
  of erroring.

## Microdata ingestion

* `ingest_zipped_sav()` unzips and reads the `.sav` file(s) bundled in a
  DANE microdata zip file, handling zips that bundle several files or where
  the `.sav` file name doesn't match the zip name.
