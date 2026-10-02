*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F13 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  set_knz_view_draw_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_knz_view_draw_detail.
  DATA: wa_zcl_plint_config TYPE zcl_plint_config.

  CLEAR wa_zcl_plint_config.
  SELECT SINGLE * FROM zcl_plint_config
    INTO wa_zcl_plint_config
    WHERE uname = sy-uname
    AND pname = 'KNZ_VIEW_DRAW_DETAIL'
    .
  IF sy-subrc NE 0.
    wa_zcl_plint_config-uname = sy-uname.
    wa_zcl_plint_config-pname = 'KNZ_VIEW_DRAW_DETAIL'.
    wa_zcl_plint_config-pwert = g_show_draw_detail.
    wa_zcl_plint_config-zclinsname = sy-uname.
    wa_zcl_plint_config-zclinsdate = sy-datum.
    wa_zcl_plint_config-zclinstime = sy-uzeit.
    wa_zcl_plint_config-zclinsprog = 'ZCL_PLINT_DESIGN_007F13'.
  ELSE.
    wa_zcl_plint_config-pwert = g_show_draw_detail.
  ENDIF.

  wa_zcl_plint_config-zclupdname = sy-uname.
  wa_zcl_plint_config-zclupddate = sy-datum.
  wa_zcl_plint_config-zclupdtime = sy-uzeit.
  wa_zcl_plint_config-zclupdprog = 'ZCL_PLINT_DESIGN_007F13'.

  MODIFY zcl_plint_config FROM wa_zcl_plint_config.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

ENDFORM.                    " set_knz_view_draw_detail
*&---------------------------------------------------------------------*
*&      Form  set_knz_view_struc_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_knz_view_struc_plotlist.
  DATA: wa_zcl_plint_config TYPE zcl_plint_config.

  CLEAR wa_zcl_plint_config.
  SELECT SINGLE * FROM zcl_plint_config
    INTO wa_zcl_plint_config
    WHERE uname = sy-uname
    AND pname = 'KNZ_VIEW_STRUC_PLOTLIST'
    .
  IF sy-subrc NE 0.
    wa_zcl_plint_config-uname = sy-uname.
    wa_zcl_plint_config-pname = 'KNZ_VIEW_STRUC_PLOTLIST'.
    wa_zcl_plint_config-pwert = g_show_struktur.
    wa_zcl_plint_config-zclinsname = sy-uname.
    wa_zcl_plint_config-zclinsdate = sy-datum.
    wa_zcl_plint_config-zclinstime = sy-uzeit.
    wa_zcl_plint_config-zclinsprog = 'ZCL_PLINT_DESIGN_007F13'.
  ELSE.
    wa_zcl_plint_config-pwert = g_show_struktur.
  ENDIF.

  wa_zcl_plint_config-zclupdname = sy-uname.
  wa_zcl_plint_config-zclupddate = sy-datum.
  wa_zcl_plint_config-zclupdtime = sy-uzeit.
  wa_zcl_plint_config-zclupdprog = 'ZCL_PLINT_DESIGN_007F13'.

  MODIFY zcl_plint_config FROM wa_zcl_plint_config.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

ENDFORM.                    " set_knz_view_struc_plotlist
*&---------------------------------------------------------------------*
*&      Form  view_plot_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_plot_log.
* Anzeige der Plot Logs / /CIDEON/PL_LOG

  CALL TRANSACTION '/CIDEON/MNT_PLOT_LOG'.
ENDFORM.                    " view_plot_log
*&---------------------------------------------------------------------*
*&      Form  get_drawing_from_bom2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_drawing_from_bom2.
  DATA: itab_draw TYPE TABLE OF draw.


  CLEAR itab_draw.
  CALL FUNCTION '/CIDEON/GET_2D_SPECIAL'
       EXPORTING
            i_user_data  = user_data
       TABLES
            io_itab_draw = itab_draw
       EXCEPTIONS
            error        = 1
            OTHERS       = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  LOOP AT itab_draw INTO wa_draw.
    SELECT SINGLE * FROM draw INTO
      CORRESPONDING FIELDS OF wa_search
      WHERE doknr = wa_draw-doknr
      AND dokar = wa_draw-dokar
      AND doktl = wa_draw-doktl
      AND dokvr = wa_draw-dokvr
      .
    IF sy-subrc NE 0.
      wa_search-doknr = wa_draw-doknr.
      wa_search-dokar = wa_draw-dokar.
      wa_search-doktl = wa_draw-doktl.
      wa_search-dokvr = wa_draw-dokvr.
      APPEND wa_search TO itab_search.
    ELSE.
      APPEND wa_search TO itab_search.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_drawing_from_bom2
