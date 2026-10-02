*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007I04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_user_dependend_functions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user_dependend_functions.
* get the userdependend functions


ENDFORM.                    " get_user_dependend_functions
*&---------------------------------------------------------------------*
*&      Form  set_knz_checked_in
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_knz_use_checked_in.
* abgelegte Dateien bevorzugen?
  DATA: index_plotjobs TYPE sy-tabix.

  IF user_data-knz_use_checked_in = 'X'.
    LOOP AT itab_plotjobs INTO wa_plotjobs.
      index_plotjobs = sy-tabix.
*     Testen ob abgelegte Version benutzt werden kann
      IF wa_plotjobs-checked IS INITIAL.
        IF wa_plotjobs-storagecategory IS INITIAL.
          CLEAR wa_plotjobs-knz_use_checked_in.
        ELSE.
          wa_plotjobs-knz_use_checked_in = 'X'.
          CLEAR wa_plotjobs-knz_fehl_blatt.
*          wa_plotjobs-light = '3'.
          CLEAR wa_plotjobs-icon_fehlblatt.
        ENDIF.
      ELSE.
        wa_plotjobs-knz_use_checked_in = 'X'.
      ENDIF.
      MODIFY itab_plotjobs FROM wa_plotjobs INDEX index_plotjobs.
    ENDLOOP.
  ELSE.
    LOOP AT itab_plotjobs INTO wa_plotjobs.
      index_plotjobs = sy-tabix.
      IF wa_plotjobs-checked IS INITIAL.
        CLEAR wa_plotjobs-knz_use_checked_in.
      ELSE.
        wa_plotjobs-knz_use_checked_in = 'X'.
      ENDIF.
      MODIFY itab_plotjobs FROM wa_plotjobs INDEX index_plotjobs.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " set_knz_checked_in
*&---------------------------------------------------------------------*
*&      Module  get_cb_0127  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_cb_0127 input.

endmodule.                 " get_cb_0127  INPUT
