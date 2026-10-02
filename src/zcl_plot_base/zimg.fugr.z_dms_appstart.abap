FUNCTION z_dms_appstart.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
* Allgemein
  DATA: ret TYPE n,
        logfile LIKE filename-fileintern,
        answer,
        x_filename LIKE rlgrap-filename,
        mtext(40),
        ind_append,
        stempel1(80),
        stempel2(80),
        stempel3(80),
        doknr LIKE draw-doknr.

  DATA: ao_naming(60),
        ao_project(60),
        ao_erase VALUE '0',
        ao_format(10),
        ao_copies(2) VALUE '1',
        ao_delete,
        ao_print VALUE '0',
        ao_datum(10).

  DATA: BEGIN OF cmd_file OCCURS 5,
          zeile(200),
        END OF cmd_file.
  DATA: cmdfile LIKE rlgrap-filename.
* Aufbau der Repro-Liste
  DATA: BEGIN OF repli_skeleton OCCURS 30,
          line(200),
        END OF repli_skeleton,
        BEGIN OF repli_stamps OCCURS 5,
          line(200),
        END OF repli_stamps,
        BEGIN OF repli_lines OCCURS 200,
          line(1000),
        END OF repli_lines,
        BEGIN OF reproliste OCCURS 500,
          line(1000),
        END OF reproliste.
*-----------------------------------------------------------------------
* Dokumentendaten holen ...

  IMPORT draw intdraz pfad applikationsnummer applikationstyp
                          FROM MEMORY ID 'SAP_APPLICATION'.

  IMPORT objectlinks FROM MEMORY ID 'ZZ_OBJECTLINKS'.

  CALL FUNCTION 'DOCUMENT_DATA_GET'
    TABLES
      in_deldrad = in_deldrad
      in_intdrad = in_intdrad
      in_mrkdrad = in_mrkdrad
      in_upddrad = in_upddrad
      in_upddrap = in_upddrap
      in_drap    = in_drap
      in_texttab = in_texttab.

  CASE applikationstyp.
    WHEN '1'.
      app_nam = 'Anzeigen'.
    WHEN '2'.
      app_nam = 'Ändern'.
    WHEN '3'.
      app_nam = 'Drucken'.
  ENDCASE.
* Zurücksetzen aller Aufrufparameter ...
  CLEAR: program, commandline.

* Dokumentenstatus lesen ...
  SELECT SINGLE * FROM tdws WHERE dokar = draw-dokar AND
                                  dokst = draw-dokst.
  SELECT SINGLE * FROM tdwat WHERE dokar = draw-dokar AND
                                   cvlang = sy-langu.

* In Dokumentennummer führende Nullen eliminieren ...
  MOVE draw-doknr TO doknr.
*  SHIFT doknr LEFT DELETING LEADING 0.
  SHIFT doknr LEFT DELETING LEADING '0'.

* Ermitteln des Datenträgertyps ...
  CALL FUNCTION 'WS_QUERY'
    EXPORTING
      environment    = 'hostname'
      query          = 'EN'
    IMPORTING
      return         = *tdwd-dttrg
    EXCEPTIONS
      inv_query      = 1
      no_batch       = 2
      frontend_error = 3
      OTHERS         = 4.

  CASE sy-subrc.
    WHEN 1 OR 2 OR 3 OR 4.
      MESSAGE e011(zc).
  ENDCASE.

  IF *tdwd-dttrg = ''.
    MOVE 'DEFAULT' TO *tdwd-dttrg.
  ENDIF.

* Datenträgertyp ermitteln ...
  SELECT SINGLE * FROM tdwd WHERE dttrg = *tdwd-dttrg.

  IF sy-subrc NE 0.
    MESSAGE e023(zc) WITH *tdwd-dttrg.
  ELSE.
    MOVE tdwd TO *tdwd.
    SELECT SINGLE * FROM tdwe INTO *tdwe WHERE typdt = tdwd-typdt.
  ENDIF.

*     Menü- und Aufrufpfad ermitteln ...
  IF applikationsnummer = space.
    applikationsnummer = 1.
  ENDIF.
  CASE applikationsnummer.

    WHEN 1 OR 2.                            "Datei 1 oder 2

      CASE applikationstyp.

        WHEN 1.                        "Anzeigen
        WHEN 2.                        "Ändern
        WHEN 3.                        "Drucken
          EXPORT *tdwe TO MEMORY ID 'ZZ_TDWE'.
