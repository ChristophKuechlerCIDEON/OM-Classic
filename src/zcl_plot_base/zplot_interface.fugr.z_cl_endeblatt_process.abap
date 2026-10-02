FUNCTION z_cl_endeblatt_process.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(WA_JOBLIST_FILE) LIKE  ZCL_S_PLOTLIST STRUCTURE
*"        ZCL_S_PLOTLIST OPTIONAL
*"     VALUE(I_ENDE_DOWN_PATH) LIKE  RLGRAP-FILENAME OPTIONAL
*"  TABLES
*"      O_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      I_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : lv_stripped_name TYPE rlgrap-filename,
         lv_file_path     TYPE rlgrap-filename,
         lv_num_copy(2)   TYPE c.


  MOVE 'AOFB' TO o_itab_x_lines-line.
  APPEND o_itab_x_lines.

  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.

*   'APPL$_KIND = 3' means it is an Endeblatt.rtf.
  CONCATENATE 'APPL$_KIND = ' '3' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ERASE = ' '0' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  IF NOT ( i_ende_down_path IS INITIAL ) .
    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
         EXPORTING
              full_name     = i_ende_down_path
         IMPORTING
              stripped_name = lv_stripped_name
              file_path     = lv_file_path
         EXCEPTIONS
              x_error       = 1
              OTHERS        = 2.

    IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  CONCATENATE 'APPL$_ORIGINALNAME = ' lv_stripped_name
                                INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ONLY_PATH = ' '0' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.


  CLEAR lv_stripped_name.
  CLEAR lv_file_path.

  SPLIT i_ende_down_path AT 'SCAN' INTO
                                lv_stripped_name lv_file_path.
  CONCATENATE 'APPL$_PATH = ' lv_file_path
                                      INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_RESOLUTION = '
          wa_joblist_file-aufloesung INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_TARGETFORMAT = ' '4' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_SCALINGX = '
         wa_joblist_file-skalieren_x INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_SCALINGY = '
         wa_joblist_file-skalieren_y INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_MEDIUM = '
              wa_joblist_file-medium INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ROTATE ='
              wa_joblist_file-drehen INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_MIRROR = '
            wa_joblist_file-spiegeln INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  MOVE wa_joblist_file-kopien TO lv_num_copy.
  CONCATENATE 'APPL$_COPY = '  lv_num_copy INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_FOLD = ' 'nein' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_PUNCH = '
              wa_joblist_file-lochen INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_FORMAT = ' 'A4' INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_TYPE = '
           wa_joblist_file-appl_type INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_COMPRESSION = '
           wa_joblist_file-appl_comp INTO o_itab_x_lines-line+1.
  APPEND o_itab_x_lines.

  MOVE 'AOFE' TO o_itab_x_lines.
  APPEND o_itab_x_lines.

  CLEAR o_itab_x_lines.


ENDFUNCTION.
