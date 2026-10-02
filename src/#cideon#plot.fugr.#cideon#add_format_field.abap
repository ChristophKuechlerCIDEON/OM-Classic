FUNCTION /cideon/add_format_field.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"  TABLES
*"      ITAB_TMP_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 12.07.2004 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.

  DATA: tmp_atwrt LIKE ausp-atwrt.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    CLEAR tmp_atwrt.
    SELECT SINGLE atwrt FROM ausp
      INTO tmp_atwrt
      WHERE objek = wa_plotjobs-objky
      AND atinn = i_wa_default_data-merkmal_format
      .
    IF sy-subrc NE 0.
      PERFORM appl_log_write USING
        'W' '022' 'ZCL_PLINT_MESSAGE_01'
         wa_plotjobs-dokar wa_plotjobs-doknr
         wa_plotjobs-dokvr wa_plotjobs-doktl.
    ELSE.
      wa_plotjobs-format_ausgabe = tmp_atwrt.
      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
