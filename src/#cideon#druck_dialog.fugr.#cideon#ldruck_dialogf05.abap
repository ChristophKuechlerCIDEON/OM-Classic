*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  appl_log_write
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0046   text
*      -->P_0047   text
*      -->P_0048   text
*      -->P_0049   text
*      -->P_PNAME  text
*      -->P_0051   text
*      -->P_0052   text
*----------------------------------------------------------------------*
FORM appl_log_write USING    value(typ)
                             value(nummer)
                             value(klasse)
                             value(message1)
                             value(message2)
                             value(message3)
                             value(message4).
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
