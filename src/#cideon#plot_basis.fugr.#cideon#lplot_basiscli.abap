*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/LPLOT_BASISCLI                                     *
*----------------------------------------------------------------------*

TYPE-POOLS: icon.

CLASS lcl_event_receiver_psrb_select IMPLEMENTATION.

  METHOD handle_toolbar.

    DATA:    ls_toolbar  TYPE stb_button.

    MOVE me->ci_separator    TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.

    MOVE 'DELETE'                 TO ls_toolbar-function.
    MOVE 'Löschen     .'(070)     TO ls_toolbar-text.
    MOVE 'Löschen     .'(071)     TO ls_toolbar-quickinfo.
    MOVE ICON_DELETE              TO ls_toolbar-icon.

    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD handle_usercommand.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DELETE'
        .

  ENDMETHOD.

*  e_row e_column es_row_no
  METHOD handle_doubleclick.

    READ TABLE gt_stored_search INDEX e_row-index INTO gs_stored_search.

    IF gs_stored_search-OBJECT_TYPE = 'DOCUMENT'.
      SET PARAMETER ID 'CV1' FIELD gs_stored_search-doknr.
      SET PARAMETER ID 'CV2' FIELD gs_stored_search-dokar.
      SET PARAMETER ID 'CV3' FIELD gs_stored_search-dokvr.
      SET PARAMETER ID 'CV4' FIELD gs_stored_search-doktl.
      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
