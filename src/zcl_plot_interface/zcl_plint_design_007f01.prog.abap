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
form get_data_for_search_list.
  refresh itab_search_tmp.

  perform search_tmp_to_draw.

  call function 'CV100_DOC_SEARCH'
   exporting
     pf_cv04_list_type       = '2'
*    PF_WEB_LIST_TYPE        =
     api_flag                = 'X'
   tables
     ptx_draw                = itab_draw
    .

  perform draw_to_search_tmp.

  clear wa_search_tmp.
  clear wa_search.

*  perform add_dttrg_to_search.
  loop at itab_search_tmp into wa_search_tmp.
    move-corresponding wa_search_tmp to wa_search.
    append wa_search to itab_search.
  endloop.

endform.                    " get_data_for_search_list
*&---------------------------------------------------------------------*
*&      Form  save_wa_akt_plotjobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_wa_akt_plotjobs.
* Saves the WA
  data: wa_old_plotjob like wa_akt_plotjobs.


  if wa_akt_plotjobs is initial.
    exit.
  else.
    if not wa_akt_plotjobs-dokar is initial
      and not wa_akt_plotjobs-doknr is initial
      and not wa_akt_plotjobs-dokvr is initial
      and not wa_akt_plotjobs-doktl is initial
      .
      perform change_kompression.

      if wa_akt_plotjobs-kopien is initial.
        read table itab_plotjobs into wa_old_plotjob
          index index_itab_plotjobs.
        wa_akt_plotjobs-kopien = wa_old_plotjobs-kopien.
      else.
      endif.

      read table itab_plotjobs into wa_old_plotjob
        index index_itab_plotjobs.

      if wa_akt_plotjobs-verteiler is initial.
        wa_akt_plotjobs-verteiler = wa_old_plotjobs-verteiler.
      else.
      endif.

*     Nur zugelassener Verteiler soll wählbar sein
      perform check_verteiler_on_update
        changing wa_old_plotjob.

      modify itab_plotjobs from wa_akt_plotjobs
        index index_itab_plotjobs.

      if ok_code = 'NODE_DOUBLE_CLICK'.
      else.
        perform refresh_joblist.
      endif.
    else.
    endif.
  endif.
endform.                    " save_wa_akt_plotjobs
*&---------------------------------------------------------------------*
*&      Form  change_priotity
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_priority.
* change for the selected lines in the plot grid the priority
* get the selected line in the plot ALV
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    loop at itab_et_index_rows_plotlist
      into wa_et_index_rows_plotlist.
      clear wa_akt_plotjobs.
      read table itab_plotjobs
        into wa_akt_plotjobs index wa_et_index_rows_plotlist.
      wa_akt_plotjobs-prio = g_prio.
      modify itab_plotjobs from wa_akt_plotjobs
        index wa_et_index_rows_plotlist.
    endloop.
  endif.

  clear wa_akt_plotjobs.

endform.                    " change_priotity
*&---------------------------------------------------------------------*
*&      Form  change_priotity_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_priority_node.
* try to change Items from Plottree
* try to get the double clicked node
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).
  data: itab_tree_source type treemsnota.
  data: itab_found_1 type treemsnota.
  data: itab_found_2 type treemsnota.
  data: itab_result type treemsnota.
  data: wa_tree_source type treemsnodt.
  data: wa_found_1 type treemsnodt.
  data: wa_found_2 type treemsnodt.
  data: wa_result type treemsnodt.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  node_key = g_node_key.
  clear properties.

  call method simple_tree_plotlist->node_get_properties
    exporting
      node_key       = node_key
    importing
      properties     = properties
    exceptions
      node_not_found = 1
      others         = 2
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    message i055(zcl_plint_message_01)
        with node_key ''  '' ''.
    clear properties.
    exit.
  else.
    if properties-isfolder = 'X'.
*     try to get the tree
      refresh itab_tree_source.
      refresh itab_found_1.
      refresh itab_found_2.
      call method simple_tree_plotlist->get_tree
        importing
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      loop at itab_tree_source into wa_tree_source
        where relatkey = node_key.
        append wa_tree_source to itab_found_1 .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     second step
*     copy
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     third step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fourth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fifth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.

      refresh itab_et_index_rows_plotlist.
      clear wa_et_index_rows_plotlist.
      loop at itab_result into wa_result.
        split wa_result-node_key at '' into text1 text2.
        index_itab_plotjobs_tmp = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs_tmp.
        append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.
      endloop.
      sort itab_et_index_rows_plotlist by index descending.
      loop at itab_et_index_rows_plotlist
        into wa_et_index_rows_plotlist.
        read table itab_plotjobs index wa_et_index_rows_plotlist
          into wa_plotjobs.
        wa_plotjobs-prio = g_prio.
        modify itab_plotjobs index wa_et_index_rows_plotlist
          from wa_plotjobs.
      endloop.

      exit.
    else.
*     try to get the whole Information
      split node_key at '' into text1 text2.
      index_itab_plotjobs_tmp = text1.
      read table itab_plotjobs index index_itab_plotjobs_tmp
        into wa_plotjobs.
      wa_plotjobs-prio = g_prio.
      modify itab_plotjobs index index_itab_plotjobs_tmp
        from wa_plotjobs.

    endif.
  endif.



endform.                    " change_priotity_node
*&---------------------------------------------------------------------*
*&      Form  plotlist_up_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form plotlist_up_one_item.
  data: i type i.
  data: j type i.
  data: old_position type i.
  data: new_position type i.
  data: f_exit.
  clear f_exit.
* get the selected lines in the plotjob ALV
  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    read table itab_et_index_rows_plotlist
      into wa_et_index_rows_plotlist index 1.
    i =   wa_et_index_rows_plotlist-index - 1.
    old_position = wa_et_index_rows_plotlist-index - 1.

    loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist.
      j = i + 1.
      if j = wa_et_index_rows_plotlist-index.
      else.
        message i040(zcl_plint_message_01)
          with '' '' '' ''.
        exit.
      endif.
      i = i + 1.
    endloop.
    if f_exit = 'X'.
      exit.
    endif.

    new_position = wa_et_index_rows_plotlist-index.
    read table itab_plotjobs into wa_akt_plotjobs index old_position.
    if sy-subrc ne 0.
      message i041(zcl_plint_message_01)
        with '' '' '' ''.
      exit.
    else.
      delete itab_plotjobs index old_position.
      insert wa_akt_plotjobs into itab_plotjobs index new_position.
    endif.


  endif.


endform.                    " plotlist_up_one_item
*&---------------------------------------------------------------------*
*&      Form  plotlist_down_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form plotlist_down_one_item.
  data: i type i.
  data: j type i.
  data: old_position type i.
  data: new_position type i.
  data: f_exit.
  clear f_exit.
* get the selected lines in the plotjob ALV
  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    read table itab_et_index_rows_plotlist
      into wa_et_index_rows_plotlist index 1.
    i =   wa_et_index_rows_plotlist-index - 1.
    new_position = wa_et_index_rows_plotlist-index.

    loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist.
      j = i + 1.
      if j = wa_et_index_rows_plotlist-index.
      else.
        message i040(zcl_plint_message_01)
          with '' '' '' ''.
        exit.
      endif.
      i = i + 1.
    endloop.
    if f_exit = 'X'.
      exit.
    endif.
    old_position = wa_et_index_rows_plotlist-index + 1.

    read table itab_plotjobs into wa_akt_plotjobs index old_position.
    if sy-subrc ne 0.
      message i041(zcl_plint_message_01)
        with '' '' '' ''.
      exit.
    else.
      delete itab_plotjobs index old_position.
      insert wa_akt_plotjobs into itab_plotjobs index new_position.
    endif.


  endif.