*&---------------------------------------------------------------------*
*&      Form  delta_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delta_update.
* Delta Update - Test auf schon vorhandene Kombination von
* LIFNR und DIS im Plotlog
  DATA: index TYPE i.

  CALL FUNCTION '/CIDEON/CHECK_EBELN_SEARCH'
       EXPORTING
            i_wa_user_data    = user_data
            i_wa_default_data = default_data
       TABLES
            itab_search       = itab_search
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " delta_update
*&---------------------------------------------------------------------*
*&      Form  set_ebeln_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_ebeln_selection.
*   Selektion setzen bei Übernahme aus Bestellung etc.
  DATA: index TYPE i.

  IF user_data-check_ebeln_strategy = 'S'.
    CLEAR itab_et_index_rows_searchlist.
    LOOP AT itab_search INTO wa_search.
      IF wa_search-sel_from_ebeln = 'X'.
      ELSE.
        CONTINUE.
      ENDIF.

      index = sy-tabix.
      CLEAR wa_et_index_rows_searchlist.
      wa_et_index_rows_searchlist-index = index.
      APPEND wa_et_index_rows_searchlist TO
        itab_et_index_rows_searchlist.

      CASE user_data-check_ebeln_strategy.
        WHEN 'S'.
*         Tabelle für Selection füllen
          wa_search-sel_from_ebeln = 'X'.
          MODIFY itab_search FROM wa_search INDEX index.
*         Meldung schreiben
          MESSAGE s016(/cideon/plot_basis).
        WHEN 'D'.
*         Löschen
          DELETE itab_search INDEX index.
*         Meldung schreiben
          MESSAGE s015(/cideon/plot_basis).
      ENDCASE.

    ENDLOOP.

    CALL METHOD grid_searchlist->set_selected_rows
       EXPORTING
         it_index_rows = itab_et_index_rows_searchlist
*      IT_ROW_NO     =
        .
  ELSE.
  ENDIF.

ENDFORM.                    " set_ebeln_selection
*&---------------------------------------------------------------------*
*&      Form  get_lieferanten_daten
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_lieferanten_daten.
* holt sich die Daten zu einem Lieferanten

  CALL FUNCTION '/CIDEON/GET_LIFNR_DATA'
       EXPORTING
            i_wa_user_data    = user_data
            i_wa_default_data = default_data
       TABLES
            itab_search       = itab_search
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " get_lieferanten_daten
*&---------------------------------------------------------------------*
*&      Form  change_ebeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_ebeln.
* changes the EBELN
  DATA: ebeln TYPE zcl_s_plotlist-ebeln.
  DATA: wa_tmp_plotlist_aufnr TYPE zcl_s_plotlist.

** neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFA'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

*  IF count_lines = 1.
*    CLEAR wa_tmp_plotlist_aufnr.
*    LOOP AT itab_et_index_rows_plotlist
*       INTO wa_et_index_rows_plotlist.
*      READ TABLE itab_plotjobs INTO wa_tmp_plotlist_aufnr
*        INDEX wa_et_index_rows_plotlist-index.
*    ENDLOOP.
*  ELSE.
*  ENDIF.

  CLEAR ebeln.
  CALL FUNCTION '/CIDEON/ASK_FOR_EBELN'
       IMPORTING
            o_ebeln = ebeln
       EXCEPTIONS
            error   = 1
            forget  = 2
            OTHERS  = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-ebeln = ebeln.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

ENDFORM.                    " change_ebeln
*&---------------------------------------------------------------------*
*&      Form  change_ebeln_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_ebeln_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_ebeln.

