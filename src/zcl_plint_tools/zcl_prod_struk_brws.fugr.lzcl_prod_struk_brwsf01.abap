***INCLUDE LZCL_PROD_STRUK_BRWSF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                          p_table_name
                          p_mark_name
                 CHANGING p_ok      LIKE sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA: l_ok              TYPE sy-ucomm,
         l_offset          TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
   SEARCH p_ok FOR p_tc_name.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = strlen( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.
* execute general and TC specific operations                           *
   CASE l_ok.
     WHEN 'INSR'.                      "insert row
       PERFORM fcode_insert_row USING    p_tc_name
                                         p_table_name.
       CLEAR p_ok.

     WHEN 'DELE'.                      "delete row
       PERFORM fcode_delete_row USING    p_tc_name
                                         p_table_name
                                         p_mark_name.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM fcode_tc_mark_lines USING p_tc_name
                                         p_table_name
                                         p_mark_name   .
       CLEAR p_ok.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM fcode_tc_demark_lines USING p_tc_name
                                           p_table_name
                                           p_mark_name .
       CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_lines_name       LIKE feld-name.
   DATA l_selline          LIKE sy-stepl.
   DATA l_lastline         TYPE i.
   DATA l_line             TYPE i.
   DATA l_table_name       LIKE feld-name.
   FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lines>              TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* get looplines of TableControl
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
   ASSIGN (l_lines_name) TO <lines>.

* get current line
   GET CURSOR LINE l_selline.
   IF sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*   set top line and new cursor line                                   *
     IF l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
       l_line = 1.
     ELSE.
       <tc>-top_line = 1.
       l_line = l_selline.
     ENDIF.
   ELSE.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
*   set top line and new cursor line                                   *
     l_lastline = l_selline + <lines> - 1.
     IF l_lastline <= <tc>-lines.
       <tc>-top_line = l_selline.
       l_line = 1.
     ELSEIF <lines> > <tc>-lines.
       <tc>-top_line = 1.
       l_line = l_selline.
     ELSE.
       <tc>-top_line = <tc>-lines - <lines> + 2 .
       l_line = l_selline - <tc>-top_line + 1.
     ENDIF.
   ENDIF.
* insert initial line
   INSERT INITIAL LINE INTO <table> INDEX l_selline.
   <tc>-lines = <tc>-lines + 1.
* set cursor
   SET CURSOR LINE l_line.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name
                        p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* delete marked lines                                                  *
   DESCRIBE TABLE <table> LINES <tc>-lines.

   LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     IF <mark_field> = 'X'.
       DELETE <table> INDEX syst-tabix.
       IF sy-subrc = 0.
         <tc>-lines = <tc>-lines - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM compute_scrolling_in_tc USING    p_tc_name
                                       p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_tc_new_top_line     TYPE i.
   DATA l_tc_name             LIKE feld-name.
   DATA l_tc_lines_name       LIKE feld-name.
   DATA l_tc_field_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lines>      TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.
* get looplines of TableControl
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
   ASSIGN (l_tc_lines_name) TO <lines>.


* is no line filled?                                                   *
   IF <tc>-lines = 0.
*   yes, ...                                                           *
     l_tc_new_top_line = 1.
   ELSE.
*   no, ...                                                            *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
          EXPORTING
               entry_act             = <tc>-top_line
               entry_from            = 1
               entry_to              = <tc>-lines
               last_page_full        = 'X'
               loops                 = <lines>
               ok_code               = p_ok
               overlapping           = 'X'
          IMPORTING
               entry_new             = l_tc_new_top_line
          EXCEPTIONS
               no_entry_or_page_act  = 01
               no_entry_to           = 02
               no_ok_code_or_page_go = 03
               OTHERS                = 99.
   ENDIF.

* get actual tc and column                                             *
   GET CURSOR FIELD l_tc_field_name
              AREA  l_tc_name.

   IF syst-subrc = 0.
     IF l_tc_name = p_tc_name.
*     set actual column                                                *
       SET CURSOR FIELD l_tc_field_name LINE 1.
     ENDIF.
   ENDIF.

* set the new top line                                                 *
   <tc>-top_line = l_tc_new_top_line.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_mark_lines USING p_tc_name
                                p_table_name
                                p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* mark all filled lines                                                *
   LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_demark_lines USING p_tc_name
                                  p_table_name
                                  p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* demark all filled lines                                              *
   LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = space.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  read_stored_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM read_stored_search.

   CLEAR wa_stored_search.
   REFRESH itab_stored_search.


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

 ENDFORM.                    " read_stored_search
*&---------------------------------------------------------------------*
*&      Form  check_fb__mat_bom_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM check_fb__mat_bom_print.
* testet, ob Fubnktionsbaustein '/CIDEON/MATNR_MAT_BOM_PRINT'
* vorhanden und aktiv ist
   TABLES: tfdir.
   TABLES: rsinfdir.

   SELECT SINGLE * FROM tfdir
     WHERE funcname = '/CIDEON/MATNR_MAT_BOM_PRINT'
     .
   IF sy-subrc NE 0.
     MESSAGE e011(zcl_prod_struk_brws)
       WITH '/CIDEON/MATNR_MAT_BOM_PRINT'
       '' '' '' RAISING error.
   ELSE.
   ENDIF.
*  active
   SELECT SINGLE * FROM rsinfdir
     WHERE funcname = '/CIDEON/MATNR_MAT_BOM_PRINT'
     .
   IF sy-subrc NE 0.
   ELSE.
     MESSAGE e012(zcl_prod_struk_brws)
       WITH '/CIDEON/MATNR_MAT_BOM_PRINT'
       '' '' '' RAISING error.
   ENDIF.

 ENDFORM.                    " check_fb__mat_bom_print
*&---------------------------------------------------------------------*
*&      Form  check_datum_stueckliste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM check_datum_stueckliste.
* Datum für Stücklistenauflösung testen
* Liegt die Stückliste im Gültigkeitszeitraum
* -> Kopf der Stückliste
*   DATA:
*           ls_t001w TYPE t001w,
*           ls_makt TYPE makt,
*           lt_mastb TYPE TABLE OF mastb,
*           lt_stkob TYPE TABLE OF stkob,
*           lt_stzub TYPE TABLE OF stzub,
*           ls_stkob TYPE stkob.
*
*   CALL FUNCTION 'CS_BOMHEADERS_GET_MAT'
*        EXPORTING
*             matnr           = wa_objects-matnr
*             stlal           = wa_bom_print-stlal
*             stlan           = wa_bom_print-stlan
*             werks           = wa_bom_print-werks
*             datuv           = wa_bom_print-bomdatuv
*        TABLES
*             mastb_wa        = lt_mastb
*             stkob_wa        = lt_stkob
*             stzub_wa        = lt_stzub
*        EXCEPTIONS
*             call_invalid    = 1
*             no_record_found = 2
*             OTHERS          = 3.
*   IF sy-subrc <> 0.
*   ENDIF.

 ENDFORM.                    " check_datum_stueckliste
