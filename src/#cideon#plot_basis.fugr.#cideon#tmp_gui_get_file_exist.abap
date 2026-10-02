FUNCTION /cideon/tmp_gui_get_file_exist.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(FNAME) TYPE  C
*"  EXPORTING
*"     VALUE(EXIST) TYPE  C
*"     VALUE(ISDIR) TYPE  C
*"     VALUE(FILESIZE) TYPE  I
*"  EXCEPTIONS
*"      FILEINFO_ERROR
*"----------------------------------------------------------------------
* SP 146
* 24.01.2011 - CKR
* 7.0.146.1
*              /CIDEON/TMP_GUI_GET_FILE_EXIST
*              Test für Zugriffsbeschleunigung über
*              CL_GUI_FRONTEND_SERVICES



*  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
*       EXPORTING
*            fname          = fname
*       IMPORTING
*            exist          = exist
*            isdir          = isdir
*            filesize       = filesize
*       EXCEPTIONS
*            fileinfo_error = 1
*            OTHERS         = 2.
*  IF sy-subrc <> 0.
*    CASE sy-subrc.
*      WHEN '1'.
*        RAISE fileinfo_error.
*
*      WHEN OTHERS.
*    ENDCASE.
*  ENDIF.


  DATA: name TYPE string.
  CLEAR name.

  DATA: result TYPE abap_bool.
  CLEAR result.

  name = fname.

  CLEAR exist.
  CLEAR isdir.

  CALL METHOD cl_gui_frontend_services=>directory_exist
    EXPORTING
      directory            = name
    RECEIVING
      result               = result
   EXCEPTIONS
     cntl_error           = 1
     error_no_gui         = 2
     wrong_parameter      = 3
     not_supported_by_gui = 4
     OTHERS               = 5
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
     RAISING fileinfo_error.
  ENDIF.

  IF result = 'X'.
    isdir = 'X'.
    exist = 'X'.
  ELSE.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file            = name
    RECEIVING
      result          = result
    EXCEPTIONS
      cntl_error      = 1
      error_no_gui    = 2
      wrong_parameter = 3
      OTHERS          = 4
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
     RAISING fileinfo_error.
  ENDIF.

  IF result = 'X'.
    CLEAR isdir .
    exist = 'X'.
  ELSE.
  ENDIF.

ENDFUNCTION.
