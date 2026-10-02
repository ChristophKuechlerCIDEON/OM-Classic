*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOT_BASISI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'OK'.
*     Selectierte Daten holen
      PERFORM get_sel_items.
      CLEAR ok_code.
*      PERFORM free_alv.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR ok_code.
*      PERFORM free_alv.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'OK'.
*     Selectierte Daten holen
      PERFORM get_sel_items_2.
      CLEAR ok_code.
*      PERFORM free_alv.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR ok_code.
*      PERFORM free_alv.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      GET PARAMETER ID 'CV1' FIELD doknr.
      GET PARAMETER ID 'CV2' FIELD dokar.
      GET PARAMETER ID 'CV3' FIELD dokvr.
      GET PARAMETER ID 'CV4' FIELD doktl.
      GET PARAMETER ID 'AEN' FIELD aennr.

      ccdat = wa_zcl_s_draw01-ccdat.

      g_draw_doknr = doknr.
      g_draw_dokar = dokar.
      g_draw_dokvr = dokvr.
      g_draw_doktl = doktl.

      g_aennr = aennr.
      g_ccdat = ccdat.

      stufe = g_stufe.

      IF doknr IS INITIAL
       OR dokvr IS INITIAL
       OR dokar IS INITIAL
       OR doktl IS INITIAL
      .
        MESSAGE i070(/cideon/plot_basis)
          WITH '' '' '' ''.
        CLEAR ok_code.
        LEAVE TO SCREEN 600.
        EXIT.
      ELSE.
        IF dokar IS INITIAL.
          MESSAGE i070(/cideon/plot_basis)
            WITH '' '' '' ''.
          LEAVE TO SCREEN 600.
        ELSE.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR g_draw_doknr.
      CLEAR g_draw_dokar.
      CLEAR g_draw_dokvr.
      CLEAR g_draw_doktl.

      CLEAR g_aennr.
      CLEAR g_ccdat.

      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0650  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0650 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      GET PARAMETER ID 'CV1' FIELD doknr.
      GET PARAMETER ID 'CV2' FIELD dokar.
      GET PARAMETER ID 'CV3' FIELD dokvr.
      GET PARAMETER ID 'CV4' FIELD doktl.
      GET PARAMETER ID 'AEN' FIELD aennr.

      ccdat = wa_zcl_s_draw01-ccdat.

      g_draw_doknr = doknr.
      g_draw_dokar = dokar.
      g_draw_dokvr = dokvr.
      g_draw_doktl = doktl.

      g_aennr = aennr.
      g_ccdat = ccdat.


*     Überprüfen auf leere Range
      IF so_dokar[] IS INITIAL.
        MESSAGE w010(/cideon/plot_basis).
        CLEAR ok_code.
        LEAVE TO SCREEN 650.
      ELSE.
      ENDIF.

      IF doknr IS INITIAL
       OR dokvr IS INITIAL
       OR dokar IS INITIAL
       OR doktl IS INITIAL
      .
        MESSAGE i070(/cideon/plot_basis)
          WITH '' '' '' ''.
        CLEAR ok_code.
        LEAVE TO SCREEN 650.
        EXIT.
      ELSE.
        IF dokar IS INITIAL.
          MESSAGE i070(/cideon/plot_basis)
            WITH '' '' '' ''.
          LEAVE TO SCREEN 650.
        ELSE.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR g_draw_doknr.
      CLEAR g_draw_dokar.
      CLEAR g_draw_dokvr.
      CLEAR g_draw_doktl.

      CLEAR g_aennr.
      CLEAR g_ccdat.

      LEAVE TO SCREEN 0.
    WHEN 'SO_DOKAR'.
*     Aufruf der Routine für SO_DOKAR
      CLEAR ls_tab_field.
      ls_tab_field-tablename = 'DRAW'.
      ls_tab_field-fieldname = 'DOKAR'.

*     Übergabe des Wertes des WA an Range

      CALL FUNCTION 'COMPLEX_SELECTIONS_DIALOG'
        EXPORTING
          title                   = text-020
*     TEXT                    =
*     SIGNED                  = 'X'
*     LOWER_CASE              = ' '
*     NO_INTERVAL_CHECK       = ' '
*     JUST_DISPLAY            = ' '
*     JUST_INCL               = ' '
*     EXCLUDED_OPTIONS        =
*     DESCRIPTION             =
*     HELP_FIELD              =
*     SEARCH_HELP             =
          tab_and_field           = ls_tab_field
        TABLES
          range                   = so_dokar
         EXCEPTIONS
           no_range_tab            = 1
           cancelled               = 2
           internal_error          = 3
           invalid_fieldname       = 4
           OTHERS                  = 5
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

