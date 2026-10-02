REPORT /cideon/conv_doc_bom.
*&---------------------------------------------------------------------*
*& Modulpool         /CIDEON/CONV_DOC_BOM                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
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
* 04.04.2004 - Reaktion auf das Setzen eines Status innerhalb des
*              DMS / Konvertierung starten
* 30.04.2005 - Reaktion auf Fehler, bei Massenfreigabe -> noch nicht
*              abgelegte und verbuchte Einzelteile einer Assembly
* 26.01.2006 - Reaktion auf iParts -> Parts mit Dokumentenstückliste
*-----------------------------------------------------------------------
TABLES: draw.

*TYPES
*ITAB
*WA
*NORMAL

"/CIDEON/CONV_DOC_BOM
AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD '/CIDEON/CONV_DOC_BOM'.
IF sy-subrc NE 0.
  "keine Berechtigung
  MESSAGE e000(26) WITH text-000.
ELSE.
ENDIF.


*&---------------------------------------------------------------------*
*&      Form  start_conversion_at_status_chg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_conversion_at_status_chg.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'TCD' FIELD '/CIDEON/CONV_DOC_BOM'.
  IF sy-subrc NE 0.
    "keine Berechtigung
    MESSAGE e000(26) WITH text-000.
  ELSE.
  ENDIF.

* wegen der Möglichkeit, daß Unterbaugruppen noch nicht
* abgelegt und verbucht sind
  COMMIT WORK AND WAIT.

  SUBMIT conv_convert_doc_structure
    AND RETURN
    WITH dokar = draw-dokar
    WITH doknr = draw-doknr
    WITH doktl = draw-doktl
    WITH dokvr = draw-dokvr
     .

  COMMIT WORK AND WAIT.

ENDFORM.                    " start_conversion_at_status_chg
*
*&---------------------------------------------------------------------*
*&      Form  start_conv_doc_struc_t_n_c
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_conv_doc_struc_t_n_c.
* kein Commit, aber Transaktion

  AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'TCD' FIELD '/CIDEON/CONV_DOC_BOM'.
  IF sy-subrc NE 0.
    "keine Berechtigung
    MESSAGE e000(26) WITH text-000.
  ELSE.
  ENDIF.


  SUBMIT conv_convert_doc_structure
    AND RETURN
    WITH dokar = draw-dokar
    WITH doknr = draw-doknr
    WITH doktl = draw-doktl
    WITH dokvr = draw-dokvr
     .

*  COMMIT WORK AND WAIT.

ENDFORM.                    " start_conv_doc_struc_t_n_c
*&---------------------------------------------------------------------*
*&      Form  start_conv_doc_struc_fb_c
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_conv_doc_struc_fb_c.
* Commit, + FB

  AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD '/CIDEON/CONV_DOC_BOM'.
  IF sy-subrc NE 0.
    "keine Berechtigung
    MESSAGE e000(26) WITH text-000.
  ELSE.
  ENDIF.

* wegen der Möglichkeit, daß Unterbaugruppen noch nicht
* abgelegt und verbucht sind
  COMMIT WORK AND WAIT.

  CALL FUNCTION 'CONV_API_CONVERT_DOC_STRUCTURE'
    EXPORTING
      documenttype               = draw-dokar
      documentnumber             = draw-doknr
      documentnumber_ext         = ''
      documentpart               = draw-doktl
      documentversion            = draw-dokvr
*     CHANGE_NUMBER_INT          =
*     CHANGE_NUMBER              =
*     KEY_DATE_INT               =
*     KEY_DATE                   =
*     DOCUMENT_STATUS_INT        =
*     DOCUMENT_STATUS            =
*     CHECK_DOCUMENT_EXIST       =
*    IMPORTING
*     error_message              =
            .

  COMMIT WORK AND WAIT.

ENDFORM.                    " start_conv_doc_struc_fb_c
*&---------------------------------------------------------------------*
*&      Form  start_conv_doc_struc_fb_N_c
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_conv_doc_struc_fb_n_c.
* kein Commit, + FB


  AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD '/CIDEON/CONV_DOC_BOM'.
  IF sy-subrc NE 0.
    "keine Berechtigung
    MESSAGE e000(26) WITH text-000.
  ELSE.
  ENDIF.

  CALL FUNCTION 'CONV_API_CONVERT_DOC_STRUCTURE'
    EXPORTING
      documenttype               = draw-dokar
      documentnumber             = draw-doknr
      documentnumber_ext         = ''
      documentpart               = draw-doktl
      documentversion            = draw-dokvr
*     CHANGE_NUMBER_INT          =
*     CHANGE_NUMBER              =
*     KEY_DATE_INT               =
*     KEY_DATE                   =
*     DOCUMENT_STATUS_INT        =
*     DOCUMENT_STATUS            =
*     CHECK_DOCUMENT_EXIST       =
*    IMPORTING
*     error_message              =
            .


