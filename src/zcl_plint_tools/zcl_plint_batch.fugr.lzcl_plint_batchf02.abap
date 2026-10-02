*----------------------------------------------------------------------*
*   INCLUDE LZCL_PLINT_BATCHF02                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  read_user_and_default_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_user_and_default_data.


  call function '/CIDEON/READ_DEFAULTDATA'
       exporting
            i_batch        = 'X'
       importing
            o_default_data = wa_default_data.

  call function '/CIDEON/READ_USERDATA'
       exporting
            i_default_data = wa_default_data
            i_uname        = g_user
            i_batch        = 'X'
       importing
            o_user_data    = wa_user_data.
endform.                    " read_user_and_default_data
*&---------------------------------------------------------------------*
*&      Form  read_default_verteiler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_default_verteiler.

  clear wa_default_verteiler.
  call function '/CIDEON/GET_DEFAULT_VERTEILER'
       exporting
            i_wa_user_data         = wa_user_data
            i_wa_default_data      = wa_default_data
       importing
            o_wa_default_verteiler = wa_default_verteiler
       exceptions
            error                  = 1
            others                 = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " read_default_verteiler
*&---------------------------------------------------------------------*
*&      Form  read_mat_status_exc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_mat_status_exc.

  call function '/CIDEON/PROC_MAT_STATUS_EXC'
       exporting
            i_wa_user_data      = wa_user_data
       tables
            itab_mat_status_exc = itab_mat_status_exc
       exceptions
            error               = 1
            others              = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " read_mat_status_exc
*&---------------------------------------------------------------------*
*&      Form  read_stored_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_stored_search.

  call function '/CIDEON/READ_STORED_SEARCH'
       exporting
            i_wa_user_data    = wa_user_data
            i_wa_default_data = wa_default_data
       tables
            itab_search       = itab_search
       exceptions
            error             = 1
            others            = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " read_stored_search
*&---------------------------------------------------------------------*
*&      Form  get_dok_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_dok_text.

  call function '/CIDEON/GET_DOK_TEXT'
       tables
            itab_search = itab_search
       exceptions
            error       = 1
            others      = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " get_dok_text
*&---------------------------------------------------------------------*
*&      Form  get_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_matnr.

  call function '/CIDEON/GET_MATNR'
       exporting
            i_wa_user_data = wa_user_data
       tables
            itab_search    = itab_search
       exceptions
            error          = 1
            others         = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " get_matnr
*&---------------------------------------------------------------------*
*&      Form  make_knz_freigabe_led
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_knz_freigabe_led.

  call function '/CIDEON/MAKE_KNZ_FREIGABE_LED'
       tables
            itab_search = itab_search
       exceptions
            error       = 1
            others      = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " make_knz_freigabe_led
*&---------------------------------------------------------------------*
*&      Form  MAKE_MAT_STATUS_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_mat_status_icon.

  call function '/CIDEON/MAKE_MAT_STATUS_ICON'
       exporting
            i_wa_user_data      = wa_user_data
       tables
            itab_search         = itab_search
            itab_mat_status_exc = itab_mat_status_exc
       exceptions
            error               = 1
            others              = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " MAKE_MAT_STATUS_ICON
*&---------------------------------------------------------------------*
*&      Form  MAKE_DISPLAY_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_display_icon.

  call function '/CIDEON/MAKE_DISPLAY_ICON'
       tables
            itab_search = itab_search
       exceptions
            error       = 1
            others      = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " MAKE_DISPLAY_ICON
