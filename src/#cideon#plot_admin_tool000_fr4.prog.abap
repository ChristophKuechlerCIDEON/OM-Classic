*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_ADMIN_TOOL000_FR4 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_class_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_class_data.
* Klassendaten holen und in Stempel Tabelle einfügen
  DATA: itab_class_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: wa_class_data TYPE zcl_s_stempel_value.
  DATA: wa_stempel_wert TYPE zcl_s_stempel_value..

  CLEAR itab_class_data.

  CALL FUNCTION '/CIDEON/GET_CLASS_DATA'
       EXPORTING
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            o_itab_class_data = itab_class_data
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Anhängen, dann Sortieren
  LOOP AT itab_class_data INTO wa_class_data.
    CLEAR wa_stempel_wert.
    MOVE-CORRESPONDING wa_class_data TO wa_stempel_wert.
    APPEND wa_stempel_wert TO itab_stempel_wert.
  ENDLOOP.

  SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.
*  DELETE ADJACENT DUPLICATES FROM itab_class_data.


ENDFORM.                    " get_class_data
