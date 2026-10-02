*----------------------------------------------------------------------*
***INCLUDE LZCL_PLINT_TOOLSF03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  save_to_fb_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_to_fb_list.
* speichert als Fehlblattliste
  DATA: itab_plotjobs TYPE TABLE OF zcl_s_plotlist.
  DATA: wa_plotjobs TYPE zcl_s_plotlist.

  LOOP AT itab_fail_document_alv INTO wa_fail_document_alv.
    CLEAR wa_plotjobs.
    MOVE-CORRESPONDING wa_fail_document_alv TO wa_plotjobs.
    APPEND wa_plotjobs TO itab_plotjobs.
  ENDLOOP.

  CALL FUNCTION '/CIDEON/DOWNLOAD_FEHLBLATT_LST'
       EXPORTING
            i_speicher_ort_fb_liste = speicher_ort_fb_liste
            i_knz_static            = knz_static_fb_liste
            i_trennzeichen          = trennzeichen_fb_liste
            i_dialog                = knz_dialog_fb_liste
       TABLES
            i_itab_plotjobs         = itab_plotjobs
       EXCEPTIONS
            error                   = 1
            trennzeichen_initial    = 2
            OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " save_to_fb_list
*&---------------------------------------------------------------------*
*&      Form  get_local_work_path
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_local_work_path
  CHANGING path TYPE localfile.
* holt sich lokalen Arbeitspfad
  DATA: text(60).

* 7.0.1.21
* 22.02.2010 - /CIDEON/LPLOT_TOOLSF01
*              form get_local_work_path
*              Problem bei Aufruf CALL TRANSACTION mit MODE
*              -> GUI Services schlagen fehl
*              -> Service ausgebaut
*              Trumpf


** 20.09.2006 - Anpassung, falls im Hintergrund aufgerufen
*  IF sy-batch = 'X'.
*    EXIT.
*  ELSE.
*  ENDIF.

* default_data-view_down_path
  CALL FUNCTION 'WS_QUERY'
    EXPORTING
*     ENVIRONMENT          =
*     FILENAME             =
      query                = 'CD'
*     WINID                =
   IMPORTING
      return               = path "default_data-view_down_path
   EXCEPTIONS
     inv_query            = 1
     no_batch             = 2
     frontend_error       = 3
     OTHERS               = 4
            .
  IF sy-subrc <> 0.
    CLEAR path.

    CLEAR text.

*    CASE sy-subrc.
*      WHEN '1'.
*        text = 'inv_query'.
*      WHEN '2'.
*        text = 'no_batch'.
*      WHEN '3'.
*        text = 'frontend_error'.
*      WHEN '4'.
*        text = 'others'.
*      WHEN OTHERS.
*        text = '????????'.
*    ENDCASE.
*
*    text = sy.
*
*    MESSAGE w164(zcl_plint_message_01)
*      WITH text 'LZCL_PLINT_TOOLSF03' '' ''.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.




ENDFORM.                    " get_local_work_path
*&---------------------------------------------------------------------*
*&      Form  suche_via_cv04n
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM suche_via_cv04n.
* Suche über CV04N
*
*  clear it_draw.
*
*  CALL FUNCTION 'CV100_DOC_SEARCH'
*   EXPORTING
*     pf_cv04_list_type       = '2' "2
**    PF_WEB_LIST_TYPE        =
*     api_flag                = 'X' "X
*   TABLES
*     ptx_draw                = it_draw
*    .
*
** Anzeige und Auswahl



ENDFORM.                    " suche_via_cv04n
