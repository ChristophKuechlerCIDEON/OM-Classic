FUNCTION /cideon/send_mail_vbeln_plot.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_USER) TYPE  SY-UNAME DEFAULT 'KUECHLER'
*"     VALUE(I_VBDKA) TYPE  VBDKA
*"  TABLES
*"      LT_VBDPA STRUCTURE  VBDPA
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* Sended Expressmail
* Benutzung nach der Ausgabe von Dokumenten
* Vertriebsbelegsdokumente
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 23.02.2007 - Erstellung
* 21.04.2007 - SP 36
*            - Übergabe weiterer Felder für die eMail
* 27.04.2007 - Kopie
* 05.05.2007 - SP 37
*              Probleme mit eMail senden in der Hintergrundverarb.
*              bein VA22..
* 03.08.2007 - SP 44
*              Positionen mit in eMail anzeigen
*-----------------------------------------------------------------------
* to Do
*  - mgl, an die Benachrichtigung noch die PDF der Bestellung hängen
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------

  DATA: document_data TYPE sodocchgi1.
  DATA: it_receivers TYPE TABLE OF somlreci1.
  DATA: wa_receivers TYPE somlreci1.
  DATA: lt_object_cont TYPE TABLE OF solisti1.
  DATA: wa_object_cont TYPE solisti1.

  CLEAR document_data.

  document_data-obj_descr = text-030. "'S-PSO Benachrichtigung'.

  IF i_vbdka-vbeln IS INITIAL.
  ELSE.
    CONCATENATE
      text-044
      i_vbdka-vbeln
      document_data-obj_descr

      INTO document_data-obj_descr
      SEPARATED BY space.
  ENDIF.


  document_data-proc_type = 'T'.
  document_data-proc_name = '/CIDEON/SPSO'.

  document_data-proc_type = 'R'.
  document_data-proc_name = '/CIDEON/START_SPSO_WITH_QUEUE'.

* document_data-proc_name = 'ZCL_PLOT_INTERFACE'.
*document_data-proc_name = 'ME23N'.

  document_data-proc_syst = sy-sysid.
  document_data-proc_clint = sy-mandt.
  document_data-no_change = 'X'.


*
  wa_object_cont-line =
       text-032.
  APPEND wa_object_cont TO lt_object_cont.

  wa_object_cont-line =
       text-033.
  APPEND wa_object_cont TO lt_object_cont.

  wa_object_cont-line =
       text-034.
  APPEND wa_object_cont TO lt_object_cont.

*  wa_object_cont-line =
*       text-039.
*  APPEND wa_object_cont TO lt_object_cont.

  wa_object_cont-line =
       text-039.
  APPEND wa_object_cont TO lt_object_cont.
* Leerzeile
  wa_object_cont-line =
       text-033.
  APPEND wa_object_cont TO lt_object_cont.


  wa_object_cont-line =
       text-041.
  APPEND wa_object_cont TO lt_object_cont.



  wa_object_cont-line =
       text-033.
  APPEND wa_object_cont TO lt_object_cont.
  wa_object_cont-line =
       text-040.
  APPEND wa_object_cont TO lt_object_cont.


  wa_object_cont-line =
       text-036.
  APPEND wa_object_cont TO lt_object_cont.

  wa_object_cont-line =
     text-037.
  APPEND wa_object_cont TO lt_object_cont.

  wa_object_cont-line =
       text-036.
  APPEND wa_object_cont TO lt_object_cont.

  wa_object_cont-line =
       text-038.
  APPEND wa_object_cont TO lt_object_cont.
** Bitte diese eMail mit Strg+F6 ausführen!
*  wa_object_cont-line =
*       text-031.
*  APPEND wa_object_cont TO lt_object_cont.

* leere Zeile
  wa_object_cont-line =
       text-036.
  APPEND wa_object_cont TO lt_object_cont.

* leere Zeile
  wa_object_cont-line =
       text-036.
  APPEND wa_object_cont TO lt_object_cont.

* leere Zeile
  wa_object_cont-line =
       text-036.
  APPEND wa_object_cont TO lt_object_cont.

* Liste der Position
  wa_object_cont-line =
       text-045.
  APPEND wa_object_cont TO lt_object_cont.

* leere Zeile
  wa_object_cont-line =
       text-036.
  APPEND wa_object_cont TO lt_object_cont.


* Angabe der Positionen
  DATA: lw_vbdpa TYPE vbdpa.
  LOOP AT lt_vbdpa INTO lw_vbdpa.
    CONCATENATE
      lw_vbdpa-posnr lw_vbdpa-matnr
      lw_vbdpa-arktx
      INTO wa_object_cont-line
      SEPARATED BY space.

    APPEND wa_object_cont TO lt_object_cont.
  ENDLOOP.


  CLEAR wa_receivers.
  wa_receivers-receiver = sy-uname.
  wa_receivers-receiver = i_user.

  wa_receivers-rec_type = 'B'.
  wa_receivers-express = 'X'.

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
ENDFUNCTION.
