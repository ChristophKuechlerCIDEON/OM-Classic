FUNCTION /cideon/check_stamp_wsapp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NUTZER) TYPE  XUBNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  XUBNAME
*"     VALUE(I_WSAPP) TYPE  DAPPL
*"  EXCEPTIONS
*"      ERROR
*"      DO_NOT_STAMP
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   -  checkt für welche Workstationapplikation gestempelt werden soll
*   -
*-----------------------------------------------------------------------
* Journal
* 03.07.2003
*-----------------------------------------------------------------------

*TYPES
*ITAB
*WA
  DATA: wa_v_usr_grp_ws TYPE zcl_v_usr_grp_ws.
*NORMAL



* Stempel für Nutzer holen
* Nutzer -> Nutzergruppe -> DOKAR
* ZCL_V_USR_GRP_WS

  SELECT SINGLE * FROM zcl_v_usr_grp_ws INTO wa_v_usr_grp_ws
    WHERE nutzer = i_nutzer
      AND wsapplication = i_wsapp.
  IF sy-subrc NE 0.
    SELECT SINGLE * FROM zcl_v_usr_grp_ws INTO wa_v_usr_grp_ws
      WHERE nutzer = i_default_nutzer
        AND wsapplication = i_wsapp.
    IF sy-subrc NE 0.
      RAISE do_not_stamp.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


ENDFUNCTION.
