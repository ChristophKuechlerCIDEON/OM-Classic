FUNCTION Z_CL_UPLOAD_SKELETON_AND_LINES.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DEFAULT_USER) TYPE  XUBNAME DEFAULT 'SAP*'
*"  TABLES
*"      O_REP_SKELETON STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      O_REP_SKELETON_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* Read the Skeleton Data to internal table.
  CALL FUNCTION 'Z_CL_READ_SKEL_CLF'
       EXPORTING
            i_uname     = sy-uname
       TABLES
            o_itab_data = o_rep_skeleton
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.

  IF sy-subrc <> 0.
*   If the data not found with the User name ,
*   Process with the Default-User name 'SAP*'.
    CALL FUNCTION 'Z_CL_READ_SKEL_CLF'
         EXPORTING
              i_uname     = default_user
         TABLES
              o_itab_data = o_rep_skeleton
         EXCEPTIONS
              error       = 1
              OTHERS      = 2.
    IF sy-subrc <> 0.
      MESSAGE e012(zcvn) RAISING error.
    ENDIF.

  ENDIF.

* Read the Skeleton Lines Data to internal table.
  CALL FUNCTION 'Z_CL_READ_SKEL_CLF_LINES'
       EXPORTING
            i_uname     = sy-uname
       TABLES
            o_itab_data = o_rep_skeleton_lines
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.

  IF sy-subrc <> 0.
*   If the data not found with the User name ,
*   Process with the Default-User name 'SAP*'.
    CALL FUNCTION 'Z_CL_READ_SKEL_CLF_LINES'
         EXPORTING
              i_uname     = default_user
         TABLES
              o_itab_data = o_rep_skeleton_lines
         EXCEPTIONS
              error       = 1
              OTHERS      = 2.

    IF sy-subrc <> 0.
      MESSAGE e014(zcvn) RAISING error.
    ENDIF.

  ENDIF.

ENDFUNCTION.