ENDFORM.                    " change_ebeln_tree
*&---------------------------------------------------------------------*
*&      Form  change_vendor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_vendor.
* changes the LIFNR / NAME1_LIFNR
  DATA: lifnr TYPE zcl_s_plotlist-lifnr.
  DATA: name1_lifnr TYPE zcl_s_plotlist-name1_lifnr.
  DATA: wa_tmp_plotlist_aufnr TYPE zcl_s_plotlist.

** neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFA'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

*  IF count_lines = 1.
*    CLEAR wa_tmp_plotlist_aufnr.
*    LOOP AT itab_et_index_rows_plotlist
*       INTO wa_et_index_rows_plotlist.
*      READ TABLE itab_plotjobs INTO wa_tmp_plotlist_aufnr
*        INDEX wa_et_index_rows_plotlist-index.
*    ENDLOOP.
*  ELSE.
*  ENDIF.

  CLEAR lifnr.
  CLEAR name1_lifnr.
  CALL FUNCTION '/CIDEON/ASK_FOR_LIFNR'
       IMPORTING
            o_lifnr       = lifnr
            o_name1_lifnr = name1_lifnr
       EXCEPTIONS
            error         = 1
            forget        = 2
            OTHERS        = 3.

  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-lifnr = lifnr.
    wa_plotjobs-name1_lifnr = name1_lifnr.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.


ENDFORM.                    " change_vendor
*&---------------------------------------------------------------------*
*&      Form  change_vendor_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_vendor_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_vendor.

ENDFORM.                    " change_vendor_tree
*&---------------------------------------------------------------------*
*&      Form  change_lif_telnr_long
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_lif_telnr_long.
* changes the LIF_TELNR_LONG
  DATA: lif_telnr_long TYPE zcl_s_plotlist-lif_telnr_long.
  DATA: wa_tmp_plotlist_aufnr TYPE zcl_s_plotlist.

** neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFA'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

*  IF count_lines = 1.
*    CLEAR wa_tmp_plotlist_aufnr.
*    LOOP AT itab_et_index_rows_plotlist
*       INTO wa_et_index_rows_plotlist.
*      READ TABLE itab_plotjobs INTO wa_tmp_plotlist_aufnr
*        INDEX wa_et_index_rows_plotlist-index.
*    ENDLOOP.
*  ELSE.
*  ENDIF.

  CLEAR lif_telnr_long.
  CALL FUNCTION '/CIDEON/ASK_FOR_LIF_TELNR_LONG'
       IMPORTING
            o_lif_telnr_long = lif_telnr_long
       EXCEPTIONS
            error            = 1
            forget           = 2
            OTHERS           = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-lif_telnr_long = lif_telnr_long.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.


ENDFORM.                    " change_lif_telnr_long
*&---------------------------------------------------------------------*
*&      Form  change_lif_telnr_long_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_lif_telnr_long_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_lif_telnr_long.

ENDFORM.                    " change_lif_telnr_long_tree
*&---------------------------------------------------------------------*
*&      Form  change_lif_faxnr_long
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_lif_faxnr_long.
* changes the LIF_FAXNR_LONG
  DATA: lif_faxnr_long TYPE zcl_s_plotlist-lif_faxnr_long.
  DATA: wa_tmp_plotlist_aufnr TYPE zcl_s_plotlist.

** neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFA'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

*  IF count_lines = 1.
*    CLEAR wa_tmp_plotlist_aufnr.
*    LOOP AT itab_et_index_rows_plotlist
*       INTO wa_et_index_rows_plotlist.
*      READ TABLE itab_plotjobs INTO wa_tmp_plotlist_aufnr
*        INDEX wa_et_index_rows_plotlist-index.
*    ENDLOOP.
*  ELSE.
*  ENDIF.

  CLEAR lif_faxnr_long.
  CALL FUNCTION '/CIDEON/ASK_FOR_LIF_FAXNR_LONG'
       IMPORTING
            o_lif_faxnr_long = lif_faxnr_long
       EXCEPTIONS
            error            = 1
            forget           = 2
            OTHERS           = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-lif_faxnr_long = lif_faxnr_long.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

ENDFORM.                    " change_lif_faxnr_long
*&---------------------------------------------------------------------*
*&      Form  change_lif_faxnr_long_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_lif_faxnr_long_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_lif_faxnr_long.

