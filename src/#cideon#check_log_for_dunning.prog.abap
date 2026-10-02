*&---------------------------------------------------------------------*
*& Report  /CIDEON/CHECK_LOG_FOR_DUNNING                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Anpassungen:
*-----------------------------------------------------------------------
* Journal
* 13.11.2007 - Erstellung
*              Beachtung EBELN / LIFNR
* 14.11.2007 -
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------

REPORT  /cideon/check_log_for_dunning .
*ITAB
DATA: lt_log TYPE TABLE OF /cideon/pl_log.
DATA: lt_log_email TYPE TABLE OF /cideon/pl_log.
DATA: lt_log_user TYPE TABLE OF /cideon/pl_log.

DATA: mahnstufe.

*WA
DATA: lc_log TYPE /cideon/pl_log.
DATA: lc_log_email TYPE /cideon/pl_log.
DATA: lc_log_user TYPE /cideon/pl_log.

DATA: date TYPE sy-datum.

DATA: str TYPE string.

*  CLEAR lt_log_email.
DATA: document_data TYPE sodocchgi1.
DATA: it_receivers TYPE TABLE OF somlreci1.
DATA: wa_receivers TYPE somlreci1.
DATA: lt_object_cont TYPE TABLE OF solisti1.
DATA: wa_object_cont TYPE solisti1.


PARAMETERS pdays TYPE int4 DEFAULT '10'.

* alle Einträge aus PlotLOG mir DUEDATE = sy-datum
* EBELN <> initial
* beachten, daß schon gemahnt sein kann
* Datum 1. Mahnung / Datum 2. Mahnung

date = sy-datum + pdays.

* Mahnung
CLEAR lt_log.
SELECT * FROM /cideon/pl_log
  INTO TABLE lt_log
  WHERE duedate <= sy-datum
  AND duedate <> '00000000'
  AND m1date = '00000000'
*  AND m2date = '00000000'
  AND status = '00'
  AND lifnr <> ''
  .
IF sy-subrc NE 0.
ELSE.
ENDIF.

* Verarbeiten nach Nutzer unterscheiden und
* dann senden

* unterschiedliche Nutzer herausfinden für die
* unterschiedlichen eMails
mahnstufe = '0'.
PERFORM make_email_tab_and_send.




date = sy-datum - pdays.

* 1. Mahnung erfolgt
CLEAR lt_log.
SELECT * FROM /cideon/pl_log
  INTO TABLE lt_log
  WHERE duedate <= sy-datum
  AND m1date <= date
  AND m1date <> '00000000'
  AND m2date = '00000000'
  AND status = '00'
  AND lifnr <> ''
  .
IF sy-subrc NE 0.
ELSE.
ENDIF.
mahnstufe = '1'.
PERFORM make_email_tab_and_send.



* 2. Mahnung erfolgt und nicht bestätigt
CLEAR lt_log.
SELECT * FROM /cideon/pl_log
  INTO TABLE lt_log
  WHERE duedate <= sy-datum
  AND m1date <= sy-datum
  AND m2date <= date
  AND m2date <> '00000000'
  AND m1date <> '00000000'
  AND status = '00'
  AND lifnr <> ''
  .
IF sy-subrc NE 0.
ELSE.
ENDIF.
mahnstufe = '2'.
PERFORM make_email_tab_and_send.














* Meldung schicken
*&---------------------------------------------------------------------*
*&      Form  sendmail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sendmail USING stufe.

