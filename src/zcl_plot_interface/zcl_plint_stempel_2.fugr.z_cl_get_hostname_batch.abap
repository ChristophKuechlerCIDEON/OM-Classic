FUNCTION z_cl_get_hostname_batch.
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
* 26.07.2002 - Erstellung
*-----------------------------------------------------------------------

  DATA pf_batch.
  IF sy-uname = 'WF-BATCH'.
    pf_batch = 'X'.
  ENDIF.

  IF sy-batch = 'X'.
    pf_batch = 'X'.
  ELSE.
  ENDIF.

  CALL FUNCTION 'CV120_GET_HOSTNAME'
       EXPORTING
            pf_batch          = pf_batch
       IMPORTING
            pfx_host          = o_stempel_wert
       EXCEPTIONS
            error             = 1
            no_valid_frontend = 2
            OTHERS            = 3.
  IF sy-subrc <> 0.
*    PERFORM appl_log_write USING
*      'W' '012' 'ZCL_PLINT_TOOLS'
*      '' ''
*      '' 'Z_CL_GET_HOSTNAME'.
  ENDIF.



ENDFUNCTION.
