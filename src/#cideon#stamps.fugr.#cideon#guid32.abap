FUNCTION /cideon/guid32.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------
* GUID erstellen
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 04.11.2009
*
* 7.0.170.1
* 2014/10/02 - APEX
* Anpassung der Sourcen auf Ersetzung von FB GUID_CREATE
*-----------------------------------------------------------------------

  DATA: lc_guid_32 TYPE guid_32.

  CLEAR lc_guid_32.

  "CALL FUNCTION 'GUID_CREATE'
  CALL FUNCTION '/CIDEON/OM_CLASSIC_GUID_CREATE'
   IMPORTING
*     EV_GUID_16       =
*     EV_GUID_22       =
      ev_guid_32       = lc_guid_32
            .



  o_stempel_wert = lc_guid_32.


ENDFUNCTION.
