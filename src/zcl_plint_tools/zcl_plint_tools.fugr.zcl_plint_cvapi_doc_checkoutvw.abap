FUNCTION ZCL_PLINT_CVAPI_DOC_CHECKOUTVW.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(PF_DOKAR) TYPE  DRAW-DOKAR
*"             VALUE(PF_DOKNR) TYPE  DRAW-DOKNR
*"             VALUE(PF_DOKVR) TYPE  DRAW-DOKVR
*"             VALUE(PF_DOKTL) TYPE  DRAW-DOKTL
*"             VALUE(PF_FTP_DEST) TYPE  RFCDES-RFCDEST DEFAULT SPACE
*"             VALUE(PF_HTTP_DEST) TYPE  RFCDES-RFCDEST DEFAULT SPACE
*"             VALUE(PF_HOSTNAME) TYPE  TDWD-NTADR DEFAULT SPACE
*"             VALUE(PF_CONTENT_PROVIDE) TYPE  MCDOK-CONTENT_PROVIDE
*"                             DEFAULT SPACE
*"             VALUE(PS_API_CONTROL) TYPE  CVAPI_API_CONTROL OPTIONAL
*"       EXPORTING
*"             VALUE(PSX_MESSAGE) TYPE  MESSAGES
*"             VALUE(PSX_DRAW) TYPE  DRAW
*"       TABLES
*"              PT_FILES STRUCTURE  CVAPI_DOC_FILE OPTIONAL
*"              PTX_COMPONENTS STRUCTURE  CVAPI_DOC_COMP OPTIONAL
*"              PTX_CONTENT STRUCTURE  DRAO OPTIONAL
*"----------------------------------------------------------------------
*
*  DATA: ls_draw     LIKE draw,
*        ls_draw_old LIKE draw,
*        ls_phio     LIKE dms_phio,
*        ls_cout_def LIKE dms_checkout_def,
*        ls_doc_key  LIKE dms_doc_key,
*        ls_doc_file LIKE dms_doc_file,
*        ls_frontend LIKE dms_frontend_data,
*        lf_filename LIKE draw-filep.
*
*  DATA: lt_draz       LIKE draz         OCCURS 0 WITH HEADER LINE,
*        lt_kpro_data  TYPE dms_rec_file OCCURS 0 WITH HEADER LINE,
*        lt_components LIKE dms_rec_comp OCCURS 0 WITH HEADER LINE,
*        lt_api_comp   TYPE TABLE OF cvapi_doc_comp.
*
*  DATA: lf_error(1)   TYPE c.
***
*---------------------------------------------------------------------
*
***
*---------------------------------------------------------------------
*** Convert the key´s to uppercase
***
*---------------------------------------------------------------------
*  CLEAR: ls_draw,
*         ptx_components.
*
*  REFRESH ptx_components.
*
*  ls_draw-dokar = pf_dokar.
*  ls_draw-doknr = pf_doknr.
*  ls_draw-dokvr = pf_dokvr.
*  ls_draw-doktl = pf_doktl.
*
*  PERFORM convert_doc_keys CHANGING ls_draw.
*
***
*---------------------------------------------------------------------
*** Open document for display
***
*---------------------------------------------------------------------
*  CALL FUNCTION 'CV115_DOC_OPEN_DISPLAY'
*       EXPORTING: pf_api_flag  = 'X'
*                  pf_dokar     = ls_draw-dokar
*                  pf_doknr     = ls_draw-doknr
*                  pf_doktl     = ls_draw-doktl
*                  pf_dokvr     = ls_draw-dokvr
*                  pf_read_drat = ''
*                  pf_read_drad = ''
*                  pf_read_kpro = 'X'
*                  pf_read_comp = 'X'
*       IMPORTING: psx_draw     = ls_draw
*       TABLES:    ptx_draz     = lt_draz
*                  ptx_files    = lt_kpro_data
*       EXCEPTIONS: not_found    = 1
*                   no_auth      = 2
*                   error        = 3
*                   OTHERS       = 4.
*  IF sy-subrc <> 0.
*    PERFORM msg_fill_from_sys CHANGING psx_message.
*    EXIT.
*  ENDIF.
*
***
*---------------------------------------------------------------------
*** Get customizing-data
***
*---------------------------------------------------------------------
*  PERFORM cust_read_data USING ls_draw-dokar.
*
***
*---------------------------------------------------------------------
*** Get frontend-data
***
*---------------------------------------------------------------------
*  CALL FUNCTION 'CV120_GET_FRONTEND_TYPE'
*       EXPORTING: pf_batch          = 'X'
*                  pf_host           = pf_hostname
*       IMPORTING: pfx_frontend_type = ls_frontend-frontend_type
*                  pfx_host          = ls_frontend-hostname
*                  pfx_winsys        = ls_frontend-winsys
*       EXCEPTIONS: error             = 1
*                   no_valid_frontend = 2
*                   OTHERS            = 3.
*  IF sy-subrc <> 0.
*    PERFORM msg_fill_from_sys CHANGING psx_message.
*    EXIT.
*  ENDIF.
*
***
*---------------------------------------------------------------------
*** Loop at files & checkout for view
***
*---------------------------------------------------------------------
*  CLEAR lt_draz.
*  REFRESH lt_draz.
*
*  CLEAR ls_cout_def.
** change by Chris Küchler
*  ls_cout_def-batchmode = ''.
** Cheange End
*  ls_cout_def-kpro_use  = gs_tdwa-kpro_use.
*  ls_cout_def-ftp_dest  = pf_ftp_dest.
*  ls_cout_def-http_dest = pf_http_dest.
*  ls_cout_def-comp_get  = ps_api_control-comp_get.
*  ls_cout_def-comp_path = ps_api_control-comp_path.
*
*** Checkout to server, client, table, ...
*  IF pf_content_provide IS INITIAL.
*    ls_cout_def-content_provide = 'CLNT'.
*  ELSE.
*    ls_cout_def-content_provide = pf_content_provide.
*  ENDIF.
*
*  LOOP AT pt_files.
*    CLEAR ls_doc_file.
*    IF gs_tdwa-kpro_use = 'X'.
*      PERFORM doc_file_fill_phio
*          TABLES lt_kpro_data
*                 lt_components
*          USING  pt_files-lo_objid
*                 pt_files-ph_objid
*          CHANGING ls_phio
*                   ls_doc_file.
*      IF ls_phio IS INITIAL.
*        PERFORM msg_fill_from_sys CHANGING psx_message.
*        EXIT.
*      ENDIF.
*
*      lf_filename = ls_phio-filename.
*
*    ELSE.
*      ls_doc_file-fileno = pt_files-appnr.
*
*      IF pt_files-appnr = '1'.
*        lf_filename = ls_draw-mrk_filep.
*      ELSE.
*        lf_filename = ls_draw-mrk_filep1.
*      ENDIF.
*    ENDIF.
*
*    ls_doc_file-dttrg = pt_files-dttrg.
*
***
*---------------------------------------------------------------------
*** if only the path is given -> create temp.-filename
***
*---------------------------------------------------------------------
*    IF NOT pt_files-pathname IS INITIAL AND
*           pt_files-filename IS INITIAL.
*      PERFORM create_tmp_file
*          USING ls_frontend
*                lf_filename
*          CHANGING pt_files.
*    ENDIF.
*
***
*---------------------------------------------------------------------
*** define filename for checkout
***
*---------------------------------------------------------------------
*    PERFORM set_checkout_file_name
*        CHANGING pt_files
*                 ls_doc_file-filename.
*
***
*---------------------------------------------------------------------
*** Call API
***
*---------------------------------------------------------------------
*    CALL FUNCTION 'CV120_DOC_CHECKOUT_VIEW'
*         EXPORTING: ps_cout_def   = ls_cout_def
*                    pf_tcode      = c_dms_display
*                    ps_doc_file   = ls_doc_file
*                    ps_draw       = ls_draw
*                    ps_phio       = ls_phio
*                    ps_frontend   = ls_frontend
*         IMPORTING: pfx_file      = pt_files-filename
*                    pfx_url       = pt_files-url
*         TABLES:    pt_components = lt_components
*                    pt_draz       = lt_draz
*                    ptx_content   = ptx_content
*         EXCEPTIONS: error        = 1
*                     OTHERS       = 2.
*    IF sy-subrc <> 0.
*      PERFORM msg_fill_from_sys CHANGING psx_message. EXIT.
*    ENDIF.
*
*** Save filename from checkout_view
*    MODIFY pt_files.
*
** Save Comp. -> back to caller
*    IF ls_cout_def-comp_get = 'X'.
*      IF gs_tdwa-kpro_use = 'X'.
*        PERFORM move_kpro_comp2api
*            TABLES lt_api_comp
*                   lt_components.
*
*      ELSE.
*        PERFORM move_draz2api
*            TABLES lt_api_comp
*                   lt_draz.
*      ENDIF.
*
*      APPEND LINES OF lt_api_comp TO ptx_components.
*    ENDIF.
*  ENDLOOP.
*
*  psx_draw = ls_draw.
ENDFUNCTION.