ENDFORM.                    " change_lif_faxnr_long_tree
*&---------------------------------------------------------------------*
*&      Form  change_lif_smtp_addr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_lif_smtp_addr.
* changes the lif_smtp_addr
  DATA: lif_smtp_addr TYPE zcl_s_plotlist-lif_smtp_addr.
  DATA: wa_tmp_plotlist_aufnr TYPE zcl_s_plotlist.

** neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFA'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

*  IF count_lines = 1.
*    CLEAR wa_tmp_plotlist_aufnr.
*    LOOP AT itab_et_index_rows_plotlist
*       INTO wa_et_index_rows_plotlist.
*      READ TABLE itab_plotjobs INTO wa_tmp_plotlist_aufnr
*        INDEX wa_et_index_rows_plotlist-index.
*    ENDLOOP.
*  ELSE.
*  ENDIF.

  CLEAR lif_smtp_addr.
  CALL FUNCTION '/CIDEON/ASK_FOR_LIF_SMTP_ADDR'
       IMPORTING
            o_lif_smtp_addr = lif_smtp_addr
       EXCEPTIONS
            error           = 1
            forget          = 2
            OTHERS          = 3.

  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-lif_smtp_addr = lif_smtp_addr.
    wa_plotjobs-lif_smtp_srch = lif_smtp_addr.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.


ENDFORM.                    " change_lif_smtp_addr
*&---------------------------------------------------------------------*
*&      Form  change_lif_smtp_addr_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_lif_smtp_addr_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_lif_smtp_addr.

ENDFORM.                    " change_lif_smtp_addr_tree
*&---------------------------------------------------------------------*
*&      Form  get_drawing_from_bom3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_drawing_from_bom3.
*  DATA: itab_draw TYPE TABLE OF draw.
  DATA: itab_draw TYPE TABLE OF zcl_s_docsearch.
  DATA: wa_draw TYPE zcl_s_docsearch.

  CLEAR itab_draw.
  CALL FUNCTION '/CIDEON/GET_2D_SPECIAL_MATNR'
       EXPORTING
            i_user_data  = user_data
       TABLES
            io_itab_draw = itab_draw
       EXCEPTIONS
            error        = 1
            OTHERS       = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT itab_draw INTO wa_draw.
    CLEAR wa_search.

    SELECT SINGLE * FROM draw INTO
      CORRESPONDING FIELDS OF wa_search
      WHERE doknr = wa_draw-doknr
      AND dokar = wa_draw-dokar
      AND doktl = wa_draw-doktl
      AND dokvr = wa_draw-dokvr
      .
    IF sy-subrc NE 0.
*      wa_search-doknr = wa_draw-doknr.
*      wa_search-dokar = wa_draw-dokar.
*      wa_search-doktl = wa_draw-doktl.
*      wa_search-dokvr = wa_draw-dokvr.
      wa_search = wa_draw.

      APPEND wa_search TO itab_search.
    ELSE.
      APPEND wa_search TO itab_search.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_drawing_from_bom3
*&---------------------------------------------------------------------*
*&      Form  set_ao_merge
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_ao_merge.
*Setzen des Parameters AO_MERGE
* AO$_MERGE: 0 = kein
*            1 = 1. Wert
*            2 = letzter Wert
*ITAB
*WA
  DATA: return TYPE bapiret2.
  DATA: wa_documentfiles TYPE bapi_doc_files2.
*NORMAL
  DATA: checkout_path TYPE bapi_doc_aux-filename.
  DATA: ausgabe_progress TYPE char100.
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.

** neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTDN'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

*   Setzen des AO_MERGE
* AO$_MERGE: 0 = kein
*            1 = 1. Wert
*            2 = letzter Wert
    wa_plotjobs-ao_merge = '1'.
    MODIFY itab_plotjobs FROM wa_plotjobs INDEX
      wa_et_index_rows_plotlist-index.


    IF akt_dec <> last_dec.
      prozent = akt_dec * 100.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = prozent
                text       = ausgabe_progress.
    ELSE.
    ENDIF.
    last = akt.
    last_dec = akt_dec.

  ENDLOOP.


