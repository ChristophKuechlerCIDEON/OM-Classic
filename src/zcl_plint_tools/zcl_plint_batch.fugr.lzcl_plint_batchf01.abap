*----------------------------------------------------------------------*
***INCLUDE LZCL_PLINT_BATCHF01 .
*----------------------------------------------------------------------*
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
*&      Form  get_local_work_path
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_local_work_path
  changing path type localfile.
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
      return               = path "default_data-view_down_path
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
      with text 'LZCL_PLINT_BATCHF01' '' ''.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.




endform.                    " get_local_work_path
*&---------------------------------------------------------------------*
*&      Form  fill_itab_items_fauf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form fill_itab_items_fauf.

  call function 'CONVERSION_EXIT_ALPHA_INPUT'
       exporting
            input  = g_draw_key-doknr
       importing
            output = g_draw_key-doknr.

     call function 'TERM_TRANSLATE_TO_UPPER_CASE'
      exporting
       langu                     = sy-langu
       text                      = g_draw_key-dokar
     importing
       text_uc                   = g_draw_key-dokar .
     call function 'TERM_TRANSLATE_TO_UPPER_CASE'
      exporting
       langu                     = sy-langu
       text                      = g_draw_key-doktl
     importing
       text_uc                   = g_draw_key-doktl .
    call function 'TERM_TRANSLATE_TO_UPPER_CASE'
      exporting
       langu                     = sy-langu
       text                      = g_draw_key-dokvr
     importing
       text_uc                   = g_draw_key-dokvr .

  select single * from draw into wa_draw
      where dokar = g_draw_key-dokar
      and   doknr = g_draw_key-doknr
      and   doktl = g_draw_key-doktl
      and   dokvr = g_draw_key-dokvr.

  if sy-subrc = 0.

    move wa_draw-dokar to wa_item_fauf-dokar.
    move wa_draw-doknr to wa_item_fauf-doknr.
    move wa_draw-doktl to wa_item_fauf-doktl.
    move wa_draw-dokvr to wa_item_fauf-dokvr.

    append wa_item_fauf to itab_items_fauf.

  endif.

  clear: wa_user_data,  wa_default_data.

endform.                    " fill_itab_items_fauf