* Repro-Listendatei aufbauen ...
          CALL FUNCTION 'FILE_GET_NAME'
               EXPORTING
*                  CLIENT                  = SY-MANDT
                    logical_filename        = 'ZZ_REPRO_CLF_STANDARD'
*                  OPERATING_SYSTEM        = SY-OPSYS
                    parameter_1             = 'SKELETON.CLF'
*                  PARAMETER_2             = ' '
*                  PARAMETER_3             = ' '
                    use_presentation_server = 'X'
*                  WITH_FILE_EXTENSION     = ' '
*                  USE_BUFFER              = ' '
               IMPORTING
*                  EMERGENCY_FLAG          =
*                  FILE_FORMAT             =
                    file_name               = x_filename
               EXCEPTIONS
                    file_not_found          = 1
                    OTHERS                  = 2
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          DATA lc_fname TYPE rs38l_fnam.
          CLEAR lc_fname.
          lc_fname = 'WS_UPLOAD'.

          "CALL FUNCTION 'WS_UPLOAD'
          CALL FUNCTION lc_fname
               EXPORTING
*                  CODEPAGE                = ' '
                    filename                = x_filename
*                  FILETYPE                = 'ASC'
*                  HEADLEN                 = ' '
*                  LINE_EXIT               = ' '
*                  TRUNCLEN                = ' '
*                  USER_FORM               = ' '
*                  USER_PROG               = ' '
*                  DAT_D_FORMAT            = ' '
*             IMPORTING
*                  FILELENGTH              =
               TABLES
                    data_tab                = repli_skeleton
               EXCEPTIONS
                    conversion_error        = 1
                    file_open_error         = 2
                    file_read_error         = 3
                    invalid_type            = 4
                    no_batch                = 5
                    unknown_error           = 6
                    invalid_table_width     = 7
                    gui_refuse_filetransfer = 8
                    customer_error          = 9
                    OTHERS                  = 10
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          CALL FUNCTION 'FILE_GET_NAME'
               EXPORTING
*                  CLIENT                  = SY-MANDT
                    logical_filename        = 'ZZ_REPRO_CLF_STANDARD'
*                  OPERATING_SYSTEM        = SY-OPSYS
                    parameter_1             = 'STAMPS.CLF'
*                  PARAMETER_2             = ' '
*                  PARAMETER_3             = ' '
                    use_presentation_server = 'X'
*                  WITH_FILE_EXTENSION     = ' '
*                  USE_BUFFER              = ' '
               IMPORTING
*                  EMERGENCY_FLAG          =
*                  FILE_FORMAT             =
                    file_name               = x_filename
               EXCEPTIONS
                    file_not_found          = 1
                    OTHERS                  = 2
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.


          CLEAR lc_fname.
          lc_fname = 'WS_UPLOAD'.

          "CALL FUNCTION 'WS_UPLOAD'
          CALL FUNCTION lc_fname
               EXPORTING
*                  CODEPAGE                = ' '
                    filename                = x_filename
*                  FILETYPE                = 'ASC'
*                  HEADLEN                 = ' '
*                  LINE_EXIT               = ' '
*                  TRUNCLEN                = ' '
*                  USER_FORM               = ' '
*                  USER_PROG               = ' '
*                  DAT_D_FORMAT            = ' '
*             IMPORTING
*                  FILELENGTH              =
               TABLES
                    data_tab                = repli_stamps
               EXCEPTIONS
                    conversion_error        = 1
                    file_open_error         = 2
                    file_read_error         = 3
                    invalid_type            = 4
                    no_batch                = 5
                    unknown_error           = 6
                    invalid_table_width     = 7
                    gui_refuse_filetransfer = 8
                    customer_error          = 9
                    OTHERS                  = 10
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          CALL FUNCTION 'FILE_GET_NAME'
               EXPORTING
*                  CLIENT                  = SY-MANDT
                    logical_filename        = 'ZZ_REPRO_CLF_STANDARD'
*                  OPERATING_SYSTEM        = SY-OPSYS
                    parameter_1             = 'LINES.CLF'
*                  PARAMETER_2             = ' '
*                  PARAMETER_3             = ' '
                    use_presentation_server = 'X'
*                  WITH_FILE_EXTENSION     = ' '
*                  USE_BUFFER              = ' '
               IMPORTING
