FUNCTION /cideon/check_exist_files.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 16.07.2004 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.

* checks if there are not existing files in the plotjob entries like
* local files that are not checked in
  DATA: f_exist(1) VALUE ''.
  DATA: f_isdir(1) VALUE ''.
  DATA: filename_tmp TYPE file_name.
  DATA: index_plotjobs TYPE sy-tabix.

  LOOP AT itab_plotjobs INTO wa_plotjobs.
    index_plotjobs = sy-tabix.
    IF wa_plotjobs-checked IS INITIAL.
*     check for existenz
      IF wa_plotjobs-knz_spez_dok = 'X'.
        CONTINUE.
      ELSE.
      ENDIF.

      filename_tmp = wa_plotjobs-filep.
      CLEAR f_exist.
      CLEAR f_isdir.

      CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
           EXPORTING
                fname          = filename_tmp
           IMPORTING
                exist          = f_exist
                isdir          = f_isdir
           EXCEPTIONS
                fileinfo_error = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "APPL LOG

        "MESSAGE s072(zcl_plint_message_01)
        "  WITH filename_tmp '' '' ''.
      ELSE.
        IF f_exist IS INITIAL.
          "MESSAGE s061(zcl_plint_message_01)
          " WITH filename_tmp '' '' ''.
          wa_plotjobs-knz_fehl_blatt = 'X'.
          "wa_plotjobs-light = 1.
          wa_plotjobs-icon_fehlblatt = i_wa_user_data-fehlblatt_icon.
          MODIFY itab_plotjobs FROM wa_plotjobs INDEX index_plotjobs.
        ELSE.
        ENDIF.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