*     Übergabe des ersten Wertes der Range an die WA

*     Überprüfen auf leere Range
      IF so_dokar[] IS INITIAL.
        MESSAGE s010(/cideon/plot_basis).
        CLEAR ok_code.
        LEAVE TO SCREEN 650.
      ELSE.
      ENDIF.

    WHEN 'SEARCH'.
      CALL TRANSACTION 'CV04N'.
      GET PARAMETER ID 'CV1' FIELD doknr.
      GET PARAMETER ID 'CV2' FIELD dokar.
      GET PARAMETER ID 'CV3' FIELD dokvr.
      GET PARAMETER ID 'CV4' FIELD doktl.

      g_draw_doknr = doknr.
      g_draw_dokar = dokar.
      g_draw_dokvr = dokvr.
      g_draw_doktl = doktl.

      zcl_s_draw01-doknr = doknr.
      zcl_s_draw01-dokar = dokar.
      zcl_s_draw01-dokvr = dokvr.
      zcl_s_draw01-doktl = doktl.

      wa_zcl_s_draw01-doknr = doknr.
      wa_zcl_s_draw01-dokar = dokar.
      wa_zcl_s_draw01-dokvr = dokvr.
      wa_zcl_s_draw01-doktl = doktl.

      CLEAR ok_code.
      LEAVE TO SCREEN 650.

    WHEN 'STACK'.
      DATA: wa_stack TYPE object_keyfields.
      CLEAR wa_stack.
      CALL FUNCTION 'C_PDM_SHOW_OBJECTS_FROM_STACK'
           EXPORTING
                objtyp              = 'DOCUMENT'
           IMPORTING
                new_object_fields   = wa_stack
           EXCEPTIONS
                fehlender_objekttyp = 1
                OTHERS              = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF wa_stack IS INITIAL.
      ELSE.
        g_draw_doknr = wa_stack-doknr.
        g_draw_dokar = wa_stack-dokar.
        g_draw_dokvr = wa_stack-dokvr.
        g_draw_doktl = wa_stack-doktl.

        zcl_s_draw01-doknr = wa_stack-doknr.
        zcl_s_draw01-dokar = wa_stack-dokar.
        zcl_s_draw01-dokvr = wa_stack-dokvr.
        zcl_s_draw01-doktl = wa_stack-doktl.

        wa_zcl_s_draw01-doknr = wa_stack-doknr.
        wa_zcl_s_draw01-dokar = wa_stack-dokar.
        wa_zcl_s_draw01-dokvr = wa_stack-dokvr.
        wa_zcl_s_draw01-doktl = wa_stack-doktl.

      ENDIF.

      CLEAR ok_code.
      LEAVE TO SCREEN 650.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0650  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_lif_telnr_long.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0710  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0710 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_lif_faxnr_long.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0710  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0720  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0720 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_lif_smtp_addr.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0720  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0675  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0675 INPUT.
  CASE ok_code.
    WHEN 'OK'.
*      GET PARAMETER ID 'CV1' FIELD doknr.
*      GET PARAMETER ID 'CV2' FIELD dokar.
*      GET PARAMETER ID 'CV3' FIELD dokvr.
*      GET PARAMETER ID 'CV4' FIELD doktl.
      GET PARAMETER ID 'AEN' FIELD aennr.
      GET PARAMETER ID 'MAT' FIELD matnr.
      GET PARAMETER ID 'CSA' FIELD capid.

      ccdat = wa_zcl_s_draw01-ccdat.

*      g_draw_doknr = doknr.
*      g_draw_dokar = dokar.
*      g_draw_dokvr = dokvr.
*      g_draw_doktl = doktl.

*      g_aennr = aennr.
*      g_ccdat = ccdat.

      g_matnr = matnr.
      g_capid = capid..


*     Überprüfen auf leere Range
      IF so_dokar[] IS INITIAL.
        MESSAGE w010(/cideon/plot_basis).
        CLEAR ok_code.
        LEAVE TO SCREEN 675.
      ELSE.
      ENDIF.

      IF matnr IS INITIAL
       OR capid IS INITIAL
      .
        MESSAGE i070(/cideon/plot_basis)
          WITH '' '' '' ''.
        CLEAR ok_code.
        LEAVE TO SCREEN 675.
        EXIT.
      ELSE.
        IF matnr IS INITIAL.
          MESSAGE i070(/cideon/plot_basis)
            WITH '' '' '' ''.
          LEAVE TO SCREEN 675.
        ELSE.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR g_matnr.
      CLEAR g_capid.
      CLEAR g_stufe.

      CLEAR g_aennr.
      CLEAR g_ccdat.

      LEAVE TO SCREEN 0.
    WHEN 'SO_DOKAR'.
