*&---------------------------------------------------------------------*
*& Report  ZCL_UPDATE_PROGRAM_INFO_PA*
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
REPORT  zcl_update_program_info_pa       .

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
PARAMETERS: p_file TYPE draw-filep NO-DISPLAY.
PARAMETERS: p_tcode LIKE  tstc-tcode DEFAULT 'ZCL_PLOT_INTERFACE'.
PARAMETERS: p_langu LIKE zcl_prog_info_pa-langu DEFAULT sy-langu.
SELECTION-SCREEN END OF BLOCK bl1.

START-OF-SELECTION.

  IF p_check = 'X'.
    CALL FUNCTION 'Z_CL_UPDATE_PROG_INFO_PA'
         EXPORTING
              i_filename = p_file
              i_langu    = p_langu
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
