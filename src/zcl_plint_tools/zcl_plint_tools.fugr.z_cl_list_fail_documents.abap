FUNCTION z_cl_list_fail_documents .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_LED_STYLE) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_SPEICHER_ORT_FB_LISTE) TYPE  FILEP
*"     VALUE(I_KNZ_STATIC) TYPE  CHAR1
*"     VALUE(I_TRENNZEICHEN) TYPE  CHAR1
*"     VALUE(I_DIALOG) TYPE  CHAR1
*"  TABLES
*"      I_ITAB_FAIL_DOCUMENT STRUCTURE  ZCL_S_FAIL_DOCUMENT OPTIONAL
*"      O_ITAB_FAIL_DOCUMENT STRUCTURE  ZCL_S_FAIL_DOCUMENT OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 27.08.2002 Erstellung
*-----------------------------------------------------------------------
*
* Listet Dokumente auf, welche keine Originaldateien besitzen
* oder für keine für eine bestimmte Auswahl von Workstationaplltypen ...
*----------------------------------------------------------------------

  g_led_style = i_led_style.
  g_first = 'X'.

  speicher_ort_fb_liste = i_speicher_ort_fb_liste.
  knz_static_fb_liste = i_knz_static.
  trennzeichen_fb_liste = i_trennzeichen.
  knz_dialog_fb_liste = i_dialog.


  REFRESH itab_fail_document_alv.
  LOOP AT i_itab_fail_document INTO wa_fail_document.
    CLEAR wa_fail_document_alv.
    MOVE-CORRESPONDING wa_fail_document TO wa_fail_document_alv.

    wa_fail_document_alv-status = icon_transfer.
    IF wa_fail_document_alv-knz_kein_file = 'X'.
      IF wa_fail_document_alv-knz_garkein_file = 'X'.
        wa_fail_document_alv-light = 1.
      ELSE.
        wa_fail_document_alv-light = 2.
      ENDIF.
    ELSE.
      IF wa_fail_document_alv-knz_garkein_file = 'X'.
        wa_fail_document_alv-light = 1.
      ELSE.
        wa_fail_document_alv-light = 3.
      ENDIF.
    ENDIF.


    APPEND wa_fail_document_alv TO itab_fail_document_alv.
  ENDLOOP.

  CALL SCREEN 700 STARTING AT 10 10 ENDING AT 80 20.

  o_itab_fail_document[] = itab_tmp_fail_document[].


ENDFUNCTION.