endform.                    " plotlist_down_one_item
*&---------------------------------------------------------------------*
*&      Form  plottree_up_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form plottree_up_one_item.
* try to change Items from Plottree
* try to get the double clicked node
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).
  data: itab_tree_source type treemsnota.
  data: itab_found_1 type treemsnota.
  data: itab_found_2 type treemsnota.
  data: itab_result type treemsnota.
  data: wa_tree_source type treemsnodt.
  data: wa_found_1 type treemsnodt.
  data: wa_found_2 type treemsnodt.
  data: wa_result type treemsnodt.

  data: i type i.
  data: j type i.
  data: old_position type i.
  data: new_position type i.
  data: f_exit.
  clear f_exit.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  node_key = g_node_key.
  clear properties.

  call method simple_tree_plotlist->node_get_properties
    exporting
      node_key       = node_key
    importing
      properties     = properties
    exceptions
      node_not_found = 1
      others         = 2
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    message i055(zcl_plint_message_01)
        with node_key ''  '' ''.
    clear properties.
    exit.
  else.
    if properties-isfolder = 'X'.
*     try to get the tree
      refresh itab_tree_source.
      refresh itab_found_1.
      refresh itab_found_2.
      call method simple_tree_plotlist->get_tree
        importing
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      loop at itab_tree_source into wa_tree_source
        where relatkey = node_key.
        append wa_tree_source to itab_found_1 .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     second step
*     copy
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     third step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fourth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fifth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.

      refresh itab_et_index_rows_plotlist.
      clear wa_et_index_rows_plotlist.
      loop at itab_result into wa_result.
        split wa_result-node_key at '' into text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.
      endloop.

      refresh itab_tmp_plotjobs.
      read table itab_et_index_rows_plotlist
        into wa_et_index_rows_plotlist index 1.
      i =   wa_et_index_rows_plotlist-index - 1.
      old_position = wa_et_index_rows_plotlist-index - 1.

      loop at itab_et_index_rows_plotlist
        into wa_et_index_rows_plotlist.
        j = i + 1.
        if j = wa_et_index_rows_plotlist-index.
        else.
          message i040(zcl_plint_message_01)
            with '' '' '' ''.
          exit.
        endif.
        i = i + 1.
      endloop.
      if f_exit = 'X'.
        exit.
      endif.

      new_position = wa_et_index_rows_plotlist-index.
      read table itab_plotjobs into wa_akt_plotjobs index old_position.
      if sy-subrc ne 0.
        message i041(zcl_plint_message_01)
          with '' '' '' ''.
        exit.
      else.
        delete itab_plotjobs index old_position.
        insert wa_akt_plotjobs into itab_plotjobs index new_position.
      endif.
    else.
*     try to get the whole Information
      split node_key at '' into text1 text2.
      index_itab_plotjobs = text1.
      read table itab_plotjobs index index_itab_plotjobs
        into wa_akt_plotjobs.
      if sy-subrc ne 0.
        message i041(zcl_plint_message_01)
          with '' '' '' ''.
        exit.
      else.
        delete itab_plotjobs index index_itab_plotjobs.
        index_itab_plotjobs = index_itab_plotjobs - 1.
        insert wa_akt_plotjobs into itab_plotjobs
          index index_itab_plotjobs .
      endif.
    endif.
  endif.

endform.                    " plottree_up_one_item
*&---------------------------------------------------------------------*
*&      Form  plottree_down_one_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form plottree_down_one_item.
* try to change Items from Plottree
* try to get the double clicked node
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).
  data: itab_tree_source type treemsnota.
  data: itab_found_1 type treemsnota.
  data: itab_found_2 type treemsnota.
  data: itab_result type treemsnota.
  data: wa_tree_source type treemsnodt.
  data: wa_found_1 type treemsnodt.
  data: wa_found_2 type treemsnodt.
  data: wa_result type treemsnodt.

  data: i type i.
  data: j type i.
  data: old_position type i.
  data: new_position type i.
  data: f_exit.
  clear f_exit.


  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  node_key = g_node_key.
  clear properties.

  call method simple_tree_plotlist->node_get_properties
    exporting
      node_key       = node_key
    importing
      properties     = properties
    exceptions
      node_not_found = 1
      others         = 2
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    message i055(zcl_plint_message_01)
        with node_key ''  '' ''.
    clear properties.
    exit.
  else.
    if properties-isfolder = 'X'.
*     try to get the tree
      refresh itab_tree_source.
      refresh itab_found_1.
      refresh itab_found_2.
      call method simple_tree_plotlist->get_tree
        importing
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      loop at itab_tree_source into wa_tree_source
        where relatkey = node_key.
        append wa_tree_source to itab_found_1 .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     second step
*     copy
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     third step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fourth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fifth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.

      refresh itab_et_index_rows_plotlist.
      clear wa_et_index_rows_plotlist.
      loop at itab_result into wa_result.
        split wa_result-node_key at '' into text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.
      endloop.

      refresh itab_tmp_plotjobs.
      read table itab_et_index_rows_plotlist
        into wa_et_index_rows_plotlist index 1.
      i =   wa_et_index_rows_plotlist-index - 1.
      new_position = wa_et_index_rows_plotlist-index.

     loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist.
        j = i + 1.
        if j = wa_et_index_rows_plotlist-index.
        else.
          message i040(zcl_plint_message_01)
            with '' '' '' ''.
          exit.
        endif.
        i = i + 1.
      endloop.
      if f_exit = 'X'.
        exit.
      endif.
      old_position = wa_et_index_rows_plotlist-index + 1.

      read table itab_plotjobs into wa_akt_plotjobs index old_position.
      if sy-subrc ne 0.
        message i041(zcl_plint_message_01)
          with '' '' '' ''.
        exit.
      else.
        delete itab_plotjobs index old_position.
        insert wa_akt_plotjobs into itab_plotjobs index new_position.
      endif.
    else.
*     try to get the whole Information
      split node_key at '' into text1 text2.
      index_itab_plotjobs = text1.
      read table itab_plotjobs index index_itab_plotjobs
        into wa_akt_plotjobs.
      if sy-subrc ne 0.
        message i041(zcl_plint_message_01)
          with '' '' '' ''.
        exit.
      else.
        delete itab_plotjobs index index_itab_plotjobs.
        index_itab_plotjobs = index_itab_plotjobs + 1.
        insert wa_akt_plotjobs into itab_plotjobs
          index index_itab_plotjobs .
      endif.
    endif.
  endif.


endform.                    " plottree_down_one_item
*&---------------------------------------------------------------------*
*&      Form  copy_in_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form copy_in_plotlist.
  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  refresh itab_copy_cut_plotjobs.
  clear f_paste.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    sort itab_et_index_rows_plotlist by index ascending.
    loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist.
      read table itab_plotjobs into wa_akt_plotjobs
        index wa_et_index_rows_plotlist-index.
      append wa_akt_plotjobs to itab_copy_cut_plotjobs .
    endloop.
    f_paste = 'X'.
  endif.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
endform.                    " copy_in_plotlist
*&---------------------------------------------------------------------*
*&      Form  cut_in_plotList
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form cut_in_plotlist.
  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    refresh itab_copy_cut_plotjobs.
    sort itab_et_index_rows_plotlist by index descending.
    loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist.
      read table itab_plotjobs into wa_akt_plotjobs
        index wa_et_index_rows_plotlist-index.
