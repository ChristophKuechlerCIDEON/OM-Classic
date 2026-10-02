*----------------------------------------------------------------------*
***INCLUDE LZCL_INVENTOR_FORMATF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  write_return
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0018   text
*      -->P_0019   text
*      -->P_0020   text
*      -->P_0021   text
*      -->P_0022   text
*      -->P_0023   text
*----------------------------------------------------------------------*
FORM write_return USING    value(id)
                           value(nummer)
                           value(msgv1)
                           value(msgv2)
                           value(msgv3)
                           value(msgv4).

  CLEAR g_return.

  g_return-id = id.
  g_return-number = nummer.
  "g_return-message =
  g_return-message_v1 = msgv1.
  g_return-message_v2 = msgv2.
  g_return-message_v3 = msgv3.
  g_return-message_v4 = msgv4.
  g_return-system = sy-sysid.

ENDFORM.                    " write_return
*---------------------------------------------------------------------*
*       FORM FILL_BAPI_MESSAGE_FROM_SYST                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PS_BAPI_MESSAGE                                               *
*---------------------------------------------------------------------*
FORM fill_bapi_message_from_syst
     CHANGING ps_bapi_message LIKE messages.

  CLEAR ps_bapi_message.
  MOVE: sy-msgid  TO ps_bapi_message-msg_id,
        sy-msgty  TO ps_bapi_message-msg_type,
        sy-msgno  TO ps_bapi_message-msg_no,
        sy-msgv1  TO ps_bapi_message-msg_v1,
        sy-msgv2  TO ps_bapi_message-msg_v2,
        sy-msgv3  TO ps_bapi_message-msg_v3,
        sy-msgv4  TO ps_bapi_message-msg_v4.

ENDFORM.                               " FILL_BAPI_MESSAGE_FROM_SYST
*---------------------------------------------------------------------*
*       FORM FILL_BAPI_RETURN2                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PF_ROW                                                        *
*  -->  PS_MESSAGE                                                    *
*  -->  PS_RETURN                                                     *
*---------------------------------------------------------------------*
FORM fill_bapi_return2
     USING    pf_row
              ps_message STRUCTURE messages
     CHANGING ps_return  STRUCTURE bapiret2.

  CLEAR ps_return.
  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
       EXPORTING:  type       = ps_message-msg_type
                   cl         = ps_message-msg_id
                   number     = ps_message-msg_no
                   par1       = ps_message-msg_v1
                   par2       = ps_message-msg_v2
                   par3       = ps_message-msg_v3
                   par4       = ps_message-msg_v4
                   row        = pf_row
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
      IMPORTING : return = ps_return.

  IF NOT ps_message-msg_txt IS INITIAL.
    ps_return-message = ps_message-msg_txt.
  ENDIF.
ENDFORM.                               " FILL_BAPI_RETURN1
