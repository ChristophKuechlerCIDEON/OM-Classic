FUNCTION z_cl_fehlblatt.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_FILE) LIKE  RLGRAP-FILENAME OPTIONAL
*"     REFERENCE(I_STRIP_NAME) LIKE  RLGRAP-FILENAME OPTIONAL
*"  EXPORTING
*"     VALUE(E_FEHL_DOWN_PATH) LIKE  RLGRAP-FILENAME
*"  TABLES
*"      T_FEHL_LIST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"      T_JOB_FEHLLIST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*  DATA : ao_datum(30) TYPE c.

  DATA : d1           LIKE rlgrap-filename,
         d2           LIKE rlgrap-filename,
         fehl_rtf     LIKE rlgrap-filename,
         file         TYPE string.

  DATA : stripped_name1 LIKE rlgrap-filename,
         file_path     LIKE rlgrap-filename,
         rtf_down_load LIKE rlgrap-filename.

  IF obj_frontend IS INITIAL.

    CREATE OBJECT obj_frontend.

  ENDIF.


  LOOP AT t_fehl_list.

    MOVE t_fehl_list-fehlblatt TO file.

    IF i_strip_name NE space.
      SPLIT i_strip_name AT 'SAP_DMS_List' INTO d1 d2.
      CONCATENATE d1 'fehlBLATT' d2 INTO fehl_rtf.
      CLEAR: d1,d2.
      SPLIT fehl_rtf AT '.' INTO d1 d2.
    ELSE.
      CONCATENATE sy-uname '_fehlblatt_' sy-datum sy-uzeit INTO d1.
    ENDIF.

    CLEAR fehl_rtf.

    CALL FUNCTION 'STRING_CONCATENATE_3'
      EXPORTING
        string1   = d1
        string2   = '.'
        string3   = 'rtf'
      IMPORTING
        string    = fehl_rtf
      EXCEPTIONS
        too_small = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CONCATENATE 'C:\Programme\AutoORG\PlottingSolution\PostProcessor\scan\'
            fehl_rtf INTO rtf_down_load.

    CLEAR gv_stru-y_filename.
    gv_stru-langu = 'D'.

    MOVE fehl_rtf TO gv_stru-y_filename.

    IF gv_stru-langu = sy-langu.
      TRANSLATE gv_stru-y_filename TO LOWER CASE.
    ELSE.
    ENDIF.

    MOVE gv_stru-y_filename TO fehl_rtf .

    CALL METHOD obj_frontend->file_exist
      EXPORTING
        file            = file
      RECEIVING
        result          = file_exist
      EXCEPTIONS
        cntl_error      = 1
        error_no_gui    = 2
        wrong_parameter = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


    IF file_exist EQ space.

      REPLACE 'C:\' WITH 'D:\' INTO file.

      CALL METHOD obj_frontend->file_exist
        EXPORTING
          file            = file
        RECEIVING
          result          = file_exist
        EXCEPTIONS
          cntl_error      = 1
          error_no_gui    = 2
          wrong_parameter = 3
          OTHERS          = 4.
    ENDIF.

    IF file_exist EQ space.
      MESSAGE i002(zcvn) WITH 'This' 'file does not' 'exist in '
      'this path'.
    ENDIF.



    CALL METHOD obj_frontend->gui_upload
      EXPORTING
        filename                = file
        filetype                = 'ASC'
*    HAS_FIELD_SEPARATOR     = SPACE
*    HEADER_LENGTH           = 0
*  IMPORTING
*    FILELENGTH              =
*    HEADER                  =
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.



    LOOP AT it_lines INTO wa_lines.

      MOVE wa_lines-line TO it_liste-line.

      IF it_liste-line CS '%Empfaenger%' .
        REPLACE '%Empfaenger%' WITH t_fehl_list-name1
                                             INTO it_liste-line .
        IF sy-subrc = 0.
          IF it_liste-line CS '%Datum%'.
            REPLACE '%Datum%' WITH gv_ao_datum INTO it_liste-line .
          ENDIF.
        ENDIF.

      ELSEIF it_liste-line CS '%Auftraggeber%'.
        REPLACE '%Auftraggeber%' WITH sy-uname INTO it_liste-line .

      ELSEIF it_liste-line CS '%Empfaenger%'.
        REPLACE '%Empfaenger%' WITH t_fehl_list-name1
                                                  INTO it_liste-line .

      ELSEIF it_liste-line CS '%Firma%'.
        REPLACE '%Firma%' WITH t_fehl_list-firma INTO it_liste-line .

      ELSEIF it_liste-line CS '%Strasse%'.
        REPLACE '%Strasse%' WITH  t_fehl_list-stras INTO it_liste-line
       .

      ELSEIF it_liste-line CS '%PLZ%'.
        REPLACE '%PLZ%' WITH t_fehl_list-pstlz INTO it_liste-line .

      ELSEIF it_liste-line CS '%Ort%'.
        REPLACE '%Ort%' WITH t_fehl_list-ort1 INTO it_liste-line .

      ELSEIF it_liste-line CS '%Telefon%'.
        REPLACE '%Telefon%' WITH t_fehl_list-telf1 INTO it_liste-line .

      ELSEIF it_liste-line CS '%Email%'.
        REPLACE '%Email%' WITH t_fehl_list-smtp_addr
                                         INTO it_liste-line .

      ELSEIF it_liste-line CS '%Kostenstelle%'.
        REPLACE '%Kostenstelle%' WITH t_fehl_list-kostl
                                         INTO it_liste-line .

      ELSEIF it_liste-line CS '%Projektnummer%'.
        REPLACE '%Projektnummer%' WITH 'RX250_AP7K-2385'
                                          INTO it_liste-line .

      ELSEIF it_liste-line CS '%Kommission%'.
        REPLACE '%Kommission%' WITH 'X_Kommission' INTO it_liste-line .

      ENDIF.

      APPEND it_liste.

    ENDLOOP.
  ENDLOOP.

  CLEAR stripped_name1.
  CLEAR file_path.
  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = rtf_down_load
    IMPORTING
      stripped_name = stripped_name1
      file_path     = file_path
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CLEAR filename.

  CONCATENATE file_path 'temp_cv\' fehl_rtf INTO rtf_down_load.

  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'WS_DOWNLOAD'.

  "CALL FUNCTION 'WS_DOWNLOAD'
  CALL FUNCTION lc_fname
   EXPORTING
*   BIN_FILESIZE                  = ' '
*   CODEPAGE                      = ' '
     filename                      = rtf_down_load
     filetype                      = 'ASC'
*   MODE                          = ' '
*   WK1_N_FORMAT                  = ' '
*   WK1_N_SIZE                    = ' '
*   WK1_T_FORMAT                  = ' '
*   WK1_T_SIZE                    = ' '
*   COL_SELECT                    = ' '
*   COL_SELECTMASK                = ' '
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
    TABLES
      data_tab                      = it_liste
*   FIELDNAMES                    =
   EXCEPTIONS
     file_open_error               = 1
     file_write_error              = 2
     invalid_filesize              = 3
     invalid_type                  = 4
     no_batch                      = 5
     unknown_error                 = 6
     invalid_table_width           = 7
     gui_refuse_filetransfer       = 8
     customer_error                = 9
     OTHERS                        = 10
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  REFRESH it_liste.
  CLEAR it_liste.

  MOVE rtf_down_load TO e_fehl_down_path.
  CLEAR rtf_down_load.

ENDFUNCTION.