*     Aufruf der Routine für SO_DOKAR
      CLEAR ls_tab_field.
      ls_tab_field-tablename = 'DRAW'.
      ls_tab_field-fieldname = 'DOKAR'.

*     Übergabe des Wertes des WA an Range

      CALL FUNCTION 'COMPLEX_SELECTIONS_DIALOG'
        EXPORTING
          title                   = text-020
*     TEXT                    =
*     SIGNED                  = 'X'
*     LOWER_CASE              = ' '
*     NO_INTERVAL_CHECK       = ' '
*     JUST_DISPLAY            = ' '
*     JUST_INCL               = ' '
*     EXCLUDED_OPTIONS        =
*     DESCRIPTION             =
*     HELP_FIELD              =
*     SEARCH_HELP             =
          tab_and_field           = ls_tab_field
        TABLES
          range                   = so_dokar
         EXCEPTIONS
           no_range_tab            = 1
           cancelled               = 2
           internal_error          = 3
           invalid_fieldname       = 4
           OTHERS                  = 5
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

*     Übergabe des ersten Wertes der Range an die WA

*     Überprüfen auf leere Range
      IF so_dokar[] IS INITIAL.
        MESSAGE s010(/cideon/plot_basis).
        CLEAR ok_code.
        LEAVE TO SCREEN 675.
      ELSE.
      ENDIF.
    WHEN 'SO_DOKAR_LINKS'.
*     Aufruf der Routine für SO_DOKAR
      CLEAR ls_tab_field.
      ls_tab_field-tablename = 'DRAW'.
      ls_tab_field-fieldname = 'DOKAR'.

      CALL FUNCTION 'COMPLEX_SELECTIONS_DIALOG'
           EXPORTING
                title             = text-020
                tab_and_field     = ls_tab_field
           TABLES
                range             = so_dokar_links
           EXCEPTIONS
                no_range_tab      = 1
                cancelled         = 2
                internal_error    = 3
                invalid_fieldname = 4
                OTHERS            = 5.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CLEAR ok_code.
      LEAVE TO SCREEN 675.

    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.


ENDMODULE.                 " USER_COMMAND_0675  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0680  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0680 INPUT.
  DATA: itab_et_index_rows_mast  TYPE lvc_t_row.
  DATA: wa_row TYPE i.
  DATA: lines TYPE i.

  CASE ok_code.
    WHEN 'OK'.
*     Selektion holen
      REFRESH itab_et_index_rows_mast.
      CALL METHOD alv_mast->get_selected_rows
        IMPORTING
          et_index_rows = itab_et_index_rows_mast.
*      ET_ROW_NO     =
      .
      DESCRIBE TABLE itab_et_index_rows_mast LINES lines.
      IF lines <> 1.
        REFRESH itab_et_index_rows_mast.
        MESSAGE e000(zcl_plint_message_01)
          WITH text-051 lines '' ''.
      ELSE.
        CLEAR wa_row.
        READ TABLE itab_et_index_rows_mast INTO wa_row INDEX 1.
        CLEAR wa_mast.
        READ TABLE itab_mast INTO wa_mast INDEX wa_row.
      ENDIF.

      CLEAR ok_code.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR ok_code.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      CLEAR ok_code.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND_0680  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0730  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0730 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      CLEAR ok_code.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR g_converter_spec_name.
      RAISE error.
      CLEAR ok_code.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      CLEAR ok_code.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0730  INPUT
*&---------------------------------------------------------------------*
*&      Module  spras_cs02  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE spras_cs02 INPUT.
* Werte umsetzen für Sprache
* break kuechler.

  DATA: it_return TYPE TABLE OF ddshretval.
  DATA: wa_return TYPE ddshretval.

  CLEAR it_return.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'T002'
      fieldname                 = 'SPRAS'
*   SEARCHHELP                = ' '
*   SHLPPARAM                 = ' '
*   DYNPPROG                  = ' '
*   DYNPNR                    = ' '
*   DYNPROFIELD               = ' '
*   STEPL                     = 0
*   VALUE                     = ' '
*   MULTIPLE_CHOICE           = ' '
*   DISPLAY                   = ' '
*   SUPPRESS_RECORDLIST       = ' '
*   CALLBACK_PROGRAM          = ' '
*   CALLBACK_FORM             = ' '
  TABLES
    return_tab                = it_return
