*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_001F01                                    *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_data_for_search_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_for_search_list.
  REFRESH itab_search_tmp.

  PERFORM search_tmp_to_draw.


  DATA: f_skip.
  CLEAR f_skip.

  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CALL METHOD badi_main_pre_001->chg_dialog_cv04n
      CHANGING
        f_skip  = f_skip
        lt_draw = itab_draw
        .
  ENDIF.

  IF f_skip = 'X'.
  ELSE.
    CALL FUNCTION 'CV100_DOC_SEARCH'
     EXPORTING
       pf_cv04_list_type       = '2'
*    PF_WEB_LIST_TYPE        =
       api_flag                = 'X'
     TABLES
       ptx_draw                = itab_draw
      .
  ENDIF.

  PERFORM draw_to_search_tmp.

  CLEAR wa_search_tmp.
  CLEAR wa_search.

*  perform add_dttrg_to_search.
  LOOP AT itab_search_tmp INTO wa_search_tmp.
    MOVE-CORRESPONDING wa_search_tmp TO wa_search.
    APPEND wa_search TO itab_search.
  ENDLOOP.

ENDFORM.                    " get_data_for_search_list
*&---------------------------------------------------------------------*
*&      Form  save_wa_akt_plotjobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_wa_akt_plotjobs.
* Saves the WA
  DATA: wa_old_plotjob LIKE wa_akt_plotjobs.


  IF wa_akt_plotjobs IS INITIAL.
    EXIT.
  ELSE.
    IF NOT wa_akt_plotjobs-dokar IS INITIAL
      AND NOT wa_akt_plotjobs-doknr IS INITIAL
      AND NOT wa_akt_plotjobs-dokvr IS INITIAL
      AND NOT wa_akt_plotjobs-doktl IS INITIAL
      .
      PERFORM change_kompression.

      IF wa_akt_plotjobs-kopien IS INITIAL.
        READ TABLE itab_plotjobs INTO wa_old_plotjob
          INDEX index_itab_plotjobs.
        wa_akt_plotjobs-kopien = wa_old_plotjobs-kopien.
      ELSE.
      ENDIF.

      READ TABLE itab_plotjobs INTO wa_old_plotjob
        INDEX index_itab_plotjobs.

      IF wa_akt_plotjobs-verteiler IS INITIAL.
        wa_akt_plotjobs-verteiler = wa_old_plotjobs-verteiler.
      ELSE.
      ENDIF.

*     Nur zugelassener Verteiler soll wählbar sein
      PERFORM check_verteiler_on_update
        CHANGING wa_old_plotjob.

      MODIFY itab_plotjobs FROM wa_akt_plotjobs
        INDEX index_itab_plotjobs.

      IF ok_code = 'NODE_DOUBLE_CLICK'.
      ELSE.
        PERFORM refresh_joblist.
      ENDIF.
    ELSE.
    ENDIF.
  ENDIF.
ENDFORM.                    " save_wa_akt_plotjobs
*&---------------------------------------------------------------------*
*&      Form  change_priotity
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_priority.
* change for the selected lines in the plot grid the priority
* get the selected line in the plot ALV
  REFRESH itab_et_index_rows_plotlist.
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
  ELSE.
    LOOP AT itab_et_index_rows_plotlist
      INTO wa_et_index_rows_plotlist.
      CLEAR wa_akt_plotjobs.
      READ TABLE itab_plotjobs
        INTO wa_akt_plotjobs INDEX wa_et_index_rows_plotlist.
      wa_akt_plotjobs-prio = g_prio.
      MODIFY itab_plotjobs FROM wa_akt_plotjobs
        INDEX wa_et_index_rows_plotlist.
    ENDLOOP.
  ENDIF.

  CLEAR wa_akt_plotjobs.

ENDFORM.                    " change_priotity
*&---------------------------------------------------------------------*
*&      Form  change_priotity_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_priority_node.
* try to change Items from Plottree
* try to get the double clicked node
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).
  DATA: itab_tree_source TYPE treemsnota.
  DATA: itab_found_1 TYPE treemsnota.
  DATA: itab_found_2 TYPE treemsnota.
  DATA: itab_result TYPE treemsnota.
  DATA: wa_tree_source TYPE treemsnodt.
  DATA: wa_found_1 TYPE treemsnodt.
  DATA: wa_found_2 TYPE treemsnodt.
  DATA: wa_result TYPE treemsnodt.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  node_key = g_node_key.
  CLEAR properties.

  CALL METHOD simple_tree_plotlist->node_get_properties
    EXPORTING
      node_key       = node_key
    IMPORTING
      properties     = properties
    EXCEPTIONS
      node_not_found = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE i055(zcl_plint_message_01)
        WITH node_key ''  '' ''.
    CLEAR properties.
    EXIT.
  ELSE.
    IF properties-isfolder = 'X'.
*     try to get the tree
      REFRESH itab_tree_source.
      REFRESH itab_found_1.
      REFRESH itab_found_2.
      CALL METHOD simple_tree_plotlist->get_tree
        IMPORTING
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      LOOP AT itab_tree_source INTO wa_tree_source
        WHERE relatkey = node_key.
        APPEND wa_tree_source TO itab_found_1 .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     second step
*     copy
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     third step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fourth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fifth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.

      REFRESH itab_et_index_rows_plotlist.
      CLEAR wa_et_index_rows_plotlist.
      LOOP AT itab_result INTO wa_result.
        SPLIT wa_result-node_key AT '' INTO text1 text2.
        index_itab_plotjobs_tmp = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs_tmp.
        APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.
      ENDLOOP.
      SORT itab_et_index_rows_plotlist BY index DESCENDING.
      LOOP AT itab_et_index_rows_plotlist
        INTO wa_et_index_rows_plotlist.
        READ TABLE itab_plotjobs INDEX wa_et_index_rows_plotlist
          INTO wa_plotjobs.
        wa_plotjobs-prio = g_prio.
        MODIFY itab_plotjobs INDEX wa_et_index_rows_plotlist
          FROM wa_plotjobs.
      ENDLOOP.

      EXIT.
    ELSE.
*     try to get the whole Information
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs_tmp = text1.
      READ TABLE itab_plotjobs INDEX index_itab_plotjobs_tmp
        INTO wa_plotjobs.
      wa_plotjobs-prio = g_prio.
      MODIFY itab_plotjobs INDEX index_itab_plotjobs_tmp
        FROM wa_plotjobs.

    ENDIF.
  ENDIF.



ENDFORM.                    " change_priotity_node
*&---------------------------------------------------------------------*
*&      Form  plotlist_up_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM plotlist_up_one_item.
  DATA: i TYPE i.
  DATA: j TYPE i.
  DATA: old_position TYPE i.
  DATA: new_position TYPE i.
  DATA: f_exit.
  CLEAR f_exit.
* get the selected lines in the plotjob ALV
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
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
  ELSE.
    READ TABLE itab_et_index_rows_plotlist
      INTO wa_et_index_rows_plotlist INDEX 1.
    i =   wa_et_index_rows_plotlist-index - 1.
    old_position = wa_et_index_rows_plotlist-index - 1.

    LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
      j = i + 1.
      IF j = wa_et_index_rows_plotlist-index.
      ELSE.
        MESSAGE i040(zcl_plint_message_01)
          WITH '' '' '' ''.
        EXIT.
      ENDIF.
      i = i + 1.
    ENDLOOP.
    IF f_exit = 'X'.
      EXIT.
    ENDIF.

    new_position = wa_et_index_rows_plotlist-index.
    READ TABLE itab_plotjobs INTO wa_akt_plotjobs INDEX old_position.
    IF sy-subrc NE 0.
      MESSAGE i041(zcl_plint_message_01)
        WITH '' '' '' ''.
      EXIT.
    ELSE.
      DELETE itab_plotjobs INDEX old_position.
      INSERT wa_akt_plotjobs INTO itab_plotjobs INDEX new_position.
    ENDIF.


  ENDIF.


ENDFORM.                    " plotlist_up_one_item
*&---------------------------------------------------------------------*
*&      Form  plotlist_down_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM plotlist_down_one_item.
  DATA: i TYPE i.
  DATA: j TYPE i.
  DATA: old_position TYPE i.
  DATA: new_position TYPE i.
  DATA: f_exit.
  CLEAR f_exit.
* get the selected lines in the plotjob ALV
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
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
  ELSE.
    READ TABLE itab_et_index_rows_plotlist
      INTO wa_et_index_rows_plotlist INDEX 1.
    i =   wa_et_index_rows_plotlist-index - 1.
    new_position = wa_et_index_rows_plotlist-index.

    LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
      j = i + 1.
      IF j = wa_et_index_rows_plotlist-index.
      ELSE.
        MESSAGE i040(zcl_plint_message_01)
          WITH '' '' '' ''.
        EXIT.
      ENDIF.
      i = i + 1.
    ENDLOOP.
    IF f_exit = 'X'.
      EXIT.
    ENDIF.
    old_position = wa_et_index_rows_plotlist-index + 1.

    READ TABLE itab_plotjobs INTO wa_akt_plotjobs INDEX old_position.
    IF sy-subrc NE 0.
      MESSAGE i041(zcl_plint_message_01)
        WITH '' '' '' ''.
      EXIT.
    ELSE.
      DELETE itab_plotjobs INDEX old_position.
      INSERT wa_akt_plotjobs INTO itab_plotjobs INDEX new_position.
    ENDIF.


  ENDIF.