*      APPEND wa_akt_plotjobs TO itab_copy_cut_plotjobs .
      insert wa_akt_plotjobs into itab_copy_cut_plotjobs index 1.
      delete itab_plotjobs index wa_et_index_rows_plotlist-index.
    endloop.
    f_paste = 'X'.
  endif.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
endform.                    " cut_in_plotList
*&---------------------------------------------------------------------*
*&      Form  paste_in_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form paste_in_plotlist.
  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines <> 1.
    if itab_plotjobs[] is initial.
      insert lines of itab_copy_cut_plotjobs into
        itab_plotjobs index 1.
    else.
      message e003(zcl_plint_message_01)
        with '' '' '' ''.
      exit.
    endif.
    refresh itab_et_index_rows_plotlist.
  else.
    if itab_copy_cut_plotjobs[] is initial.
      message e004(zcl_plint_message_01)
        with '' '' '' ''.
      exit.
    else.
      read table itab_et_index_rows_plotlist
        into wa_et_index_rows_plotlist index 1.
      if sy-subrc ne 0.
      else.
        insert lines of itab_copy_cut_plotjobs into
          itab_plotjobs index wa_et_index_rows_plotlist-index.
      endif.
    endif.
  endif.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
endform.                    " paste_in_plotlist
*&---------------------------------------------------------------------*
*&      Form  copy_in_plottree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form copy_in_plottree.
  perform get_sel_tree.
  if f_error is initial.
  else.
    clear f_error.
    exit.
  endif.
  refresh itab_tmp_plotjobs.
*  REFRESH itab_et_index_rows_plotlist.
  refresh itab_copy_cut_plotjobs.
  clear f_paste.
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    refresh itab_copy_cut_plotjobs.
    sort itab_et_index_rows_plotlist by index ascending.
    loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist
.
      read table itab_plotjobs into wa_akt_plotjobs
        index wa_et_index_rows_plotlist-index.
      append wa_akt_plotjobs to itab_copy_cut_plotjobs .
    endloop.
    f_paste = 'X'.
  endif.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.

endform.                    " copy_in_plottree
*&---------------------------------------------------------------------*
*&      Form  get_sel_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_sel_tree.
* try to get the selected tree items
* give the index_list back
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).
  data: itab_tree_source type treemsnota.
  data: itab_found_1 type treemsnota.
  data: itab_found_2 type treemsnota.
  data: itab_result type treemsnota.
  data: wa_tree_source type treemsnodt.
  data: wa_found_1 type treemsnodt.
  data: wa_found_2 type treemsnodt.
  data: wa_result type treemsnodt.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  node_key = g_node_key.
  clear properties.

  call method simple_tree_plotlist->node_get_properties
    exporting
      node_key       = node_key
    importing
      properties     = properties
    exceptions
      node_not_found = 1
      others         = 2
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    message i055(zcl_plint_message_01)
        with node_key ''  '' ''.
    clear properties.
    f_error = 'X'.
    exit.
  else.
    if properties-isfolder = 'X'.
*     try to get the tree
      refresh itab_tree_source.
      refresh itab_found_1.
      refresh itab_found_2.
      call method simple_tree_plotlist->get_tree
        importing
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      loop at itab_tree_source into wa_tree_source
        where relatkey = node_key.
        append wa_tree_source to itab_found_1 .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     second step
*     copy
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     third step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fourth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fifth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.

      refresh itab_et_index_rows_plotlist.
      clear wa_et_index_rows_plotlist.
      loop at itab_result into wa_result.
        split wa_result-node_key at '' into text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.
      endloop.
      exit.
    else.
*    try to get the whole information
      refresh itab_et_index_rows_plotlist.
      split node_key at '' into text1 text2.
      index_itab_plotjobs = text1.
      wa_et_index_rows_plotlist-index = index_itab_plotjobs.
      append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.
    endif.
  endif.


endform.                    " get_sel_tree
*&---------------------------------------------------------------------*
*&      Form  cut_in_plottree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form cut_in_plottree.
  perform get_sel_tree.
  if f_error is initial.
  else.
    clear f_error.
    exit.
  endif.
  refresh itab_tmp_plotjobs.
*  REFRESH itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    refresh itab_copy_cut_plotjobs.
    sort itab_et_index_rows_plotlist by index descending.
    loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist.
      read table itab_plotjobs into wa_akt_plotjobs
        index wa_et_index_rows_plotlist-index.
*      APPEND wa_akt_plotjobs TO itab_copy_cut_plotjobs .
      insert wa_akt_plotjobs into itab_copy_cut_plotjobs index 1.
      delete itab_plotjobs index wa_et_index_rows_plotlist-index.
    endloop.
    f_paste = 'X'.
  endif.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
endform.                    " cut_in_plottree
*&---------------------------------------------------------------------*
*&      Form  paste_in_plottree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form paste_in_plottree.
  perform get_sel_tree.
  if f_error is initial.
  else.
    clear f_error.
    exit.
  endif.
  refresh itab_tmp_plotjobs.
*  REFRESH itab_et_index_rows_plotlist.
*  CALL METHOD grid_plotlist->get_selected_rows
*    IMPORTING
*      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
*  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines <> 1.
*    REFRESH itab_et_index_rows_plotlist.
*    MESSAGE e003(zcl_plint_message_01)
*      WITH '' '' '' ''.
*    EXIT.
    read table itab_et_index_rows_plotlist
      into wa_et_index_rows_plotlist index 1.
    insert lines of itab_copy_cut_plotjobs into
      itab_plotjobs index wa_et_index_rows_plotlist-index.
  else.
    if itab_copy_cut_plotjobs[] is initial.
      message e004(zcl_plint_message_01)
        with '' '' '' ''.
      exit.
    else.
      read table itab_et_index_rows_plotlist
        into wa_et_index_rows_plotlist index 1.
      if sy-subrc ne 0.
      else.
        insert lines of itab_copy_cut_plotjobs into
          itab_plotjobs index wa_et_index_rows_plotlist-index.
      endif.
    endif.
  endif.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.
endform.                    " paste_in_plottree
*&---------------------------------------------------------------------*
*&      Form  maintain_CFG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_cfg.
  call transaction 'Z_CL_MNTN_CONFIG'.
endform.                    " maintain_CFG
*&---------------------------------------------------------------------*
*&      Form  maintain_applictypes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_applictypes.
  call transaction 'Z_CL_MNTN_USR_TDWP'.
endform.                    " maintain_applictypes
*&---------------------------------------------------------------------*
*&      Form  maintain_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_layout.

endform.                    " maintain_layout
*&---------------------------------------------------------------------*
*&      Form  maintain_views
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_views.
  call transaction 'Z_CL_MNTN_USR_VIEW'.
endform.                    " maintain_views
*&---------------------------------------------------------------------*
*&      Form  view_appl_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_appl_log.
*  CALL FUNCTION 'Z_CL_APPL_LOG_READ'
*            .
  call function 'Z_CL_APPL_LOG_READ_T_DISPLAY'
    exporting
      i_date        = sy-datum
      i_time        = sy-uzeit
*     I_DIFF        = '0600'
            .


endform.                    " view_appl_log
*&---------------------------------------------------------------------*
*&      Form  change_job_properties
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_job_properties.
  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  clear f_paste.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    sort itab_et_index_rows_plotlist by index ascending.
    case tbstcrt_plotlist-activetab.
      when 'TAB1_PL'.
*      Anzahl Kopien, Notizen, Voreinstellung, Verteiler
        loop at itab_et_index_rows_plotlist
          into wa_et_index_rows_plotlist.
          read table itab_plotjobs into wa_plotjobs
            index wa_et_index_rows_plotlist-index.
