FUNCTION z_cl_deckblatt.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_DOWN_DECKBLATT) LIKE  RLGRAP-FILENAME OPTIONAL
*"     REFERENCE(I_STRIP_NAME) LIKE  RLGRAP-FILENAME OPTIONAL
*"  EXPORTING
*"     VALUE(E_DECK_DOWN_PATH) LIKE  RLGRAP-FILENAME
*"  TABLES
*"      T_DECK_LIST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : lv_deck_rtf_name     LIKE rlgrap-filename.

  IF obj_frontend IS INITIAL.
    CREATE OBJECT obj_frontend.
  ENDIF.

  LOOP AT t_deck_list.

    MOVE t_deck_list-deckblatt TO gv_filename.

    SPLIT i_strip_name AT 'SAP_DMS_List'
                            INTO gv_stripped_name1 gv_stripped_name2.

    CONCATENATE gv_stripped_name1 'DECKBLATT'
                             gv_stripped_name2 INTO lv_deck_rtf_name.

    CLEAR: gv_stripped_name1,gv_stripped_name2.

    SPLIT lv_deck_rtf_name AT '.' INTO
                             gv_stripped_name1 gv_stripped_name2.
    CLEAR lv_deck_rtf_name.

    CALL FUNCTION 'STRING_CONCATENATE_3'
         EXPORTING
              string1   = gv_stripped_name1
              string2   = '.'
              string3   = 'rtf'
         IMPORTING
              string    = lv_deck_rtf_name
         EXCEPTIONS
              too_small = 1
              OTHERS    = 2.

    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CLEAR gv_stru-y_filename.
    gv_stru-langu = 'D'.

    MOVE lv_deck_rtf_name TO gv_stru-y_filename.

    IF gv_stru-langu = sy-langu.
      TRANSLATE gv_stru-y_filename TO LOWER CASE.
    ELSE.
    ENDIF.

    MOVE gv_stru-y_filename TO lv_deck_rtf_name.

    CALL METHOD obj_frontend->file_exist
      EXPORTING
        file            = gv_filename
      RECEIVING
        result          = file_exist
      EXCEPTIONS
        cntl_error      = 1
        error_no_gui    = 2
        wrong_parameter = 3
        OTHERS          = 4
            .
    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF file_exist EQ space.
      MESSAGE i002(zcvn) WITH 'This' 'file does not' 'exist in '
      'this path'.
    ENDIF.

    CALL METHOD obj_frontend->gui_upload
      EXPORTING
        filename                = gv_filename
        filetype                = 'ASC'