ENDFORM.                    " plotlist_down_one_item
*&---------------------------------------------------------------------*
*&      Form  plottree_up_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM plottree_up_one_item.
* try to change Items from Plottree
* try to get the double clicked node
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).
  DATA: itab_tree_source TYPE treemsnota.
  DATA: itab_found_1 TYPE treemsnota.
  DATA: itab_found_2 TYPE treemsnota.
  DATA: itab_result TYPE treemsnota.
  DATA: wa_tree_source TYPE treemsnodt.
  DATA: wa_found_1 TYPE treemsnodt.
  DATA: wa_found_2 TYPE treemsnodt.
  DATA: wa_result TYPE treemsnodt.

  DATA: i TYPE i.
  DATA: j TYPE i.
  DATA: old_position TYPE i.
  DATA: new_position TYPE i.
  DATA: f_exit.
  CLEAR f_exit.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  node_key = g_node_key.
  CLEAR properties.

  CALL METHOD simple_tree_plotlist->node_get_properties
    EXPORTING
      node_key       = node_key
    IMPORTING
      properties     = properties
    EXCEPTIONS
      node_not_found = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE i055(zcl_plint_message_01)
        WITH node_key ''  '' ''.
    CLEAR properties.
    EXIT.
  ELSE.
    IF properties-isfolder = 'X'.
*     try to get the tree
      REFRESH itab_tree_source.
      REFRESH itab_found_1.
      REFRESH itab_found_2.
      CALL METHOD simple_tree_plotlist->get_tree
        IMPORTING
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      LOOP AT itab_tree_source INTO wa_tree_source
        WHERE relatkey = node_key.
        APPEND wa_tree_source TO itab_found_1 .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     second step
*     copy
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     third step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fourth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fifth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.

      REFRESH itab_et_index_rows_plotlist.
      CLEAR wa_et_index_rows_plotlist.
      LOOP AT itab_result INTO wa_result.
        SPLIT wa_result-node_key AT '' INTO text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.
      ENDLOOP.

      REFRESH itab_tmp_plotjobs.
      READ TABLE itab_et_index_rows_plotlist
        INTO wa_et_index_rows_plotlist INDEX 1.
      i =   wa_et_index_rows_plotlist-index - 1.
      old_position = wa_et_index_rows_plotlist-index - 1.

      LOOP AT itab_et_index_rows_plotlist
        INTO wa_et_index_rows_plotlist.
        j = i + 1.
        IF j = wa_et_index_rows_plotlist-index.
        ELSE.
          MESSAGE i040(zcl_plint_message_01)
            WITH '' '' '' ''.
          EXIT.
        ENDIF.
        i = i + 1.
      ENDLOOP.
      IF f_exit = 'X'.
        EXIT.
      ENDIF.

      new_position = wa_et_index_rows_plotlist-index.
      READ TABLE itab_plotjobs INTO wa_akt_plotjobs INDEX old_position.
      IF sy-subrc NE 0.
        MESSAGE i041(zcl_plint_message_01)
          WITH '' '' '' ''.
        EXIT.
      ELSE.
        DELETE itab_plotjobs INDEX old_position.
        INSERT wa_akt_plotjobs INTO itab_plotjobs INDEX new_position.
      ENDIF.
    ELSE.
*     try to get the whole Information
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs = text1.
      READ TABLE itab_plotjobs INDEX index_itab_plotjobs
        INTO wa_akt_plotjobs.
      IF sy-subrc NE 0.
        MESSAGE i041(zcl_plint_message_01)
          WITH '' '' '' ''.
        EXIT.
      ELSE.
        DELETE itab_plotjobs INDEX index_itab_plotjobs.
        index_itab_plotjobs = index_itab_plotjobs - 1.
        INSERT wa_akt_plotjobs INTO itab_plotjobs
          INDEX index_itab_plotjobs .
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " plottree_up_one_item
*&---------------------------------------------------------------------*
*&      Form  plottree_down_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM plottree_down_one_item.
* try to change Items from Plottree
* try to get the double clicked node
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).
  DATA: itab_tree_source TYPE treemsnota.
  DATA: itab_found_1 TYPE treemsnota.
  DATA: itab_found_2 TYPE treemsnota.
  DATA: itab_result TYPE treemsnota.
  DATA: wa_tree_source TYPE treemsnodt.
  DATA: wa_found_1 TYPE treemsnodt.
  DATA: wa_found_2 TYPE treemsnodt.
  DATA: wa_result TYPE treemsnodt.

  DATA: i TYPE i.
  DATA: j TYPE i.
  DATA: old_position TYPE i.
  DATA: new_position TYPE i.
  DATA: f_exit.
  CLEAR f_exit.


  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  node_key = g_node_key.
  CLEAR properties.

  CALL METHOD simple_tree_plotlist->node_get_properties
    EXPORTING
      node_key       = node_key
    IMPORTING
      properties     = properties
    EXCEPTIONS
      node_not_found = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE i055(zcl_plint_message_01)
        WITH node_key ''  '' ''.
    CLEAR properties.
    EXIT.
  ELSE.
    IF properties-isfolder = 'X'.
*     try to get the tree
      REFRESH itab_tree_source.
      REFRESH itab_found_1.
      REFRESH itab_found_2.
      CALL METHOD simple_tree_plotlist->get_tree
        IMPORTING
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      LOOP AT itab_tree_source INTO wa_tree_source
        WHERE relatkey = node_key.
        APPEND wa_tree_source TO itab_found_1 .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     second step
*     copy
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     third step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fourth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fifth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.

      REFRESH itab_et_index_rows_plotlist.
      CLEAR wa_et_index_rows_plotlist.
      LOOP AT itab_result INTO wa_result.
        SPLIT wa_result-node_key AT '' INTO text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.
      ENDLOOP.

      REFRESH itab_tmp_plotjobs.
      READ TABLE itab_et_index_rows_plotlist
        INTO wa_et_index_rows_plotlist INDEX 1.
      i =   wa_et_index_rows_plotlist-index - 1.
      new_position = wa_et_index_rows_plotlist-index.

     LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
        j = i + 1.
        IF j = wa_et_index_rows_plotlist-index.
        ELSE.
          MESSAGE i040(zcl_plint_message_01)
            WITH '' '' '' ''.
          EXIT.
        ENDIF.
        i = i + 1.
      ENDLOOP.
      IF f_exit = 'X'.
        EXIT.
      ENDIF.
      old_position = wa_et_index_rows_plotlist-index + 1.

      READ TABLE itab_plotjobs INTO wa_akt_plotjobs INDEX old_position.
      IF sy-subrc NE 0.
        MESSAGE i041(zcl_plint_message_01)
          WITH '' '' '' ''.
        EXIT.
      ELSE.
        DELETE itab_plotjobs INDEX old_position.
        INSERT wa_akt_plotjobs INTO itab_plotjobs INDEX new_position.
      ENDIF.
    ELSE.
*     try to get the whole Information
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs = text1.
      READ TABLE itab_plotjobs INDEX index_itab_plotjobs
        INTO wa_akt_plotjobs.
      IF sy-subrc NE 0.
        MESSAGE i041(zcl_plint_message_01)
          WITH '' '' '' ''.
        EXIT.
      ELSE.
        DELETE itab_plotjobs INDEX index_itab_plotjobs.
        index_itab_plotjobs = index_itab_plotjobs + 1.
        INSERT wa_akt_plotjobs INTO itab_plotjobs
          INDEX index_itab_plotjobs .
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.                    " plottree_down_one_item
*&---------------------------------------------------------------------*
*&      Form  copy_in_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_in_plotlist.
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  REFRESH itab_copy_cut_plotjobs.
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
  ELSE.
    SORT itab_et_index_rows_plotlist BY index ASCENDING.
    LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
      READ TABLE itab_plotjobs INTO wa_akt_plotjobs
        INDEX wa_et_index_rows_plotlist-index.
      APPEND wa_akt_plotjobs TO itab_copy_cut_plotjobs .
    ENDLOOP.
    f_paste = 'X'.
  ENDIF.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
ENDFORM.                    " copy_in_plotlist
*&---------------------------------------------------------------------*
*&      Form  cut_in_plotList
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cut_in_plotlist.
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
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
  ELSE.
    REFRESH itab_copy_cut_plotjobs.
    SORT itab_et_index_rows_plotlist BY index DESCENDING.
    LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
      READ TABLE itab_plotjobs INTO wa_akt_plotjobs
        INDEX wa_et_index_rows_plotlist-index.
*      APPEND wa_akt_plotjobs TO itab_copy_cut_plotjobs .
      INSERT wa_akt_plotjobs INTO itab_copy_cut_plotjobs INDEX 1.
      DELETE itab_plotjobs INDEX wa_et_index_rows_plotlist-index.
    ENDLOOP.
    f_paste = 'X'.
  ENDIF.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
ENDFORM.                    " cut_in_plotList
*&---------------------------------------------------------------------*
*&      Form  paste_in_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM paste_in_plotlist.
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines <> 1.
    IF itab_plotjobs[] IS INITIAL.
      INSERT LINES OF itab_copy_cut_plotjobs INTO
        itab_plotjobs INDEX 1.
    ELSE.
      MESSAGE e003(zcl_plint_message_01)
        WITH '' '' '' ''.
      EXIT.
    ENDIF.
    REFRESH itab_et_index_rows_plotlist.
  ELSE.
    IF itab_copy_cut_plotjobs[] IS INITIAL.
      MESSAGE e004(zcl_plint_message_01)
        WITH '' '' '' ''.
      EXIT.
    ELSE.
      READ TABLE itab_et_index_rows_plotlist
        INTO wa_et_index_rows_plotlist INDEX 1.
      IF sy-subrc NE 0.
      ELSE.
        INSERT LINES OF itab_copy_cut_plotjobs INTO
          itab_plotjobs INDEX wa_et_index_rows_plotlist-index.
      ENDIF.
    ENDIF.
  ENDIF.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
ENDFORM.                    " paste_in_plotlist
*&---------------------------------------------------------------------*
*&      Form  copy_in_plottree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_in_plottree.
  PERFORM get_sel_tree.
  IF f_error IS INITIAL.
  ELSE.
    CLEAR f_error.
    EXIT.
  ENDIF.
  REFRESH itab_tmp_plotjobs.
