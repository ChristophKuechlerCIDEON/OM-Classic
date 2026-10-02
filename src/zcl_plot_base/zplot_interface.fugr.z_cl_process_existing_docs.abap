FUNCTION z_cl_process_existing_docs.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(WA_EXIST_FILES) LIKE  ZCL_S_PLOTLIST STRUCTURE
*"        ZCL_S_PLOTLIST OPTIONAL
*"     VALUE(I_DIR_CREATE) TYPE  STRING OPTIONAL
*"  TABLES
*"      O_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      I_ITAB_X_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------


  DATA : lv_stripped_name   LIKE rlgrap-filename,
         lv_file_path       LIKE rlgrap-filename,
         lv_split_full_path LIKE rlgrap-filename,
         lv_num_copy        TYPE c.

  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.

  MOVE 'AOFB' TO o_itab_x_lines.
  APPEND o_itab_x_lines.

  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.


  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 45
            text       = text-109.

  CONCATENATE 'APPL$_KIND = ' '1'
                            INTO o_itab_x_lines+1.
*          SHIFT x_lines-line RIGHT BY 1 PLACES.

  APPEND o_itab_x_lines.


  CONCATENATE 'APPL$_ERASE = ' '0' INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.


  CLEAR lv_stripped_name.
  CLEAR lv_file_path.
  CLEAR lv_split_full_path.

  MOVE wa_exist_files-filep TO lv_split_full_path.

  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
       EXPORTING
            full_name     = lv_split_full_path
       IMPORTING
            stripped_name = lv_stripped_name
            file_path     = lv_file_path
       EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CONCATENATE 'APPL$_ORIGINALNAME = ' lv_stripped_name
                                INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE i_dir_create '\' lv_stripped_name
                                  INTO moved_directory.

  CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_PATH = ' moved_directory
                                        INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_RESOLUTION = '
              wa_exist_files-aufloesung INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

****
*          LOOP AT itab_paper_format INTO
*            wa_paper_format WHERE
*                  paper_format = WA_EXIST_FILES-format_ausgabe.
*
*            CONCATENATE 'APPL$_TARGETFORMAT = '
*                    wa_paper_format-paper_index INTO o_itab_x_lines+1.
*            APPEND x_lines.
*          ENDLOOP.

****

  CONCATENATE 'APPL$_SCALINGX = '
             wa_exist_files-skalieren_x INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_SCALINGY = '
             wa_exist_files-skalieren_y INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_MEDIUM = '
                  wa_exist_files-medium INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ROTATE ='
                  wa_exist_files-drehen INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_MIRROR = '
                wa_exist_files-spiegeln INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.


  MOVE wa_exist_files-kopien TO num_copy.
  CONCATENATE 'APPL$_COPY = '  num_copy INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_FOLD = '
              wa_exist_files-falten INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_PUNCH = '
               wa_exist_files-lochen INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_BINDINGEDGE = '
            wa_exist_files-heftrand INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_STAMP = '
                wa_exist_files-stempel INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.


  CONCATENATE 'APPL$_FORMAT = '
          wa_exist_files-format_ausgabe INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_PENTABLE = '
            wa_exist_files-stifttabelle INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_ORIENTATION = '
          wa_exist_files-ausrichtung
                        INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

*         If the document is converted by Client '1' else '0'.
*         For more details refer Doc-Manager.
*         But at this moment itz '0' as hard coded one.
  CONCATENATE 'APPL$_CONVERTED = ' '0' INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_CORRECTIONX = ' '1'
                                INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_CORRECTIONY = ' '1'
                                INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_DAPPL1 = '
           wa_exist_files-wsapplication INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_TYPE = '
               wa_exist_files-appl_type INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_COMPRESSION = '
               wa_exist_files-appl_comp INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

  CONCATENATE 'APPL$_OFFSETXY = '
            wa_exist_files-verschiebung INTO o_itab_x_lines+1.
  APPEND o_itab_x_lines.

*         Process only when this WA_EXIST_FILES-SEITE is filled with
*         some data.
  IF wa_exist_files-seite NE space.
    CONCATENATE 'APPL$_PAGES = '
                wa_exist_files-seite INTO o_itab_x_lines+1.
    APPEND o_itab_x_lines.
  ELSE.
  ENDIF.

  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.

  MOVE 'AOFE' TO o_itab_x_lines.
  APPEND o_itab_x_lines.

  CLEAR o_itab_x_lines-line.
  CLEAR o_itab_x_lines.

ENDFUNCTION.