*                  EMERGENCY_FLAG          =
*                  FILE_FORMAT             =
                    file_name               = x_filename
               EXCEPTIONS
                    file_not_found          = 1
                    OTHERS                  = 2
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.


          CLEAR lc_fname.
          lc_fname = 'WS_UPLOAD'.

          "CALL FUNCTION 'WS_UPLOAD'
          CALL FUNCTION lc_fname
               EXPORTING
*                  CODEPAGE                = ' '
                    filename                = x_filename
*                  FILETYPE                = 'ASC'
*                  HEADLEN                 = ' '
*                  LINE_EXIT               = ' '
*                  TRUNCLEN                = ' '
*                  USER_FORM               = ' '
*                  USER_PROG               = ' '
*                  DAT_D_FORMAT            = ' '
*             IMPORTING
*                  FILELENGTH              =
               TABLES
                    data_tab                = repli_lines
               EXCEPTIONS
                    conversion_error        = 1
                    file_open_error         = 2
                    file_read_error         = 3
                    invalid_type            = 4
                    no_batch                = 5
                    unknown_error           = 6
                    invalid_table_width     = 7
                    gui_refuse_filetransfer = 8
                    customer_error          = 9
                    OTHERS                  = 10
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
* Montieren der Repro-Listdatei ...
          LOOP AT repli_skeleton.
            ind_append = 'X'.
            MOVE repli_skeleton-line TO reproliste-line.
            IF reproliste-line CS '%SY-UNAME%'.
              REPLACE '%SY-UNAME%' WITH sy-uname INTO reproliste-line.
            ENDIF.
            IF reproliste-line CS '%SY-DATUM%'.
              WRITE sy-datum TO ao_datum DD/MM/YYYY.
              REPLACE '%SY-DATUM%' WITH ao_datum INTO reproliste-line.
            ENDIF.
            IF reproliste-line CS '%PRPS-POSID%'.
              LOOP AT in_intdrad.
              ENDLOOP.
              REPLACE '%PRPS-POSID%' WITH in_intdrad
                      INTO reproliste-line.
              CONDENSE reproliste-line.
            ENDIF.
            IF reproliste-line CS '%PRINTMODE%'.
              REPLACE '%PRINTMODE%' WITH '0' INTO reproliste-line.
            ENDIF.
            IF reproliste-line CS '%STAMPS.CLF%'.
              IF repli_stamps[] IS INITIAL.
                CLEAR reproliste-line.
              ENDIF.
              LOOP AT repli_stamps.
                MOVE repli_stamps-line TO reproliste-line.
                IF reproliste-line CS '%STEMPEL1%'.
                  CONCATENATE 'Status:' draw-dokst draw-adatum
                              INTO stempel1 SEPARATED BY space.
                  REPLACE '%STEMPEL1%' WITH stempel1
                          INTO reproliste-line.
                  CONDENSE reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ENDIF.
                IF reproliste-line CS '%STEMPEL2%'.
                  CONCATENATE sy-uname sy-datum
                              INTO stempel2 SEPARATED BY space.
                  REPLACE '%STEMPEL2%' WITH stempel2
                          INTO reproliste-line.
                  CONDENSE reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ENDIF.
                IF reproliste-line CS '%STEMPEL3%'.
                  CONCATENATE sy-uname sy-datum
                              INTO stempel3 SEPARATED BY space.
                  REPLACE '%STEMPEL3%' WITH stempel3
                          INTO reproliste-line.
                  CONDENSE reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ENDIF.
              ENDLOOP.
            ENDIF.
            IF reproliste-line CS '%LINES.CLF%'.
              LOOP AT repli_lines.
                MOVE repli_lines-line TO reproliste-line.
                IF reproliste-line CS '%NAMING%'.
                  CONCATENATE draw-doknr draw-doktl draw-dokvr
                     INTO ao_naming.
                  REPLACE '%NAMING%' WITH ao_naming INTO
                                                    reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSEIF reproliste-line CS '%PROJECT%'.
                  LOOP AT in_intdrad.
                    MOVE in_intdrad TO ao_project.
                  ENDLOOP.
                  REPLACE '%PROJECT%' WITH ao_project INTO
                                                      reproliste-line.
                  CONDENSE reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSEIF reproliste-line CS '%ERASE%'.
                  REPLACE '%ERASE%' WITH ao_erase INTO reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSEIF reproliste-line CS '%PATH%'.
                  REPLACE '%PATH%' WITH pfad INTO reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSEIF reproliste-line CS '%FORMAT%'.
                  REPLACE '%FORMAT%' WITH ao_format INTO
                                                    reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSEIF reproliste-line CS '%COPIES%'.
                  REPLACE '%COPIES%' WITH ao_copies INTO
                                                    reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSEIF reproliste-line CS '%DELETE%'.
                  REPLACE '%DELETE%' WITH ao_delete INTO
                                                    reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSEIF reproliste-line CS '%PRINT%'.
                  REPLACE '%PRINT%' WITH ao_print INTO reproliste-line.
                  CLEAR ind_append.
                  APPEND reproliste.
                ELSE.
                  APPEND reproliste.
                ENDIF.
              ENDLOOP.
            ENDIF.
            IF ind_append = 'X'.
              APPEND reproliste.
            ENDIF.
          ENDLOOP.
