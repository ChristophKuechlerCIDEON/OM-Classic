*----------------------------------------------------------------------*
***INCLUDE /CIDEON/L_PROD_STRUK_BRWSI01 .
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
module user_command_0100 input.
  data: index_search type sy-tabix.

  case ok_code.
    when 'OK' or 'CANC'.
      refresh itab_stored_search.
      leave to screen 0.
    when 'DELE'.
      loop at itab_stored_search into wa_stored_search.
        if wa_stored_search-mark = 'X'.
          delete  from  zcl_psb_tmp
            where uname = wa_stored_search-uname
            and object_type = wa_stored_search-object_type
            and dokar = wa_stored_search-dokar
            and doknr = wa_stored_search-doknr
            and dokvr = wa_stored_search-dokvr
            and doktl = wa_stored_search-doktl
            and counter = wa_stored_search-counter
            .
          if sy-subrc ne 0.

          else.
            delete itab_stored_search index sy-tabix.
          endif.
        else.
        endif.
      endloop.
    when 'DEL_DUPPLI'.
      loop at itab_stored_search into wa_stored_search.
        delete  from  zcl_psb_tmp
          where uname = wa_stored_search-uname
          and object_type = wa_stored_search-object_type
          and dokar = wa_stored_search-dokar
          and doknr = wa_stored_search-doknr
          and dokvr = wa_stored_search-dokvr
          and doktl = wa_stored_search-doktl
          and counter <> wa_stored_search-counter
          .
        if sy-subrc ne 0.
        else.
        endif.
        loop at itab_stored_search into wa_stored_search
          where uname = wa_stored_search-uname
          and object_type = wa_stored_search-object_type
          and dokar = wa_stored_search-dokar
          and doknr = wa_stored_search-doknr
          and dokvr = wa_stored_search-dokvr
          and doktl = wa_stored_search-doktl
          .
          delete itab_stored_search index sy-tabix.
        endloop.
      endloop.
      select * from zcl_psb_tmp
        into table itab_stored_search
        where uname = sy-uname
        .
      if sy-subrc ne 0.
        message s151(zcl_plint_message_01) with
          '' '' '' ''.
        exit.
      else.
      endif.
    when 'REFRESH'.
      perform read_stored_search.
  endcase.
  clear ok_code.

endmodule.                 " USER_COMMAND_0100  INPUT

* INPUT MODULE FOR TABLECONTROL 'TAB_CNTRL_01': MARK TABLE
module tab_cntrl_01_mark input.
  modify itab_stored_search
    from wa_stored_search
    index tab_cntrl_01-current_line
    transporting mark.
endmodule.

* INPUT MODULE FOR TABLECONTROL 'TAB_CNTRL_01': PROCESS USER COMMAND
module tab_cntrl_01_user_command input.
  perform user_ok_tc using    'TAB_CNTRL_01'
                              'ITAB_STORED_SEARCH'
                              'MARK'
                     changing ok_code.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0200 input.

  case ok_code.
    when 'OK'.
      leave to screen 0.
    when 'CANC'.
      wa_capid-capid = user_data-mat_capid.
      wa_stpos-stufe = user_data-mat_stpst.
      leave to screen 0.
    when others.
  endcase.

endmodule.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0300 input.

  case ok_code.
    when 'OK'.
      leave to screen 0.
    when 'CANC'.
      leave to screen 0.
    when others.
      leave to screen 0.
  endcase.
endmodule.                 " USER_COMMAND_0300  INPUT_0200  INPUT
