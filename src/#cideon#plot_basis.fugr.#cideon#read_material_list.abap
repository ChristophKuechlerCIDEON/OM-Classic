FUNCTION /cideon/read_material_list.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      O_ITAB_SEARCH STRUCTURE  ZCL_S_DOCSEARCH
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
* 09.08.2007 - Erstellung
*-----------------------------------------------------------------------
* toDo
*   -
*-----------------------------------------------------------------------

* TYPES
* ITAB
  DATA: filetable TYPE filetable.
  DATA: data_tab TYPE TABLE OF matnr.
* WA
  DATA: wa_filetable TYPE file_table.
  DATA: wa_data_tab TYPE matnr.
  DATA: wa_itab_search TYPE zcl_s_docsearch.
* NORMAL
  DATA: rc TYPE i.
  DATA: window_title TYPE string.

  DATA: fs TYPE REF TO cl_gui_frontend_services.

  CREATE OBJECT fs
*   EXPORTING
*     TITLE  = text-060
*      INIT_DIRECTORY =
      .

* Datei angeben lassen
  CLEAR rc.
  CLEAR filetable.
  window_title = text-060.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = window_title
*      default_extension       = 'CSV'
      default_filename        = '*.csv'
      file_filter             = 'csv'
*      INITIAL_DIRECTORY       =
*      MULTISELECTION          =
    CHANGING
      file_table              = filetable
      rc                      = rc
*      USER_ACTION             =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      OTHERS                  = 4
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.


* Datei einlesen
  READ TABLE filetable INTO wa_filetable INDEX 1.
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

* Materialien auslesen
  DATA: filename TYPE string.
  CLEAR filename.
  filename = wa_filetable-filename.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = filename
*      FILETYPE                = 'ASC'
*      HAS_FIELD_SEPARATOR     = SPACE
*      HEADER_LENGTH           = 0
*    IMPORTING
*      FILELENGTH              =
*      HEADER                  =
    CHANGING
      data_tab                = data_tab
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
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Daten bereinigen
  IF data_tab[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.


  LOOP AT data_tab INTO wa_data_tab.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              input  = wa_data_tab
         IMPORTING
              output = wa_data_tab.

    MODIFY data_tab FROM wa_data_tab INDEX sy-tabix.
  ENDLOOP.

* Dokumentenlinks holen und in Ausgabetabelle schreiben
  DATA: wa_mara TYPE mara.
  DATA: key TYPE drad-objky.
  CLEAR wa_mara.
  CLEAR key.

  DATA: it_drad TYPE TABLE OF drad.
  DATA: wa_drad TYPE drad.


  CLEAR o_itab_search.

  LOOP AT data_tab INTO wa_data_tab.
    CLEAR wa_drad.
    CLEAR it_drad.

    key = wa_data_tab.
    CALL FUNCTION 'DOKUMENTE_ZU_OBJEKT'
      EXPORTING
        key                       = key
      objekt                    = 'MARA'
*     MANDT                     = SY-MANDT
*     CHECK_BUFFER_AND_DB       = ' '
    TABLES
      doktab                    = it_drad
    EXCEPTIONS
      kein_dokument             = 1
      OTHERS                    = 2
            .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT it_drad INTO wa_drad.
      MOVE-CORRESPONDING wa_drad TO wa_itab_search.
      wa_itab_search-matnr = wa_data_tab.

      APPEND wa_itab_search TO o_itab_search.
    ENDLOOP.



  ENDLOOP.













ENDFUNCTION.