*  REFRESH itab_et_index_rows_plotlist.
  REFRESH itab_copy_cut_plotjobs.
  CLEAR f_paste.
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
  ELSE.
    REFRESH itab_copy_cut_plotjobs.
    SORT itab_et_index_rows_plotlist BY index ASCENDING.
    LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist
.
      READ TABLE itab_plotjobs INTO wa_akt_plotjobs
        INDEX wa_et_index_rows_plotlist-index.
      APPEND wa_akt_plotjobs TO itab_copy_cut_plotjobs .
    ENDLOOP.
    f_paste = 'X'.
  ENDIF.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.

ENDFORM.                    " copy_in_plottree
*&---------------------------------------------------------------------*
*&      Form  get_sel_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sel_tree.
* try to get the selected tree items
* give the index_list back
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).
  DATA: itab_tree_source TYPE treemsnota.
  DATA: itab_found_1 TYPE treemsnota.
  DATA: itab_found_2 TYPE treemsnota.
  DATA: itab_result TYPE treemsnota.
  DATA: wa_tree_source TYPE treemsnodt.
  DATA: wa_found_1 TYPE treemsnodt.
  DATA: wa_found_2 TYPE treemsnodt.
  DATA: wa_result TYPE treemsnodt.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  node_key = g_node_key.
  CLEAR properties.

  CALL METHOD simple_tree_plotlist->node_get_properties
    EXPORTING
      node_key       = node_key
    IMPORTING
      properties     = properties
    EXCEPTIONS
      node_not_found = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE i055(zcl_plint_message_01)
        WITH node_key ''  '' ''.
    CLEAR properties.
    f_error = 'X'.
    EXIT.
  ELSE.
    IF properties-isfolder = 'X'.
*     try to get the tree
      REFRESH itab_tree_source.
      REFRESH itab_found_1.
      REFRESH itab_found_2.
      CALL METHOD simple_tree_plotlist->get_tree
        IMPORTING
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      LOOP AT itab_tree_source INTO wa_tree_source
        WHERE relatkey = node_key.
        APPEND wa_tree_source TO itab_found_1 .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     second step
*     copy
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     third step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fourth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fifth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.

      REFRESH itab_et_index_rows_plotlist.
      CLEAR wa_et_index_rows_plotlist.
      LOOP AT itab_result INTO wa_result.
        SPLIT wa_result-node_key AT '' INTO text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.
      ENDLOOP.
      EXIT.
    ELSE.
*    try to get the whole information
      REFRESH itab_et_index_rows_plotlist.
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs = text1.
      wa_et_index_rows_plotlist-index = index_itab_plotjobs.
      APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.
    ENDIF.
  ENDIF.


ENDFORM.                    " get_sel_tree
*&---------------------------------------------------------------------*
*&      Form  cut_in_plottree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cut_in_plottree.
  PERFORM get_sel_tree.
  IF f_error IS INITIAL.
  ELSE.
    CLEAR f_error.
    EXIT.
  ENDIF.
  REFRESH itab_tmp_plotjobs.
*  REFRESH itab_et_index_rows_plotlist.
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
  ELSE.
    REFRESH itab_copy_cut_plotjobs.
    SORT itab_et_index_rows_plotlist BY index DESCENDING.
    LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
      READ TABLE itab_plotjobs INTO wa_akt_plotjobs
        INDEX wa_et_index_rows_plotlist-index.
*      APPEND wa_akt_plotjobs TO itab_copy_cut_plotjobs .
      INSERT wa_akt_plotjobs INTO itab_copy_cut_plotjobs INDEX 1.
      DELETE itab_plotjobs INDEX wa_et_index_rows_plotlist-index.
    ENDLOOP.
    f_paste = 'X'.
  ENDIF.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
ENDFORM.                    " cut_in_plottree
*&---------------------------------------------------------------------*
*&      Form  paste_in_plottree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM paste_in_plottree.
  PERFORM get_sel_tree.
  IF f_error IS INITIAL.
  ELSE.
    CLEAR f_error.
    EXIT.
  ENDIF.
  REFRESH itab_tmp_plotjobs.
*  REFRESH itab_et_index_rows_plotlist.
*  CALL METHOD grid_plotlist->get_selected_rows
*    IMPORTING
*      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
*  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines <> 1.
*    REFRESH itab_et_index_rows_plotlist.
*    MESSAGE e003(zcl_plint_message_01)
*      WITH '' '' '' ''.
*    EXIT.
    READ TABLE itab_et_index_rows_plotlist
      INTO wa_et_index_rows_plotlist INDEX 1.
    INSERT LINES OF itab_copy_cut_plotjobs INTO
      itab_plotjobs INDEX wa_et_index_rows_plotlist-index.
  ELSE.
    IF itab_copy_cut_plotjobs[] IS INITIAL.
      MESSAGE e004(zcl_plint_message_01)
        WITH '' '' '' ''.
      EXIT.
    ELSE.
      READ TABLE itab_et_index_rows_plotlist
        INTO wa_et_index_rows_plotlist INDEX 1.
      IF sy-subrc NE 0.
      ELSE.
        INSERT LINES OF itab_copy_cut_plotjobs INTO
          itab_plotjobs INDEX wa_et_index_rows_plotlist-index.
      ENDIF.
    ENDIF.
  ENDIF.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
ENDFORM.                    " paste_in_plottree
*&---------------------------------------------------------------------*
*&      Form  maintain_CFG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_cfg.
  CALL TRANSACTION 'Z_CL_MNTN_CONFIG'.
ENDFORM.                    " maintain_CFG
*&---------------------------------------------------------------------*
*&      Form  maintain_applictypes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_applictypes.
  CALL TRANSACTION 'Z_CL_MNTN_USR_TDWP'.
ENDFORM.                    " maintain_applictypes
*&---------------------------------------------------------------------*
*&      Form  maintain_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_layout.

ENDFORM.                    " maintain_layout
*&---------------------------------------------------------------------*
*&      Form  maintain_views
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_views.
  CALL TRANSACTION 'Z_CL_MNTN_USR_VIEW'.
ENDFORM.                    " maintain_views
*&---------------------------------------------------------------------*
*&      Form  view_appl_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_appl_log.
*  CALL FUNCTION 'Z_CL_APPL_LOG_READ'
*            .
  CALL FUNCTION 'Z_CL_APPL_LOG_READ_T_DISPLAY'
    EXPORTING
      i_date        = sy-datum
      i_time        = sy-uzeit
*     I_DIFF        = '0600'
            .


ENDFORM.                    " view_appl_log
*&---------------------------------------------------------------------*
*&      Form  change_job_properties
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_job_properties.
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
  ELSE.
    SORT itab_et_index_rows_plotlist BY index ASCENDING.
    CASE tbstcrt_plotlist-activetab.
      WHEN 'TAB1_PL'.
*      Anzahl Kopien, Notizen, Voreinstellung, Verteiler
        LOOP AT itab_et_index_rows_plotlist
          INTO wa_et_index_rows_plotlist.
          READ TABLE itab_plotjobs INTO wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index.
*         Kopien
          IF  wa_akt_plotjobs-kopien IS INITIAL.
          ELSE.
            wa_plotjobs-kopien = wa_akt_plotjobs-kopien.
          ENDIF.
*         Notiz
          IF wa_akt_plotjobs-notiz IS INITIAL.
          ELSE.
            wa_plotjobs-notiz = wa_akt_plotjobs-notiz.
          ENDIF.
*         Voreinstellung
          IF wa_akt_plotjobs-voreinstellung IS INITIAL.
          ELSE.
            wa_plotjobs-voreinstellung = wa_akt_plotjobs-voreinstellung.
          ENDIF.
*         Verteiler
          IF wa_akt_plotjobs-verteiler IS INITIAL.
          ELSE.
*           Nur zugelassener Verteiler soll wählbar sein
            PERFORM check_verteiler_on_update
              CHANGING wa_plotjobs.
            wa_plotjobs-verteiler = wa_akt_plotjobs-verteiler.
          ENDIF.

          MODIFY itab_plotjobs FROM wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index..
        ENDLOOP.
      WHEN 'TAB2_PL'.
*       Zielformat, SkalierenX, SkaliernY, Drehwinkel, AusgabeSpiegeln
*       Seite, Seite_von, Seite_bis
        LOOP AT itab_et_index_rows_plotlist
          INTO wa_et_index_rows_plotlist.
          READ TABLE itab_plotjobs INTO wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index.
          wa_plotjobs-zielformat = wa_akt_plotjobs-zielformat.
          wa_plotjobs-skalieren_x = wa_akt_plotjobs-skalieren_x.
          wa_plotjobs-skalieren_y = wa_akt_plotjobs-skalieren_y.
          wa_plotjobs-spiegeln = wa_akt_plotjobs-spiegeln.
          wa_plotjobs-seite = wa_akt_plotjobs-seite.
          wa_plotjobs-seite_von = wa_akt_plotjobs-seite_von.
          wa_plotjobs-seite_bis = wa_akt_plotjobs-seite_bis.
          MODIFY itab_plotjobs FROM wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index..
        ENDLOOP.
      WHEN 'TAB3_PL'.
*       Stempel, Format, Ausrichtung, Ausgabetyp, Stifttabelle
        LOOP AT itab_et_index_rows_plotlist
          INTO wa_et_index_rows_plotlist.
          READ TABLE itab_plotjobs INTO wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index.
          wa_plotjobs-stempel = wa_akt_plotjobs-stempel.
          wa_plotjobs-format_ausgabe = wa_akt_plotjobs-format_ausgabe.
          wa_plotjobs-ausrichtung = wa_akt_plotjobs-ausrichtung.
          wa_plotjobs-typ = wa_akt_plotjobs-typ.
          wa_plotjobs-stifttabelle = wa_akt_plotjobs-stifttabelle.
          MODIFY itab_plotjobs FROM wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index..
        ENDLOOP.
      WHEN 'TAB4_PL'.
