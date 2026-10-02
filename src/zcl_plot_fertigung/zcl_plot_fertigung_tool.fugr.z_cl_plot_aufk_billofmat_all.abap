FUNCTION z_cl_plot_aufk_billofmat_all.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_MATNR) TYPE  MATNR
*"     VALUE(I_STLAN) TYPE  STLAN DEFAULT ' '
*"     VALUE(I_STLAL) TYPE  STLAL DEFAULT ' '
*"     VALUE(I_STUFE) TYPE  STPOX-STUFE
*"     VALUE(I_CAPID) TYPE  TC04-CAPID
*"  TABLES
*"      O_ITAB_MATNR STRUCTURE  MARA
*"      O_ITAB_DOK STRUCTURE  STPOX
*"      O_ITAB_TXT STRUCTURE  STPOX
*"      O_ITAB_STPOX STRUCTURE  ZCL_SL_TMP
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
*-----------------------------------------------------------------------
*TYPES
*ITAB
  DATA: itab_stb TYPE TABLE OF stpox.
  DATA: itab_zcl_sl_tmp TYPE TABLE OF zcl_sl_tmp.

*WA
  DATA: wa_stb TYPE stpox.
  DATA: wa_mara TYPE mara.
  DATA: wa_dok TYPE stpox.
  DATA: wa_txt TYPE stpox.
  DATA: wa_zcl_sl_tmp TYPE zcl_sl_tmp.

*NORMAL


* Initialisieren
  REFRESH itab_stb.
  REFRESH o_itab_matnr.


* Stückliste abfragen

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
     capid                       = i_capid
     chlst                       = ' '
     cospr                       = ' '
     cuobj                       = 000000000000000
     cuovs                       = 0
     cuols                       = ' '
     datuv                       = sy-datum
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
     stpst                       = i_stufe "0
     svwvo                       = 'X'
     werks                       = ' '
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
    RAISE error.
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

* Stücklisteninhalte in ITAB schreiben und übergeben
  CLEAR itab_zcl_sl_tmp.
  LOOP AT itab_stb INTO wa_stb.
    CLEAR wa_zcl_sl_tmp.
    MOVE-CORRESPONDING wa_stb TO wa_zcl_sl_tmp.
    wa_zcl_sl_tmp-zcl_index = wa_stb-index.

    APPEND wa_zcl_sl_tmp TO itab_zcl_sl_tmp.
  ENDLOOP.

  O_ITAB_STPOX[] = itab_zcl_sl_tmp[].

ENDFUNCTION.
