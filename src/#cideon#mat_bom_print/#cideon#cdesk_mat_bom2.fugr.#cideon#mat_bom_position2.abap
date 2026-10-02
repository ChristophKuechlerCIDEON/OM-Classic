FUNCTION /cideon/mat_bom_position2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(MATNR) TYPE  MARA-MATNR
*"     VALUE(PLANT) TYPE  STKO-WRKAN
*"     VALUE(USAGE) TYPE  MASTB-STLAN
*"     VALUE(ALTER) TYPE  STKO-STLAL
*"     VALUE(AENNR) TYPE  STKOB-AENNR
*"     VALUE(DATUV) TYPE  DATUV
*"     REFERENCE(SPRAS) TYPE  SPRAS DEFAULT SY-LANGU
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"  TABLES
*"      MAT_BOM STRUCTURE  STPOX OPTIONAL
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
*
*           Chris Küchler
*           Christoph.Kuechler@cideon.com
*
*-----------------------------------------------------------------------
* Journal   14.01.2005 Ermitteln der Positionsdaten zur Stückliste
*                      bei Übergabe der Kopfmaterialdaten
*           20.06.2005 Erweiterung um Parameter DATUV
* SP 104
*           28.09.2009 Auflösungsstufe übergeben
* SP 105
* 05.10.2008 - Verwendung benutzen, falls es sich um CS03 handelt
*-----------------------------------------------------------------------


  DATA: lt_stpox TYPE TABLE OF stpox,
        ls_stpox TYPE stpox.

  " CKR
  "g_capid = 'PP01'.
  "BOMTYPE -> Auflösung für CS03 -> nicht mehrstufig
  "
  DATA: mehrs TYPE csdata-xfeld.
  mehrs = 'X'.

  IF g_bomtype = 'CS03'.
    CLEAR mehrs.
  ELSE.
    CLEAR g_usage.
  ENDIF.


  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
       EXPORTING
            capid                 = g_capid
            datuv                 = g_datuv
            ehndl                 = '1'
            emeng                 = 1
            mktls                 = 'X'
            mehrs                 = mehrs "'X'
            mmory                 = '1'
            mtnrv                 = g_head_matnr
            stlal                 = g_alternative
            stlan                 = g_usage
            stpst                 = g_stpst                 "'99'
            svwvo                 = 'X'
            werks                 = g_plant
            vrsvo                 = 'X'
       TABLES
            stb                   = lt_stpox
       EXCEPTIONS
            alt_not_found         = 1
            call_invalid          = 2
            material_not_found    = 3
            missing_authorization = 4
            no_bom_found          = 5
            no_plant_data         = 6
            no_suitable_bom_found = 7
            conversion_error      = 8
            OTHERS                = 9.
  IF sy-subrc <> 0.
    MOVE 'E' TO return-type.
  ELSE.
    mat_bom[] = lt_stpox[].
  ENDIF.

ENDFUNCTION.
