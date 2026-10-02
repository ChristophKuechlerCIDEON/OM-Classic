FUNCTION z_cl_fehlblatt_process.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(WA_FEHL_FILES) LIKE  ZCL_S_PLOTLIST STRUCTURE
*"        ZCL_S_PLOTLIST OPTIONAL
*"  TABLES
*"      O_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      I_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : lv_fehl_doc_detail(200) TYPE c.

  CLEAR i_itab_x_lines.
  CLEAR i_itab_x_lines-line.

  MOVE 'AOFB' TO i_itab_x_lines-line.
  APPEND i_itab_x_lines.

  CLEAR i_itab_x_lines.
  CLEAR i_itab_x_lines-line.

  CONCATENATE 'APPL$_KIND = ' '1' INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_ERASE = ' '0' INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE job_fehllist-dokar '_'
              job_fehllist-doknr '_'
              job_fehllist-dokvr '_'
              job_fehllist-doktl
              INTO fehl_doc_detail.

  CONCATENATE 'APPL$_ORIGINALNAME = ' lv_fehl_doc_detail
                                INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.


  CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.


  CONCATENATE 'APPL$_PATH = ' 'C:\' lv_fehl_doc_detail
                                    INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_RESOLUTION = ' job_fehllist-aufloesung
                                        INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  LOOP AT itab_paper_format INTO
        wa_paper_format WHERE paper_format =
                           job_fehllist-format_ausgabe.
    CONCATENATE 'APPL$_TARGETFORMAT = '
        wa_paper_format-paper_index INTO i_itab_x_lines-line+1.
    APPEND i_itab_x_lines.
  ENDLOOP.


  CONCATENATE 'APPL$_SCALINGX = '
           job_fehllist-skalieren_x INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_SCALINGY = '
           job_fehllist-skalieren_y INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_MEDIUM = '
                job_fehllist-medium INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_ROTATE ='
                job_fehllist-drehen INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_MIRROR = '
              job_fehllist-spiegeln INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CLEAR num_copy.
  MOVE job_fehllist-kopien TO num_copy.
  CONCATENATE 'APPL$_COPY = '  num_copy INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_FOLD = '
              job_fehllist-falten INTO  i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_PUNCH = '
               job_fehllist-lochen INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_BINDINGEDGE = '
            job_fehllist-heftrand INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_STAMP = '
                job_fehllist-stempel INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.


  CONCATENATE 'APPL$_FORMAT = '
          job_fehllist-format_ausgabe INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_PENTABLE = '
            job_fehllist-stifttabelle INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_ORIENTATION = '
              job_fehllist-ausrichtung INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

*         If the document is converted by Client '1' else '0'.
*         For more details refer Doc-Manager.
*         But at this moment itz '0' as hard coded one.
  CONCATENATE 'APPL$_CONVERTED = ' '0' INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_CORRECTIONX = ' '1'
                                INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_CORRECTIONY = ' '1'
                                INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_DAPPL1 = '
           job_fehllist-wsapplication INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_TYPE = '
             job_fehllist-appl_type INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_COMPRESSION = '
             job_fehllist-appl_comp INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  CONCATENATE 'APPL$_OFFSETXY = '
             job_fehllist-verschiebung INTO i_itab_x_lines-line+1.
  APPEND i_itab_x_lines.

  IF job_fehllist-seite NE space.
    CONCATENATE 'APPL$_PAGES = '
                job_fehllist-seite INTO i_itab_x_lines-line+1.
    APPEND i_itab_x_lines.
  ELSE.
  ENDIF.

  MOVE 'AOFE' TO i_itab_x_lines-line.
  APPEND i_itab_x_lines.



ENDFUNCTION.
