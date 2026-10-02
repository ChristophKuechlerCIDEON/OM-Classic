FUNCTION z_cl_process_failed_docs.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(WA_ZCL_S_PLOTLIST) LIKE  ZCL_S_PLOTLIST STRUCTURE
*"        ZCL_S_PLOTLIST OPTIONAL
*"  TABLES
*"      I_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      O_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : lv_no_lines_in_job_fehllist TYPE i,
         lv_fehl_doc_detail(200)     TYPE c,
         lv_num_copy                 TYPE n,
         lv_n                        TYPE i VALUE 1.

  DATA  : wa_job_fehllist TYPE zcl_s_plotlist.

  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.

  MOVE 'AOFB' TO i_itab_x_lines-line.
  APPEND i_itab_x_lines.


  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 45
            text       = text-108.

  CONCATENATE 'APPL$_KIND = ' '1' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ERASE = ' '0' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE job_fehllist-dokar '_'
              job_fehllist-doknr '_'
              job_fehllist-dokvr '_'
              job_fehllist-doktl
              INTO lv_fehl_doc_detail.

  CONCATENATE 'APPL$_ORIGINALNAME = ' lv_fehl_doc_detail
                                INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.


  CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.


  CONCATENATE 'APPL$_PATH = ' 'C:\' lv_fehl_doc_detail
                                    INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_RESOLUTION = ' wa_zcl_s_plotlist-aufloesung
                                        INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.


  LOOP AT itab_paper_format INTO
        wa_paper_format WHERE paper_format =
                           wa_zcl_s_plotlist-format_ausgabe.
    CONCATENATE 'APPL$_TARGETFORMAT = '
        wa_paper_format-paper_index INTO o_itab_x_lines-line+1.
    APPEND o_itab_x_lines.
  ENDLOOP.


  CONCATENATE 'APPL$_SCALINGX = '
           wa_zcl_s_plotlist-skalieren_x INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_SCALINGY = '
           wa_zcl_s_plotlist-skalieren_y INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_MEDIUM = '
                wa_zcl_s_plotlist-medium INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ROTATE ='
                wa_zcl_s_plotlist-drehen INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_MIRROR = '
              wa_zcl_s_plotlist-spiegeln INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CLEAR num_copy.
  MOVE wa_zcl_s_plotlist-kopien TO lv_num_copy.
  CONCATENATE 'APPL$_COPY = '  lv_num_copy INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_FOLD = '
              wa_zcl_s_plotlist-falten INTO  o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_PUNCH = '
               wa_zcl_s_plotlist-lochen INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_BINDINGEDGE = '
            wa_zcl_s_plotlist-heftrand INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_STAMP = '
                wa_zcl_s_plotlist-stempel INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.


  CONCATENATE 'APPL$_FORMAT = '
          wa_zcl_s_plotlist-format_ausgabe INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_PENTABLE = '
            wa_zcl_s_plotlist-stifttabelle INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ORIENTATION = '
              wa_zcl_s_plotlist-ausrichtung INTO o_itab_x_lines-line+1
.
  APPEND o_itab_x_lines.

*         If the document is converted by Client '1' else '0'.
*         For more details refer Doc-Manager.
*         But at this moment itz '0' as hard coded one.
  CONCATENATE 'APPL$_CONVERTED = ' '0' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_CORRECTIONX = ' '1'
                                INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_CORRECTIONY = ' '1'
                                INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_DAPPL1 = '
           wa_zcl_s_plotlist-wsapplication INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_TYPE = '
             wa_zcl_s_plotlist-appl_type INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_COMPRESSION = '
             wa_zcl_s_plotlist-appl_comp INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_OFFSETXY = '
             wa_zcl_s_plotlist-verschiebung INTO o_itab_x_lines-line+1
.
  APPEND o_itab_x_lines.

  IF wa_zcl_s_plotlist-seite NE space.
    CONCATENATE 'APPL$_PAGES = '
                wa_zcl_s_plotlist-seite INTO o_itab_x_lines-line+1.
    APPEND o_itab_x_lines.
  ELSE.
  ENDIF.

  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.

  MOVE 'AOFE' TO i_itab_x_lines-line.
  APPEND i_itab_x_lines.

ENDFUNCTION.
