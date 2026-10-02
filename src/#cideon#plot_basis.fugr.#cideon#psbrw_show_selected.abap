FUNCTION /cideon/psbrw_show_selected.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"  TABLES
*"      SELECTED_OBJECTS STRUCTURE  PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*           Eric Voss
*           eric.voss@cideon.com
*-----------------------------------------------------------------------
* Journal
*
*-------------------------------------------------------------------
********************************************
* ACHTUNG !  Parallel-FB Z_CL_PSBRW_SHOW_SELECTED_z
*            bitte gleichlautend anpassen !
* 2009/06/22 - Kopie Eric Voss von Z_CL_PSBRW_SHOW_SELECTED
*              Tablecontrol durch ALV ersetzt
*
*
***********************************************************************

  CLEAR:    ok_code, gs_stored_search.
  REFRESH   gt_stored_search.


  SELECT * FROM zcl_psb_tmp
    INTO TABLE gt_stored_search
    WHERE uname = sy-uname
    .

  IF sy-subrc NE 0.
    MESSAGE s151(zcl_plint_message_01) WITH
      '' '' '' ''.
  ELSE.
  ENDIF.

  CALL SCREEN 800 STARTING AT 10 10.

  CLEAR:     ok_code, gs_stored_search.
  REFRESH    gt_stored_search.

ENDFUNCTION.