*       Lochen, Falten, Heftrand
        LOOP AT itab_et_index_rows_plotlist
          INTO wa_et_index_rows_plotlist.
          READ TABLE itab_plotjobs INTO wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index.
          wa_plotjobs-lochen = wa_akt_plotjobs-lochen.
          wa_plotjobs-falten = wa_akt_plotjobs-falten.
          wa_plotjobs-heftrand = wa_akt_plotjobs-heftrand.
          MODIFY itab_plotjobs FROM wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index..
        ENDLOOP.
      WHEN 'TAB5_PL'.
*       Satzanzahl, Deckblatt, Endeblatt, Inhaltsverzeichnis
*       Inhaltsblatt
        LOOP AT itab_et_index_rows_plotlist
          INTO wa_et_index_rows_plotlist.
          READ TABLE itab_plotjobs INTO wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index.
          wa_plotjobs-satzanzahl = wa_akt_plotjobs-satzanzahl.
          wa_plotjobs-deckblatt = wa_akt_plotjobs-deckblatt.
          wa_plotjobs-endeblatt = wa_akt_plotjobs-endeblatt.
          wa_plotjobs-knz_inhalt_vz =
            wa_akt_plotjobs-knz_inhalt_vz.
          wa_plotjobs-inhaltsblatt = wa_akt_plotjobs-inhaltsblatt.
          MODIFY itab_plotjobs FROM wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index..
        ENDLOOP.
      WHEN 'TAB6_PL'.
*       Verkaufsbelegnummer, Auftragsnummer,
        LOOP AT itab_et_index_rows_plotlist
          INTO wa_et_index_rows_plotlist.
          READ TABLE itab_plotjobs INTO wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index.
*         VBELn
          IF wa_akt_plotjobs-vbeln IS INITIAL.
          ELSE.
            wa_plotjobs-vbeln = wa_akt_plotjobs-vbeln.
          ENDIF.
*         AUFNR
          IF wa_akt_plotjobs-aufnr IS INITIAL.
          ELSE.
            wa_plotjobs-aufnr = wa_akt_plotjobs-aufnr.
          ENDIF.
*         FIRMA
          IF wa_akt_plotjobs-firma IS INITIAL.
          ELSE.
            wa_plotjobs-firma = wa_akt_plotjobs-firma.
          ENDIF.
*         KOSTL
          IF wa_akt_plotjobs-kostl IS INITIAL.
          ELSE.
            wa_plotjobs-kostl = wa_akt_plotjobs-kostl.
          ENDIF.
*         PSPID
          IF wa_akt_plotjobs-pspid IS INITIAL.
          ELSE.
            wa_plotjobs-pspid = wa_akt_plotjobs-pspid.
          ENDIF.
*         ID_PLOTJOB
          IF wa_akt_plotjobs-id_plotjob IS INITIAL.
          ELSE.
            wa_plotjobs-id_plotjob = wa_akt_plotjobs-id_plotjob.
          ENDIF.
*         EBELN
          IF wa_akt_plotjobs-ebeln IS INITIAL.
          ELSE.
            wa_plotjobs-ebeln = wa_akt_plotjobs-ebeln.
          ENDIF.
*         LIFNR
          IF wa_akt_plotjobs-lifnr IS INITIAL.
          ELSE.
            wa_plotjobs-lifnr = wa_akt_plotjobs-lifnr.
          ENDIF.
*         NAME1_LIFNR
          IF wa_akt_plotjobs-name1_lifnr IS INITIAL.
          ELSE.
            wa_plotjobs-name1_lifnr = wa_akt_plotjobs-name1_lifnr.
          ENDIF.

          MODIFY itab_plotjobs FROM wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index..
        ENDLOOP.
      WHEN 'TAB7_PL'.
*       Lieferantendaten
        LOOP AT itab_et_index_rows_plotlist
          INTO wa_et_index_rows_plotlist.
          READ TABLE itab_plotjobs INTO wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index.
*         EBELN
          IF wa_akt_plotjobs-ebeln IS INITIAL.
          ELSE.
            wa_plotjobs-ebeln = wa_akt_plotjobs-ebeln.
          ENDIF.
*         LIFNR
          IF wa_akt_plotjobs-lifnr IS INITIAL.
          ELSE.
            wa_plotjobs-lifnr = wa_akt_plotjobs-lifnr.
          ENDIF.
*         NAME1_LIFNR
          IF wa_akt_plotjobs-name1_lifnr IS INITIAL.
          ELSE.
            wa_plotjobs-name1_lifnr = wa_akt_plotjobs-name1_lifnr.
          ENDIF.
*         LIF_FAXNR_LONG
          IF wa_akt_plotjobs-lif_faxnr_long IS INITIAL.
          ELSE.
            wa_plotjobs-lif_faxnr_long = wa_akt_plotjobs-lif_faxnr_long.
          ENDIF.
*         LIF_TELNR_LONG
          IF wa_akt_plotjobs-lif_telnr_long IS INITIAL.
          ELSE.
            wa_plotjobs-lif_telnr_long = wa_akt_plotjobs-lif_telnr_long.
          ENDIF.
*         LIF_SMTP_ADDR
          IF wa_akt_plotjobs-lif_smtp_addr IS INITIAL.
          ELSE.
            wa_plotjobs-lif_smtp_addr = wa_akt_plotjobs-lif_smtp_addr.
          ENDIF.

          MODIFY itab_plotjobs FROM wa_plotjobs
            INDEX wa_et_index_rows_plotlist-index..
        ENDLOOP.

    ENDCASE.
  ENDIF.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.

ENDFORM.                    " change_job_properties
*&---------------------------------------------------------------------*
*&      Form  change_job_properties_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_job_properties_tree.
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.

  "PERFORM get_sel_tree.
  "PERFORM get_sel_tree_2.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_job_properties.

*  IF f_error IS INITIAL.
*  ELSE.
*    CLEAR f_error.
*    EXIT.
*  ENDIF.
*
*  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
*  IF count_lines < 1.
*    REFRESH itab_et_index_rows_plotlist.
*    MESSAGE e001(zcl_plint_message_01)
*      WITH text-051 count_lines '' ''.
*  ELSE.
*    SORT itab_et_index_rows_plotlist BY index ASCENDING.
*    CASE tbstcrt_plotlist-activetab.
*      WHEN 'TAB1_PL'.
**      Anzahl Kopien
*        LOOP AT itab_et_index_rows_plotlist
*          INTO wa_et_index_rows_plotlist.
*          READ TABLE itab_plotjobs INTO wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*          wa_plotjobs-kopien = wa_akt_plotjobs-kopien.
*          MODIFY itab_plotjobs FROM wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index..
*        ENDLOOP.
*      WHEN 'TAB2_PL'.
**       Zielformat, SkalierenX, SkaliernY, Drehwinkel, AusgabeSpiegeln
*        LOOP AT itab_et_index_rows_plotlist
*          INTO wa_et_index_rows_plotlist.
*          READ TABLE itab_plotjobs INTO wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*          wa_plotjobs-zielformat = wa_akt_plotjobs-zielformat.
*          wa_plotjobs-skalieren_x = wa_akt_plotjobs-skalieren_x.
*          wa_plotjobs-skalieren_y = wa_akt_plotjobs-skalieren_y.
*          wa_plotjobs-spiegeln = wa_akt_plotjobs-spiegeln.
*          MODIFY itab_plotjobs FROM wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*        ENDLOOP.
*      WHEN 'TAB3_PL'.
**       Stempel, Format, Ausrichtung, Ausgabetyp, Stifttabelle
*        LOOP AT itab_et_index_rows_plotlist
*          INTO wa_et_index_rows_plotlist.
*          READ TABLE itab_plotjobs INTO wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*          wa_plotjobs-stempel = wa_akt_plotjobs-stempel.
*          wa_plotjobs-format_ausgabe = wa_akt_plotjobs-format_ausgabe.
*          wa_plotjobs-ausrichtung = wa_akt_plotjobs-ausrichtung.
*          wa_plotjobs-typ = wa_akt_plotjobs-typ.
*          wa_plotjobs-stifttabelle = wa_akt_plotjobs-stifttabelle.
*          MODIFY itab_plotjobs FROM wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*        ENDLOOP.
*      WHEN 'TAB4_PL'.
**       Lochen, Falten, Heftrand
*        LOOP AT itab_et_index_rows_plotlist
*          INTO wa_et_index_rows_plotlist.
*          READ TABLE itab_plotjobs INTO wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*          wa_plotjobs-lochen = wa_akt_plotjobs-lochen.
*          wa_plotjobs-falten = wa_akt_plotjobs-falten.
*          wa_plotjobs-heftrand = wa_akt_plotjobs-heftrand.
*          MODIFY itab_plotjobs FROM wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*        ENDLOOP.
*      WHEN 'TAB5_PL'.
**       Satzanzahl, Deckblatt, Endeblatt, Inhaltsverzeichnis
**       Inhaltsblatt
*        LOOP AT itab_et_index_rows_plotlist
*          INTO wa_et_index_rows_plotlist.
*          READ TABLE itab_plotjobs INTO wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index.
*          wa_plotjobs-satzanzahl = wa_akt_plotjobs-satzanzahl.
*          wa_plotjobs-deckblatt = wa_akt_plotjobs-deckblatt.
*          wa_plotjobs-endeblatt = wa_akt_plotjobs-endeblatt.
*          wa_plotjobs-knz_inhalt_vz =
*            wa_akt_plotjobs-knz_inhalt_vz.
*          wa_plotjobs-inhaltsblatt = wa_akt_plotjobs-inhaltsblatt.
*
*          MODIFY itab_plotjobs FROM wa_plotjobs
*            INDEX wa_et_index_rows_plotlist-index..
*        ENDLOOP.
*    ENDCASE.
*  ENDIF.
**  MESSAGE i002(zcl_plint_message_01)
**    WITH '' '' '' ''.
*