ENDFORM.                    " set_ao_merge
*&---------------------------------------------------------------------*
*&      Form  make_display_version
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_display_version.
* Aktualisierung der Ikone für Versionen / CDESK
* DIR_STAT_VERS
* Ampel Ikonen
*

  CALL FUNCTION '/CIDEON/MAKE_DISPLAY_VERSION'
       TABLES
            itab_search = itab_search
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


**ICON_4 ICON_GREEN_LIGHT               '@08@'."  Green light; positive
**ICON_4 ICON_YELLOW_LIGHT              '@09@'."  Yellow light; neutral
**ICON_4 ICON_RED_LIGHT                 '@0A@'."  Red light; negative
*
** keine neuere Version -> Grün
** neuere freigegebene Version -> Rot
** neuere nicht freigegebene Version -> Gelb
*
*  DATA: itab_draw TYPE TABLE OF draw.
*  DATA: wa_draw TYPE draw.
*  DATA: lines TYPE i.
*  DATA: frknz TYPE tdws-frknz.
*  DATA: dosar TYPE tdws-dosar.
*
*
*  LOOP AT itab_search INTO wa_search.
*    CLEAR draw.
*    CLEAR itab_draw.
*    SELECT * FROM draw INTO TABLE itab_draw
*      WHERE dokar = wa_search-dokar
*      AND doknr = wa_search-doknr
*      AND doktl = wa_search-doktl
*      AND dokvr > wa_search-dokvr
*      ORDER BY dokvr.
*    IF sy-subrc NE 0.
**     keine neuere -> Grün
*      wa_search-dir_stat_vers = icon_green_light.
*      MODIFY itab_search FROM wa_search INDEX sy-tabix.
*      CONTINUE.
*    ELSE.
*    ENDIF.
*
**   Testen auf mehrere Versionen
*    CLEAR lines.
*    DESCRIBE TABLE itab_draw LINES lines.
*    LOOP AT itab_draw INTO wa_draw.
*      CLEAR frknz.
*      CLEAR dosar.
*
**     Freigabekennzeichen
*      CLEAR frknz.
*      SELECT SINGLE frknz FROM tdws
*        INTO frknz
*        WHERE dokar = wa_draw-dokar
*        AND dokst = wa_draw-dokst
*        .
*      IF sy-subrc NE 0.
*        wa_search-dir_stat_vers = icon_red_light.
*      ELSE.
*        IF frknz = 'X'.
**       ein freigegebenes existiert
*          wa_search-dir_stat_vers = icon_red_light.
*          MODIFY itab_search FROM wa_search INDEX sy-tabix.
*          EXIT.
*        ELSE.
**       kein freigegebenes existiert
*          wa_search-dir_stat_vers = icon_yellow_light.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
*    MODIFY itab_search FROM wa_search INDEX sy-tabix.
*
*  ENDLOOP.
*
**  DATA: frknz TYPE tdws-frknz.
**  DATA: dosar TYPE tdws-dosar.
**
*** Freigabekennzeichen
**  CLEAR frknz.
**  SELECT SINGLE frknz FROM tdws
**    INTO frknz
**    WHERE dokar = i_dokar
**    AND dokst = i_dokst
**    .
**  IF sy-subrc NE 0.
**    RAISE error.
**  ELSE.
**  ENDIF.
**
**  IF frknz = 'X'.
**    RAISE freigabe.
**  ELSE.
**  ENDIF.
**
**
*** Sperrstatus
**  CLEAR dosar.
**  SELECT SINGLE dosar FROM tdws
**    INTO dosar
**    WHERE dokar = i_dokar
**    AND dokst = i_dokst
**    .
**  IF sy-subrc NE 0.
**    RAISE error.
**  ELSE.
**  ENDIF.
**
**  IF dosar = 'S'.
**    RAISE gesperrt.
**  ELSE.
**  ENDIF.


ENDFORM.                    " make_display_version
*&---------------------------------------------------------------------*
*&      Form  map_information_fauf_cs_f
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM map_information_fauf_cs_f.
*   normale Weitergabe von Informationen speziellen Felder des
*   Fertigungsauftrages / CS Auftrages
*   für Fehldokumente

  CALL FUNCTION '/CIDEON/MAP_INFORMATION_FAIL_D'
       EXPORTING
            wa_search_tmp       = wa_search_tmp
       TABLES
            itab_zori_doc_files = itab_fail_document
       EXCEPTIONS
            error               = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " map_information_fauf_cs_f
