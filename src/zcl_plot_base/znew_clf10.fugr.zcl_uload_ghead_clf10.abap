FUNCTION zcl_uload_ghead_clf10.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(USER) TYPE  XUBNAME DEFAULT 'SAP*'
*"  TABLES
*"      O_GHEAD_CLF10 STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
*
* Author :  Srinivas Mamillapalli
*
* Änderungen:
*           Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 01.12.2003  Überarbeitung
* 12.01.2004  Überarbeitung
* 15.03.2004  ORDER BY counter
*-----------------------------------------------------------------------

  DATA : itab_ghead_clf10 TYPE TABLE OF zcl_ghead_clf10,
         wa_ghead_clf10 TYPE zcl_ghead_clf10.

  DATA : wa_s_line TYPE zcl_s_line_256.

  SELECT * FROM zcl_ghead_clf10 INTO TABLE itab_ghead_clf10
  WHERE nutzer = sy-uname
  ORDER BY counter.

  IF sy-subrc EQ 0.

    LOOP AT itab_ghead_clf10 INTO wa_ghead_clf10.
      MOVE wa_ghead_clf10-line TO wa_s_line-line.
      APPEND wa_s_line TO o_ghead_clf10.
    ENDLOOP.

  ELSE.
    SELECT * FROM zcl_ghead_clf10 INTO TABLE itab_ghead_clf10
      WHERE nutzer EQ user
      ORDER BY counter.

    IF sy-subrc NE 0.
      MESSAGE i030(zcl_plint_tools) WITH
        'zcl_ghead_clf10' user 'ZCL_ULOAD_GHEAD_CLF10' ''.
    ELSE.
    ENDIF.

    LOOP AT itab_ghead_clf10 INTO wa_ghead_clf10.
      MOVE wa_ghead_clf10-line TO wa_s_line-line.
      APPEND wa_s_line TO o_ghead_clf10.
    ENDLOOP.

  ENDIF.

ENDFUNCTION.