ENDFORM.                    " change_job_properties_tree
*&---------------------------------------------------------------------*
*&      Form  maintain_cfg_00
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_cfg_00.
* allgemeine konfiguration
  CALL TRANSACTION 'Z_CL_MNTN_CFG_00'.
ENDFORM.                    " maintain_cfg_00
*&---------------------------------------------------------------------*
*&      Form  get_default_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_default_values.
* get same user values from configuration tables
**
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).


* Stempelsprache für sprachabhängige Stempel
  SET PARAMETER ID 'ZCL_STAMP_LANGUAGE' FIELD sy-langu.

*  CLEAR default_data.

  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = ''
       IMPORTING
            o_default_data = default_data.


ENDFORM.                    " get_default_values
*&---------------------------------------------------------------------*
*&      Form  maintain_mail_cfg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_mail_cfg.
  CALL TRANSACTION 'Z_CL_MNTN_MAIL_CFG'.
ENDFORM.                    " maintain_mail_cfg
*&---------------------------------------------------------------------*
*&      Form  maintain_user_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_user_group.
  CALL TRANSACTION 'Z_CL_MNTN_USR_GRP_TB'.
ENDFORM.                    " maintain_user_group
*&---------------------------------------------------------------------*
*&      Form  get_default_verteiler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_default_verteiler.
* try to get the default distributor
  CLEAR wa_default_verteiler.
*  SELECT SINGLE * FROM zcl_voreinstell
*    INTO wa_default_verteiler
*    WHERE uname = default_data-default_nutzer
*    AND voreinstellung = default_data-default_voreinstellung
*    .
*  IF sy-subrc NE 0.
*    IF user_data-knz_use_post = 'X'.
*    ELSE.
*      EXIT.
*    ENDIF.
*    MESSAGE s052(zcl_plint_tools)
*      WITH 'zcl_voreinstell' text-050
*      default_data-default_nutzer
*      default_data-default_verteiler
*      .
*  ELSE.
*    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_data-default_nutzer.
*  ENDIF.


  CALL FUNCTION '/CIDEON/GET_DEFAULT_VERTEILER'
       EXPORTING
            i_wa_user_data         = user_data
            i_wa_default_data      = default_data
       IMPORTING
            o_wa_default_verteiler = wa_default_verteiler
       EXCEPTIONS
            error                  = 1
            OTHERS                 = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " get_default_verteiler
*&---------------------------------------------------------------------*
*&      Form  update_on_enter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_on_enter.
* makes some updates / specialy if an F4 help occurs
  IF f_f4_voreinstellung = 'X'.
    CLEAR f_f4_voreinstellung.
    IF wa_old_plotjobs-voreinstellung <> wa_akt_plotjobs-voreinstellung.
      CLEAR wa_voreinstellung.
      SELECT SINGLE * FROM zcl_voreinstell
        INTO wa_voreinstellung
        WHERE uname = wa_akt_plotjobs-uname
        AND voreinstellung = wa_akt_plotjobs-voreinstellung
        .
      IF sy-subrc NE 0.
        MESSAGE s052(zcl_plint_tools)
          WITH 'zcl_voreinstell' text-050
          wa_akt_plotjobs-uname
          wa_akt_plotjobs-voreinstellung
          .
      ELSE.
        wa_akt_plotjobs-ausgabegeraet = wa_voreinstellung-ausgabegeraet.
        wa_akt_plotjobs-zielformat = wa_voreinstellung-zielformat .
        wa_akt_plotjobs-skalieren_x = wa_voreinstellung-skalieren_x .
        wa_akt_plotjobs-skalieren_y = wa_voreinstellung-skalieren_y .
        wa_akt_plotjobs-medium = wa_voreinstellung-medium .
        wa_akt_plotjobs-drehen = wa_voreinstellung-drehen .
        wa_akt_plotjobs-spiegeln = wa_voreinstellung-spiegeln .
        wa_akt_plotjobs-kopien = wa_voreinstellung-kopien .
        wa_akt_plotjobs-falten = wa_voreinstellung-falten .
        wa_akt_plotjobs-lochen = wa_voreinstellung-lochen .
        wa_akt_plotjobs-heftrand = wa_voreinstellung-heftrand .
        wa_akt_plotjobs-stempel = wa_voreinstellung-stempel .
        wa_akt_plotjobs-format_ausgabe =
          wa_voreinstellung-format_ausgabe .
        wa_akt_plotjobs-ausrichtung = wa_voreinstellung-ausrichtung .
        wa_akt_plotjobs-aufloesung = wa_voreinstellung-aufloesung .
        wa_akt_plotjobs-typ = wa_voreinstellung-typ .
        wa_akt_plotjobs-stifttabelle = wa_voreinstellung-stifttabelle .
        wa_akt_plotjobs-verschiebung = wa_voreinstellung-verschiebung .
        "wa_akt_plotjobs-seite = wa_voreinstellung-seite.
      ENDIF.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

ENDFORM.                    " update_on_enter
*&---------------------------------------------------------------------*
*&      Form  add_objectkey_to_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_objectkey_to_plotlist.
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    CALL FUNCTION 'Z_CL_MAKE_OBJECT_KEY'
         EXPORTING
              i_dokar = wa_plotjobs-dokar
              i_doknr = wa_plotjobs-doknr
              i_dokvr = wa_plotjobs-dokvr
              i_doktl = wa_plotjobs-doktl
         IMPORTING
              o_objky = wa_plotjobs-objky
         EXCEPTIONS
              error   = 1
              OTHERS  = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.
ENDFORM.                    " add_objectkey_to_plotlist
*&---------------------------------------------------------------------*
*&      Form  add_format_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_format_field.
*  DATA: tmp_atwrt LIKE ausp-atwrt.
*
*  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*    CLEAR tmp_atwrt.
*    SELECT SINGLE atwrt FROM ausp
*      INTO tmp_atwrt
*      WHERE objek = wa_plotjobs-objky
*      AND atinn = default_data-merkmal_format
*      .
*    IF sy-subrc NE 0.
*      PERFORM appl_log_write USING
*        'W' '022' 'ZCL_PLINT_MESSAGE_01'
*         wa_plotjobs-dokar wa_plotjobs-doknr
*         wa_plotjobs-dokvr wa_plotjobs-doktl.
*    ELSE.
*      wa_plotjobs-format_ausgabe = tmp_atwrt.
*      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
*    ENDIF.
*  ENDLOOP.

  CALL FUNCTION '/CIDEON/ADD_FORMAT_FIELD'
       EXPORTING
            i_wa_default_data = default_data
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " add_format_field
*&---------------------------------------------------------------------*
*&      Form  make_send_log_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_send_log_entries.
  CALL FUNCTION '/CIDEON/MAKE_SEND_LOG_ENTRIES'
       EXPORTING
            i_msgid         = 'ZCL_PLINT_MESSAGE_01'
            i_msgno         = '101'
       TABLES
            i_itab_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error           = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*  DATA: text1 TYPE symsgv.
*  DATA: text2 TYPE symsgv.
*  DATA: text3 TYPE symsgv.
*  DATA: text4 TYPE symsgv.
*  DATA: f_new_head TYPE c.
*  DATA: f_first TYPE c.
*
*  f_first = 'X'.
*  CLEAR f_new_head.
*  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*    CLEAR text1.
*    CLEAR text2.
*    CLEAR text3.
*    CLEAR text4.
**    text1 = wa_plotjobs-dokar.
**    text2 = wa_plotjobs-doknr.
**    text3 = wa_plotjobs-dokvr.
**    text4 = wa_plotjobs-doktl.
*
*    IF NOT f_first IS INITIAL.
*      f_new_head = 'X'.
*    ELSE.
*      CLEAR f_new_head.
*    ENDIF.
*
**   Mitloggen des Nutzers und des PreProcessors
*    CONCATENATE wa_plotjobs-verteiler ''
*      INTO text1.
*    text2 = sy-uname.
*
*    CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_2'
*         EXPORTING
*              i_object   = 'Z_CIDEON'
*              i_subobj   = 'Z_PLOT'
*              i_number   = 101
*              i_msgtyp   = 'I'
*              i_msgid    = 'ZCL_PLINT_MESSAGE_01'
*              i_msgno    = 102
*              i_msgv1    = text1
*              i_msgv2    = text2
*              i_msgv3    = text3
*              i_msgv4    = text4
*              i_class    = ' '
*              i_newhead  = f_new_head
*              i_messhead = 'X'
*         EXCEPTIONS
*              error      = 1
*              OTHERS     = 2.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    CLEAR f_new_head.
*
*    CONCATENATE wa_plotjobs-dokar wa_plotjobs-doknr wa_plotjobs-dokvr
*      wa_plotjobs-doktl INTO text1.
*    text2 = wa_plotjobs-filep.
*
*    CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_2'
*         EXPORTING
*              i_object   = 'Z_CIDEON'
*              i_subobj   = 'Z_PLOT'
*              i_number   = 101
*              i_msgtyp   = 'I'
*              i_msgid    = 'ZCL_PLINT_MESSAGE_01'
*              i_msgno    = 101
*              i_msgv1    = text1
*              i_msgv2    = text2
*              i_msgv3    = text3
*              i_msgv4    = text4
*              i_class    = ' '
*              i_newhead  = f_new_head
*              i_messhead = 'X'
*         EXCEPTIONS
*              error      = 1
*              OTHERS     = 2.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    CLEAR f_first.
*
*  ENDLOOP.

ENDFORM.                    " make_send_log_entries
*&---------------------------------------------------------------------*
*&      Form  set_screen_attributes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_screen_attributes.
  IF user_data-knz_use_post = 'X'.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group3 = 'POS'.
        screen-input = '1'.
      ELSE.
      ENDIF.
      IF screen-group3 = 'PRE'.
        screen-input = '0'.
        screen-invisible = '1'.
      ELSE.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  CASE user_data-modus.
    WHEN 'SUPER'.
    WHEN 'ADMIN'.
    WHEN 'NORMAL'.
      LOOP AT SCREEN.
        IF screen-group2 = 'NRM'.
          screen-input = '0'.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group3 = 'INV'.
      screen-invisible = '1'.
      screen-input = '0'.
      screen-output = '0'.
    ELSE.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*  LOOP AT SCREEN.
