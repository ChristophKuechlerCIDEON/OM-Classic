*----------------------------------------------------------------------*
*   INCLUDE ZCL_MAINTAIN_BEDINGUNG_SET_CL1                             *
*----------------------------------------------------------------------*
* Klassen

CLASS lcl_event_handler_alv DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm
   .

ENDCLASS.



CLASS lcl_event_handler_alv IMPLEMENTATION.

  METHOD catch_dblclick.
    lv_index_itab_beding_set = e_row.
    READ TABLE itab_beding_set INDEX lv_index_itab_beding_set INTO
      wa_beding_set.
*
    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DBLCLICK_ALV'
*      IMPORTING
*        RC       =
        .
  ENDMETHOD.


  METHOD handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'DELETE_SEARCH_ITEM'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DELETE_SEARCH_ITEM'
*      IMPORTING
*        RC       =
            .

    ENDCASE.
  ENDMETHOD.


ENDCLASS.
