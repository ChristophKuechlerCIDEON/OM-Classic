FUNCTION /cideon/mat_bom_change.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(BOM_PRINT) TYPE  /CIDEON/BOM_PRINT
*"  CHANGING
*"     REFERENCE(HEAD_MAT_STRUC) TYPE  ANY
*"     REFERENCE(MAT_BOM_TAB) TYPE  ANY
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*       CIDEON Software GmbH
*       Peterstraße 1
*       02826 Görlitz
*----------------------------------------------------------------------
*       Editiermöglichkeit der Materialstückliste
*       vorm Druck - Musterimplementierung des BADI
*       METHOD /CIDEON/IF_EX_MAT_BOM_PRIN~CHANGE_TABLE
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           13.05.2005
*-----------------------------------------------------------------------
* Journal   13.05.2005 Anlegen Musterimplementierung und FB
*DDIF_NAMETAB_GET -> Laufzeitinformation der DD-Komponente


  FIELD-SYMBOLS:  <table> TYPE ANY TABLE,
                  <struc> TYPE ANY,
                  <field> TYPE ANY.

  MOVE bom_print TO gs_bom_print.
*1.  Ermittlung des Tabellennamens
  CASE gs_bom_print-bomtype.
    WHEN 'CS03'.
      CASE bom_print-bomausp.
        WHEN 'A'.
          tabname = '/CIDEON/STPOS_CS03_A'.
        WHEN 'D'.
          tabname = '/CIDEON/STPOS_CS03_D'.
        WHEN 'M'.
          tabname = '/CIDEON/STPOS_CS03_M'.
      ENDCASE.
    WHEN 'CS11'.
      tabname = '/CIDEON/STPOS_CS11'.
    WHEN 'CS12'.
      tabname = '/CIDEON/STPOS_CS12'.
    WHEN 'CS13'.
      tabname = '/CIDEON/STPOS_CS13'.
    WHEN OTHERS.
      CLEAR tabname.
  ENDCASE.

*2.  Ermittlung der Tabellenstruktur
  CHECK NOT tabname IS INITIAL.
  CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
            tabname   = tabname
       TABLES
            dfies_tab = dfies_tab
       EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
  IF sy-subrc <> 0.
    RAISE error.
  ENDIF.

*3.  Auslesen der Namen der Felder für Operationen
  LOOP AT dfies_tab ASSIGNING <struc>.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <struc> TO <field>.
    CHECK <field> IS ASSIGNED.
    gs_fields = <field>.
    APPEND gs_fields TO gt_fields.
  ENDLOOP.

*4.  Erzeugen ALV zum Editieren
  CALL SCREEN 100.

ENDFUNCTION.