*    IF screen-group4 = 'INV'.
*      screen-invisible = '1'.
*      screen-input = '0'.
*      screen-output = '0'.
*    ELSE.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

ENDFORM.                    " set_screen_attributes
*&---------------------------------------------------------------------*
*&      Form  get_data_sl_sueckliste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_sl_stueckliste.
* search in a document part list
* 09.08.2006 - Mitgabe der Stücklisteninformationen / oberstes Element
*ITAB
  DATA: itab_stpo_api02 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_1 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_2 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_result TYPE TABLE OF stpo_api02.
  DATA: itab_draw TYPE TABLE OF draw.

  DATA: itab_documentstructure TYPE TABLE OF bapi_doc_structure.
*WA
  DATA: wa_stpo_api02 TYPE stpo_api02.
  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.
  DATA: wa_dost TYPE dost.
  DATA: wa_draw TYPE draw.
  DATA: wa_stored_search TYPE zcl_psb_tmp.

  DATA: return TYPE bapiret2.
  DATA: wa_documentstructure TYPE bapi_doc_structure.
*NORMAL
  DATA: laenge TYPE i.
  DATA: char25(25).
  DATA: anzahl TYPE i.

  REFRESH itab_search_tmp.
  REFRESH itab_stpo_api02.

  CALL FUNCTION 'Z_CL_PLINT_ASK_DOCUMENT_NR'
       IMPORTING
            o_doknr = document
            o_dokar = doc_type
            o_dokvr = doc_vers
            o_doktl = doc_part
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM dost INTO wa_dost
    WHERE doknr = document
    AND dokar = doc_type
    AND dokvr = doc_vers
    AND doktl = doc_part
    .
  IF sy-subrc NE 0.
    MESSAGE i071(zcl_plint_tools)
      WITH document doc_type doc_part doc_vers.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_stored_search.
  wa_stored_search-dokar = doc_type.
  wa_stored_search-doknr = document.
  wa_stored_search-dokvr = doc_vers.
  wa_stored_search-doktl = doc_part.

*  CALL FUNCTION 'Z_CL_GET_BILLOFDOC_ALL'
*       EXPORTING
*            i_dokar     = wa_stored_search-dokar
*            i_doknr     = wa_stored_search-doknr
*            i_dokvr     = wa_stored_search-dokvr
*            i_doktl     = wa_stored_search-doktl
*       TABLES
*            o_itab_draw = itab_draw
*       EXCEPTIONS
*            error       = 1
*            OTHERS      = 2.
*  IF sy-subrc <> 0.
**          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

  REFRESH itab_documentstructure.
  CLEAR wa_documentstructure.
  CALL FUNCTION 'BAPI_DOCUMENT_GETSTRUCTURE'
    EXPORTING
      documenttype              = wa_stored_search-dokar
      documentnumber            = wa_stored_search-doknr
      documentpart              = wa_stored_search-doktl
      documentversion           = wa_stored_search-dokvr
      multilevelexplosion       = 'X'
*     DOCBOMCHANGENUMBER        =
*     DOCBOMVALIDFROM           =
*     DOCBOMREVISIONLEVEL       =
    IMPORTING
      return                    = return
    TABLES
      documentstructure         = itab_documentstructure
            .

  REFRESH itab_draw.
  LOOP AT itab_documentstructure INTO wa_documentstructure.
    CLEAR wa_draw.
    wa_draw-dokar = wa_documentstructure-documenttype.
    wa_draw-doknr = wa_documentstructure-documentnumber.
    wa_draw-doktl = wa_documentstructure-documentpart.
    wa_draw-dokvr = wa_documentstructure-documentversion.
    APPEND wa_draw TO itab_draw.
  ENDLOOP.

  CLEAR wa_draw.
  wa_draw-dokar           = wa_stored_search-dokar.
  wa_draw-doknr           = wa_stored_search-doknr.
  wa_draw-dokvr           = wa_stored_search-dokvr.
  wa_draw-doktl           = wa_stored_search-doktl.
  "APPEND wa_draw TO itab_draw.
  INSERT wa_draw INTO itab_draw INDEX 1.

  CLEAR wa_search.

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

      wa_search-stlnr = wa_dost-stlnr.

      wa_search-dokar_bom = doc_type.
      wa_search-doknr_bom = document.
      wa_search-doktl_bom = doc_part.
      wa_search-dokvr_bom = doc_vers.

      APPEND wa_search TO itab_search.
    ELSE.
      wa_search-stlnr = wa_dost-stlnr.

      wa_search-dokar_bom = doc_type.
      wa_search-doknr_bom = document.
      wa_search-doktl_bom = doc_part.
      wa_search-dokvr_bom = doc_vers.

      APPEND wa_search TO itab_search.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " get_data_sl_sueckliste
*&---------------------------------------------------------------------*
*&      Form  maintain_tiff_Komp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_tiff_komp.
  CALL TRANSACTION 'Z_CL_MNTN_TIFF_KOMP'.
ENDFORM.                    " maintain_tiff_Komp
*&---------------------------------------------------------------------*
*&      Form  add_compression_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_compression_field.
  DATA: tmp_kompression LIKE zcl_comp_tiff-typ_kompression.
  DATA: langu TYPE sy-langu.


  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    IF wa_plotjobs-kompression IS INITIAL.
    ELSE.
      CONTINUE.
    ENDIF.
    CLEAR tmp_kompression.
    SET LOCALE LANGUAGE langu.
    TRANSLATE wa_plotjobs-typ TO UPPER CASE.
    SET LOCALE LANGUAGE space.
    SELECT SINGLE typ_kompression FROM zcl_comp_tiff
      INTO tmp_kompression
      WHERE typ_tiff = wa_plotjobs-typ
      .
    IF sy-subrc NE 0.
      wa_plotjobs-kompression = 'KEINE'.
      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
    ELSE.
      wa_plotjobs-kompression = tmp_kompression.
      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " add_compression_field
*&---------------------------------------------------------------------*
*&      Form  add_dttrg_to_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_dttrg_to_search.
  CLEAR wa_search_tmp.
  CLEAR wa_search.
  LOOP AT itab_search_tmp INTO wa_search_tmp.
    SELECT SINGLE dttrg FROM draw
      INTO wa_search_tmp-dttrg
      WHERE dokar = wa_search_tmp-dokar
      AND doknr = wa_search_tmp-doknr
      AND dokvr = wa_search_tmp-dokvr
      AND doktl = wa_search_tmp-doktl
      .
    IF sy-subrc NE 0.
      CLEAR wa_search_tmp-dttrg.
    ELSE.
    ENDIF.
    MODIFY itab_search_tmp FROM wa_search_tmp INDEX sy-tabix.
  ENDLOOP.
ENDFORM.                    " add_dttrg_to_search
*&---------------------------------------------------------------------*
*&      Form  check_kapro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_kapro.
* if the File is checked in then dowload it to a temp. path
  DATA: tmp_path TYPE bapi_doc_aux-filename.
  "  tmp_path = 'c:\temp\'.
  tmp_path = user_data-view_down_path.

  IF wa_plotjobs-checked = 'X'.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
              percentage = '15'  " Balkenanzeige
              text       = text-010.

    CALL FUNCTION 'Z_CL_PLINT_DOWNLOAD_CHECK_FILE'
         EXPORTING
              i_wa_plotjobs = wa_plotjobs
              i_temp_path   = tmp_path
         IMPORTING
              o_filename    = wa_plotjobs-filep
         EXCEPTIONS
              error         = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE i065(zcl_plint_message_01) WITH
        wa_plotjobs-filep  tmp_path'' ''.
    ENDIF.

*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              percentage = '90'  " Balkenanzeige
*              text       = text-010.
  ELSE.
  ENDIF.

ENDFORM.                    " check_kapro
*&---------------------------------------------------------------------*
*&      Form  delete_after_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_after_view.
  DATA: tmp_filename TYPE rlgrap-filename.
  DATA: return TYPE c.
  DATA: str_filename TYPE string.
  DATA: rc TYPE i.

  tmp_filename = wa_plotjobs-filep.

  IF wa_plotjobs-checked = 'X'.

    CREATE OBJECT frontend_service
*      EXPORTING
*        TITLE  =
*        INIT_DIRECTORY =
        .

    str_filename = tmp_filename.
    CALL METHOD frontend_service->file_delete
      EXPORTING
        filename           = str_filename
      CHANGING
        rc                 = rc
      EXCEPTIONS
        file_delete_failed = 1
        cntl_error         = 2
        error_no_gui       = 3
        file_not_found     = 4
        access_denied      = 5
        unknown_error      = 6
        OTHERS             = 7
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     einfügen,. Datei nicht gelöscht werden konnte
      msgv1 =  tmp_filename.
      msgv2 = 'ZCL_PLINT_DESIGN_007F01'.
      msgv3 = 'delete_after_view'.
      CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
           EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = 66
                i_msgtyp   = 'E'
                i_msgid    = 'ZCL_PLINT_MESSAGE_01'
                i_msgno    = 66
                i_msgv1    = msgv1
                i_msgv2    = msgv2
                i_msgv3    = msgv3
                i_msgv4    = msgv4
                i_class    = ' '
                i_newhead  = 'X'
                i_messhead = 'X'
           EXCEPTIONS
                error      = 1
                OTHERS     = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDIF.



