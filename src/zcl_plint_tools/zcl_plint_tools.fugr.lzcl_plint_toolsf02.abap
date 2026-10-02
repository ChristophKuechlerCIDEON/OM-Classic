*----------------------------------------------------------------------*
*   INCLUDE LZCL_PLINT_TOOLSF02                                        *
*---------------------------------------------------------------------


*INCLUDE lcvbapif03.
*INCLUDE lcvbapif01.
*INCLUDE lcvapi01f01.
*INCLUDE lcvapi01f17.
*INCLUDE lcvapi01f09.
*INCLUDE lcvapi01f03.
*INCLUDE lcvapi01f07.
*INCLUDE lcvapi01f11.
*&---------------------------------------------------------------------*
*&      Form  get_selectet_rows
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_selectet_rows.
* get the selected line in the fail_documents ALV
  data: index_itab_fail_doc type sy-tabix.

  refresh itab_et_index_rows_fail_doc.
  refresh itab_tmp_fail_document.
  call method fail_document_alv->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_fail_doc.
*      ET_ROW_NO     =
  .
  loop at itab_et_index_rows_fail_doc into wa_et_index_rows_fail_doc.
    clear wa_fail_document.
    clear wa_fail_document_alv.
    index_itab_fail_doc = wa_et_index_rows_fail_doc-index.
    read table itab_fail_document_alv index index_itab_fail_doc
      into wa_fail_document_alv.
    move-corresponding wa_fail_document_alv to wa_fail_document.
    append wa_fail_document to itab_tmp_fail_document.
  endloop.


endform.                    " get_selectet_rows
*&---------------------------------------------------------------------*
*&      Form  get_selectet_rows_zori
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_selectet_rows_zori.
* get the selected line in the zori_documents ALV
  data: index_itab_zori_doc type sy-tabix.

  refresh itab_et_index_rows_zori_doc.
  refresh itab_tmp_zori_doc_files.
  refresh itab_tmp_zori_doc_files_detail.
  call method zori_document_alv->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_zori_doc.
*      ET_ROW_NO     =
  .
  loop at itab_et_index_rows_zori_doc into wa_et_index_rows_zori_doc.
    clear wa_zori_doc_files.
    clear wa_zori_doc_files_alv.
    index_itab_zori_doc = wa_et_index_rows_zori_doc-index.

    read table itab_zori_doc_files_alv index index_itab_zori_doc
      into wa_zori_doc_files_alv.
    append wa_zori_doc_files_alv to itab_tmp_zori_doc_files.

    read table itab_zori_doc_files_detail index index_itab_zori_doc
      into wa_tmp_zori_doc_files_detail.
    append wa_tmp_zori_doc_files_detail to
      itab_tmp_zori_doc_files_detail.

  endloop.


endform.                    " get_selectet_rows_zori
*&---------------------------------------------------------------------*
*&      Form  View_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_doc.
* try to view selected document

  set parameter id 'CV1' field wa_fail_document_alv-doknr.
  set parameter id 'CV2' field wa_fail_document_alv-dokar.
  set parameter id 'CV3' field wa_fail_document_alv-dokvr.
  set parameter id 'CV4' field wa_fail_document_alv-doktl.

  call transaction 'CV03N' and skip first screen.

endform.                    " View_doc
*&---------------------------------------------------------------------*
*&      Form  view_sel_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_sel_doc.
* try to view selected document
* itab_fail_document_alv

* get the selected line in the fail_documents ALV
  data: index_itab_fail_doc type sy-tabix.
  data: count_lines type i.

  refresh itab_et_index_rows_fail_doc.
  call method fail_document_alv->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_fail_doc.
*      ET_ROW_NO     =
  .

  describe table itab_et_index_rows_fail_doc lines count_lines.
  if count_lines <> 1.
    message e000(zcl_plint_message_01)
      with text-051 count_lines '' ''.
    exit.
  else.
    read table itab_et_index_rows_fail_doc index  1
      into wa_et_index_rows_fail_doc.
    read table itab_fail_document_alv index
      wa_et_index_rows_fail_doc-index
      into wa_fail_document_alv.
  endif.

  set parameter id 'CV1' field wa_fail_document_alv-doknr.
  set parameter id 'CV2' field wa_fail_document_alv-dokar.
  set parameter id 'CV3' field wa_fail_document_alv-dokvr.
  set parameter id 'CV4' field wa_fail_document_alv-doktl.

  call transaction 'CV03N' and skip first screen.

endform.                    " view_sel_doc
*&---------------------------------------------------------------------*
*&      Form  appl_log_write
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0078   text
*      -->P_0079   text
*      -->P_0080   text
*      -->P_DEL_LOG  text
*      -->P_NON_DEL_LOG  text
*      -->P_0083   text
*      -->P_0084   text
*----------------------------------------------------------------------*
form appl_log_write using    value(typ)
                             value(nummer)
                             value(klasse)
                             value(message1)
                             value(message2)
                             value(message3)
                             value(message4).
  data: msgv1 type symsgv.
  data: msgv2 type symsgv.
  data: msgv3 type symsgv.
  data: msgv4 type symsgv.

  data: number(3) type n.
  data: msgno type symsgno.

  clear msgv1.
  clear msgv2.
  clear msgv3.
  clear msgv4.
  msgv1 = message1.
  msgv2 = message2.
  msgv3 = message3.
  msgv4 = message4.
  number = nummer.
  msgno = nummer.

  call function '/CIDEON/APPL_LOG_WRITE_2'
       exporting
            i_object   = 'Z_CIDEON'
            i_subobj   = 'Z_PLOT'
            i_number   = msgno
            i_msgtyp   = typ
            i_msgid    = klasse
            i_msgno    = msgno
            i_msgv1    = msgv1
            i_msgv2    = msgv2
            i_msgv3    = msgv3
            i_msgv4    = msgv4
            i_class    = ' '
            i_newhead  = ' '
            i_messhead = ' '
       exceptions
            error      = 1
            others     = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " appl_log_write
*&---------------------------------------------------------------------*
*&      Form  load_home_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form load_home_page.
  data: doc_url(80).

  call method html_control->load_html_document
       exporting
            document_id  = 'HTMLCNTL_CNHTTST1_START'
       importing
            assigned_url = doc_url
       exceptions
            others       = 1.

  if sy-subrc eq 0.
    call method html_control->show_url
         exporting
              url       = doc_url.
  endif.

endform.                    " load_home_page
