*----------------------------------------------------------------------*
***INCLUDE ZCL_PLOT_FERTIGUNGSAUFTRAG_F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  aufpl_folgen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM aufpl_folgen.
* Eintrag für Arbeitsplanfolgen erstellen
  CLEAR wa_drad.
  wa_drad-object_type = c_fg_object_type.
  wa_drad-aufpl = wa_afko-aufpl.

  APPEND wa_drad TO itab_drad.
ENDFORM.                    " aufpl_folgen
*&---------------------------------------------------------------------*
*&      Form  aufpl_vorgaenge
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM aufpl_vorgaenge.
* Eintrag für Arbeitsplan Vorgänge erstellen
  CLEAR wa_drad.
  wa_drad-object_type = c_vg_object_type.
  wa_drad-aufpl = wa_afko-aufpl.

  APPEND wa_drad TO itab_drad.
ENDFORM.                    " aufpl_vorgaenge
*&---------------------------------------------------------------------*
*&      Form  auftragsnummer_schreiben
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auftragsnummer_schreiben.

  LOOP AT itab_drad INTO wa_drad.
    wa_drad-aufnr_pp = wa_fertigung-aufnr.
    MODIFY itab_drad FROM wa_drad INDEX sy-tabix.
  ENDLOOP.
ENDFORM.                    " auftragsnummer_schreiben
