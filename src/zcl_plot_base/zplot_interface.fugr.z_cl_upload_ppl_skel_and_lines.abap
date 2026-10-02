FUNCTION Z_CL_UPLOAD_PPL_SKEL_AND_LINES.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DEFAULT_USER) TYPE  XUBNAME DEFAULT 'SAP*'
*"  TABLES
*"      O_ITAB_PPL_SKELETON STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      O_ITAB_PPL_SKEL_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* These 2 Function Modules will down load the data from the data base
* dependding upon the USER who is executing this function Module.
* The data is already existing in the data base which is to be UPLOADED
* or MODIFIED by the USER with Function Module'Z_CL_UPDATE_SKELETON'
* and 'Z_CL_UPDATE_SKELETON_LINES'. These Functin Modules are existing
* in the function Group 'ZCL_PLINT_TOOLS'.


* If SKELETON and SKELETON_LINES data is not available with with the
* USER name then a DEFAULT_USER data will be dowloaded. The data with
* the DEFAULT_USER always available in the data base table. So this data
* will be available for the processing.

*  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*       EXPORTING
*            percentage = 15
*            text       = text-101.


  CALL FUNCTION 'Z_CL_READ_SKELETON'
       EXPORTING
            i_uname     = sy-uname
       TABLES
            o_itab_data = O_ITAB_PPL_SKELETON
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
    CALL FUNCTION 'Z_CL_READ_SKELETON'
         EXPORTING
              i_uname     = default_user
         TABLES
              o_itab_data = O_ITAB_PPL_SKELETON
         EXCEPTIONS
              error       = 1
              OTHERS      = 2.
    IF sy-subrc <> 0.
      MESSAGE e012(zcvn) RAISING error.
    ENDIF.
  ENDIF.

*  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*       EXPORTING
*            percentage = 15
*            text       = text-102.


  CALL FUNCTION 'Z_CL_READ_SKELETON_LINES'
       EXPORTING
            i_uname     = sy-uname
       TABLES
            o_itab_data = O_ITAB_PPL_SKEL_LINES
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
    CALL FUNCTION 'Z_CL_READ_SKELETON_LINES'
         EXPORTING
              i_uname     = default_user
         TABLES
              o_itab_data = O_ITAB_PPL_SKEL_LINES
         EXCEPTIONS
              error       = 1
              OTHERS      = 2.
    IF sy-subrc <> 0.
      MESSAGE e014(zcvn) RAISING error.
    ENDIF.

  ENDIF.

ENDFUNCTION.
