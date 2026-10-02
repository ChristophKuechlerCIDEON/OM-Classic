*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/LPLOT_BASISCLD                                     *
*----------------------------------------------------------------------*


CLASS lcl_event_receiver_psrb_select DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar
        FOR EVENT toolbar
          OF cl_gui_alv_grid
          IMPORTING e_object e_interactive sender,
      handle_usercommand
        FOR EVENT user_command
          OF cl_gui_alv_grid
          IMPORTING e_ucomm sender,
      handle_doubleclick
        FOR EVENT double_click
          OF cl_gui_alv_grid
          IMPORTING e_row e_column es_row_no.


  PRIVATE SECTION.
    CONSTANTS:  ci_separator  TYPE i VALUE 3.

ENDCLASS.