*         Kopien
          if  wa_akt_plotjobs-kopien is initial.
          else.
            wa_plotjobs-kopien = wa_akt_plotjobs-kopien.
          endif.
*         Notiz
          if wa_akt_plotjobs-notiz is initial.
          else.
            wa_plotjobs-notiz = wa_akt_plotjobs-notiz.
          endif.
*         Voreinstellung
          if wa_akt_plotjobs-voreinstellung is initial.
          else.
            wa_plotjobs-voreinstellung = wa_akt_plotjobs-voreinstellung.
          endif.
*         Verteiler
          if wa_akt_plotjobs-verteiler is initial.
          else.
*           Nur zugelassener Verteiler soll wählbar sein
            perform check_verteiler_on_update
              changing wa_plotjobs.
            wa_plotjobs-verteiler = wa_akt_plotjobs-verteiler.
          endif.

          modify itab_plotjobs from wa_plotjobs
            index wa_et_index_rows_plotlist-index..
        endloop.
      when 'TAB2_PL'.
*       Zielformat, SkalierenX, SkaliernY, Drehwinkel, AusgabeSpiegeln
*       Seite, Seite_von, Seite_bis
        loop at itab_et_index_rows_plotlist
          into wa_et_index_rows_plotlist.
          read table itab_plotjobs into wa_plotjobs
            index wa_et_index_rows_plotlist-index.
          wa_plotjobs-zielformat = wa_akt_plotjobs-zielformat.
          wa_plotjobs-skalieren_x = wa_akt_plotjobs-skalieren_x.
          wa_plotjobs-skalieren_y = wa_akt_plotjobs-skalieren_y.
          wa_plotjobs-spiegeln = wa_akt_plotjobs-spiegeln.
          wa_plotjobs-seite = wa_akt_plotjobs-seite.
          wa_plotjobs-seite_von = wa_akt_plotjobs-seite_von.
          wa_plotjobs-seite_bis = wa_akt_plotjobs-seite_bis.
          modify itab_plotjobs from wa_plotjobs
            index wa_et_index_rows_plotlist-index..
        endloop.
      when 'TAB3_PL'.
*       Stempel, Format, Ausrichtung, Ausgabetyp, Stifttabelle
        loop at itab_et_index_rows_plotlist
          into wa_et_index_rows_plotlist.
          read table itab_plotjobs into wa_plotjobs
            index wa_et_index_rows_plotlist-index.
          wa_plotjobs-stempel = wa_akt_plotjobs-stempel.
          wa_plotjobs-format_ausgabe = wa_akt_plotjobs-format_ausgabe.
          wa_plotjobs-ausrichtung = wa_akt_plotjobs-ausrichtung.
          wa_plotjobs-typ = wa_akt_plotjobs-typ.
          wa_plotjobs-stifttabelle = wa_akt_plotjobs-stifttabelle.
          modify itab_plotjobs from wa_plotjobs
            index wa_et_index_rows_plotlist-index..
        endloop.
      when 'TAB4_PL'.
*       Lochen, Falten, Heftrand
        loop at itab_et_index_rows_plotlist
          into wa_et_index_rows_plotlist.
          read table itab_plotjobs into wa_plotjobs
            index wa_et_index_rows_plotlist-index.
          wa_plotjobs-lochen = wa_akt_plotjobs-lochen.
          wa_plotjobs-falten = wa_akt_plotjobs-falten.
          wa_plotjobs-heftrand = wa_akt_plotjobs-heftrand.
          modify itab_plotjobs from wa_plotjobs
            index wa_et_index_rows_plotlist-index..
        endloop.
      when 'TAB5_PL'.
*       Satzanzahl, Deckblatt, Endeblatt, Inhaltsverzeichnis
*       Inhaltsblatt
        loop at itab_et_index_rows_plotlist
          into wa_et_index_rows_plotlist.
          read table itab_plotjobs into wa_plotjobs
            index wa_et_index_rows_plotlist-index.
          wa_plotjobs-satzanzahl = wa_akt_plotjobs-satzanzahl.
          wa_plotjobs-deckblatt = wa_akt_plotjobs-deckblatt.
          wa_plotjobs-endeblatt = wa_akt_plotjobs-endeblatt.
          wa_plotjobs-knz_inhalt_vz =
            wa_akt_plotjobs-knz_inhalt_vz.
          wa_plotjobs-inhaltsblatt = wa_akt_plotjobs-inhaltsblatt.
          modify itab_plotjobs from wa_plotjobs
            index wa_et_index_rows_plotlist-index..
        endloop.
      when 'TAB6_PL'.
*       Verkaufsbelegnummer, Auftragsnummer,
        loop at itab_et_index_rows_plotlist
          into wa_et_index_rows_plotlist.
          read table itab_plotjobs into wa_plotjobs
            index wa_et_index_rows_plotlist-index.
*         VBELn
          if wa_akt_plotjobs-vbeln is initial.
          else.
            wa_plotjobs-vbeln = wa_akt_plotjobs-vbeln.
          endif.
*         AUFNR
          if wa_akt_plotjobs-aufnr is initial.
          else.
            wa_plotjobs-aufnr = wa_akt_plotjobs-aufnr.
          endif.
*         FIRMA
          if wa_akt_plotjobs-firma is initial.
          else.
            wa_plotjobs-firma = wa_akt_plotjobs-firma.
          endif.
*         KOSTL
          if wa_akt_plotjobs-kostl is initial.
          else.
            wa_plotjobs-kostl = wa_akt_plotjobs-kostl.
          endif.
*         PSPID
          if wa_akt_plotjobs-pspid is initial.
          else.
            wa_plotjobs-pspid = wa_akt_plotjobs-pspid.
          endif.
*         ID_PLOTJOB
          if wa_akt_plotjobs-id_plotjob is initial.
          else.
            wa_plotjobs-id_plotjob = wa_akt_plotjobs-id_plotjob.
          endif.
*         EBELN
          if wa_akt_plotjobs-ebeln is initial.
          else.
            wa_plotjobs-ebeln = wa_akt_plotjobs-ebeln.
          endif.
*         LIFNR
          if wa_akt_plotjobs-lifnr is initial.
          else.
            wa_plotjobs-lifnr = wa_akt_plotjobs-lifnr.
          endif.
*         NAME1_LIFNR
          if wa_akt_plotjobs-name1_lifnr is initial.
          else.
            wa_plotjobs-name1_lifnr = wa_akt_plotjobs-name1_lifnr.
          endif.

          modify itab_plotjobs from wa_plotjobs
            index wa_et_index_rows_plotlist-index..
        endloop.
      when 'TAB7_PL'.
*       Lieferantendaten
        loop at itab_et_index_rows_plotlist
          into wa_et_index_rows_plotlist.
          read table itab_plotjobs into wa_plotjobs
            index wa_et_index_rows_plotlist-index.
*         EBELN
          if wa_akt_plotjobs-ebeln is initial.
          else.
            wa_plotjobs-ebeln = wa_akt_plotjobs-ebeln.
          endif.
*         LIFNR
          if wa_akt_plotjobs-lifnr is initial.
          else.
            wa_plotjobs-lifnr = wa_akt_plotjobs-lifnr.
          endif.
*         NAME1_LIFNR
          if wa_akt_plotjobs-name1_lifnr is initial.
          else.
            wa_plotjobs-name1_lifnr = wa_akt_plotjobs-name1_lifnr.
          endif.
