FUNCTION zcl_upload_group_clf10.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(USER) TYPE  XUBNAME DEFAULT SY-UNAME
*"  TABLES
*"      O_GROUP_CLF10 STRUCTURE  ZCL_S_LINE_256 OPTIONAL
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
*-----------------------------------------------------------------------


  DATA : itab_group_clf10 TYPE TABLE OF zcl_group_clf10,
         wa_group_clf10   TYPE          zcl_group_clf10.


  DATA : wa_s_line TYPE zcl_s_line_256.

  SELECT * FROM zcl_group_clf10 INTO TABLE itab_group_clf10
    WHERE nutzer EQ sy-uname.
  IF sy-subrc EQ 0.
    LOOP AT itab_group_clf10 INTO wa_group_clf10.
      MOVE wa_group_clf10-line TO wa_s_line-line.
      APPEND wa_s_line TO o_group_clf10.
    ENDLOOP.

  ELSE.
    SELECT * FROM zcl_group_clf10 INTO TABLE itab_group_clf10
      WHERE nutzer EQ user.
    LOOP AT itab_group_clf10 INTO wa_group_clf10.
      MOVE wa_group_clf10-line TO wa_s_line-line.
      APPEND wa_s_line TO o_group_clf10.
    ENDLOOP.

  ENDIF.

ENDFUNCTION.