*&---------------------------------------------------------------------*
*&      Form  set_knz_single_entry_on
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_knz_single_entry_on.
  DATA: wa_zcl_plint_config TYPE zcl_plint_config.

  CLEAR wa_zcl_plint_config.
  SELECT SINGLE * FROM zcl_plint_config
    INTO wa_zcl_plint_config
    WHERE uname = sy-uname
    AND pname = 'KNZ_SINGLE_ENTRY'
    .
  IF sy-subrc NE 0.
    wa_zcl_plint_config-uname = sy-uname.
    wa_zcl_plint_config-pname = 'KNZ_SINGLE_ENTRY'.
    wa_zcl_plint_config-pwert = 'X'.
    wa_zcl_plint_config-zclinsname = sy-uname.
    wa_zcl_plint_config-zclinsdate = sy-datum.
    wa_zcl_plint_config-zclinstime = sy-uzeit.
    wa_zcl_plint_config-zclinsprog = 'ZCL_PLINT_DESIGN_007F13'.
  ELSE.
    wa_zcl_plint_config-pwert = 'X'.
  ENDIF.

  wa_zcl_plint_config-zclupdname = sy-uname.
  wa_zcl_plint_config-zclupddate = sy-datum.
  wa_zcl_plint_config-zclupdtime = sy-uzeit.
  wa_zcl_plint_config-zclupdprog = 'ZCL_PLINT_DESIGN_007F13'.

  MODIFY zcl_plint_config FROM wa_zcl_plint_config.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Erfolgsmeldung
  MESSAGE s000(/cideon/plot_basis)
    WITH '' '' '' ''.
*   Änderung ist erfolgt. & & & &

ENDFORM.                    " set_knz_single_entry_on
*&---------------------------------------------------------------------*
*&      Form  set_knz_single_entry_off
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_knz_single_entry_off.
  DATA: wa_zcl_plint_config TYPE zcl_plint_config.

  CLEAR wa_zcl_plint_config.
  SELECT SINGLE * FROM zcl_plint_config
    INTO wa_zcl_plint_config
    WHERE uname = sy-uname
    AND pname = 'KNZ_SINGLE_ENTRY'
    .
  IF sy-subrc NE 0.
    wa_zcl_plint_config-uname = sy-uname.
    wa_zcl_plint_config-pname = 'KNZ_SINGLE_ENTRY'.
    wa_zcl_plint_config-pwert = ''.
    wa_zcl_plint_config-zclinsname = sy-uname.
    wa_zcl_plint_config-zclinsdate = sy-datum.
    wa_zcl_plint_config-zclinstime = sy-uzeit.
    wa_zcl_plint_config-zclinsprog = 'ZCL_PLINT_DESIGN_007F13'.
  ELSE.
    wa_zcl_plint_config-pwert = g_show_struktur.
  ENDIF.

  wa_zcl_plint_config-zclupdname = sy-uname.
  wa_zcl_plint_config-zclupddate = sy-datum.
  wa_zcl_plint_config-zclupdtime = sy-uzeit.
  wa_zcl_plint_config-zclupdprog = 'ZCL_PLINT_DESIGN_007F13'.

  MODIFY zcl_plint_config FROM wa_zcl_plint_config.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Erfolgsmeldung
  MESSAGE s000(/cideon/plot_basis)
    WITH '' '' '' ''.
*   Änderung ist erfolgt. & & & &

ENDFORM.                    " set_knz_single_entry_off
*&---------------------------------------------------------------------*
*&      Form  show_versions_info_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_versions_info_2.
* Versionsinformationen anzeigen
  DATA: versionsinfo TYPE REF TO /cideon/cl_versionsinfo.

  CREATE OBJECT versionsinfo.
  CALL METHOD versionsinfo->get_info_lvc
    EXPORTING
      objtype = 'REPS'
      objname = 'ZCL_PLINT_DESIGN_007'
      version = text-v00
      .



ENDFORM.                    " show_versions_info_2
*&---------------------------------------------------------------------*
*&      Form  create_toc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_toc.
* Setzen des Kennzeichen für die Erstellung eines Inhalts-
* verzeichnisses
  PERFORM get_selected_entries_plotlist.

  LOOP AT itab_et_index_rows_plotlist
  INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-knz_create_toc = 'X'.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