*         LIF_FAXNR_LONG
          if wa_akt_plotjobs-lif_faxnr_long is initial.
          else.
            wa_plotjobs-lif_faxnr_long = wa_akt_plotjobs-lif_faxnr_long.
          endif.
*         LIF_TELNR_LONG
          if wa_akt_plotjobs-lif_telnr_long is initial.
          else.
            wa_plotjobs-lif_telnr_long = wa_akt_plotjobs-lif_telnr_long.
          endif.
*         LIF_SMTP_ADDR
          if wa_akt_plotjobs-lif_smtp_addr is initial.
          else.
            wa_plotjobs-lif_smtp_addr = wa_akt_plotjobs-lif_smtp_addr.
          endif.

          modify itab_plotjobs from wa_plotjobs
            index wa_et_index_rows_plotlist-index..
        endloop.

    endcase.
  endif.
*  MESSAGE i002(zcl_plint_message_01)
*    WITH '' '' '' ''.

endform.                    " change_job_properties
*&---------------------------------------------------------------------*
*&      Form  change_job_properties_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_job_properties_tree.
  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.

  "PERFORM get_sel_tree.
  "PERFORM get_sel_tree_2.

  perform sel_tree_to_sel_list.
  perform change_job_properties.

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

endform.                    " change_job_properties_tree
*&---------------------------------------------------------------------*
*&      Form  maintain_cfg_00
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_cfg_00.
* allgemeine konfiguration
  call transaction 'Z_CL_MNTN_CFG_00'.
endform.                    " maintain_cfg_00
*&---------------------------------------------------------------------*
*&      Form  get_default_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_default_values.
* get same user values from configuration tables
**
  data: pwert type pwert.
  data: pname type pname.
  data: tmp_str(255).


* Stempelsprache für sprachabhängige Stempel
  set parameter id 'ZCL_STAMP_LANGUAGE' field sy-langu.

*  CLEAR default_data.

  call function '/CIDEON/READ_DEFAULTDATA'
       exporting
            i_batch        = ''
       importing
            o_default_data = default_data.


endform.                    " get_default_values
*&---------------------------------------------------------------------*
*&      Form  maintain_mail_cfg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_mail_cfg.
  call transaction 'Z_CL_MNTN_MAIL_CFG'.
endform.                    " maintain_mail_cfg
*&---------------------------------------------------------------------*
*&      Form  maintain_user_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_user_group.
  call transaction 'Z_CL_MNTN_USR_GRP_TB'.
endform.                    " maintain_user_group
*&---------------------------------------------------------------------*
*&      Form  get_default_verteiler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_default_verteiler.
* try to get the default distributor
  clear wa_default_verteiler.
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


  call function '/CIDEON/GET_DEFAULT_VERTEILER'
       exporting
            i_wa_user_data         = user_data
            i_wa_default_data      = default_data
       importing
            o_wa_default_verteiler = wa_default_verteiler
       exceptions
            error                  = 1
            others                 = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " get_default_verteiler
*&---------------------------------------------------------------------*
*&      Form  update_on_enter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_on_enter.
* makes some updates / specialy if an F4 help occurs
  if f_f4_voreinstellung = 'X'.
    clear f_f4_voreinstellung.
    if wa_old_plotjobs-voreinstellung <> wa_akt_plotjobs-voreinstellung.
      clear wa_voreinstellung.
      select single * from zcl_voreinstell
        into wa_voreinstellung
        where uname = wa_akt_plotjobs-uname
        and voreinstellung = wa_akt_plotjobs-voreinstellung
        .
      if sy-subrc ne 0.
        message s052(zcl_plint_tools)
          with 'zcl_voreinstell' text-050
          wa_akt_plotjobs-uname
          wa_akt_plotjobs-voreinstellung
          .
      else.
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
      endif.
    else.
    endif.
  else.
  endif.

endform.                    " update_on_enter
*&---------------------------------------------------------------------*
*&      Form  add_objectkey_to_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_objectkey_to_plotlist.
  loop at itab_tmp_plotjobs into wa_plotjobs.
    call function 'Z_CL_MAKE_OBJECT_KEY'
         exporting
              i_dokar = wa_plotjobs-dokar
              i_doknr = wa_plotjobs-doknr
              i_dokvr = wa_plotjobs-dokvr
              i_doktl = wa_plotjobs-doktl
         importing
              o_objky = wa_plotjobs-objky
         exceptions
              error   = 1
              others  = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.
endform.                    " add_objectkey_to_plotlist
*&---------------------------------------------------------------------*
*&      Form  add_format_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_format_field.
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

  call function '/CIDEON/ADD_FORMAT_FIELD'
       exporting
            i_wa_default_data = default_data
       tables
            itab_tmp_plotjobs = itab_tmp_plotjobs
       exceptions
            error             = 1
            others            = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " add_format_field
*&---------------------------------------------------------------------*
*&      Form  make_send_log_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_send_log_entries.
  call function '/CIDEON/MAKE_SEND_LOG_ENTRIES'
       exporting
            i_msgid         = 'ZCL_PLINT_MESSAGE_01'
            i_msgno         = '101'
       tables
            i_itab_plotjobs = itab_tmp_plotjobs
       exceptions
            error           = 1
            others          = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


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

endform.                    " make_send_log_entries
*&---------------------------------------------------------------------*
*&      Form  set_screen_attributes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_screen_attributes.
  if user_data-knz_use_post = 'X'.
  else.
    loop at screen.
      if screen-group3 = 'POS'.
        screen-input = '1'.
      else.
      endif.
      if screen-group3 = 'PRE'.
        screen-input = '0'.
        screen-invisible = '1'.
      else.
      endif.
      modify screen.
    endloop.
  endif.

  case user_data-modus.
    when 'SUPER'.
    when 'ADMIN'.
    when 'NORMAL'.
      loop at screen.
        if screen-group2 = 'NRM'.
          screen-input = '0'.
        endif.
        modify screen.
      endloop.
  endcase.

  loop at screen.
    if screen-group3 = 'INV'.
      screen-invisible = '1'.
      screen-input = '0'.
      screen-output = '0'.
    else.
    endif.
    modify screen.
  endloop.

*  LOOP AT SCREEN.
*    IF screen-group4 = 'INV'.
*      screen-invisible = '1'.
*      screen-input = '0'.
*      screen-output = '0'.
*    ELSE.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

endform.                    " set_screen_attributes
*&---------------------------------------------------------------------*
*&      Form  get_data_sl_sueckliste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_data_sl_stueckliste.
* search in a document part list
* 09.08.2006 - Mitgabe der Stücklisteninformationen / oberstes Element
*ITAB
  data: itab_stpo_api02 type table of stpo_api02.
  data: itab_stpo_1 type table of stpo_api02.
  data: itab_stpo_2 type table of stpo_api02.
  data: itab_stpo_result type table of stpo_api02.
  data: itab_draw type table of draw.

  data: itab_documentstructure type table of bapi_doc_structure.
*WA
  data: wa_stpo_api02 type stpo_api02.
  data: document type csap_dbom-doknr.
  data: doc_type type csap_dbom-dokar.
  data: doc_vers type csap_dbom-dokvr.
  data: doc_part type csap_dbom-doktl.
  data: wa_dost type dost.
  data: wa_draw type draw.
  data: wa_stored_search type zcl_psb_tmp.

  data: return type bapiret2.
  data: wa_documentstructure type bapi_doc_structure.
