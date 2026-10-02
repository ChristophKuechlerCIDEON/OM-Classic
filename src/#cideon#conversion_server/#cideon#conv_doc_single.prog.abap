REPORT /cideon/conv_doc_single.
*&---------------------------------------------------------------------*
*& Modulpool         /CIDEON/CONV_DOC_SINGLE                          *
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
* 16.11.2005 - Reaktion auf das Setzen eines Status innerhalb des
*              DMS / Konvertierung starten
*
*              Einzelne Konvertierung starten bei einem Temporärstatus
*-----------------------------------------------------------------------
TABLES: draw.

*TYPES
*ITAB
*WA
*NORMAL

"/CIDEON/CONV_DOC_SIN

AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD '/CIDEON/CONV_DOC_SIN'.
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
           ID 'TCD' FIELD '/CIDEON/CONV_DOC_SIN'.
  IF sy-subrc NE 0.
    "keine Berechtigung
    MESSAGE e000(26) WITH text-000.
  ELSE.
  ENDIF.

  COMMIT WORK AND WAIT.

  SUBMIT conv_convert_document
    AND RETURN
    WITH dokar = draw-dokar
    WITH doknr = draw-doknr
    WITH doktl = draw-doktl
    WITH dokvr = draw-dokvr
    WITH dokst = draw-dokst
     .

  COMMIT WORK AND WAIT.

ENDFORM.                    " start_conversion_at_status_chg
*
