FUNCTION z_cl_get_billofmat_all.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_MATNR) TYPE  MATNR
*"     VALUE(I_STLAN) TYPE  STLAN DEFAULT ' '
*"     VALUE(I_STLAL) TYPE  STLAL DEFAULT ' '
*"     VALUE(I_WERKS) TYPE  WERKS_D DEFAULT ' '
*"     VALUE(I_DATUM) TYPE  SY-DATUM OPTIONAL
*"  TABLES
*"      O_ITAB_MATNR STRUCTURE  MARA
*"      O_ITAB_DOK STRUCTURE  STPOX
*"      O_ITAB_TXT STRUCTURE  STPOX
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 16.10.2006 - Übergabe des Auflösungsdatums
*-----------------------------------------------------------------------
*TYPES
  TYPES:
    BEGIN OF t_default_data,
      mat_capid TYPE tc04-capid,
      mat_stpst TYPE stpox-stufe,
    END OF t_default_data.
  TYPES:
    BEGIN OF t_user_data,
      mat_capid TYPE tc04-capid,
      uname TYPE sy-uname,
      mat_stpst TYPE stpox-stufe,
    END OF t_user_data.
*ITAB
  DATA: itab_stb TYPE TABLE OF stpox.
*WA
  DATA: wa_stb TYPE stpox.
  DATA: wa_mara TYPE mara.
  DATA: default_data TYPE t_default_data.
  DATA: user_data TYPE t_user_data.
  DATA: wa_dok TYPE stpox.
  DATA: wa_txt TYPE stpox.

*NORMAL
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).


* Initialisieren
  REFRESH itab_stb.
  REFRESH o_itab_matnr.

* Einstellungen einlesen
  CLEAR user_data.
  CLEAR default_data.
  user_data-uname = sy-uname.
* MAT_CAPID
  CLEAR tmp_str.
  pname = 'MAT_CAPID'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_capid = 'PP01'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'PP01' ''.
  ELSE.
    default_data-mat_capid = tmp_str.
  ENDIF.

  CLEAR tmp_str.
  pname = 'MAT_CAPID'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_capid = default_data-mat_capid.
  ELSE.
    user_data-mat_capid = tmp_str.
  ENDIF.

* MAT_STPST
  CLEAR tmp_str.
  pname = 'MAT_STPST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_stpst = '0'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '0' ''.
  ELSE.
    default_data-mat_stpst = tmp_str.
  ENDIF.

  CLEAR tmp_str.
  pname = 'MAT_STPST'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_stpst = default_data-mat_stpst.
  ELSE.
    user_data-mat_stpst = tmp_str.
  ENDIF.



* Stückliste abfragen
  IF i_datum = '00000000'.
    i_datum = sy-datum.
  ELSE.
  ENDIF.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
   EXPORTING
     ftrel                       = ' '
     altvo                       = ' '
     aufsw                       = ' '
     aumgb                       = ' '
     aumng                       = 0
     auskz                       = ' '
     amind                       = ' '
     bagrp                       = ' '
     beikz                       = ' '
     bessl                       = ' '
     bgixo                       = ' '
     brems                       = ' '
     capid                       = user_data-mat_capid
     chlst                       = ' '
     cospr                       = ' '
     cuobj                       = 000000000000000
     cuovs                       = 0
     cuols                       = ' '
     datuv                       = i_datum "sy-datum
     delnl                       = ' '
     drldt                       = ' '
     ehndl                       = '1'
     emeng                       = 1
     erskz                       = ' '
     erssl                       = ' '
     fbstp                       = ' '
     knfba                       = ' '
     ksbvo                       = ' '
     mbwls                       = ' '
     mktls                       = 'X'
     mdmps                       = ' '
     mehrs                       = 'X' "' '
     mkmat                       = ' '
     mmaps                       = ' '
     salww                       = ' '
     splww                       = ' '
     mmory                       = '1' "' '
     mtnrv                       = i_matnr
     nlink                       = ' '
     postp                       = ' '
     rndkz                       = ' '
     rvrel                       = ' '
     sanfr                       = ' '
     sanin                       = ' '
     sanka                       = ' '
     sanko                       = ' '
     sanvs                       = ' '
     schgt                       = ' '
     stkkz                       = ' '
     stlal                       = i_stlal "' '
     stlan                       = i_stlan "' '
     stpst                       = user_data-mat_stpst "0
     svwvo                       = 'X'
     werks                       = i_werks "' '
     norvl                       = ' '
     mdnot                       = ' '
     panot                       = ' '
     qverw                       = ' '
     verid                       = ' '
     vrsvo                       = 'X'
*   IMPORTING
*     TOPMAT                      =
*     DSTST                       =
    TABLES
      stb                         = itab_stb
*     MATCAT                      =
   EXCEPTIONS
     alt_not_found               = 1
     call_invalid                = 2
     material_not_found          = 3
     missing_authorization       = 4
     no_bom_found                = 5
     no_plant_data               = 6
     no_suitable_bom_found       = 7
     conversion_error            = 8
     OTHERS                      = 9
            .
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    raise error.
  ENDIF.

  REFRESH o_itab_matnr.
  REFRESH o_itab_dok.
  REFRESH o_itab_txt.

  LOOP AT itab_stb INTO wa_stb.
    IF wa_stb-idnrk IS INITIAL.
      CASE wa_stb-postp.
        WHEN 'D'.
          APPEND wa_stb TO o_itab_dok.
        WHEN 'T'.
          APPEND wa_stb TO o_itab_txt.
        WHEN OTHERS.
      ENDCASE.
    ELSE.
      CLEAR wa_mara.
      wa_mara-matnr = wa_stb-idnrk.
      APPEND wa_mara TO o_itab_matnr.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
