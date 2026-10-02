FUNCTION /CIDEON/BAPI_DOC_GETSTRUC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DOCUMENTTYPE) LIKE  BAPI_DOC_AUX-DOCTYPE
*"     VALUE(DOCUMENTNUMBER) LIKE  BAPI_DOC_AUX-DOCNUMBER
*"     VALUE(DOCUMENTPART) LIKE  BAPI_DOC_AUX-DOCPART
*"     VALUE(DOCUMENTVERSION) LIKE  BAPI_DOC_AUX-DOCVERSION
*"     VALUE(MULTILEVELEXPLOSION) LIKE  BAPI_DOC_AUX-FLAG DEFAULT ''
*"     VALUE(DOCBOMCHANGENUMBER) LIKE  BAPI_DOC_DRAW2-ECNUMBER OPTIONAL
*"     VALUE(DOCBOMVALIDFROM) LIKE  BAPI_DOC_DRAW2-VALIDFROMDATE
*"       OPTIONAL
*"     VALUE(DOCBOMREVISIONLEVEL) LIKE  BAPI_DOC_DRAW2-REVLEVEL
*"       OPTIONAL
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      DOCUMENTSTRUCTURE STRUCTURE  BAPI_DOC_STRUCTURE OPTIONAL
*"      DOC_BOM STRUCTURE  STPOX OPTIONAL
*"----------------------------------------------------------------------
* CIDEON Holen Dokumentenstruktur mit Standard-FB
*        BAPI_DOCUMENT_GETSTRUCTURE erweitert um
*        Table DOC_BOM mit Hirarchiestufe
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           24.03.2004
*-----------------------------------------------------------------------
* Journal

  DATA: lf_subrc          LIKE syst-subrc,
        lf_error(1)       TYPE c,
        lf_rows           TYPE i.

  DATA: lf_dokar LIKE draw-dokar,
        lf_doknr LIKE draw-doknr,
        lf_doktl LIKE draw-doktl,
        lf_dokvr LIKE draw-dokvr,
        lf_date  LIKE rc29l-datuv,
        lf_multilevel(1) TYPE c.

  DATA: ls_document LIKE bapi_doc_draw2.

  DATA: lt_messages LIKE messages OCCURS 10 WITH HEADER LINE,
        lt_doc_bom  LIKE stpox    OCCURS  0 WITH HEADER LINE.
  DATA: bapi_message LIKE messages.

* ----------------------------------------------------------------------

  CLEAR: return.

* ----------------------------------------------------------------------
* Document-Keys
* ----------------------------------------------------------------------
  TRANSLATE documenttype    TO UPPER CASE.               "#EC TRANSLANG
  TRANSLATE documentnumber  TO UPPER CASE.               "#EC TRANSLANG
  TRANSLATE documentversion TO UPPER CASE.               "#EC TRANSLANG
  TRANSLATE documentpart    TO UPPER CASE.               "#EC TRANSLANG

  lf_dokar = documenttype.
  lf_doknr = documentnumber.
  lf_doktl = documentpart.
  lf_dokvr = documentversion.

  ls_document-documenttype = documenttype.
  ls_document-documentnumber = documentnumber.
  ls_document-documentpart = documentpart.
  ls_document-documentversion = documentversion.

  lf_multilevel = multilevelexplosion.
  CLEAR bapi_message.
** Read date

  CALL FUNCTION 'CAD_ECM_READ'
       EXPORTING
            document       = ls_document
            change_number  = docbomchangenumber
            valid_from     = docbomvalidfrom
            revision_level = docbomrevisionlevel
            multi_level    = lf_multilevel
       IMPORTING
            date_internal  = lf_date
            return         = return.

  IF return-type CA 'EA'. EXIT. ENDIF.

** Read Document-BOM
  CALL FUNCTION 'API_DOCUMENT_READ_BOM'
       EXPORTING: pf_dokar      = lf_dokar
                  pf_doknr      = lf_doknr
                  pf_doktl      = lf_doktl
                  pf_dokvr      = lf_dokvr
                  pf_datum      = lf_date
                  pf_multilevel = lf_multilevel
       TABLES:    pt_doc_bom    = lt_doc_bom
                  pt_messages   = lt_messages
       EXCEPTIONS: error          = 1
                   no_data_found  = 2.

  IF sy-subrc <> 0.
    bapi_message-msg_id = '29'.
    bapi_message-msg_type = 'E'.
    bapi_message-msg_no = '731'.

   CLEAR RETURN.
  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
       EXPORTING:  TYPE       = bapi_MESSAGE-MSG_TYPE
                   CL         = bapi_MESSAGE-MSG_ID
                   NUMBER     = bapi_MESSAGE-MSG_NO
                   PAR1       = bapi_MESSAGE-MSG_V1
                   PAR2       = bapi_MESSAGE-MSG_V2
                   PAR3       = bapi_MESSAGE-MSG_V3
                   PAR4       = bapi_MESSAGE-MSG_V4
                   ROW        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
      IMPORTING : RETURN = RETURN.

  IF NOT bapi_MESSAGE-MSG_TXT IS INITIAL.
    RETURN-MESSAGE = bapi_MESSAGE-MSG_TXT.
  ENDIF.

** Fill DOCUMENTSTRUCTURE
  ELSE.
    LOOP AT lt_doc_bom.
      CLEAR: documentstructure, doc_bom.
      documentstructure-documenttype    = lt_doc_bom-dokar.
      documentstructure-documentnumber  = lt_doc_bom-doknr.
      documentstructure-documentpart    = lt_doc_bom-doktl.
      documentstructure-documentversion = lt_doc_bom-dokvr.
      documentstructure-sortstring      = lt_doc_bom-sortf.
      documentstructure-recallowed      = lt_doc_bom-rekrs.
      documentstructure-cad_pos         = lt_doc_bom-cadpo.
      MOVE lt_doc_bom-menge TO documentstructure-quantity.
      APPEND documentstructure.
      doc_bom-dokar  = lt_doc_bom-dokar.
      doc_bom-doknr  = lt_doc_bom-doknr.
      doc_bom-doktl  = lt_doc_bom-doktl.
      doc_bom-dokvr  = lt_doc_bom-dokvr.
      doc_bom-stufe  = lt_doc_bom-stufe.
      append doc_bom.

    ENDLOOP.
  ENDIF.
ENDFUNCTION.
