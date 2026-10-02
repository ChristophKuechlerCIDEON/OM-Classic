FUNCTION /cideon/proc_mat_status_exc.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      ITAB_MAT_STATUS_EXC STRUCTURE  ZCL_S_MSTAE
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
* 05.07.2004 - Erstellung
*-----------------------------------------------------------------------

*TYPES
*ITAB
*WA
*NORMAL

  REFRESH itab_mat_status_exc.
  SPLIT i_wa_user_data-mat_status_exc AT i_wa_user_data-trennzeichen
    INTO TABLE itab_mat_status_exc.

ENDFUNCTION.
