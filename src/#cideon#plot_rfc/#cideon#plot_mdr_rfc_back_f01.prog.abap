*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_MDR_RFC_BACK_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  test_RFC_DEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form test_rfc_dest using p_rfc_dest.
* Testen der RFC Destinationen

  data : rfc_mess(80).
  clear rfc_mess.
  call function 'RFC_PING'
    destination p_rfc_dest
              exceptions system_failure = 1
                          message rfc_mess
                          communication_failure = 2
                          message rfc_mess.
  .
  if sy-subrc <> 0.
    message id '/CIDEON/PLOT_RFC' type 'E' number '002' with
                rfcdest rfc_mess '' ''.
  else.
  endif.


endform.                    " test_RFC_DEST
*&---------------------------------------------------------------------*
*&      Form  move_ok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form move_ok using wa_file_out structure /cideon/s_rfc_svr_file_info.
* Datei verschieben, falls alles in Ordnung ist

  clear return.
  clear lt_file_in2.
  clear lt_file_out2.

  clear wa_file_in2.
  clear wa_file_out2.

  wa_file_in2-filename = wa_file_out-filename.
  append wa_file_in2 to lt_file_in2.

  clear pf_path.
  clear pfx_path.
  clear pfx_file.

  pf_path = wa_file_in2-filename.

  call function 'CV120_SPLIT_PATH'
       exporting
            pf_path  = pf_path
       importing
            pfx_path = pfx_path
            pfx_file = pfx_file.

  concatenate pdirok pfx_file
    into wa_file_out2-filename.
  append wa_file_out2 to lt_file_out2.

  call function '/CIDEON/RFC_SVR_FILE_MAN'
    destination rfcdest
    exporting
      fcode                       = 'MOVE_FILE'
    importing
      return                      = return
     tables
       filetab1                    = lt_file_in2
       filetab2                    = lt_file_out2
     exceptions
       system_failure              = 1
       communication_failure       = 2
       others                      = 3
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " move_ok

*---------------------------------------------------------------------*
*       FORM move_error                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  WA_FILE_OUT                                                   *
*---------------------------------------------------------------------*
form move_error using wa_file_out structure /cideon/s_rfc_svr_file_info.
* Datei verschieben, falls Fehler aufgetreten ist

  clear return.
  clear lt_file_in2.
  clear lt_file_out2.

  clear wa_file_in2.
  clear wa_file_out2.

  wa_file_in2-filename = wa_file_out-filename.
  append wa_file_in2 to lt_file_in2.

  clear pf_path.
  clear pfx_path.
  clear pfx_file.

  pf_path = wa_file_in2-filename.

  call function 'CV120_SPLIT_PATH'
       exporting
            pf_path  = pf_path
       importing
            pfx_path = pfx_path
            pfx_file = pfx_file.

  concatenate pdirerr pfx_file
    into wa_file_out2-filename.
  append wa_file_out2 to lt_file_out2.

  call function '/CIDEON/RFC_SVR_FILE_MAN'
    destination rfcdest
    exporting
      fcode                       = 'MOVE_FILE'
    importing
      return                      = return
     tables
       filetab1                    = lt_file_in2
       filetab2                    = lt_file_out2
     exceptions
       system_failure              = 1
       communication_failure       = 2
       others                      = 3
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " move_ok

*---------------------------------------------------------------------*
*       FORM appl_log_write                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(TYP)                                                    *
*  -->  VALUE(NUMMER)                                                 *
*  -->  VALUE(KLASSE)                                                 *
*  -->  VALUE(MESSAGE1)                                               *
*  -->  VALUE(MESSAGE2)                                               *
*  -->  VALUE(MESSAGE3)                                               *
*  -->  VALUE(MESSAGE4)                                               *
*---------------------------------------------------------------------*
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



endform.
