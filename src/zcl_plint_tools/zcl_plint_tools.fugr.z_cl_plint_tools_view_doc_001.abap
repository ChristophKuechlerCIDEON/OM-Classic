FUNCTION z_cl_plint_tools_view_doc_001.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(FILENAME) TYPE  ZCL_S_PLOTLIST-FILEP
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
*
*-----------------------------------------------------------------------

*Normal
*data: ok_CODE(10).
  DATA: f_exist(1) VALUE ''.
  DATA: f_isdir(1) VALUE ''.


*make URL
  CLEAR url.

  IF filename(2) = '\\'.
    url = filename.
  ELSE.
    CONCATENATE 'file://' filename INTO url.
  ENDIF.


  filename_tmp = filename.

* check if files exists
  CLEAR f_exist.
  CLEAR f_isdir.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
      fname                = filename_tmp
   IMPORTING
     exist                = f_exist
     isdir                = f_isdir
*     FILESIZE             =
   EXCEPTIONS
     fileinfo_error       = 1
     OTHERS               = 2
            .
  IF sy-subrc <> 0.
    MESSAGE s072(zcl_plint_message_01)
      WITH filename_tmp '' '' ''.
  ELSE.
    IF f_exist IS INITIAL.
      MESSAGE s061(zcl_plint_message_01)
        WITH filename_tmp '' '' ''.
    ELSE.
      CALL SCREEN 100 STARTING AT 1 11 ENDING AT 150 40.
    ENDIF.
  ENDIF.



ENDFUNCTION.
