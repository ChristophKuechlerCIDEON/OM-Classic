FUNCTION z_cl_doc_change_event_batch.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT OPTIONAL
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE OPTIONAL
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE OPTIONAL
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY OPTIONAL
*"     VALUE(EXCEPTIONS_ALLOWED) LIKE  SWEFLAGS-EXC_OK DEFAULT SPACE
*"     VALUE(WF_ERZEUGER) LIKE  WFSYST-AGENT OPTIONAL
*"     VALUE(OBJ_KEY) LIKE  SWEINSTCOU-OBJKEY OPTIONAL
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"----------------------------------------------------------------------


* Einstellungen lesen
  CLEAR wa_user_data.
  CLEAR wa_default_data.
  CLEAR:  g_user, g_draw_key,
          wa_draw, wa_item_fauf,
          wa_default_verteiler,
          itab_items_fauf,
          itab_mat_status_exc,
          itab_search.

  g_draw_key = objkey.


  SELECT SINGLE * FROM draw INTO wa_draw
      WHERE dokar = g_draw_key-dokar
      AND   doknr = g_draw_key-doknr
      AND   doktl = g_draw_key-doktl
      AND   dokvr = g_draw_key-dokvr.
  IF sy-subrc = 0.

    MOVE wa_draw-dokar TO wa_item_fauf-dokar.
    MOVE wa_draw-doknr TO wa_item_fauf-doknr.
    MOVE wa_draw-doktl TO wa_item_fauf-doktl.
    MOVE wa_draw-dokvr TO wa_item_fauf-dokvr.

    APPEND wa_item_fauf TO itab_items_fauf.

  ENDIF.

  CLEAR: wa_user_data,  wa_default_data.

*---------------------------------------------------
*  ZCL_PLINT_DESIGN_007
*---------------------------------------------------
*PBO Status 100

  PERFORM read_user_and_default_data.


* Aufruf des FBs
  IF itab_items_fauf[] IS INITIAL.
  ELSE.

*  Schreiben in temporäre Plotqueue (wird im FB
*  '/CIDEON/READ_STORED_SEARCH' wieder gelöscht !)

    CALL FUNCTION 'Z_CL_WRITE_PLOT_PSB_NOSTR_BTCH'
         EXPORTING
              f_aut_process = wa_user_data-knz_auto_fauf
              g_user        = g_user
         TABLES
              i_itab_items  = itab_items_fauf
         EXCEPTIONS
              error         = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    COMMIT WORK.

* mglw. automatischer Durchlauf durch PlotInterface
    IF wa_user_data-knz_auto_fauf = 'X'.
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
    ELSE.
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
    ENDIF.
* Aufruf des PlotInterfaces
    SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
* weiter mit PBO Status 100:

    PERFORM read_default_verteiler.
    PERFORM read_mat_status_exc.
    PERFORM read_stored_search.

    IF itab_search[] IS INITIAL.
    ELSE.

      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM make_knz_freigabe_led.
      PERFORM make_mat_status_icon.
      PERFORM make_display_icon.


*  UP TO_PLOTLIST:
* get the allowed filetypes for this special user
      IF wa_user_data-use_filter = 'X'.
        PERFORM get_file_types.
      ELSE.
      ENDIF.
      PERFORM itab_search_to_draw.

* verarbeiten von Sondereinträgen

      PERFORM zori_doc_files.

*     checks if there are any entries available
      DESCRIBE TABLE itab_zori_doc_files LINES count_lines.
      IF count_lines > 0.
        PERFORM add_to_plotlist USING ''.
      ELSE.
      ENDIF.
*     checks if there are entries in the fail_doc available

      IF itab_fail_document[] IS INITIAL.
      ELSE.
*       checks what for a strategy shold be used
*       ask, ignore, list, failure document
        CASE wa_user_data-strategy.
          WHEN 'I'. "Ignore
            REFRESH itab_fail_document.
          WHEN 'F'. "Fail document
            PERFORM create_fail_items.
          WHEN OTHERS. "then ignore
            REFRESH itab_fail_document.
        ENDCASE.
      ENDIF.
*     check for not existing files
      PERFORM set_knz_use_checked_in.
      PERFORM reindex_table_2.

* Kundendaten anfügen
      PERFORM add_client_data_3.
* Kostenstelle einfügen
      PERFORM add_cost_center_2.


**********************************************************
*  Spezialeinschub zum Anhalten im BATCH:
*  mit SM50 und ausreichender Schnelligkeit
*  i sollte man dann manipulieren !

*      DATA: lt_dd02l TYPE TABLE OF dd02l WITH HEADER LINE,
*      i TYPE i.
*
*      SELECT * FROM dd02l INTO TABLE lt_dd02l.
*      LOOP AT lt_dd02l.
*        APPEND lt_dd02l.
*        LOOP AT lt_dd02l.
*          APPEND lt_dd02l.
*          i = sy-tabix.
*          IF i >= 10000000.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*        i = sy-tabix.
*        IF i >= 10000000.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
************************************************************

* UP 'SEND':

      PERFORM send_to_preprocessor.


* Einstellungen zurücksetzen
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.

      COMMIT WORK.
    ENDIF.
  ENDIF.

ENDFUNCTION.