*NORMAL
  data: laenge type i.
  data: char25(25).
  data: anzahl type i.

  refresh itab_search_tmp.
  refresh itab_stpo_api02.

  call function 'Z_CL_PLINT_ASK_DOCUMENT_NR'
       importing
            o_doknr = document
            o_dokar = doc_type
            o_dokvr = doc_vers
            o_doktl = doc_part
       exceptions
            error   = 1
            others  = 2.
  if sy-subrc <> 0.
    exit.
  endif.

  select single * from dost into wa_dost
    where doknr = document
    and dokar = doc_type
    and dokvr = doc_vers
    and doktl = doc_part
    .
  if sy-subrc ne 0.
    message i071(zcl_plint_tools)
      with document doc_type doc_part doc_vers.
    exit.
  else.
  endif.

  clear wa_stored_search.
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

  refresh itab_documentstructure.
  clear wa_documentstructure.
  call function 'BAPI_DOCUMENT_GETSTRUCTURE'
    exporting
      documenttype              = wa_stored_search-dokar
      documentnumber            = wa_stored_search-doknr
      documentpart              = wa_stored_search-doktl
      documentversion           = wa_stored_search-dokvr
      multilevelexplosion       = 'X'
*     DOCBOMCHANGENUMBER        =
*     DOCBOMVALIDFROM           =
*     DOCBOMREVISIONLEVEL       =
    importing
      return                    = return
    tables
      documentstructure         = itab_documentstructure
            .

  refresh itab_draw.
  loop at itab_documentstructure into wa_documentstructure.
    clear wa_draw.
    wa_draw-dokar = wa_documentstructure-documenttype.
    wa_draw-doknr = wa_documentstructure-documentnumber.
    wa_draw-doktl = wa_documentstructure-documentpart.
    wa_draw-dokvr = wa_documentstructure-documentversion.
    append wa_draw to itab_draw.
  endloop.

  clear wa_draw.
  wa_draw-dokar           = wa_stored_search-dokar.
  wa_draw-doknr           = wa_stored_search-doknr.
  wa_draw-dokvr           = wa_stored_search-dokvr.
  wa_draw-doktl           = wa_stored_search-doktl.
  "APPEND wa_draw TO itab_draw.
  insert wa_draw into itab_draw index 1.

  clear wa_search.

  loop at itab_draw into wa_draw.
    select single * from draw into
      corresponding fields of wa_search
      where doknr = wa_draw-doknr
      and dokar = wa_draw-dokar
      and doktl = wa_draw-doktl
      and dokvr = wa_draw-dokvr
      .
    if sy-subrc ne 0.
      wa_search-doknr = wa_draw-doknr.
      wa_search-dokar = wa_draw-dokar.
      wa_search-doktl = wa_draw-doktl.
      wa_search-dokvr = wa_draw-dokvr.

      wa_search-stlnr = wa_dost-stlnr.

      wa_search-dokar_bom = doc_type.
      wa_search-doknr_bom = document.
      wa_search-doktl_bom = doc_part.
      wa_search-dokvr_bom = doc_vers.

      append wa_search to itab_search.
    else.
      wa_search-stlnr = wa_dost-stlnr.

      wa_search-dokar_bom = doc_type.
      wa_search-doknr_bom = document.
      wa_search-doktl_bom = doc_part.
      wa_search-dokvr_bom = doc_vers.

      append wa_search to itab_search.
    endif.
  endloop.


endform.                    " get_data_sl_sueckliste
*&---------------------------------------------------------------------*
*&      Form  maintain_tiff_Komp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_tiff_komp.
  call transaction 'Z_CL_MNTN_TIFF_KOMP'.
endform.                    " maintain_tiff_Komp
*&---------------------------------------------------------------------*
*&      Form  add_compression_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_compression_field.
  data: tmp_kompression like zcl_comp_tiff-typ_kompression.
  data: langu type sy-langu.


  loop at itab_tmp_plotjobs into wa_plotjobs.
    if wa_plotjobs-kompression is initial.
    else.
      continue.
    endif.
    clear tmp_kompression.
    set locale language langu.
    translate wa_plotjobs-typ to upper case.
    set locale language space.
    select single typ_kompression from zcl_comp_tiff
      into tmp_kompression
      where typ_tiff = wa_plotjobs-typ
      .
    if sy-subrc ne 0.
      wa_plotjobs-kompression = 'KEINE'.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    else.
      wa_plotjobs-kompression = tmp_kompression.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    endif.
  endloop.


endform.                    " add_compression_field
*&---------------------------------------------------------------------*
*&      Form  add_dttrg_to_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_dttrg_to_search.
  clear wa_search_tmp.
  clear wa_search.
  loop at itab_search_tmp into wa_search_tmp.
    select single dttrg from draw
      into wa_search_tmp-dttrg
      where dokar = wa_search_tmp-dokar
      and doknr = wa_search_tmp-doknr
      and dokvr = wa_search_tmp-dokvr
      and doktl = wa_search_tmp-doktl
      .
    if sy-subrc ne 0.
      clear wa_search_tmp-dttrg.
    else.
    endif.
    modify itab_search_tmp from wa_search_tmp index sy-tabix.
  endloop.
endform.                    " add_dttrg_to_search
*&---------------------------------------------------------------------*
*&      Form  check_kapro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_kapro.
* if the File is checked in then dowload it to a temp. path
  data: tmp_path type bapi_doc_aux-filename.
  "  tmp_path = 'c:\temp\'.
  tmp_path = user_data-view_down_path.

  if wa_plotjobs-checked = 'X'.
    call function 'SAPGUI_PROGRESS_INDICATOR'
         exporting
              percentage = '15'  " Balkenanzeige
              text       = text-010.

    call function 'Z_CL_PLINT_DOWNLOAD_CHECK_FILE'
         exporting
              i_wa_plotjobs = wa_plotjobs
              i_temp_path   = tmp_path
         importing
              o_filename    = wa_plotjobs-filep
         exceptions
              error         = 1
              others        = 2.
    if sy-subrc <> 0.
      message i065(zcl_plint_message_01) with
        wa_plotjobs-filep  tmp_path'' ''.
    endif.

*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              percentage = '90'  " Balkenanzeige
*              text       = text-010.
  else.
  endif.

endform.                    " check_kapro
*&---------------------------------------------------------------------*
*&      Form  delete_after_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form delete_after_view.
  data: tmp_filename type rlgrap-filename.
  data: return type c.
  data: str_filename type string.
  data: rc type i.

  tmp_filename = wa_plotjobs-filep.

  if wa_plotjobs-checked = 'X'.

    create object frontend_service
*      EXPORTING
*        TITLE  =
*        INIT_DIRECTORY =
        .

    str_filename = tmp_filename.
    call method frontend_service->file_delete
      exporting
        filename           = str_filename
      changing
        rc                 = rc
      exceptions
        file_delete_failed = 1
        cntl_error         = 2
        error_no_gui       = 3
        file_not_found     = 4
        access_denied      = 5
        unknown_error      = 6
        others             = 7
            .
    if sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     einfügen,. Datei nicht gelöscht werden konnte
      msgv1 =  tmp_filename.
      msgv2 = 'ZCL_PLINT_DESIGN_007F01'.
      msgv3 = 'delete_after_view'.
      call function '/CIDEON/APPL_LOG_WRITE_2'
           exporting
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
           exceptions
                error      = 1
                others     = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

    endif.



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
  else.
  endif.

endform.                    " delete_after_view
*&---------------------------------------------------------------------*
*&      Form  change_kompression
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_kompression.
  data: tmp_kompression like zcl_comp_tiff-typ_kompression.

  clear tmp_kompression.
  select single typ_kompression from zcl_comp_tiff
    into tmp_kompression
    where typ_tiff = wa_akt_plotjobs-typ
    .
  if sy-subrc ne 0.
  else.
    wa_akt_plotjobs-kompression = tmp_kompression.
  endif.

