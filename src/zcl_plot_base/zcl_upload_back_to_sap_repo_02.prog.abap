*&---------------------------------------------------------------------*
*& Report  ZCL_UPLOAD_BACK_TO_SAP_REPOSIT                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_upload_back_to_sap_repo_02 .

* ITAB
DATA: itab_file          TYPE TABLE OF sdokpath.
DATA: itab_dir           TYPE TABLE OF sdokpath.
* WA
DATA: wa_dir           TYPE sdokpath.
DATA: wa_draw          TYPE draw.
* NORMAL
DATA: lv_selected_folder LIKE rlgrap-filename.
DATA : tmp_chosen_folder  TYPE rlgrap-filename.
DATA : lv_file_count      TYPE i.
DATA:  lv_dir_count       TYPE i.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_check AS CHECKBOX.
PARAMETERS: p_list  RADIOBUTTON GROUP prog DEFAULT 'X' .
PARAMETERS: p_up  RADIOBUTTON GROUP prog  .
PARAMETERS: p_stor TYPE dttrg DEFAULT 'TR_TEST' NO-DISPLAY .
SELECTION-SCREEN END OF BLOCK bl1.

INITIALIZATION.

AT SELECTION-SCREEN.

START-OF-SELECTION.

  IF p_check = 'X'.
    IF p_list = 'X'.
*     Liste anzeigen
*     get LIST of Dir
      CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
           EXPORTING
                window_title    = text-010
                initial_folder  = 'C:\'
           IMPORTING
                selected_folder =
                   lv_selected_folder " '\\Soft-gr-oratest\autoorg\TEMP\
           EXCEPTIONS
                cntl_error      = 1
                OTHERS          = 2.
      IF sy-subrc <> 0.
        MESSAGE s001(zcl_konv)
          WITH '' '' '' ''.
        EXIT.
      ENDIF.

      IF lv_selected_folder IS INITIAL.
        EXIT.
      ELSE.
      ENDIF.

*     clear content
      REFRESH itab_file.
      REFRESH itab_dir.


*     get List of Dir
      PERFORM list_of_directories.

      IF itab_dir[] IS INITIAL.
        MESSAGE s003(zcl_konv)
          WITH tmp_chosen_folder '' '' ''.
        EXIT.
      ELSE.
      ENDIF.

      LOOP AT itab_dir INTO wa_dir.
        CLEAR wa_draw.
        SPLIT wa_dir AT '_' INTO wa_draw-dokar wa_draw-doknr
          wa_draw-dokvr wa_draw-doktl.
        WRITE: / wa_draw-dokar, wa_draw-doknr,
          wa_draw-doktl, wa_draw-dokvr .
        "WRITE: / wa_dir.
      ENDLOOP.

      EXIT.
    ELSE.
*     normale Verarbeitung
*     get LIST of Dir
      CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
           EXPORTING
                window_title    = text-010
                initial_folder  = 'C:\'
           IMPORTING
                selected_folder =
                   lv_selected_folder " '\\Soft-gr-oratest\autoorg\TEMP\
           EXCEPTIONS
                cntl_error      = 1
                OTHERS          = 2.
      IF sy-subrc <> 0.
        MESSAGE s001(zcl_konv)
          WITH '' '' '' ''.
        EXIT.
      ENDIF.

      IF lv_selected_folder IS INITIAL.
        EXIT.
      ELSE.
      ENDIF.

*     clear content
      REFRESH itab_file.
      REFRESH itab_dir.


*     get List of Dir
      PERFORM list_of_directories.

      IF itab_dir[] IS INITIAL.
        MESSAGE s003(zcl_konv)
          WITH tmp_chosen_folder '' '' ''.
        EXIT.
      ELSE.
      ENDIF.

      LOOP AT itab_dir INTO wa_dir.
        CONCATENATE lv_selected_folder '\' wa_dir INTO wa_dir.
        MODIFY itab_dir FROM wa_dir INDEX sy-tabix.
      ENDLOOP.

      DATA: max_lines TYPE i.
      DATA: akt_line TYPE i.
      DATA: f TYPE f.
      DATA: proz(5).
      DATA: proz_i TYPE i.
      DESCRIBE TABLE itab_dir LINES max_lines.

      f = 100 / max_lines .
      CLEAR akt_line.

*     Process directories
      LOOP AT itab_dir INTO wa_dir.

        akt_line = akt_line + 1.
        proz_i = trunc( f * akt_line ).
        proz = proz_i.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
             EXPORTING
                  percentage = proz  " Balkenanzeige
                  text       = wa_dir.

        WRITE: / text-020, wa_dir.

*       call FM
        CALL FUNCTION 'Z_CL_UPLOAD_BACK_TO_SAP_REPOS'
             EXPORTING
                  i_wa_dir = wa_dir
                  i_tresor = p_stor
             EXCEPTIONS
                  error    = 1
                  no_files = 2
                  OTHERS   = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*     EXPORTING
*       WAIT          =
*     IMPORTING
*       RETURN        =
                  .

      ENDLOOP.

    ENDIF.
  ELSE.
    EXIT.
  ENDIF.





*&---------------------------------------------------------------------*
*&      Form  list_of_directories_and_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_of_directories.

  CONCATENATE lv_selected_folder '\' INTO tmp_chosen_folder.

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
       EXPORTING
            directory  = tmp_chosen_folder
            filter     = '*.*'
       IMPORTING
            file_count = lv_file_count
            dir_count  = lv_dir_count
       TABLES
            file_table = itab_file
            dir_table  = itab_dir
       EXCEPTIONS
            cntl_error = 1
            OTHERS     = 2.

  IF sy-subrc <> 0.
    MESSAGE s002(zcl_konv)
      WITH tmp_chosen_folder '' '' ''.
    EXIT.
  ENDIF.

ENDFORM.                    " list_of_directories_and_files
