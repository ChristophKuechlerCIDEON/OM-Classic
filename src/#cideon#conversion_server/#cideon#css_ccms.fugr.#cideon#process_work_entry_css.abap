FUNCTION /cideon/process_work_entry_css.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXCEPTIONS
*"      KEIN_EINTRAG
*"      ERROR
*"      GESPERRT
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 14.06.2004 -
*-----------------------------------------------------------------------

*TYPES
*ITAB
  DATA: itab_css_job  TYPE TABLE OF /cideon/css_job.
*WA
  DATA: wa_css_job  TYPE /cideon/css_job.
  DATA: return TYPE bapiret2.
  DATA: documentdata TYPE bapi_doc_draw2.
  DATA: documentdatax TYPE bapi_doc_drawx2.
*NORMAL
  DATA: f_job_neu_einplanen.
  DATA: line(500).


  PERFORM sperren.

* Einträge lesen
  CLEAR itab_css_job.
  CLEAR wa_css_job.

  SELECT * FROM /cideon/css_job INTO
    TABLE itab_css_job.
  IF sy-subrc NE 0.
    PERFORM entsperren.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_css_job INTO wa_css_job.
    CLEAR return.
    CALL FUNCTION 'BAPI_DOCUMENT_ENQUEUE'
         EXPORTING
              documenttype    = wa_css_job-dokar
              documentnumber  = wa_css_job-doknr
              documentpart    = wa_css_job-doktl
              documentversion = wa_css_job-dokvr
         IMPORTING
              return          = return.
    IF return IS INITIAL.
    ELSE.
*    Job erneut einplanen
      f_job_neu_einplanen = 'X'.

      CONTINUE.
    ENDIF.

*   Status des Dokumentes setzen
    CLEAR return.
    CLEAR documentdata.
    CLEAR documentdatax.

    documentdata-statusintern = wa_css_job-statusintern.
    documentdata-statusextern = wa_css_job-statusextern.

    documentdatax-statusintern = 'X'.
    documentdatax-statusextern = 'X'.

    CALL FUNCTION 'BAPI_DOCUMENT_CHANGE2'
      EXPORTING
        documenttype               = wa_css_job-dokar
        documentnumber             = wa_css_job-doknr
        documentpart               = wa_css_job-doktl
        documentversion            = wa_css_job-dokvr
        documentdata               = documentdata
        documentdatax              = documentdatax
*       HOSTNAME                   =
*       DOCBOMCHANGENUMBER         =
*       DOCBOMVALIDFROM            =
*       DOCBOMREVISIONLEVEL        =
*       SENDCOMPLETEBOM            = ' '
*       PF_FTP_DEST                = ' '
*       PF_HTTP_DEST               = ' '
*       CAD_MODE                   = ' '
      IMPORTING
        return                     = return
*     TABLES
*       CHARACTERISTICVALUES       =
*       CLASSALLOCATIONS           =
*       DOCUMENTDESCRIPTIONS       =
*       OBJECTLINKS                =
*       DOCUMENTSTRUCTURE          =
*       DOCUMENTFILES              =
*       LONGTEXTS                  =
*       COMPONENTS                 =
              .
    IF return IS INITIAL.
      COMMIT WORK AND WAIT.
*     Löschen aus der Tabelle
      DELETE FROM /cideon/css_job
        WHERE dokar = wa_css_job-dokar
        AND doknr = wa_css_job-doknr
        AND doktl = wa_css_job-doktl
        AND dokvr = wa_css_job-dokvr
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
      COMMIT WORK AND WAIT.
    ELSE.
*      RAISE error.
*      WRITE: / return.
      CLEAR line.
      CONCATENATE return-type
        return-id
        return-number
        return-message
        INTO line SEPARATED BY space.
      WRITE: / line.
      f_job_neu_einplanen = 'X'.
      CLEAR return.
      CALL FUNCTION 'BAPI_DOCUMENT_DEQUEUE'
           EXPORTING
                documenttype    = wa_css_job-dokar
                documentnumber  = wa_css_job-doknr
                documentpart    = wa_css_job-doktl
                documentversion = wa_css_job-dokvr
           IMPORTING
                return          = return.
      IF return IS INITIAL.
      ELSE.
      ENDIF.
    ENDIF.

  ENDLOOP.


  IF f_job_neu_einplanen = 'X'.
*   Job erneut einplanen

  ELSE.
  ENDIF.


  PERFORM entsperren.

ENDFUNCTION.
