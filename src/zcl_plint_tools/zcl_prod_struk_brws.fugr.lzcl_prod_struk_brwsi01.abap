*----------------------------------------------------------------------*
***INCLUDE LZCL_PROD_STRUK_BRWSI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* Änderungen:
*  13.08.2004   HAENSEL  Schliessen des Dialog, wenn auf den CLOSE
*                        Button gedrückt wird.
************************************************************************
MODULE user_command_0100 INPUT.
  DATA: index_search TYPE sy-tabix.

  CASE ok_code.
    WHEN 'OK' OR 'CANC'.
      REFRESH itab_stored_search.
      LEAVE TO SCREEN 0.
    WHEN 'DELE'.
      LOOP AT itab_stored_search INTO wa_stored_search.
        IF wa_stored_search-mark = 'X'.
          DELETE  FROM  zcl_psb_tmp
            WHERE uname = wa_stored_search-uname
            AND object_type = wa_stored_search-object_type
            AND dokar = wa_stored_search-dokar
            AND doknr = wa_stored_search-doknr
            AND dokvr = wa_stored_search-dokvr
            AND doktl = wa_stored_search-doktl
            AND counter = wa_stored_search-counter
            .
          IF sy-subrc NE 0.

          ELSE.
            DELETE itab_stored_search INDEX sy-tabix.
          ENDIF.
        ELSE.
        ENDIF.
      ENDLOOP.
    WHEN 'DEL_DUPPLI'.
      LOOP AT itab_stored_search INTO wa_stored_search.
        DELETE  FROM  zcl_psb_tmp
          WHERE uname = wa_stored_search-uname
          AND object_type = wa_stored_search-object_type
          AND dokar = wa_stored_search-dokar
          AND doknr = wa_stored_search-doknr
          AND dokvr = wa_stored_search-dokvr
          AND doktl = wa_stored_search-doktl
          AND counter <> wa_stored_search-counter
          .
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
        LOOP AT itab_stored_search INTO wa_stored_search
          WHERE uname = wa_stored_search-uname
          AND object_type = wa_stored_search-object_type
          AND dokar = wa_stored_search-dokar
          AND doknr = wa_stored_search-doknr
          AND dokvr = wa_stored_search-dokvr
          AND doktl = wa_stored_search-doktl
          .
          DELETE itab_stored_search INDEX sy-tabix.
        ENDLOOP.
      ENDLOOP.
      SELECT * FROM zcl_psb_tmp
        INTO TABLE itab_stored_search
        WHERE uname = sy-uname
        .
      IF sy-subrc NE 0.
        MESSAGE s151(zcl_plint_message_01) WITH
          '' '' '' ''.
        EXIT.
      ELSE.
      ENDIF.
    WHEN 'REFRESH'.
      PERFORM read_stored_search.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

* INPUT MODULE FOR TABLECONTROL 'TAB_CNTRL_01': MARK TABLE
MODULE tab_cntrl_01_mark INPUT.
  MODIFY itab_stored_search
    FROM wa_stored_search
    INDEX tab_cntrl_01-current_line
    TRANSPORTING mark.
ENDMODULE.

* INPUT MODULE FOR TABLECONTROL 'TAB_CNTRL_01': PROCESS USER COMMAND
MODULE tab_cntrl_01_user_command INPUT.
  PERFORM user_ok_tc USING    'TAB_CNTRL_01'
                              'ITAB_STORED_SEARCH'
                              'MARK'
                     CHANGING ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      wa_capid-capid = user_data-mat_capid.
      wa_stpos-stufe = user_data-mat_stpst.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