endform.                    " change_kompression
*&---------------------------------------------------------------------*
*&      Form  add_client_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_client_data.
* Adds special client data to plotjobs
  data: wa_kna1 like kna1.
  data: mailadresse type ad_smtpadr.
  data: n10(10) type n.

  clear wa_kna1.
  clear mailadresse.

  if user_data-knz_user_dummy = 'X'.
    if user_data-user_dummy_kunnr is initial.
      message i020(zcl_plint_message_01) with '' '' '' ''.
      exit.
    else.
      n10 = user_data-user_dummy_kunnr.
      select single * from kna1 into wa_kna1
        where kunnr = n10
        .
      if sy-subrc ne 0.
        message i021(zcl_plint_message_01)
          with user_data-user_dummy_kunnr '' '' ''.
        exit.
      else.
        select single smtp_addr from adr6
          into mailadresse
          where addrnumber = wa_kna1-adrnr.
        if sy-subrc ne 0.
        else.
        endif.
      endif.
    endif.
  else.
  endif.

  loop at itab_tmp_plotjobs into wa_plotjobs.
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


    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.

  endloop.

endform.                    " add_client_data
*&---------------------------------------------------------------------*
*&      Form  add_cost_center
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_cost_center.
* try to get the cost center for the user
  data: kostl like wa_plotjobs-kostl.

  if user_data-knz_use_kostl = 'X'.
  else.
    exit.
  endif.


  call function 'Z_CL_ASK_FOR_COSTCENTER'
       exporting
            i_user          = sy-uname
       importing
            o_kostl         = kostl
       exceptions
            error           = 1
            pernr_not_found = 2
            kostl_not_found = 3
            others          = 4.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  make LOG entry
    clear msgv1.
    clear msgv2.
    clear msgv3.
    clear msgv4.
    msgv1 = sy-uname.
    call function '/CIDEON/APPL_LOG_WRITE_2'
         exporting
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
         exceptions
              error      = 1
              others     = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

    exit.
  endif.


  loop at itab_tmp_plotjobs into wa_plotjobs.
    wa_plotjobs-kostl = kostl.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.

endform.                    " add_cost_center
*&---------------------------------------------------------------------*
*&      Form  add_special_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_special_fields.
* adds special fields like Satzanzahl, Deckblatt usw.
*SATZANZAHL
*DECKBLATT
*ENDEBLATT
*KNZ_INHALT_VZ

  loop at itab_tmp_plotjobs into wa_plotjobs.
    wa_plotjobs-satzanzahl = default_data-default_satzanzahl.
    wa_plotjobs-deckblatt = default_data-default_deckblatt.
    wa_plotjobs-endeblatt = default_data-default_endeblatt.
    wa_plotjobs-knz_inhalt_vz = default_data-default_knz_inhalt_vz.

    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.

endform.                    " add_special_fields
*&---------------------------------------------------------------------*
*&      Form  read_stored_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_stored_search.
* try to read stored search entries
*ITAB
  data: itab_stpo_api02 type table of stpo_api02.
  data: itab_stpo_1 type table of stpo_api02.
  data: itab_stpo_2 type table of stpo_api02.
  data: itab_stpo_result type table of stpo_api02.
  data: itab_draw type table of draw.
*WA
  data: wa_stpo_api02 type stpo_api02.
  data: wa_draw type draw.
*NORMA
  data: document type csap_dbom-doknr.
  data: doc_type type csap_dbom-dokar.
  data: doc_vers type csap_dbom-dokvr.
  data: doc_part type csap_dbom-doktl.
  data: wa_dost type dost.
  data: laenge type i.
  data: char25(25).
  data: anzahl type i.

  data: itab_stored_search type table of zcl_psb_tmp.
  data: wa_stored_search type zcl_psb_tmp.

  data: f_lesen(1).

  break_point.                                             "#EC NOBREAK

* Lesen oder nicht Lesen, daß ist hier die Frage :-))
*  IMPORT f_lesen FROM MEMORY ID 'PLOT_READ_AKT_QUEUE'.
*  EXPORT ''
*    TO MEMORY ID 'PLOT_READ_AKT_QUEUE'.
  "break steurich.
  get parameter id 'Z_PL_READ_AKT_QUEUE' field f_lesen.
  if f_lesen = 'X'.
  else.
    exit.
  endif.

  if user_data-read_tmp_search = 'X'.
  else.
    if user_data-delete_tmp_search = 'X'.
      delete from zcl_psb_tmp
        where uname = user_data-uname
        .
      if sy-subrc ne 0.
      else.
      endif.
    else.
    endif.
    exit.
  endif.

  refresh itab_stored_search.
  clear wa_stored_search.

  select * from zcl_psb_tmp into table itab_stored_search
    where
    uname = user_data-uname
    order by counter
    .
  if sy-subrc ne 0.
    exit.
  else.
  endif.

  loop at itab_stored_search into wa_stored_search.
    clear wa_search.

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
    case wa_stored_search-object_type.
      when 'BILLOFDOC'.

*        CLEAR wa_search.

        call function 'Z_CL_GET_BILLOFDOC_ALL'
             exporting
                  i_dokar     = wa_stored_search-dokar
                  i_doknr     = wa_stored_search-doknr
                  i_dokvr     = wa_stored_search-dokvr
                  i_doktl     = wa_stored_search-doktl
             tables
                  o_itab_draw = itab_draw
             exceptions
                  error       = 1
                  others      = 2.
        if sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.

        clear wa_draw.
        wa_draw-dokar           = wa_stored_search-dokar.
        wa_draw-doknr           = wa_stored_search-doknr.
        wa_draw-dokvr           = wa_stored_search-dokvr.
        wa_draw-doktl           = wa_stored_search-doktl.
        "APPEND wa_draw TO itab_draw.
        insert wa_draw into itab_draw index 1.

        loop at itab_draw into wa_draw.
          select single * from draw into
            corresponding fields of wa_search
            where doknr = wa_draw-doknr
            and dokar = wa_draw-dokar
            and doktl = wa_draw-doktl
            and dokvr = wa_draw-dokvr
            .
          if sy-subrc ne 0.
            wa_search-doknr = wa_draw-doknr.
            wa_search-dokar = wa_draw-dokar.
            wa_search-doktl = wa_draw-doktl.
            wa_search-dokvr = wa_draw-dokvr.
            append wa_search to itab_search.
          else.
            append wa_search to itab_search.
          endif.
        endloop.

      when 'DOCUMENT'.
*        CLEAR wa_search.
        select single * from draw into
          corresponding fields of wa_search
          where dokar = wa_stored_search-dokar
          and doknr = wa_stored_search-doknr
          and dokvr = wa_stored_search-dokvr
          and doktl = wa_stored_search-doktl
          .
        if sy-subrc ne 0.
        else.
          wa_search-id_sl = wa_stored_search-id_sl.
          wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
          wa_search-aufpl = wa_stored_search-aufpl.
          wa_search-aplzl = wa_stored_search-aplzl.
          wa_search-knz_affl = wa_stored_search-knz_affl.
          wa_search-knz_afvc = wa_stored_search-knz_afvc.

          wa_search-verteiler = wa_stored_search-verteiler.

          wa_search-folnr = wa_stored_search-folnr.
          wa_search-vornr = wa_stored_search-vornr.

          append wa_search to itab_search.
        endif.
      when 'STUECKLIST'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        append wa_search to itab_search.
      when 'FOLGE'.
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

        append wa_search to itab_search.
      when 'VORGANG'.
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

        append wa_search to itab_search.
      when 'SPOOL'.
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

        append wa_search to itab_search.
    endcase.
  endloop.

  if user_data-delete_tmp_search = 'X'.
    delete from zcl_psb_tmp
      where uname = user_data-uname
      .
    if sy-subrc ne 0.
    else.
    endif.
  else.
  endif.