* Download Repro-Listdatei ...
          CALL FUNCTION 'FILE_GET_NAME'
               EXPORTING
*                  CLIENT                  = SY-MANDT
                    logical_filename        = 'ZZ_REPRO_LNA_STANDARD'
*                  OPERATING_SYSTEM        = SY-OPSYS
                   parameter_1             = 'DMS-Liste'
*                  PARAMETER_2             = ' '
*                  PARAMETER_3             = ' '
                   use_presentation_server = 'X'
*                  WITH_FILE_EXTENSION     = ' '
*                  USE_BUFFER              = ' '
               IMPORTING
*                  EMERGENCY_FLAG          =
*                  FILE_FORMAT             =
                    file_name               = x_filename
               EXCEPTIONS
                    file_not_found          = 1
                    OTHERS                  = 2
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          CALL FUNCTION 'FILE_GET_NAME'
               EXPORTING
*                  CLIENT                  = SY-MANDT
                    logical_filename        = 'ZZ_REPROCL_EXE'
*                  OPERATING_SYSTEM        = SY-OPSYS
*                  PARAMETER_1             = ' '
*                  PARAMETER_2             = ' '
*                  PARAMETER_3             = ' '
                    use_presentation_server = 'X'
*                  WITH_FILE_EXTENSION     = ' '
*                  USE_BUFFER              = ' '
               IMPORTING
*                  EMERGENCY_FLAG          =
*                  FILE_FORMAT             =
                    file_name               = program
               EXCEPTIONS
                    file_not_found          = 1
                    OTHERS                  = 2
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.


          CLEAR lc_fname.
          lc_fname = 'WS_DOWNLOAD'.

          "CALL FUNCTION 'WS_DOWNLOAD'
          CALL FUNCTION lc_fname
               EXPORTING
*                  BIN_FILESIZE            = ' '
*                  CODEPAGE                = ' '
                    filename                = x_filename
*                  FILETYPE                = 'ASC'
*                  MODE                    = ' '
*                  WK1_N_FORMAT            = ' '
*                  WK1_N_SIZE              = ' '
*                  WK1_T_FORMAT            = ' '
*                  WK1_T_SIZE              = ' '
*                  COL_SELECT              = ' '
*                  COL_SELECTMASK          = ' '
*                  NO_AUTH_CHECK           = ' '
*             IMPORTING
*                  FILELENGTH              =
               TABLES
                    data_tab                = reproliste
*                  FIELDNAMES              =
               EXCEPTIONS
                    file_open_error         = 1
                    file_write_error        = 2
                    invalid_filesize        = 3
                    invalid_type            = 4
                    no_batch                = 5
                    unknown_error           = 6
                    invalid_table_width     = 7
                    gui_refuse_filetransfer = 8
                    customer_error          = 9
                    OTHERS                  = 10
                    .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.


      ENDCASE.
    WHEN OTHERS.                            "weitere Dateien
      CASE applikationstyp.
        WHEN 1.                        "Anzeigen
        WHEN 2.                        "Ändern
        WHEN 3.                        "Drucken
      ENDCASE.
  ENDCASE.

* -> Aufruf der Anwendung ...

  IF NOT program = ''.                 "Anwendung unterstützt ?
    CALL FUNCTION 'WS_EXECUTE'
      EXPORTING
        document    = ' '
        inform      = ' '
        program     = program
        commandline = commandline.
  ELSE.
    MESSAGE i022(zc) WITH app_nam.
  ENDIF.

ENDFUNCTION.
