FUNCTION /cideon/get_stmp_dbom_dis_sl_2.
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
* 30.03.2006 - Erstellung
*-----------------------------------------------------------------------
* Stücklistennummer auf Stempel
*
*-----------------------------------------------------------------------


*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL



  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = wa_plotjob-doknr_bom
       IMPORTING
            output = wa_plotjob-doknr_bom.


  CONCATENATE
    wa_plotjob-dokar_bom '/'
    wa_plotjob-doknr_bom '/'
    wa_plotjob-doktl_bom '/'
    wa_plotjob-dokvr_bom
  INTO o_stempel_wert.




ENDFUNCTION.
