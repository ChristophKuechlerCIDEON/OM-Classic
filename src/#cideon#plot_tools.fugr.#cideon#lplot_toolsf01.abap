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
FORM appl_log_write USING    value(typ)
                             value(nummer)
                             value(klasse)
                             value(message1)
                             value(message2)
                             value(message3)
                             value(message4).
  DATA: msgv1 TYPE symsgv.
  DATA: msgv2 TYPE symsgv.
  DATA: msgv3 TYPE symsgv.
  DATA: msgv4 TYPE symsgv.

  DATA: number(3) TYPE n.
  DATA: msgno TYPE symsgno.

  CLEAR msgv1.
  CLEAR msgv2.
  CLEAR msgv3.
  CLEAR msgv4.
  msgv1 = message1.
  msgv2 = message2.
  msgv3 = message3.
  msgv4 = message4.
  number = nummer.
  msgno = nummer.

  CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
       EXPORTING
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
       EXCEPTIONS
            error      = 1
            OTHERS     = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " appl_log_write
*&---------------------------------------------------------------------*
*&      Form  get_local_work_path
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_DEFAULT_DATA_VIEW_DOWN_PATH  text
*----------------------------------------------------------------------*
FORM get_local_work_path
  CHANGING path TYPE localfile.
* holt sich lokalen Arbeitspfad
  DATA: text(60).


* SP120
* 7.0.1.21
* 22.02.2010 - /CIDEON/LPLOT_TOOLSF01
*              form get_local_work_path
*              Problem bei Aufruf CALL TRANSACTION mit MODE
*              -> GUI Services schlagen fehl
*              -> Service ausgebaut
*              Trumpf
*


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
*    CLEAR text.
*
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
**    text = sy.
*
*    MESSAGE w164(zcl_plint_message_01)
*      WITH text '/CIDEON/LPLOT_TOOLSF01' '' ''.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.




ENDFORM.                    " get_local_work_path
