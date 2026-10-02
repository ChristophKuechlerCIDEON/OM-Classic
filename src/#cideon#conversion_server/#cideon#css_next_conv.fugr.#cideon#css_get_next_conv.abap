FUNCTION /cideon/css_get_next_conv.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_DOCUMENT_KEY) TYPE  CONV_S_DOCUMENT_KEY
*"     REFERENCE(I_KPRO_USE) TYPE  TDWA-KPRO_USE
*"     REFERENCE(IS_CONV_REQUESTED) TYPE  CONV_S_REQUESTED
*"     REFERENCE(IS_CONVERT_SPEC) TYPE  CONVERT_SPEC
*"     REFERENCE(IS_CONVERTER) TYPE  CONVERTER
*"     REFERENCE(IS_CONV_PATH_AND_MATRIX) TYPE  CONV_PATH_AND_MATRIX
*"     REFERENCE(IS_CONV_REQ_DATA) TYPE  CONV_S_REQ_DATA
*"     REFERENCE(IT_DOC_FILES) TYPE  CVAPI_TBL_DOC_FILES
*"     REFERENCE(IS_DOC_FILE) TYPE  CVAPI_DOC_FILE
*"  EXCEPTIONS
*"      KEIN_NACHFOLGER
*"----------------------------------------------------------------------
* CIDEON Anbindung neue Funktionalitäten in Konvertierungsserver
*
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           Chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 07.10.2004 - Erstellung / "Tag der Republik"
* 11.10.2004 - Starten der Konvertierungen
*              LOG Einträge
* 20.12.2005 - Unterscheidung in normale Konvertierung und Konvertierung
*              mit Dokumentenstücklisten
*-----------------------------------------------------------------------
* TYPE
* ITAB
  DATA: itab_css_succ TYPE TABLE OF /cideon/css_succ.
* WA
  DATA: wa_css_succ TYPE /cideon/css_succ.
  DATA: wa_convert_spec TYPE convert_spec.
* NORMAL
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

* Alle möglichen Nachfolgekonvertierungen zur aktuellen
* Konvertierungsspezifikation lesen
  SELECT * FROM /cideon/css_succ
    INTO TABLE itab_css_succ
    WHERE quell_konverter = is_convert_spec-name
    AND status = c_conv_aktiv.
  .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Starten der Konverter über CONV02
  LOOP AT itab_css_succ INTO wa_css_succ.
*   Lesen der Konverterspezifikation
    CLEAR wa_convert_spec.
    SELECT SINGLE * FROM convert_spec
      INTO wa_convert_spec
      WHERE name = wa_css_succ-ziel_konverter.
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

* CONV_CONVERT_DOC_STRUCTURE
    CASE wa_convert_spec-checkout_depth.
      WHEN 'R  '.
        SUBMIT conv_convert_doc_structure
          WITH dokar EQ is_document_key-documenttype
          WITH doknr EQ is_document_key-documentnumber
          WITH doktl EQ is_document_key-documentpart
          WITH dokvr EQ is_document_key-documentversion
          WITH dokst EQ wa_convert_spec-auto_start
*          WITH wsappl = wa_convert_spec-source
*          WITH convers = wa_convert_spec-name
          AND RETURN.
      WHEN '1  '.
        SUBMIT conv_convert_document
          WITH dokar EQ is_document_key-documenttype
          WITH doknr EQ is_document_key-documentnumber
          WITH doktl EQ is_document_key-documentpart
          WITH dokvr EQ is_document_key-documentversion
          WITH wsappl = wa_convert_spec-source
          WITH convers = wa_convert_spec-name
          AND RETURN.

      WHEN OTHERS.
    ENDCASE.


*   schreiben in des Applikation LOG
    msgno = '001'.
    CONCATENATE is_document_key-documenttype '/'
      is_document_key-documentnumber '/'
      is_document_key-documentpart '/'
      is_document_key-documentversion '/'
      INTO msgv1.
    msgv2 = wa_convert_spec-destination.
    msgv3 = wa_convert_spec-name.

    CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
         EXPORTING
              i_object   = '/CIDEON/'
              i_subobj   = '/CIDEON/CONVERSION'
              i_number   = msgno
              i_msgtyp   = 'I'
              i_msgid    = '/CIDEON/CSS'
              i_msgno    = msgno
              i_msgv1    = msgv1
              i_msgv2    = msgv2
              i_msgv3    = msgv3
              i_msgv4    = msgv4
              i_class    = ' '
              i_newhead  = 'X'
              i_messhead = ' '
         EXCEPTIONS
              error      = 1
              OTHERS     = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
         EXPORTING
              i_object   = 'CONV'
              i_subobj   = ''
              i_number   = msgno
              i_msgtyp   = 'I'
              i_msgid    = '/CIDEON/CSS'
              i_msgno    = msgno
              i_msgv1    = msgv1
              i_msgv2    = msgv2
              i_msgv3    = msgv3
              i_msgv4    = msgv4
              i_class    = ' '
              i_newhead  = ''
              i_messhead = ' '
         EXCEPTIONS
              error      = 1
              OTHERS     = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
