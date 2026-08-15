# get_ddi_vars works

    Code
      get_ddi_vars(xml_url)
    Output
      # A tibble: 140 x 6
         name      id    files intrvl   labl                            catgry  
         <chr>     <chr> <chr> <chr>    <chr>                           <list>  
       1 COD_DPTO  V1638 F32   discrete Departamento de Nacimiento      <tibble>
       2 COD_MUNIC V1639 F32   discrete Municipio de Nacimiento         <tibble>
       3 AREANAC   V1677 F32   discrete Área del Nacimiento             <tibble>
       4 SIT_PARTO V1678 F32   discrete Sitio de la Parto               <tibble>
       5 OTRO_SIT  V1642 F32   discrete Otro sitio, ¿cuál?              <tibble>
       6 SEXO      V1643 F32   discrete Sexo del nacido vivo            <tibble>
       7 PESO_NAC  V1644 F32   discrete Peso del nacido vivo, al nacer  <tibble>
       8 TALLA_NAC V1645 F32   discrete Talla del nacido vivo, al nacer <tibble>
       9 ANO       V1646 F32   discrete Año de la ocurrencia            <tibble>
      10 MES       V1647 F32   discrete Mes de la ocurrencia            <tibble>
      # i 130 more rows

# list_ddi_files works

    Code
      list_ddi_files(xml_url)
    Output
      # A tibble: 3 x 2
        id    uri                                       
        <chr> <chr>                                     
      1 F32   EEVV_2022.Nesstar?Index=0&Name=nac2022    
      2 F33   EEVV_2022.Nesstar?Index=1&Name=fetal2022  
      3 F34   EEVV_2022.Nesstar?Index=2&Name=nofetal2022