*     HAS_FIELD_SEPARATOR     = SPACE
*       HEADER_LENGTH           = 0
*     IMPORTING
*       FILELENGTH              =
*       HEADER                  =
      CHANGING
        data_tab                = it_lines
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17
            .
    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


    CALL FUNCTION 'Z_CL_DAY_AND_MONTH'
         EXPORTING
              heute  = sy-datum
              tag    = sy-fdayw
         IMPORTING
              datum  = gv_ao_datum
         EXCEPTIONS
              error  = 1
              OTHERS = 2.
    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT it_lines INTO wa_lines.

      MOVE wa_lines-line TO it_liste-line.

      IF it_liste-line CS '%Empfaenger%' .
        REPLACE '%Empfaenger%' WITH sy-uname INTO it_liste-line .

        IF sy-subrc = 0.
          APPEND it_liste.
          IF it_liste-line CS '%Datum%'.
            REPLACE '%Datum%' WITH gv_ao_datum INTO it_liste-line .
          ENDIF.
        ENDIF.

      ELSEIF it_liste-line CS '%Kundenname%'.
        REPLACE '%Kundenname%' WITH t_deck_list-name1
                                               INTO it_liste-line .

      ELSEIF it_liste-line CS '%Datum%'.
        REPLACE '%Datum%' WITH gv_ao_datum INTO it_liste-line .

      ELSEIF it_liste-line CS '%Auftraggeber%'.
        REPLACE '%Auftraggeber%' WITH sy-uname INTO it_liste-line .

      ELSEIF it_liste-line CS '%Empfaenger%'.
       REPLACE '%Empfaenger%' WITH t_deck_list-name1 INTO it_liste-line.

      ELSEIF it_liste-line CS '%Firma%'.
        REPLACE '%Firma%' WITH t_deck_list-firma INTO it_liste-line .

      ELSEIF it_liste-line CS '%Strasse%'.
        REPLACE '%Strasse%' WITH  t_deck_list-stras INTO it_liste-line.

      ELSEIF it_liste-line CS '%PLZ%'.
        REPLACE '%PLZ%' WITH t_deck_list-pstlz INTO it_liste-line .

      ELSEIF it_liste-line CS '%Ort%'.
        REPLACE '%Ort%' WITH t_deck_list-ort1 INTO it_liste-line .

      ELSEIF it_liste-line CS '%Telefon%'.
        REPLACE '%Telefon%' WITH t_deck_list-telf1 INTO it_liste-line .

      ELSEIF it_liste-line CS '%Email%'.
        REPLACE '%Email%' WITH t_deck_list-smtp_addr
                                         INTO it_liste-line .

      ELSEIF it_liste-line CS '%Kostenstelle%'.
        REPLACE '%Kostenstelle%' WITH t_deck_list-kostl
                                         INTO it_liste-line .

      ELSEIF it_liste-line CS '%Projektnummer%'.
        REPLACE '%Projektnummer%' WITH 'RX2385' INTO it_liste-line .

      ELSEIF it_liste-line CS '%Kommission%'.
        REPLACE '%Kommission%' WITH 'X_Kommission' INTO it_liste-line .

      ENDIF.

      APPEND it_liste.

    ENDLOOP.
  ENDLOOP.

  CLEAR file_path.
  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
       EXPORTING
            full_name     = i_down_deckblatt
       IMPORTING
            stripped_name = gv_stripped_name1
            file_path     = gv_file_path
       EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CLEAR filename.

  CONCATENATE gv_file_path 'temp_cv\' lv_deck_rtf_name
                                          INTO gv_rtf_dowload_path.

  LOOP AT it_liste INTO wa_liste.
    APPEND wa_liste TO gv_itab_data_tab.
  ENDLOOP.

  MOVE gv_rtf_dowload_path TO gv_filename.

  CALL METHOD obj_frontend->gui_download
    EXPORTING
*    BIN_FILESIZE            =
    filename                = gv_filename
    filetype                = 'ASC'
    append                  = space
    write_field_separator   = space
    header                  = '00'
    trunc_trailing_blanks   = space
    write_lf                = 'X'
    col_select              = space
    col_select_mask         = space
  IMPORTING
    filelength              = gv_filelength
  CHANGING
    data_tab                = gv_itab_data_tab
  EXCEPTIONS
    file_write_error        = 1
    no_batch                = 2
    gui_refuse_filetransfer = 3
    invalid_type            = 4
    no_authority            = 5
    unknown_error           = 6
    header_not_allowed      = 7
    separator_not_allowed   = 8
    filesize_not_allowed    = 9
    header_too_long         = 10
    dp_error_create         = 11
    dp_error_send           = 12
    dp_error_write          = 13
    unknown_dp_error        = 14
    access_denied           = 15
    dp_out_of_memory        = 16
    disk_full               = 17
    dp_timeout              = 18
    file_not_found          = 19
    dataprovider_exception  = 20
    control_flush_error     = 21
    OTHERS                  = 22
          .
  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  REFRESH gv_itab_data_tab.
  CLEAR gv_itab_data_tab.

  REFRESH it_liste.
  CLEAR it_liste.

  MOVE gv_rtf_dowload_path TO e_deck_down_path.
  CLEAR gv_rtf_dowload_path.

ENDFUNCTION.