* Erfolgsmeldung
  MESSAGE s000(/cideon/plot_basis)
    WITH '' '' '' ''.
*   Änderung ist erfolgt. & & & &


ENDFORM.                    " create_toc
*&---------------------------------------------------------------------*
*&      Form  send_toc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_toc.
* Setzen des Kennzeichen für das Senden eines Inhalts-
* verzeichnisses
  PERFORM get_selected_entries_plotlist.

  LOOP AT itab_et_index_rows_plotlist
  INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-knz_send_toc = 'X'.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

* Erfolgsmeldung
  MESSAGE s000(/cideon/plot_basis)
    WITH '' '' '' ''.
*   Änderung ist erfolgt. & & & &

ENDFORM.                    " send_toc
*&---------------------------------------------------------------------*
*&      Form  dont_create_toc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dont_create_toc.
* Löschen des Kennzeichen für die Erstellung eines Inhalts-
* verzeichnisses
  PERFORM get_selected_entries_plotlist.

  LOOP AT itab_et_index_rows_plotlist
  INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-knz_create_toc = ''.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

* Erfolgsmeldung
  MESSAGE s000(/cideon/plot_basis)
    WITH '' '' '' ''.
*   Änderung ist erfolgt. & & & &

ENDFORM.                    " dont_create_toc
*&---------------------------------------------------------------------*
*&      Form  dont_send_toc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dont_send_toc.
* Löschen des Kennzeichen für das Senden eines Inhalts-
* verzeichnisses
  PERFORM get_selected_entries_plotlist.

  LOOP AT itab_et_index_rows_plotlist
  INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-knz_send_toc = ''.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

* Erfolgsmeldung
  MESSAGE s000(/cideon/plot_basis)
    WITH '' '' '' ''.
*   Änderung ist erfolgt. & & & &

ENDFORM.                    " dont_send_toc
*&---------------------------------------------------------------------*
*&      Form  get_selected_entries_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_entries_plotlist.
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

ENDFORM.                    " get_selected_entries_plotlist
*&---------------------------------------------------------------------*
*&      Form  read_queue
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_queue.
* lesen der Übergabe Queue
  DATA: it_search LIKE itab_search.

*  break kuechler.

  CLEAR it_search.

  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.

  CALL FUNCTION '/CIDEON/READ_STORED_SEARCH'
       EXPORTING
            i_wa_user_data    = user_data
            i_wa_default_data = default_data
       TABLES
            itab_search       = it_search
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT it_search INTO wa_search.
    APPEND wa_search TO itab_search.
  ENDLOOP.

  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.

ENDFORM.                    " read_queue
*&---------------------------------------------------------------------*
*&      Form  get_DO_FROM_MATERLIALIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_do_from_materlialist.


ENDFORM.                    " get_DO_FROM_MATERLIALIST
*&---------------------------------------------------------------------*
*&      Form  get_DO_FROM_MATERLIAlLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_do_from_materliallist.
* Dokumenten von der Materialliste lesen

  DATA: itab_draw TYPE TABLE OF zcl_s_docsearch.
  DATA: wa_draw TYPE zcl_s_docsearch.

  CLEAR itab_draw.

  CALL FUNCTION '/CIDEON/READ_MATERIAL_LIST'
       TABLES
            o_itab_search = itab_draw
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT itab_draw INTO wa_draw.
    CLEAR wa_search.

    SELECT SINGLE * FROM draw INTO
      CORRESPONDING FIELDS OF wa_search
      WHERE doknr = wa_draw-doknr
      AND dokar = wa_draw-dokar
      AND doktl = wa_draw-doktl
      AND dokvr = wa_draw-dokvr
      .
    IF sy-subrc NE 0.
*      wa_search-doknr = wa_draw-doknr.
*      wa_search-dokar = wa_draw-dokar.
*      wa_search-doktl = wa_draw-doktl.
*      wa_search-dokvr = wa_draw-dokvr.
      wa_search = wa_draw.

      APPEND wa_search TO itab_search.
    ELSE.
      APPEND wa_search TO itab_search.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_DO_FROM_MATERLIAlLIST
