*&---------------------------------------------------------------------*
*& Report  ZCL_UPDATE_PROGRAM_INFO                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
*-----------------------------------------------------------------------
REPORT  zcl_update_format_werte       .

* Berechtigungscheck
AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
         ID 'ZCL_TA' FIELD sy-tcode
         ID 'ACTVT' FIELD '16'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
.
IF sy-subrc > 0.
  MESSAGE s099(zcl_plint_tools)
    WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
  LEAVE PROGRAM.
ELSE.
ENDIF.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_check AS CHECKBOX.
PARAMETERS: p_file TYPE draw-filep.
PARAMETERS: p_tcode LIKE  tstc-tcode.
PARAMETERS: p_lang LIKE sy-langu DEFAULT 'D'.
SELECTION-SCREEN END OF BLOCK bl1.

START-OF-SELECTION.

  IF p_check = 'X'.
    CALL FUNCTION 'Z_CL_UPDATE_PROG_INFO'
         EXPORTING
              i_filename = p_file
              i_langu    = p_lang  "'D'
              i_tcode    = p_tcode
         EXCEPTIONS
              error      = 1
              OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      MESSAGE s004(zcl_plint_tools) WITH '' ''
        '' '' .
    ENDIF.
  ELSE.
  ENDIF.