* EXCEPTIONS
*   FIELD_NOT_FOUND           = 1
*   NO_HELP_FOR_FIELD         = 2
*   INCONSISTENT_HELP         = 3
*   NO_VALUES_FOUND           = 4
*   OTHERS                    = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  IF it_return[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_return.
  READ TABLE it_return INTO wa_return INDEX 1.

  SELECT SINGLE spras FROM t002
    INTO g_smartform_cs02_spr
     WHERE laiso = wa_return-fieldval
     .

*  g_smartform_cs02_spr = 'E'.

ENDMODULE.                 " spras_cs02  INPUT
*&---------------------------------------------------------------------*
*&      Module  spras_cs11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE spras_cs11 INPUT.
* Werte umsetzen für Sprache
* break kuechler.


  CLEAR it_return.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'T002'
      fieldname                 = 'SPRAS'
*   SEARCHHELP                = ' '
*   SHLPPARAM                 = ' '
*   DYNPPROG                  = ' '
*   DYNPNR                    = ' '
*   DYNPROFIELD               = ' '
*   STEPL                     = 0
*   VALUE                     = ' '
*   MULTIPLE_CHOICE           = ' '
*   DISPLAY                   = ' '
*   SUPPRESS_RECORDLIST       = ' '
*   CALLBACK_PROGRAM          = ' '
*   CALLBACK_FORM             = ' '
  TABLES
    return_tab                = it_return
* EXCEPTIONS
*   FIELD_NOT_FOUND           = 1
*   NO_HELP_FOR_FIELD         = 2
*   INCONSISTENT_HELP         = 3
*   NO_VALUES_FOUND           = 4
*   OTHERS                    = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  IF it_return[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_return.
  READ TABLE it_return INTO wa_return INDEX 1.

  SELECT SINGLE spras FROM t002
    INTO g_smartform_cs11_spr
     WHERE laiso = wa_return-fieldval
     .

ENDMODULE.                 " spras_cs11  INPUT
*&---------------------------------------------------------------------*
*&      Module  spras_cs12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE spras_cs12 INPUT.
* Werte umsetzen für Sprache
* break kuechler.


  CLEAR it_return.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'T002'
      fieldname                 = 'SPRAS'
*   SEARCHHELP                = ' '
*   SHLPPARAM                 = ' '
*   DYNPPROG                  = ' '
*   DYNPNR                    = ' '
*   DYNPROFIELD               = ' '
*   STEPL                     = 0
*   VALUE                     = ' '
*   MULTIPLE_CHOICE           = ' '
*   DISPLAY                   = ' '
*   SUPPRESS_RECORDLIST       = ' '
*   CALLBACK_PROGRAM          = ' '
*   CALLBACK_FORM             = ' '
  TABLES
    return_tab                = it_return
* EXCEPTIONS
*   FIELD_NOT_FOUND           = 1
*   NO_HELP_FOR_FIELD         = 2
*   INCONSISTENT_HELP         = 3
*   NO_VALUES_FOUND           = 4
*   OTHERS                    = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  IF it_return[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_return.
  READ TABLE it_return INTO wa_return INDEX 1.

  SELECT SINGLE spras FROM t002
    INTO g_smartform_cs12_spr
     WHERE laiso = wa_return-fieldval
     .


ENDMODULE.                 " spras_cs12  INPUT
*&---------------------------------------------------------------------*
*&      Module  spras_cs13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE spras_cs13 INPUT.
* Werte umsetzen für Sprache
* break kuechler.


  CLEAR it_return.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'T002'
      fieldname                 = 'SPRAS'
*   SEARCHHELP                = ' '
*   SHLPPARAM                 = ' '
*   DYNPPROG                  = ' '
*   DYNPNR                    = ' '
*   DYNPROFIELD               = ' '
*   STEPL                     = 0
*   VALUE                     = ' '
*   MULTIPLE_CHOICE           = ' '
*   DISPLAY                   = ' '
*   SUPPRESS_RECORDLIST       = ' '
*   CALLBACK_PROGRAM          = ' '
*   CALLBACK_FORM             = ' '
  TABLES
    return_tab                = it_return
* EXCEPTIONS
*   FIELD_NOT_FOUND           = 1
*   NO_HELP_FOR_FIELD         = 2
*   INCONSISTENT_HELP         = 3
*   NO_VALUES_FOUND           = 4
*   OTHERS                    = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  IF it_return[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_return.
  READ TABLE it_return INTO wa_return INDEX 1.

  SELECT SINGLE spras FROM t002
    INTO g_smartform_cs13_spr
     WHERE laiso = wa_return-fieldval
     .


ENDMODULE.                 " spras_cs13  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE ok_code.
    WHEN 'OK'.
*     Selectierte Daten holen
      PERFORM editor_get_data.
      CLEAR ok_code.
*      PERFORM free_alv.
      g_answer = 'X'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR ok_code.
*      PERFORM free_alv.
      g_answer = 'A'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
