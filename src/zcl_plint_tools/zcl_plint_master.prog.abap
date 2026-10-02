*&---------------------------------------------------------------------*
*& Report  ZCL_PLINT_MASTER                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Masterprogramm für Tools                                        *
*&---------------------------------------------------------------------*
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------

REPORT  zcl_plint_master              .

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
PARAMETERS: p_format  RADIOBUTTON GROUP prog DEFAULT 'X' .
PARAMETERS: p_info  RADIOBUTTON GROUP prog  .
PARAMETERS: p_patch  RADIOBUTTON GROUP prog  .
*PARAMETERS: p_file TYPE draw-filep.
*PARAMETERS: p_tcode LIKE  tstc-tcode.
SELECTION-SCREEN END OF BLOCK bl1.

START-OF-SELECTION.

  IF p_check = 'X'.
    IF p_format = 'X'.
      SUBMIT zcl_update_format_werte
          VIA SELECTION-SCREEN  AND RETURN .
    ELSE.
    ENDIF.
    IF p_info = 'X'.
      SUBMIT zcl_update_program_info
          VIA SELECTION-SCREEN  AND RETURN .
    ELSE.
    ENDIF.
    IF p_patch = 'X'.
      SUBMIT zcl_update_program_info_pa
          VIA SELECTION-SCREEN  AND RETURN .

    ELSE.
    ENDIF.

*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ELSE.
*      MESSAGE s004(zcl_plint_tools) WITH '' ''
*        '' '' .
*    ENDIF.
  ELSE.
  ENDIF.
