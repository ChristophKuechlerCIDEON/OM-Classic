FUNCTION Z_CL_PLINT_TOOLS_VIEW_DOC_003.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
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


  wa_plotjobs = i_wa_plotjobs.

*  filename_tmp = wa_plotjobs-filename.
  filename_tmp = wa_plotjobs-filep.

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
*     for this try to use the cl_gui_ecl_primaryviewer
      CALL SCREEN 300 STARTING AT 1 1 ENDING AT 150 40.
    ENDIF.
  ENDIF.


* for this try to use the cl_gui_ecl_primaryviewer
*  CALL SCREEN 300 STARTING AT 10 10 ENDING AT 100 50.



ENDFUNCTION.
