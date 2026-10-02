*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF06 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_local_work_path
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_local_work_path.
* holt sich lokalen Arbeitspfad
  data: text(60).

* default_data-view_down_path
  call function 'WS_QUERY'
    exporting
*     ENVIRONMENT          =
*     FILENAME             =
      query                = 'CD'
*     WINID                =
   importing
      return               = default_data-view_down_path
   exceptions
     inv_query            = 1
     no_batch             = 2
     frontend_error       = 3
     others               = 4
            .
  if sy-subrc <> 0.
    clear text.

    case sy-subrc.
      when '1'.
        text = 'inv_query'.
      when '2'.
        text = 'no_batch'.
      when '3'.
        text = 'frontend_error'.
      when '4'.
        text = 'others'.
      when others.
        text = '????????'.
    endcase.

    message w164(zcl_plint_message_01)
      with text '/CIDEON/LDRUCK_DIALOGF06' '' ''.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.



endform.                    " get_local_work_path
