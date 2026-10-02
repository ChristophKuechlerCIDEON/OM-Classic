FUNCTION z_get_dis_keys_slash .
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
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 31.01.2005 - Erstellung
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL

  wa_plotjob = i_wa_plotjobs.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = wa_plotjob-doknr
       IMPORTING
            output = wa_plotjob-doknr.

  CONCATENATE
    wa_plotjob-dokar
    wa_plotjob-doknr
    wa_plotjob-doktl
    wa_plotjob-dokvr
    INTO o_stempel_wert
    SEPARATED BY ' / '.


*  o_stempel_wert = datum.



ENDFUNCTION.
