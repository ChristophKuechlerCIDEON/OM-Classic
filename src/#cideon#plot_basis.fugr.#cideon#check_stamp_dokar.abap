FUNCTION /cideon/check_stamp_dokar.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NUTZER) TYPE  XUBNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  XUBNAME
*"     VALUE(I_DOKAR) TYPE  DOKAR
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
*   -  checkt für welche DOKAR gestempelt werden soll
*   -
*-----------------------------------------------------------------------
* Journal
* 03.07.2003
*-----------------------------------------------------------------------

*TYPES
*ITAB
*WA
  DATA: wa_v_usr_grp_dk TYPE zcl_v_usr_grp_dk.
*NORMAL



* Stempel für Nutzer holen
* Nutzer -> Nutzergruppe -> DOKAR
* ZCL_V_USR_GRP_DK

  SELECT SINGLE * FROM zcl_v_usr_grp_dk INTO wa_v_usr_grp_dk
    WHERE nutzer = i_nutzer
      AND dokar = i_dokar.
  IF sy-subrc NE 0.
    SELECT SINGLE * FROM zcl_v_usr_grp_dk INTO wa_v_usr_grp_dk
      WHERE nutzer = i_default_nutzer
        AND dokar = i_dokar.
    IF sy-subrc NE 0.
      RAISE do_not_stamp.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


ENDFUNCTION.