**  CLEAR lt_log_email.
*  DATA: document_data TYPE sodocchgi1.
*  DATA: it_receivers TYPE TABLE OF somlreci1.
*  DATA: wa_receivers TYPE somlreci1.
*  DATA: lt_object_cont TYPE TABLE OF solisti1.
*  DATA: wa_object_cont TYPE solisti1.

  CLEAR document_data.
  CLEAR lt_object_cont.

  document_data-proc_type = 'T'.
  document_data-proc_name = '/CIDEON/SPSO'.
  document_data-proc_name = '/CIDEON/MNT_PLOT_LM0'.

  CASE stufe.
    WHEN '0'.
      document_data-obj_descr = text-000.
      document_data-proc_name = '/CIDEON/MNT_PLOT_LM0'.
    WHEN '1'.
      document_data-obj_descr = text-001.
      document_data-proc_name = '/CIDEON/MNT_PLOT_LM1'.
    WHEN '2'.
      document_data-obj_descr = text-002.
      document_data-proc_name = '/CIDEON/MNT_PLOT_LM2'.
    WHEN OTHERS.
  ENDCASE.




  PERFORM leerzeile.

  wa_object_cont-line =
       text-010.
  APPEND wa_object_cont TO lt_object_cont.
  PERFORM leerzeile.

* Auflisten der Dokumente
  SORT lt_log_email BY ebeln ASCENDING.
  LOOP AT lt_log_email INTO lc_log_email.
    CLEAR str.
    CONCATENATE text-ebe lc_log_email-ebeln
      text-lif  lc_log_email-name1_lifnr
      text-dis lc_log_email-dokar
      lc_log_email-doknr
      lc_log_email-doktl
      lc_log_email-dokvr
      INTO str SEPARATED BY space.
    wa_object_cont-line = str.
    APPEND wa_object_cont TO lt_object_cont.
  ENDLOOP.

  PERFORM leerzeile.
  wa_object_cont-line =
       text-100.
  APPEND wa_object_cont TO lt_object_cont.

  PERFORM leerzeile.

  wa_object_cont-line =
       text-101.
  APPEND wa_object_cont TO lt_object_cont.

  PERFORM leerzeile.

  wa_object_cont-line =
       text-102.
  APPEND wa_object_cont TO lt_object_cont.

  PERFORM leerzeile.

  wa_object_cont-line =
       text-103.
  APPEND wa_object_cont TO lt_object_cont.




* eMail generieren und senden
  CLEAR wa_receivers.
  wa_receivers-receiver = lc_log_email-zclinsname.

  wa_receivers-rec_type = 'B'.
  wa_receivers-express = 'X'.

  REFRESH it_receivers.
  APPEND wa_receivers TO it_receivers.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      document_data                    = document_data
*   DOCUMENT_TYPE                    = 'RAW'
*   PUT_IN_OUTBOX                    = ' '
* IMPORTING
*   SENT_TO_ALL                      =
*   NEW_OBJECT_ID                    =
    TABLES
*   OBJECT_HEADER                    =
      object_content                   = lt_object_cont
*   CONTENTS_HEX                     =
*   OBJECT_PARA                      =
*   OBJECT_PARB                      =
      receivers                        = it_receivers
    EXCEPTIONS
      too_many_receivers               = 1
      document_not_sent                = 2
      document_type_not_exist          = 3
      operation_no_authorization       = 4
      parameter_error                  = 5
      x_error                          = 6
      enqueue_error                    = 7
      OTHERS                           = 8
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " sendmail
*&---------------------------------------------------------------------*
*&      Form  leerzeile
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM leerzeile.
* leere Zeile
  wa_object_cont-line =
       text-036.
  APPEND wa_object_cont TO lt_object_cont.

ENDFORM.                    " leerzeile
*&---------------------------------------------------------------------*
*&      Form  make_email_tab_and_send
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_email_tab_and_send.
  CLEAR lt_log_user.
  lt_log_user[] = lt_log[].
  SORT lt_log_user BY zclinsname ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_log_user COMPARING zclinsname.

  LOOP AT lt_log_user INTO lc_log_user.
    CLEAR lt_log_email.
    LOOP AT lt_log INTO lc_log
      WHERE zclinsname = lc_log_user-zclinsname.
      APPEND lc_log TO lt_log_email.
    ENDLOOP.

* Meldung schicken
    PERFORM sendmail USING mahnstufe..
  ENDLOOP.
ENDFORM.                    " make_email_tab_and_send
