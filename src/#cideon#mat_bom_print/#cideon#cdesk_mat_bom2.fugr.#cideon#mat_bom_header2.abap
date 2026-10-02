FUNCTION /cideon/mat_bom_header2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(MATNR) TYPE  MARA-MATNR
*"     VALUE(PLANT) TYPE  STKO-WRKAN
*"     VALUE(USAGE) TYPE  MASTB-STLAN
*"     VALUE(ALTER) TYPE  STKO-STLAL
*"     VALUE(AENNR) TYPE  STKOB-AENNR
*"     VALUE(DATUV) TYPE  DATUV
*"     VALUE(SPRAS) TYPE  SPRAS DEFAULT SY-LANGU
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"  TABLES
*"      HEAD_MAT STRUCTURE  RC29K OPTIONAL
*"----------------------------------------------------------------------
*       CIDEON Software GmbH
*       Peterstraße 1
*       02826 Görlitz
*----------------------------------------------------------------------
*       Selektion und Druck Materialstückliste
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           14.01.2005
*-----------------------------------------------------------------------
* Journal   14.01.2005 Ermitteln der Daten des Kopfmaterials
*                      zur MATNR
*           20.06.2005 Erweiterung um Parameter DATUV
*-----------------------------------------------------------------------

  DATA:
        ls_t001w TYPE t001w,
        ls_makt TYPE makt,
        lt_mastb TYPE TABLE OF mastb,
        lt_stkob TYPE TABLE OF stkob,
        lt_stzub TYPE TABLE OF stzub,
        ls_stkob TYPE stkob.

  CALL FUNCTION 'CS_BOMHEADERS_GET_MAT'
       EXPORTING
            matnr           = g_head_matnr
            stlal           = g_alternative
            stlan           = g_usage
            werks           = g_plant
            datuv           = g_datuv
       TABLES
            mastb_wa        = lt_mastb
            stkob_wa        = lt_stkob
            stzub_wa        = lt_stzub
       EXCEPTIONS
            call_invalid    = 1
            no_record_found = 2
            OTHERS          = 3.
  IF sy-subrc <> 0.
    MOVE 'E' TO return-type.
  ENDIF.


  READ TABLE lt_stkob INTO ls_stkob INDEX 1.

  head_mat-matnr = g_head_matnr.
  head_mat-werks = g_plant.
  head_mat-stlal = g_alternative.
  head_mat-stlan = g_usage.
  head_mat-aennr = g_changeno.
  head_mat-bmein = ls_stkob-bmein.
  head_mat-bmeng = ls_stkob-bmeng.
  head_mat-stlnr = ls_stkob-stlnr.
  head_mat-datuv = ls_stkob-datuv.
  head_mat-stlty = ls_stkob-stlty.
  head_mat-datub = ls_stkob-datub.

  SELECT SINGLE * FROM t001w INTO ls_t001w
  WHERE werks = g_plant.
  head_mat-wtext = ls_t001w-name1.

  SELECT SINGLE * FROM makt INTO ls_makt
  WHERE matnr = g_head_matnr
  AND   spras = spras.
  head_mat-obktx = ls_makt-maktx.

*- select revisionlevel

  CALL FUNCTION 'REVISION_LEVEL_SELECT'
       EXPORTING
            datuv              = ls_stkob-datuv
            matnr              = g_head_matnr
       IMPORTING
            arevlv             = head_mat-revlv
       EXCEPTIONS
            date_not_found     = 01
            ecn_not_found      = 02
            ecn_no_revision    = 03
            input_incomplete   = 04
            input_inconsistent = 05
            revision_not_found = 06.
  IF sy-subrc NE 0.
    return-type = space.
*  keine Aktivitäten !
  ENDIF.

  IF  head_mat-datuv IS INITIAL
  AND head_mat-aennr IS INITIAL
  AND head_mat-revlv IS INITIAL.
    MOVE 'E' TO return-type.
  ENDIF.
  APPEND head_mat.

ENDFUNCTION.
