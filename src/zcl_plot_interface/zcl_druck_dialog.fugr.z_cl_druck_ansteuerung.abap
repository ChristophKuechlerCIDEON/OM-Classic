FUNCTION z_cl_druck_ansteuerung.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PS_DRAW) TYPE  DRAW
*"     VALUE(PF_APPNR) TYPE  C
*"     VALUE(PF_DAPPL) TYPE  DRAW-DAPPL
*"     VALUE(PF_APPTP) TYPE  TDWX-APPTP
*"     VALUE(PF_FILE) TYPE  C
*"     VALUE(PF_URL) TYPE  MCDOK-URL
*"  TABLES
*"      PT_COMPONENT TYPE  DMS_TBL_COMP
*"      PT_DRAZ STRUCTURE  DRAZ
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
* 17.03.2003 Erstellung
*-----------------------------------------------------------------------


* Aufruf des Druckdialoges


* Benutzerinformationen / -einstellungen laden

* Mappen der Informationen

* Aufruf der CLF Funktionalität von Sri

*  CALL FUNCTION 'Z_CL_NEW_PLOT_LIST_CLF'
*       EXPORTING
*            default_user      = default_data-default_nutzer
*            i_down_path       = str_down_path
*            i_clf_down_path   = str_ppl_down_path
*            filter            = '*.*'
*            i_out_proc        = user_data-knz_auto_process
*            i_delete_item     = user_data-delete_item
*            i_delete_status   = user_data-delete_status
*            i_format_checking = user_data-knz_format_checking
*       TABLES
*            itab_test         = itab_tmp_plotjobs_2
*            itab_stamps       = itab_stempel_wert
*       EXCEPTIONS
*            error             = 1
*            OTHERS            = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.




ENDFUNCTION.
