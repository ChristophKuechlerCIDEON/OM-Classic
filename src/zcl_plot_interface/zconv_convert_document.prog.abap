*&---------------------------------------------------------------------*
*& Report  CONV_CONVERT_DOCUMENT                                       *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  conv_convert_document         .

DATA: error_message TYPE messages,
      bapiret       TYPE bapiret2,
      documentfiles TYPE TABLE OF bapi_doc_files2,
      lines         TYPE i,
      ta_convert_spec TYPE TABLE OF convert_spec,
      wa_convert_spec TYPE convert_spec.

DATA: gdoknr TYPE draw-doknr.
DATA: gdokar TYPE draw-dokar.
DATA: gdoktl TYPE draw-doktl.
DATA: gdokvr TYPE draw-dokvr.


PARAMETERS: dokar TYPE draw-dokar MEMORY ID cv02.
PARAMETERS: doknr TYPE draw-doknr MEMORY ID cv01.
PARAMETERS: doktl TYPE draw-doktl MEMORY ID cv04.
PARAMETERS: dokvr TYPE draw-dokvr MEMORY ID cv03.
PARAMETERS: dokst    TYPE tdwst-stabk.
*           dokst_in TYPE tdws-dokst.
PARAMETERS: wsappl   TYPE tdwp-dappl.
PARAMETERS: convers  TYPE convert_spec-name.

INITIALIZATION.
  GET PARAMETER ID 'CV1' FIELD gdoknr.
  GET PARAMETER ID 'CV2' FIELD gdokar.
  GET PARAMETER ID 'CV4' FIELD gdoktl.
  GET PARAMETER ID 'CV3' FIELD gdokvr.

  doknr = gdoknr.
  dokar = gdokar.
  doktl = gdoktl.
  dokvr = gdokvr.


AT SELECTION-SCREEN.


START-OF-SELECTION.

  IF dokvr IS INITIAL.
    dokvr = '00'.
  ENDIF.
  IF doktl IS INITIAL.
    doktl = '000'.
  ENDIF.

  IF NOT dokst IS INITIAL AND NOT convers IS INITIAL.
    MESSAGE i253(conv).  "spezify only one of dokst or convers
    EXIT.
  ENDIF.


  IF NOT wsappl IS INITIAL.
    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = dokar
        documentnumber             = doknr
        documentpart               = doktl
        documentversion            = dokvr
*     GETACTIVEFILES             = 'X'
      IMPORTING
*     DOCUMENTDATA               =
        return                     = bapiret
      TABLES
        documentfiles              = documentfiles
              .
    IF bapiret-type CA 'EA'.
      MESSAGE ID bapiret-id
            TYPE 'I'
          NUMBER bapiret-number
            WITH bapiret-message_v1 bapiret-message_v2
                 bapiret-message_v3 bapiret-message_v3.
      EXIT.
    ENDIF.
    DELETE documentfiles WHERE wsapplication <> wsappl.
    DESCRIBE TABLE documentfiles LINES lines.
    IF lines = 0.
      MESSAGE i254(conv) WITH wsappl.
      "no originalfile with ws-appl ... in doc.
      EXIT.
    ENDIF.

    IF dokst IS INITIAL.
      CALL FUNCTION 'CONVT_CONVERT_AT_STATUS_CHANGE'
           EXPORTING
                documenttype         = dokar
                documentnumber       = doknr
                documentpart         = doktl
                documentversion      = dokvr
                pf_batch             = ' '
                check_document_exist = 'X'
                convert_spec_name    = convers
                use_documentfiles    = 'X'
           IMPORTING
                error_message        = error_message
           TABLES
                documentfiles        = documentfiles.
    ELSE.
      SELECT * FROM convert_spec INTO TABLE ta_convert_spec
       WHERE            source = wsappl
       AND ( auto_sta_doctype  = dokar
       OR    auto_sta_doctype  = ' ' )
       AND         auto_start  = dokst
       AND   (  checkout_depth = '1'
       OR       checkout_depth = ' ' ) .
      IF sy-subrc <> 0.
        MESSAGE i204(conv) WITH dokar dokst.   "no specification found
        EXIT.
      ENDIF.
      LOOP AT ta_convert_spec INTO wa_convert_spec.
        CALL FUNCTION 'CONVT_CONVERT_AT_STATUS_CHANGE'
             EXPORTING
                  documenttype         = dokar
                  documentnumber       = doknr
                  documentpart         = doktl
                  documentversion      = dokvr
                  pf_batch             = ' '
                  check_document_exist = 'X'
                  convert_spec_name    = wa_convert_spec-name
                  use_documentfiles    = 'X'
             IMPORTING
                  error_message        = error_message
             TABLES
                  documentfiles        = documentfiles.
        IF NOT error_message-msg_type IS INITIAL.
          IF error_message-msg_type CA 'WEA'.
            error_message-msg_type = 'I'.
          ENDIF.
          MESSAGE ID error_message-msg_id
                TYPE error_message-msg_type
              NUMBER error_message-msg_no
                WITH error_message-msg_v1 error_message-msg_v2
                     error_message-msg_v3 error_message-msg_v4.
          CLEAR error_message.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    IF NOT convers IS INITIAL.
      MESSAGE i300(conv).
      "Conv. spec must be given only together with WS-Appl.
      EXIT.
    ENDIF.
    CALL FUNCTION 'CONVT_CONVERT_AT_STATUS_CHANGE'
         EXPORTING
              documenttype       = dokar
              documentnumber     = doknr
              documentpart       = doktl
              documentversion    = dokvr
*         documentstatus     = dokst_in
              documentstatus_ext = dokst
              pf_batch           = ' '
              check_document_exist = 'X'
         IMPORTING
              error_message      = error_message.

  ENDIF.

  IF NOT error_message-msg_type IS INITIAL.
    IF error_message-msg_type CA 'WEA'.
      error_message-msg_type = 'I'.
    ENDIF.
    MESSAGE ID error_message-msg_id
          TYPE error_message-msg_type
        NUMBER error_message-msg_no
          WITH error_message-msg_v1 error_message-msg_v2
               error_message-msg_v3 error_message-msg_v4.
  ENDIF.