*    CALL FUNCTION 'WS_FILE_DELETE'
*         EXPORTING
*              file   = tmp_filename
*         IMPORTING
*              return = return.
*    IF return NE 0.
**     einfügen,. Datei nicht gelöscht werden konnte
*      msgv1 =  tmp_filename.
*      msgv2 = 'ZCL_PLINT_DESIGN_007F01'.
*      msgv3 = 'delete_after_view'.
*      CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_2'
*           EXPORTING
*                i_object   = 'Z_CIDEON'
*                i_subobj   = 'Z_PLOT'
*                i_number   = 66
*                i_msgtyp   = 'E'
*                i_msgid    = 'ZCL_PLINT_MESSAGE_01'
*                i_msgno    = 66
*                i_msgv1    = msgv1
*                i_msgv2    = msgv2
*                i_msgv3    = msgv3
*                i_msgv4    = msgv4
*                i_class    = ' '
*                i_newhead  = 'X'
*                i_messhead = 'X'
*           EXCEPTIONS
*                error      = 1
*                OTHERS     = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*
*    ELSE.
*    ENDIF.
  ELSE.
  ENDIF.

ENDFORM.                    " delete_after_view
*&---------------------------------------------------------------------*
*&      Form  change_kompression
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_kompression.
  DATA: tmp_kompression LIKE zcl_comp_tiff-typ_kompression.

  CLEAR tmp_kompression.
  SELECT SINGLE typ_kompression FROM zcl_comp_tiff
    INTO tmp_kompression
    WHERE typ_tiff = wa_akt_plotjobs-typ
    .
  IF sy-subrc NE 0.
  ELSE.
    wa_akt_plotjobs-kompression = tmp_kompression.
  ENDIF.

ENDFORM.                    " change_kompression
*&---------------------------------------------------------------------*
*&      Form  add_client_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_client_data.
* Adds special client data to plotjobs
  DATA: wa_kna1 LIKE kna1.
  DATA: mailadresse TYPE ad_smtpadr.
  DATA: n10(10) TYPE n.

  CLEAR wa_kna1.
  CLEAR mailadresse.

  IF user_data-knz_user_dummy = 'X'.
    IF user_data-user_dummy_kunnr IS INITIAL.
      MESSAGE i020(zcl_plint_message_01) WITH '' '' '' ''.
      EXIT.
    ELSE.
      n10 = user_data-user_dummy_kunnr.
      SELECT SINGLE * FROM kna1 INTO wa_kna1
        WHERE kunnr = n10
        .
      IF sy-subrc NE 0.
        MESSAGE i021(zcl_plint_message_01)
          WITH user_data-user_dummy_kunnr '' '' ''.
        EXIT.
      ELSE.
        SELECT SINGLE smtp_addr FROM adr6
          INTO mailadresse
          WHERE addrnumber = wa_kna1-adrnr.
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
  ENDIF.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-name1 = wa_kna1-name1.
    wa_plotjobs-name2 = wa_kna1-name2.
    "wa_plotjobs-firma = wa_kna1-
    "wa_plotjobs-abteilung = wa_kna1-
    wa_plotjobs-stras = wa_kna1-stras.
    wa_plotjobs-ort1 = wa_kna1-ort01.
    wa_plotjobs-pstlz = wa_kna1-pstlz.
    wa_plotjobs-telf1 = wa_kna1-telf1.
    wa_plotjobs-telfx = wa_kna1-telfx.
    wa_plotjobs-smtp_addr = mailadresse.


    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.

  ENDLOOP.

ENDFORM.                    " add_client_data
*&---------------------------------------------------------------------*
*&      Form  add_cost_center
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cost_center.
* try to get the cost center for the user
  DATA: kostl LIKE wa_plotjobs-kostl.

  IF user_data-knz_use_kostl = 'X'.
  ELSE.
    EXIT.
  ENDIF.


  CALL FUNCTION 'Z_CL_ASK_FOR_COSTCENTER'
       EXPORTING
            i_user          = sy-uname
       IMPORTING
            o_kostl         = kostl
       EXCEPTIONS
            error           = 1
            pernr_not_found = 2
            kostl_not_found = 3
            OTHERS          = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  make LOG entry
    CLEAR msgv1.
    CLEAR msgv2.
    CLEAR msgv3.
    CLEAR msgv4.
    msgv1 = sy-uname.
    CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
         EXPORTING
              i_object   = 'Z_CIDEON'
              i_subobj   = 'Z_PLOT'
              i_number   = 067
              i_msgtyp   = 'W'
              i_msgid    = 'ZCL_PLINT_MESSAGE_01'
              i_msgno    = 067
              i_msgv1    = msgv1
              i_msgv2    = msgv2
              i_msgv3    = msgv3
              i_msgv4    = msgv4
              i_class    = ' '
              i_newhead  = 'X'
              i_messhead = 'X'
         EXCEPTIONS
              error      = 1
              OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    EXIT.
  ENDIF.


  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-kostl = kostl.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " add_cost_center
*&---------------------------------------------------------------------*
*&      Form  add_special_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_special_fields.
* adds special fields like Satzanzahl, Deckblatt usw.
*SATZANZAHL
*DECKBLATT
*ENDEBLATT
*KNZ_INHALT_VZ

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-satzanzahl = default_data-default_satzanzahl.
    wa_plotjobs-deckblatt = default_data-default_deckblatt.
    wa_plotjobs-endeblatt = default_data-default_endeblatt.
    wa_plotjobs-knz_inhalt_vz = default_data-default_knz_inhalt_vz.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " add_special_fields
*&---------------------------------------------------------------------*
*&      Form  read_stored_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_stored_search.
* try to read stored search entries
*ITAB
  DATA: itab_stpo_api02 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_1 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_2 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_result TYPE TABLE OF stpo_api02.
  DATA: itab_draw TYPE TABLE OF draw.
*WA
  DATA: wa_stpo_api02 TYPE stpo_api02.
  DATA: wa_draw TYPE draw.
*NORMA
  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.
  DATA: wa_dost TYPE dost.
  DATA: laenge TYPE i.
  DATA: char25(25).
  DATA: anzahl TYPE i.

  DATA: itab_stored_search TYPE TABLE OF zcl_psb_tmp.
  DATA: wa_stored_search TYPE zcl_psb_tmp.

  DATA: f_lesen(1).

  break_point.                                             "#EC NOBREAK

* Lesen oder nicht Lesen, daß ist hier die Frage :-))
*  IMPORT f_lesen FROM MEMORY ID 'PLOT_READ_AKT_QUEUE'.
*  EXPORT ''
*    TO MEMORY ID 'PLOT_READ_AKT_QUEUE'.
  "break steurich.
  GET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD f_lesen.
  IF f_lesen = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF user_data-read_tmp_search = 'X'.
  ELSE.
    IF user_data-delete_tmp_search = 'X'.
      DELETE FROM zcl_psb_tmp
        WHERE uname = user_data-uname
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
    EXIT.
  ENDIF.

  REFRESH itab_stored_search.
  CLEAR wa_stored_search.

  SELECT * FROM zcl_psb_tmp INTO TABLE itab_stored_search
    WHERE
    uname = user_data-uname
    ORDER BY counter
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_stored_search INTO wa_stored_search.
    CLEAR wa_search.

*   allgemeine Übergabe
    wa_search-psteu = wa_stored_search-psteu.
    wa_search-samlt = wa_stored_search-samlt.
    wa_search-pmode = wa_stored_search-pmode.
    wa_search-drart = wa_stored_search-drart.
    wa_search-ktext = wa_stored_search-ktext.
    wa_search-selpr = wa_stored_search-selpr.
    wa_search-tcode = wa_stored_search-tcode.

    wa_search-projn = wa_stored_search-projn.

*   spezielle Übergabe
    CASE wa_stored_search-object_type.
      WHEN 'BILLOFDOC'.

*        CLEAR wa_search.

        CALL FUNCTION 'Z_CL_GET_BILLOFDOC_ALL'
             EXPORTING
                  i_dokar     = wa_stored_search-dokar
                  i_doknr     = wa_stored_search-doknr
                  i_dokvr     = wa_stored_search-dokvr
                  i_doktl     = wa_stored_search-doktl
             TABLES
                  o_itab_draw = itab_draw
             EXCEPTIONS
                  error       = 1
                  OTHERS      = 2.
        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CLEAR wa_draw.
        wa_draw-dokar           = wa_stored_search-dokar.
        wa_draw-doknr           = wa_stored_search-doknr.
        wa_draw-dokvr           = wa_stored_search-dokvr.
        wa_draw-doktl           = wa_stored_search-doktl.
        "APPEND wa_draw TO itab_draw.
        INSERT wa_draw INTO itab_draw INDEX 1.

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

      WHEN 'DOCUMENT'.
*        CLEAR wa_search.
        SELECT SINGLE * FROM draw INTO
          CORRESPONDING FIELDS OF wa_search
          WHERE dokar = wa_stored_search-dokar
          AND doknr = wa_stored_search-doknr
          AND dokvr = wa_stored_search-dokvr
          AND doktl = wa_stored_search-doktl
          .
        IF sy-subrc NE 0.
        ELSE.
          wa_search-id_sl = wa_stored_search-id_sl.
          wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
          wa_search-aufpl = wa_stored_search-aufpl.
          wa_search-aplzl = wa_stored_search-aplzl.
          wa_search-knz_affl = wa_stored_search-knz_affl.
          wa_search-knz_afvc = wa_stored_search-knz_afvc.

          wa_search-verteiler = wa_stored_search-verteiler.

          wa_search-folnr = wa_stored_search-folnr.
          wa_search-vornr = wa_stored_search-vornr.

          APPEND wa_search TO itab_search.
        ENDIF.
      WHEN 'STUECKLIST'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        APPEND wa_search TO itab_search.
      WHEN 'FOLGE'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
        wa_search-aufpl = wa_stored_search-aufpl.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        APPEND wa_search TO itab_search.
      WHEN 'VORGANG'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
        wa_search-aufpl = wa_stored_search-aufpl.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        APPEND wa_search TO itab_search.
      WHEN 'SPOOL'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
        wa_search-aufpl = wa_stored_search-aufpl.

        wa_search-verteiler = wa_stored_search-verteiler.

        wa_search-drtxt = wa_stored_search-drtxt.
        wa_search-tdotftype = wa_stored_search-tdotftype.
        wa_search-tdspoolid = wa_stored_search-tdspoolid.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        wa_search-aufnr_cs = wa_stored_search-aufnr_cs.

        APPEND wa_search TO itab_search.
    ENDCASE.
  ENDLOOP.

  IF user_data-delete_tmp_search = 'X'.
    DELETE FROM zcl_psb_tmp
      WHERE uname = user_data-uname
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

