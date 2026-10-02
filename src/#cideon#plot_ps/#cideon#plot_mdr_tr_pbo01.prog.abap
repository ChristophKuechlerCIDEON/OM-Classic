*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_MDR_TR_PBO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.


  IF f_to_init IS INITIAL.
  ELSE.
*   BADI initialisieren
    IF badi_om_ps_01 IS INITIAL.
      CALL METHOD cl_exithandler=>get_instance
        CHANGING
          instance = badi_om_ps_01.
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.

*   Einstellungen lesen.
    PERFORM read_defaults.
    PERFORM map_default_data.



*  Letztes PSP Element lesen
    GET PARAMETER ID 'PRO' FIELD wa_mdr_tr-posid.
*     Lesen der Projektdaten
    IF wa_mdr_tr-pspid IS INITIAL.
      IF wa_mdr_tr-posid IS INITIAL.
      ELSE.
        PERFORM read_pspid.
        SET PARAMETER ID 'PRO' FIELD wa_mdr_tr-posid.
      ENDIF.
    ELSE.
    ENDIF.

    CLEAR f_to_init.
  ENDIF.


  SET PF-STATUS '0100'.
  SET TITLEBAR '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
