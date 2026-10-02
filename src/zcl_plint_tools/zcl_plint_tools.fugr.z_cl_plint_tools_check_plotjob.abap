FUNCTION z_cl_plint_tools_check_plotjob.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      I_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
* 23.07.2002 creation
*
*-----------------------------------------------------------------------
* to do:
*      - add some checks
*-----------------------------------------------------------------------

* check if there is an different Priority

  CLEAR wa_plotjobs.
  CLEAR wa_plotjobs_alt.
  LOOP AT i_itab_plotjobs INTO wa_plotjobs.
    IF wa_plotjobs_alt IS INITIAL.
    ELSE.
      IF wa_plotjobs-prio <> wa_plotjobs_alt-prio.
        MESSAGE i064(zcl_plint_message_01) WITH '' '' '' ''
          RAISING error.
      ELSE.
      ENDIF.
    ENDIF.
    wa_plotjobs_alt = wa_plotjobs.

  ENDLOOP.



ENDFUNCTION.
