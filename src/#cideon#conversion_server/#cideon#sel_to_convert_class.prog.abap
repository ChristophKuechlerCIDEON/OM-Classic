*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/SEL_TO_CONVERT_CLASS                               *
*----------------------------------------------------------------------*
CLASS lcl_event_handler_alv DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column
   .

ENDCLASS.                    "lcl_event_handler_alv DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_alv IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_alv IMPLEMENTATION.

  METHOD catch_dblclick.
    index_itab_alv = e_row.
    READ TABLE itab_ptx_draw INDEX index_itab_alv INTO
      wa_ptx_draw_sel.

    SET PARAMETER ID 'CV1' FIELD wa_ptx_draw_sel-doknr.
    SET PARAMETER ID 'CV2' FIELD wa_ptx_draw_sel-dokar.
    SET PARAMETER ID 'CV3' FIELD wa_ptx_draw_sel-dokvr.
    SET PARAMETER ID 'CV4' FIELD wa_ptx_draw_sel-doktl.

    AUTHORITY-CHECK OBJECT 'S_TCODE'
             ID 'TCD' FIELD 'CV03N'.
    IF sy-subrc NE 0.
    ELSE.
      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
    ENDIF.





*    CALL METHOD cl_gui_cfw=>set_new_ok_code
*      EXPORTING
*        new_code = 'DBLCLICK_ALV'
**      IMPORTING
**        RC       =
*        .
  ENDMETHOD.                    "catch_dblclick
ENDCLASS.                    "lcl_event_handler_alv IMPLEMENTATION
