FUNCTION /cideon/check_priorities.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      ITAB_TMP_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 12.07.2004 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs TYPE zcl_s_plotlist.

* sets the priorities to allowed values
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    IF wa_plotjobs-prio > i_wa_user_data-prio_bis.
      wa_plotjobs-prio = i_wa_user_data-prio_bis.
      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
    ELSE.
    ENDIF.
    IF wa_plotjobs-prio < i_wa_user_data-prio_von.
      wa_plotjobs-prio = i_wa_user_data-prio_von.
      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
    ELSE.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