ENDFORM.                    " read_stored_search
*&---------------------------------------------------------------------*
*&      Form  cv03n_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cv03n_view.
* calls Transactionb 'cv03n'
  REFRESH itab_et_index_rows_searchlist.
  CALL METHOD grid_searchlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_searchlist LINES count_lines.
  IF count_lines <> 1.
    REFRESH itab_et_index_rows_searchlist.
    MESSAGE e000(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
    READ TABLE itab_et_index_rows_searchlist
      INTO wa_et_index_rows_searchlist INDEX 1.
    READ TABLE itab_search INTO wa_search
      INDEX wa_et_index_rows_searchlist-index .
  ENDIF.

  CASE wa_search-object_type.
    WHEN 'SPOOL'.
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
           EXPORTING
                i_spoolid = wa_search-tdspoolid
           EXCEPTIONS
                error     = 1
                OTHERS    = 2.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      EXIT.
    WHEN 'URL'.
      CALL FUNCTION '/CIDEON/OM_ITEM_SHOW_URL'
           EXPORTING
                i_url = wa_search-url.


    WHEN OTHERS.
      SET PARAMETER ID 'CV1' FIELD wa_search-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_search-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_search-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_search-doktl.

      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
  ENDCASE.

** Spoolbehandlung
*  IF wa_search-object_type = 'SPOOL'.
*    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
*         EXPORTING
*              i_spoolid = wa_search-tdspoolid
*         EXCEPTIONS
*              error     = 1
*              OTHERS    = 2.
*    IF sy-subrc <> 0.
*      EXIT.
*    ENDIF.
*    EXIT.
*  ELSE.
*  ENDIF.

*  SET PARAMETER ID 'CV1' FIELD wa_search-doknr.
*  SET PARAMETER ID 'CV2' FIELD wa_search-dokar.
*  SET PARAMETER ID 'CV3' FIELD wa_search-dokvr.
*  SET PARAMETER ID 'CV4' FIELD wa_search-doktl.
*
*  CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

ENDFORM.                    " cv03n_view
*&---------------------------------------------------------------------*
*&      Form  get_latest_path_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_latest_path_entries.
* try to check if there are another path availible
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).

* ck 02.04.2003 Änderung
* generelles Reload der Einstellungen vor dem Senden
  PERFORM get_default_values.
  PERFORM get_user_values.
  EXIT.
* ck 02.04.2003 Änderung Ende

*default_data
* DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_cfg_00
*    INTO tmp_str
*    WHERE pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
*  ELSE.
*    default_data-down_path = tmp_str.
*  ENDIF.
*  clear tmp_str.
*  select klient_down_pfad
*    from zcl_preprozessor
*    into tmp_str
*    where preprozessor in
*    (  select preprozessor
*         from zcl_preproz_user
*         where uname = default_data-default_nutzer
*         and status = c_status_aktiv
*    ).
*  endselect.
*  if sy-subrc ne 0.
*    message e052(zcl_plint_tools)
*      with 'zcl_preprozessor' default_data-default_nutzer
*      '' ''.
*  else.
*    default_data-down_path = tmp_str.
*  endif.
*
*
** PPL_DOWN_PATH
*  if user_data-knz_use_post = 'X'.
*    clear tmp_str.
*    pname = 'PPL_DOWN_PATH'.
*    select pwert from zcl_plint_cfg_00
*      into tmp_str
*      where pname = pname
*      .
*    endselect.
*    if sy-subrc ne 0.
*      message e052(zcl_plint_tools)
*        with 'zcl_plint_cfg_00' pname
*        '' ''.
*    else.
*      default_data-ppl_down_path = tmp_str.
*    endif.
*  else.
*  endif.
*
** VIEW_DOWN_PATH
*  clear tmp_str.
*  pname = 'VIEW_DOWN_PATH'.
*  select pwert from zcl_plint_cfg_00
*    into tmp_str
*    where pname = pname
*    .
*  endselect.
*  if sy-subrc ne 0.
*    message e052(zcl_plint_tools)
*      with 'zcl_plint_cfg_00' pname
*      '' ''.
*  else.
*    default_data-view_down_path = tmp_str.
*  endif.

* CLF_DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'CLF_DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_cfg_00
*    INTO tmp_str
*    WHERE pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
*  ELSE.
*    default_data-clf_down_path = tmp_str.
*  ENDIF.
*  clear tmp_str.
*  select klient_scan_pfad
*    from zcl_preprozessor
*    into tmp_str
*    where preprozessor in
*    (  select preprozessor
*         from zcl_preproz_user
*         where uname = default_data-default_nutzer
*         and status = c_status_aktiv
*    ).
*  endselect.
*  if sy-subrc ne 0.
*    message e052(zcl_plint_tools)
*      with 'zcl_preprozessor' default_data-default_nutzer
*      '' ''.
*  else.
*    default_data-clf_down_path = tmp_str.
*  endif.


*user_data
*DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_config
*    INTO tmp_str
*    WHERE uname = sy-uname
*    AND pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    user_data-down_path = default_data-down_path.
*  ELSE.
*    user_data-down_path = tmp_str.
*  ENDIF.
*  clear tmp_str.
*  select klient_down_pfad
*    from zcl_preprozessor
*    into tmp_str
*    where preprozessor in
*    (  select preprozessor
*         from zcl_preproz_user
*         where uname = sy-uname
*         and status = c_status_aktiv
*    ).
*  endselect.
*  if sy-subrc ne 0.
*    user_data-down_path = default_data-down_path.
*  else.
*    user_data-down_path = tmp_str.
*  endif.

*PPL_DOWN_PATH
*  if user_data-knz_use_post = 'X'.
*    clear tmp_str.
*    pname = 'PPL_DOWN_PATH'.
*    select pwert from zcl_plint_config
*      into tmp_str
*      where uname = sy-uname
*      and pname = pname
*      .
*    endselect.
*    if sy-subrc ne 0.
*      user_data-ppl_down_path = default_data-ppl_down_path.
*    else.
*      user_data-ppl_down_path = tmp_str.
*    endif.
*  else.
*  endif.
*
**VIEW_DOWN_PATH
*  clear tmp_str.
*  pname = 'VIEW_DOWN_PATH'.
*  select pwert from zcl_plint_config
*    into tmp_str
*    where uname = sy-uname
*    and pname = pname
*    .
*  endselect.
*  if sy-subrc ne 0.
*    user_data-view_down_path = default_data-view_down_path.
*  else.
*    user_data-view_down_path = tmp_str.
*  endif.

*CLF_DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'CLF_DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_config
*    INTO tmp_str
*    WHERE uname = sy-uname
*    AND pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    user_data-clf_down_path = default_data-clf_down_path.
*  ELSE.
*    user_data-clf_down_path = tmp_str.
*  ENDIF.
*  clear tmp_str.
*  select klient_scan_pfad
*    from zcl_preprozessor
*    into tmp_str
*    where preprozessor in
*    (  select preprozessor
*         from zcl_preproz_user
*         where uname = sy-uname
*         and status = c_status_aktiv
*    ).
*  endselect.
*  if sy-subrc ne 0.
*    user_data-clf_down_path = default_data-clf_down_path.
*  else.
*    user_data-clf_down_path = tmp_str.
*  endif.
*
*
**USE_HOSTNAME
*  clear tmp_str.
*  pname = 'USE_HOSTNAME'.
*  select pwert from zcl_plint_config
*    into tmp_str
*    where uname = sy-uname
*    and pname = pname
*    .
*  endselect.
*  if sy-subrc ne 0.
*    user_data-use_hostname = ''.
*  else.
*    user_data-use_hostname = tmp_str.
*  endif.
*
**set Hostname
*  call function 'CV120_GET_HOSTNAME'
*       exporting
*            pf_batch          = ' '
*       importing
*            pfx_host          = user_data-hostname
*       exceptions
*            error             = 1
*            no_valid_frontend = 2
*            others            = 3.
*  if sy-subrc <> 0.
*    user_data-hostname = ''.
*  else.
*    clear wa_usr_host_cfg.
*    select single * from zcl_usr_host_cfg
*      into wa_usr_host_cfg
*      where uname = sy-uname
*      and host = user_data-hostname
*      .
*    if sy-subrc ne 0.
**   APPL-LOG
*    else.
*      user_data-ppl_down_path = wa_usr_host_cfg-ppl_down_path.
*      user_data-down_path = wa_usr_host_cfg-down_path.
*    endif.
*  endif.

ENDFORM.                    " get_latest_path_entries
*&---------------------------------------------------------------------*
*&      Form  check_priorties
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_priorities.
* sets the priorities to allowed values
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    IF wa_plotjobs-prio > user_data-prio_bis.
      wa_plotjobs-prio = user_data-prio_bis.
      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
    ELSE.
    ENDIF.
    IF wa_plotjobs-prio < user_data-prio_von.
      wa_plotjobs-prio = user_data-prio_von.
      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
    ELSE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " check_priorties
*&---------------------------------------------------------------------*
*&      Form  view_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_info.
* displays an INFO
  DATA: url(255) TYPE c.

  CALL FUNCTION 'Z_CL_PICTURE_LOAD_FROM_DB'
       EXPORTING
            id     = 'PLOT_001'
       IMPORTING
            o_url  = url
       EXCEPTIONS
            error  = 1
            OTHERS = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " view_info
