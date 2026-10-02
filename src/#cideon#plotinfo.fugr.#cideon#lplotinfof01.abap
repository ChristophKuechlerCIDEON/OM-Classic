*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOTINFOF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  trace_fault
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LO_RESPONSE_>FAULT  text
*----------------------------------------------------------------------*
FORM trace_fault USING fault TYPE REF TO /cideon/cl_xmlrpc_fault.
  WRITE / 'XML-RPC Fehler Code('.
  WRITE fault->code.
  WRITE ') Nachricht: '.
  WRITE fault->string.

ENDFORM.                    " trace_fault
*&---------------------------------------------------------------------*
*&      Form  editor_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM editor_get_data.
* Daten des Editor holen als interne Tabelle
  CLEAR it_text.
  CALL METHOD editor->get_text_as_r3table
*     EXPORTING
*       only_when_modified     = false
     IMPORTING
       table                  = it_text
*    IS_MODIFIED            =
     EXCEPTIONS
       error_dp               = 1
       error_cntl_call_method = 2
       error_dp_create        = 3
       potential_data_loss    = 4
       OTHERS                 = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Daten als Stream holen
  CLEAR it_text_stream.
  CALL METHOD editor->get_text_as_stream
*     EXPORTING
*       only_when_modified     = false
     IMPORTING
       text                   = it_text_stream
*      IS_MODIFIED            =
     EXCEPTIONS
       error_dp               = 1
       error_cntl_call_method = 2
       OTHERS                 = 3
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " editor_get_data
