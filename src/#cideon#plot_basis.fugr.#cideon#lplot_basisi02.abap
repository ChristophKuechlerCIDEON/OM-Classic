*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOT_BASISI02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0800 INPUT.


  CASE sy-ucomm.
    WHEN 'DELETE_DUP'.

      LOOP AT gt_stored_search INTO gs_stored_search.

        DELETE FROM  zcl_psb_tmp
          WHERE uname     = gs_stored_search-uname
          AND object_type = gs_stored_search-object_type
          AND dokar       = gs_stored_search-dokar
          AND doknr       = gs_stored_search-doknr
          AND dokvr       = gs_stored_search-dokvr
          AND doktl       = gs_stored_search-doktl
          AND counter    <> gs_stored_search-counter
          .

        IF sy-subrc NE 0.
        ELSE.
        ENDIF.


        DELETE gt_stored_search WHERE
              uname       = gs_stored_search-uname
          AND object_type = gs_stored_search-object_type
          AND dokar       = gs_stored_search-dokar
          AND doknr       = gs_stored_search-doknr
          AND dokvr       = gs_stored_search-dokvr
          AND doktl       = gs_stored_search-doktl
          .
      ENDLOOP.


      SELECT * FROM zcl_psb_tmp
        INTO TABLE gt_stored_search
        WHERE uname = sy-uname
        .
      IF sy-subrc NE 0.
        MESSAGE s151(zcl_plint_message_01) WITH
          '' '' '' ''.
        EXIT.
      ELSE.
      ENDIF.

    WHEN 'DELETE'.

      DATA: lt_index TYPE lvc_t_row,
            lt_rowno TYPE lvc_t_roid,
            ls_rowno TYPE lvc_s_roid.

      REFRESH: lt_index, lt_rowno, gt_stored_search_tmp.


      CALL METHOD go_alv->get_selected_rows
        IMPORTING
          et_index_rows = lt_index
          et_row_no     = lt_rowno
          .

      IF NOT lt_index IS INITIAL.
        DESCRIBE TABLE lt_index.
        IF sy-tfill <> 0.


          LOOP AT lt_rowno INTO ls_rowno.
            CLEAR gs_stored_search.
            READ TABLE gt_stored_search INDEX ls_rowno-row_id
              INTO gs_stored_search.

            APPEND gs_stored_search TO gt_stored_search_tmp.
          ENDLOOP.


          CLEAR gs_stored_search.
          LOOP AT gt_stored_search_tmp INTO gs_stored_search.
            IF gs_stored_search IS INITIAL.
              CONTINUE.
            ENDIF.

            DELETE FROM zcl_psb_tmp
              WHERE uname = gs_stored_search-uname
              AND object_type = gs_stored_search-object_type
              AND dokar = gs_stored_search-dokar
              AND doknr = gs_stored_search-doknr
              AND dokvr = gs_stored_search-dokvr
              AND doktl = gs_stored_search-doktl
              AND counter = gs_stored_search-counter.

            IF sy-subrc <> 0. ENDIF.

          ENDLOOP.
          ELSE.

        ENDIF.
        ELSE.
      ENDIF.


      SELECT * FROM zcl_psb_tmp
        INTO TABLE gt_stored_search
        WHERE uname = sy-uname
        .
      IF sy-subrc NE 0.
        MESSAGE s151(zcl_plint_message_01) WITH
          '' '' '' ''.
        EXIT.
      ELSE.
      ENDIF.


    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0800  INPUT
