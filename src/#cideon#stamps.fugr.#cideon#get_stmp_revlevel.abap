FUNCTION /cideon/get_stmp_revlevel.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 28.09.2006 - Erstellung
*-----------------------------------------------------------------------
* Revisionslevel holen
*
*-----------------------------------------------------------------------


  DATA: revlv TYPE revlv.
  DATA: datuv TYPE aenr-datuv.


  DATA: wa_doc_key TYPE dms_doc_key.

  CLEAR wa_doc_key.
  wa_doc_key-dokar = i_wa_plotjobs-dokar.
  wa_doc_key-doknr = i_wa_plotjobs-doknr.
  wa_doc_key-doktl = i_wa_plotjobs-doktl.
  wa_doc_key-dokvr = i_wa_plotjobs-dokvr.

  CALL FUNCTION 'CV115_ECN_DATA_GET'
       EXPORTING: ps_doc_key     = wa_doc_key
                  pf_aennr       = i_wa_plotjobs-aennr
                  pf_display     = 'X'
       IMPORTING: pfx_valid_from = datuv
                  pfx_revlevel   = revlv
                  .



  o_stempel_wert = revlv.


ENDFUNCTION.