ENDFORM.                    " start_conv_doc_struc_fb_N_c
*&---------------------------------------------------------------------*
*&      Form  start_conv_aut_at_stat_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* Journal
* 02.04.2007 - In der Struktur DRAW steht der interne Dokumentenstatus.
*              Konvertierung in den externen Status notwendig, da der
*              Report mit externen Status arbeitet.
*----------------------------------------------------------------------*
FORM start_conv_aut_at_stat_change.
* Automatisches Starten der Konvertierung mit Status
  DATA: lc_status_external TYPE dokst.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'TCD' FIELD '/CIDEON/CONV_DOC_BOM'.
  IF sy-subrc NE 0.
    "keine Berechtigung
    MESSAGE e000(26) WITH text-000.
  ELSE.
  ENDIF.


* wegen der Möglichkeit, daß Unterbaugruppen noch nicht
* abgelegt und verbucht sind
  COMMIT WORK AND WAIT.

* Internen Status in den externen Status konvertieren.
  CALL FUNCTION 'CV200_DB_TDWS_SELECT'
    EXPORTING
*     PF_USE_BUFFER         = 'X'
      pf_read_desc          = ' '
      pf_dokar              = draw-dokar
      pf_dokst              = draw-dokst
*     PF_LANG               = SY-LANGU
    IMPORTING
*     PSX_TDWS              =
      pfx_stabk             = lc_status_external
*     PFX_DESCRIPTION       =
    EXCEPTIONS
      not_found             = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  SUBMIT conv_convert_doc_structure
    AND RETURN
    WITH dokar = draw-dokar
    WITH doknr = draw-doknr
    WITH doktl = draw-doktl
    WITH dokvr = draw-dokvr
    WITH dokst = lc_status_external
     .

  COMMIT WORK AND WAIT.


ENDFORM.                    " start_conv_aut_at_stat_change

*---------------------------------------------------------------------*
*       FORM start_conv_ipart_check                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM start_conv_ipart_check.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'TCD' FIELD '/CIDEON/CONV_DOC_BOM'.
  IF sy-subrc NE 0.
    "keine Berechtigung
    MESSAGE e000(26) WITH text-000.
  ELSE.
  ENDIF.

* wegen der Möglichkeit, daß Unterbaugruppen noch nicht
* abgelegt und verbucht sind

* Test, ob Dokumentenstückliste existiert, und ob diese benutzt werden
* soll
  DATA: return TYPE bapiret2.
  DATA: itab_structure TYPE TABLE OF bapi_doc_structure.
  DATA: lines TYPE i.

  CLEAR return.
  CLEAR itab_structure.
  CALL FUNCTION 'BAPI_DOCUMENT_GETSTRUCTURE'
    EXPORTING
      documenttype              = draw-dokar
      documentnumber            = draw-doknr
      documentpart              = draw-doktl
      documentversion           = draw-dokvr
    multilevelexplosion       = 'X'
*   DOCBOMCHANGENUMBER        =
*   DOCBOMVALIDFROM           =
*   DOCBOMREVISIONLEVEL       =
    IMPORTING
      return                    = return
     TABLES
    documentstructure         = itab_structure
            .

  IF return IS INITIAL.
  ELSE.
    EXIT.
  ENDIF.

* Test auf Inhalt der Tabelle
  CLEAR lines.
  DESCRIBE TABLE itab_structure LINES lines.
  IF lines = 0.
*   normales IPT
*   CONV02 benutzen
*   CONV_CONVERT_DOCUMENT
*   Name eines speziellen Konverters benutzen
*   Name der WSA benutzen
*   Oder Status benutzen, welcher nie erreicht wird


  ELSE.
*   IPT mit Stückliste
*   also CONV04 benutzen
*   Oder speziellen Status benutzen, welcher nie erreicht wird
*   und nur für diese Konvertierungs zur verfügung steht
    COMMIT WORK AND WAIT.
    SUBMIT conv_convert_doc_structure
      AND RETURN
      WITH dokar = draw-dokar
      WITH doknr = draw-doknr
      WITH doktl = draw-doktl
      WITH dokvr = draw-dokvr
       .
    COMMIT WORK AND WAIT.
  ENDIF.

*  COMMIT WORK AND WAIT.
*
*  SUBMIT conv_convert_doc_structure
*    AND RETURN
*    WITH dokar = draw-dokar
*    WITH doknr = draw-doknr
*    WITH doktl = draw-doktl
*    WITH dokvr = draw-dokvr
*     .
*
*  COMMIT WORK AND WAIT.

ENDFORM.                    "start_conv_ipart_check
