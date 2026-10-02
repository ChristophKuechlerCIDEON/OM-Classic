FUNCTION /cideon/get_stmp_sy_datum_zeit.
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
* Normung aus Statuslog DIS / Nutzer - Fester Text
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.04.2005 - Erstellung
* 12.09.2007 - Kopie
*-----------------------------------------------------------------------

*  o_stempel_wert = 'X'.


  CONCATENATE
    sy-datum sy-uzeit
    INTO o_stempel_wert.



ENDFUNCTION.