endform.                    " read_stored_search
*&---------------------------------------------------------------------*
*&      Form  cv03n_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form cv03n_view.
* calls Transactionb 'cv03n'
  refresh itab_et_index_rows_searchlist.
  call method grid_searchlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_searchlist lines count_lines.
  if count_lines <> 1.
    refresh itab_et_index_rows_searchlist.
    message e000(zcl_plint_message_01)
      with text-051 count_lines '' ''.
    exit.
  else.
    read table itab_et_index_rows_searchlist
      into wa_et_index_rows_searchlist index 1.
    read table itab_search into wa_search
      index wa_et_index_rows_searchlist-index .
  endif.

* Spoolbehandlung
  if wa_search-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_search-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.

  set parameter id 'CV1' field wa_search-doknr.
  set parameter id 'CV2' field wa_search-dokar.
  set parameter id 'CV3' field wa_search-dokvr.
  set parameter id 'CV4' field wa_search-doktl.

  call transaction 'CV03N' and skip first screen.

endform.                    " cv03n_view
*&---------------------------------------------------------------------*
*&      Form  get_latest_path_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_latest_path_entries.
* try to check if there are another path availible
  data: pwert type pwert.
  data: pname type pname.
  data: tmp_str(255).

* ck 02.04.2003 Änderung
* generelles Reload der Einstellungen vor dem Senden
  perform get_default_values.
  perform get_user_values.
  exit.
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
  clear tmp_str.
  select klient_down_pfad
    from zcl_preprozessor
    into tmp_str
    where preprozessor in
    (  select preprozessor
         from zcl_preproz_user
         where uname = default_data-default_nutzer
         and status = c_status_aktiv
    ).
  endselect.
  if sy-subrc ne 0.
    message e052(zcl_plint_tools)
      with 'zcl_preprozessor' default_data-default_nutzer
      '' ''.
  else.
    default_data-down_path = tmp_str.
  endif.


* PPL_DOWN_PATH
  if user_data-knz_use_post = 'X'.
    clear tmp_str.
    pname = 'PPL_DOWN_PATH'.
    select pwert from zcl_plint_cfg_00
      into tmp_str
      where pname = pname
      .
    endselect.
    if sy-subrc ne 0.
      message e052(zcl_plint_tools)
        with 'zcl_plint_cfg_00' pname
        '' ''.
    else.
      default_data-ppl_down_path = tmp_str.
    endif.
  else.
  endif.

* VIEW_DOWN_PATH
  clear tmp_str.
  pname = 'VIEW_DOWN_PATH'.
  select pwert from zcl_plint_cfg_00
    into tmp_str
    where pname = pname
    .
  endselect.
  if sy-subrc ne 0.
    message e052(zcl_plint_tools)
      with 'zcl_plint_cfg_00' pname
      '' ''.
  else.
    default_data-view_down_path = tmp_str.
  endif.

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
  clear tmp_str.
  select klient_scan_pfad
    from zcl_preprozessor
    into tmp_str
    where preprozessor in
    (  select preprozessor
         from zcl_preproz_user
         where uname = default_data-default_nutzer
         and status = c_status_aktiv
    ).
  endselect.
  if sy-subrc ne 0.
    message e052(zcl_plint_tools)
      with 'zcl_preprozessor' default_data-default_nutzer
      '' ''.
  else.
    default_data-clf_down_path = tmp_str.
  endif.


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
  clear tmp_str.
  select klient_down_pfad
    from zcl_preprozessor
    into tmp_str
    where preprozessor in
    (  select preprozessor
         from zcl_preproz_user
         where uname = sy-uname
         and status = c_status_aktiv
    ).
  endselect.
  if sy-subrc ne 0.
    user_data-down_path = default_data-down_path.
  else.
    user_data-down_path = tmp_str.
  endif.

*PPL_DOWN_PATH
  if user_data-knz_use_post = 'X'.
    clear tmp_str.
    pname = 'PPL_DOWN_PATH'.
    select pwert from zcl_plint_config
      into tmp_str
      where uname = sy-uname
      and pname = pname
      .
    endselect.
    if sy-subrc ne 0.
      user_data-ppl_down_path = default_data-ppl_down_path.
    else.
      user_data-ppl_down_path = tmp_str.
    endif.
  else.
  endif.

*VIEW_DOWN_PATH
  clear tmp_str.
  pname = 'VIEW_DOWN_PATH'.
  select pwert from zcl_plint_config
    into tmp_str
    where uname = sy-uname
    and pname = pname
    .
  endselect.
  if sy-subrc ne 0.
    user_data-view_down_path = default_data-view_down_path.
  else.
    user_data-view_down_path = tmp_str.
  endif.

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
  clear tmp_str.
  select klient_scan_pfad
    from zcl_preprozessor
    into tmp_str
    where preprozessor in
    (  select preprozessor
         from zcl_preproz_user
         where uname = sy-uname
         and status = c_status_aktiv
    ).
  endselect.
  if sy-subrc ne 0.
    user_data-clf_down_path = default_data-clf_down_path.
  else.
    user_data-clf_down_path = tmp_str.
  endif.


*USE_HOSTNAME
  clear tmp_str.
  pname = 'USE_HOSTNAME'.
  select pwert from zcl_plint_config
    into tmp_str
    where uname = sy-uname
    and pname = pname
    .
  endselect.
  if sy-subrc ne 0.
    user_data-use_hostname = ''.
  else.
    user_data-use_hostname = tmp_str.
  endif.

*set Hostname
  call function 'CV120_GET_HOSTNAME'
       exporting
            pf_batch          = ' '
       importing
            pfx_host          = user_data-hostname
       exceptions
            error             = 1
            no_valid_frontend = 2
            others            = 3.
  if sy-subrc <> 0.
    user_data-hostname = ''.
  else.
    clear wa_usr_host_cfg.
    select single * from zcl_usr_host_cfg
      into wa_usr_host_cfg
      where uname = sy-uname
      and host = user_data-hostname
      .
    if sy-subrc ne 0.
*   APPL-LOG
    else.
      user_data-ppl_down_path = wa_usr_host_cfg-ppl_down_path.
      user_data-down_path = wa_usr_host_cfg-down_path.
    endif.
  endif.

endform.                    " get_latest_path_entries
*&---------------------------------------------------------------------*
*&      Form  check_priorties
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_priorities.
* sets the priorities to allowed values
  loop at itab_tmp_plotjobs into wa_plotjobs.
    if wa_plotjobs-prio > user_data-prio_bis.
      wa_plotjobs-prio = user_data-prio_bis.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    else.
    endif.
    if wa_plotjobs-prio < user_data-prio_von.
      wa_plotjobs-prio = user_data-prio_von.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    else.
    endif.
  endloop.

endform.                    " check_priorties
*&---------------------------------------------------------------------*
*&      Form  view_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_info.
* displays an INFO
  data: url(255) type c.

  call function 'Z_CL_PICTURE_LOAD_FROM_DB'
       exporting
            id     = 'PLOT_001'
       importing
            o_url  = url
       exceptions
            error  = 1
            others = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " view_info
