FUNCTION z_cl_clf_proc_skeleton_lines .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_MULTI_PAGE) TYPE  ZCL_KNZ_MULTI_PAGE OPTIONAL
*"     VALUE(I_START_PAGE_NO) TYPE  ZCL_SEITE_VON OPTIONAL
*"     VALUE(I_END_PAGE_NO) TYPE  ZCL_SEITE_BIS OPTIONAL
*"     VALUE(I_DOWNLOADED_PATH) TYPE  STRING OPTIONAL
*"     VALUE(WA_TEST) TYPE  ZCL_S_PLOTLIST OPTIONAL
*"     VALUE(I_LAST_PATH) TYPE  FILEP OPTIONAL
*"     VALUE(I_DELETE_STATUS) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(E_LAST_PATH) TYPE  FILEP
*"  TABLES
*"      IT_REP_SKEL_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      OT_REP_SKEL_LINES STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : BEGIN OF tab_lines OCCURS 0,
            line(500),
         END OF tab_lines.

  DATA : itab2_bapi_doc_files2 TYPE bapi_doc_files2 OCCURS 0.

* Working areas of the tables that were declared in
* Fuction Module Tables as internal tables.
  DATA : wa_special_doc       TYPE zcl_sl_tmp,
         wa_rep_skel_lines    TYPE zcl_s_line_256 ,
         wa_ot_rep_skel_lines TYPE zcl_s_line_256 ,
         wa_stamps            TYPE zcl_s_stempel_value.

  DATA : lv_stripped_name     LIKE rlgrap-filename,
         lv_file_path         LIKE rlgrap-filename,
         lv_full_name         LIKE rlgrap-filename,
         tmp_bapi_check_path  LIKE bapi_doc_aux-filename.

  DATA : lv_no_copies(2)      TYPE c,
         lv_out_proc          TYPE c,
         lv_no_of_loops       TYPE c,
         i_delete_item        TYPE char1 VALUE '0',
         i_format_checking    TYPE char1,
         tmp_obj_source       TYPE string,
         tmp_destiny          TYPE string.

  DATA : ao_naming(60),
         ao_datum(10),
         ao_viewname(40),
         ao_save(40),
         ao_print             VALUE '0',
         ao_appl(40)          VALUE '-',
         ao_project(60)       VALUE '-'.

  DATA : tmp_flag     TYPE c,
         tmp_stufe(2) TYPE c.

  DATA : it_sl_tmp TYPE TABLE OF zcl_sl_tmp,
         wa_sl_tmp TYPE zcl_sl_tmp.

* Kennzeichen für Multipage setzen, falls eine bestimmte Seite
* angefordert wird
  IF (
       ( NOT ( wa_test-seite_von IS INITIAL ) )
       AND
       ( NOT ( wa_test-seite_bis IS INITIAL ) )
     )
  AND ( wa_test-knz_multi_page IS INITIAL ).
    wa_test-knz_multi_page = 'X'.
  ELSE.
  ENDIF.


  IF i_multi_page IS INITIAL .
*   Kennzeichen für Multipage setzen, falls eine bestimmte Seite
*   angefordert wird
    IF ( ( NOT ( wa_test-seite IS INITIAL ) )
       )
    AND ( wa_test-knz_multi_page IS INITIAL ).
      wa_test-knz_multi_page = 'X'.
    ELSE.
    ENDIF.


    LOOP AT it_rep_skel_lines INTO wa_rep_skel_lines .
      MOVE wa_rep_skel_lines-line TO x_lines-line.

      IF x_lines-line CS '%NAMING%'.
        CLEAR ao_naming.
        CONCATENATE wa_test-dokar '/'
                    wa_test-doknr '/'
                    wa_test-dokvr '/'
                    wa_test-doktl  INTO ao_naming.
        REPLACE '%NAMING%' WITH ao_naming INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%PROJECT%'.
        IF ao_project = '-'.
          REPLACE '%PROJECT%' WITH text-058 INTO reproliste-line.
        ELSE.
          REPLACE '%PROJECT%' WITH ao_project INTO reproliste-line.
        ENDIF.

      ELSEIF x_lines-line CS 'AOFB'.
        APPEND x_lines.

      ELSEIF x_lines-line CS 'AOFE'.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%ERASE%'.
        REPLACE '%ERASE%' WITH i_delete_item INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%PATH%'.
        CONCATENATE 'AO$_PATH=' i_downloaded_path INTO x_lines-line+1.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%FORMAT%'.

        IF i_format_checking EQ space.
          REPLACE '%FORMAT%' WITH wa_test-format_ausgabe
                                            INTO x_lines-line.
          APPEND x_lines.
        ELSE.
        ENDIF.

      ELSEIF x_lines-line CS '%COPIES%'.
        CLEAR lv_no_copies.
        MOVE wa_test-kopien TO lv_no_copies.
        REPLACE '%COPIES%' WITH lv_no_copies INTO x_lines-line.
        APPEND x_lines.
        CLEAR lv_no_copies.

      ELSEIF x_lines-line CS '%PRINTMODE%'.

        IF lv_out_proc EQ 'X'.
          REPLACE '%PRINTMODE%' WITH ao_print INTO x_lines-line.
        ELSE.
          REPLACE '%PRINTMODE%' WITH '1' INTO x_lines-line.
        ENDIF.

        APPEND x_lines.

      ELSEIF x_lines-line CS '%NUMBER%'.
        REPLACE '%NUMBER%' WITH wa_test-doknr INTO x_lines-line.
        APPEND x_lines.
      ELSEIF x_lines-line CS '%APPLICATION%'.
        REPLACE '%APPLICATION%' WITH ao_appl INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%DELETE%'.
        REPLACE '%DELETE%' WITH i_delete_status INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%VIEWNAME%'.
        REPLACE '%VIEWNAME%' WITH ao_viewname INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%SAVECONVERTAS%'.
        REPLACE '%SAVECONVERTAS%' WITH ao_save INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%MULTIPAGE%'.
        IF wa_test-knz_multi_page IS INITIAL.
          REPLACE '%MULTIPAGE%' WITH '0' INTO x_lines-line.
        ELSE.
          REPLACE '%MULTIPAGE%' WITH '1' INTO x_lines-line.
        ENDIF.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%PAGE%'.
*       REPLACE '%PAGE%' WITH wa_test-seite_von INTO x_lines-line.
        REPLACE '%PAGE%' WITH wa_test-seite INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '"%STEMPEL1%"'.
*        SHIFT wa_test-cont LEFT DELETING LEADING 0.
        SHIFT wa_test-cont LEFT DELETING LEADING '0'.

        LOOP AT itab_stamps INTO wa_stamps
                      WHERE zeile_plotjob = wa_test-cont.
          IF sy-subrc = 0.
            CONCATENATE wa_stamps-stempel_name ' = '
                wa_stamps-stempel_wert INTO x_lines-line+1.
            APPEND x_lines.
          ENDIF.
        ENDLOOP.

      ELSEIF x_lines-line CS 'SAP$=%DVS%'.  "User-Felder
        CLEAR x_lines-line.

**    New Modifications for drilling down ZCL_SL_TMP Details..start
**    Starts to process only it is a Special Document
**    i.e WA_TEST-KNZ_SPEZ_DOK is filled with some details.
      ELSEIF NOT ( wa_test-knz_spez_dok IS INITIAL ).
        IF tmp_flag IS INITIAL.
          IF wa_test-id_sl EQ space.
            CONCATENATE 'ID_SL =' wa_test-id_sl INTO x_lines-line+1.
            APPEND x_lines.

          ELSE.
            REFRESH it_sl_tmp.

*           Getting values from the table ZCL_SL_TMP for
*           the Spezial Documents.
            SELECT * FROM zcl_sl_tmp INTO TABLE it_sl_tmp
            WHERE id_sl = wa_test-id_sl AND uname = wa_test-uname.

            LOOP AT it_sl_tmp INTO wa_sl_tmp.

              CONCATENATE '<FIELD' wa_test-object_type INTO
                                x_lines-line+1 SEPARATED BY space .
              CONCATENATE x_lines-line '>' INTO x_lines-line.
              APPEND x_lines.

              MOVE wa_sl_tmp-stufe TO tmp_stufe.
              CONCATENATE 'STUFE =' tmp_stufe INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'OJTXB =' wa_sl_tmp-ojtxb INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'OBJECT_TYPE =' wa_test-object_type
                                             INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE '</FIELD' wa_test-object_type INTO
                                 x_lines-line+1 SEPARATED BY space .
              CONCATENATE x_lines-line '>' INTO x_lines-line.
              APPEND x_lines.

            ENDLOOP.

          ENDIF.
*          CONCATENATE 'OBJECT_TYPE =' wa_test-object_type
*                                             INTO x_lines-line+1.
*          APPEND x_lines.

          IF wa_test-knz_spez_dok = 'X'.
            MOVE 'KNZ_SPEZ_DOK =1' TO x_lines-line+1.
            APPEND x_lines.
          ELSE.
            MOVE 'KNZ_SPEZ_DOK =' TO x_lines-line+1.
            APPEND x_lines.
          ENDIF.

          CONCATENATE 'VORLAGE_L_AND_L =' wa_test-vorlage_l_and_l
                                             INTO x_lines-line+1.
          APPEND x_lines.

          tmp_flag = 'X'.

        ENDIF.
**    New Modifications for drilling down ZCL_SL_TMP Details..end
      ENDIF.
    ENDLOOP.

  ELSE.

    DATA : tmp_counter(2) TYPE c.

    lv_no_of_loops = i_end_page_no - i_start_page_no + 1.
    tmp_counter = i_start_page_no.

    DO lv_no_of_loops TIMES.

      CLEAR wa_rep_skel_lines .

      LOOP AT it_rep_skel_lines INTO wa_rep_skel_lines .
        MOVE wa_rep_skel_lines-line TO x_lines-line.

        IF x_lines-line CS '%NAMING%'.
          CLEAR ao_naming.
          CONCATENATE wa_test-dokar '/'
                      wa_test-doknr '/'
                      wa_test-dokvr '/'
                      wa_test-doktl  INTO ao_naming.
          REPLACE '%NAMING%' WITH ao_naming INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%PROJECT%'.
          IF ao_project = '-'.
            REPLACE '%PROJECT%' WITH text-058 INTO reproliste-line.
          ELSE.
            REPLACE '%PROJECT%' WITH ao_project INTO reproliste-line.
          ENDIF.

        ELSEIF x_lines-line CS 'AOFB'.
          APPEND x_lines.

        ELSEIF x_lines-line CS 'AOFE'.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%ERASE%'.
          REPLACE '%ERASE%' WITH i_delete_item INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%PATH%'.
          CONCATENATE 'AO$_PATH=' i_downloaded_path INTO x_lines-line+1.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%FORMAT%'.

          IF i_format_checking EQ space.
            REPLACE '%FORMAT%' WITH wa_test-format_ausgabe
                                              INTO x_lines-line.
            APPEND x_lines.
          ELSE.
          ENDIF.

        ELSEIF x_lines-line CS '%COPIES%'.
          CLEAR lv_no_copies.
          MOVE wa_test-kopien TO lv_no_copies.
          REPLACE '%COPIES%' WITH lv_no_copies INTO x_lines-line.
          APPEND x_lines.
          CLEAR lv_no_copies.

        ELSEIF x_lines-line CS '%PRINTMODE%'.

          IF lv_out_proc EQ 'X'.
            REPLACE '%PRINTMODE%' WITH ao_print INTO x_lines-line.
          ELSE.
            REPLACE '%PRINTMODE%' WITH '1' INTO x_lines-line.
          ENDIF.

          APPEND x_lines.

        ELSEIF x_lines-line CS '%NUMBER%'.
          REPLACE '%NUMBER%' WITH wa_test-doknr INTO x_lines-line.
          APPEND x_lines.
        ELSEIF x_lines-line CS '%APPLICATION%'.
          REPLACE '%APPLICATION%' WITH ao_appl INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%DELETE%'.
          REPLACE '%DELETE%' WITH i_delete_status INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%VIEWNAME%'.
          REPLACE '%VIEWNAME%' WITH ao_viewname INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%SAVECONVERTAS%'.
          REPLACE '%SAVECONVERTAS%' WITH ao_save INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%MULTIPAGE%'.
          IF wa_test-knz_multi_page IS INITIAL.
            REPLACE '%MULTIPAGE%' WITH '0' INTO x_lines-line.
          ELSE.
            REPLACE '%MULTIPAGE%' WITH '1' INTO x_lines-line.
          ENDIF.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%PAGE%'.
          REPLACE '%PAGE%' WITH tmp_counter INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '"%STEMPEL1%"'.
*          SHIFT wa_test-cont LEFT DELETING LEADING 0.
          SHIFT wa_test-cont LEFT DELETING LEADING '0'.

          LOOP AT itab_stamps INTO wa_stamps
                        WHERE zeile_plotjob = wa_test-cont.
            IF sy-subrc = 0.
              CONCATENATE wa_stamps-stempel_name ' = '
                  wa_stamps-stempel_wert INTO x_lines-line+1.
              APPEND x_lines.
            ENDIF.
          ENDLOOP.

        ELSEIF x_lines-line CS 'SAP$=%DVS%'.  "User-Felder
          CLEAR x_lines-line.

**    New Modifications for drilling down ZCL_SL_TMP Details..start
**    Starts to process only it is a Special Document
**    i.e WA_TEST-KNZ_SPEZ_DOK is filled with some details.
        ELSEIF NOT ( wa_test-knz_spez_dok IS INITIAL ).
          IF tmp_flag IS INITIAL.
            IF wa_test-id_sl EQ space.
              CONCATENATE 'ID_SL =' wa_test-id_sl INTO x_lines-line+1.
              APPEND x_lines.
            ELSE.
              REFRESH it_sl_tmp.

*             Getting values from the table ZCL_SL_TMP for
*             the Spezial Documents.
              SELECT * FROM zcl_sl_tmp INTO TABLE it_sl_tmp
              WHERE id_sl = wa_test-id_sl AND uname = wa_test-uname.

              LOOP AT it_sl_tmp INTO wa_sl_tmp.

                CONCATENATE '<FIELD' wa_test-object_type INTO
                                  x_lines-line+1 SEPARATED BY space .
                CONCATENATE x_lines-line '>' INTO x_lines-line.
                APPEND x_lines.

                MOVE wa_sl_tmp-stufe TO tmp_stufe.
                CONCATENATE 'STUFE =' tmp_stufe INTO x_lines-line+1.
                APPEND x_lines.

              CONCATENATE 'OJTXB =' wa_sl_tmp-ojtxb INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'OBJECT_TYPE =' wa_test-object_type
                                                   INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE '<FIELD' wa_test-object_type INTO
                                  x_lines-line+1 SEPARATED BY space .
                CONCATENATE x_lines-line '>' INTO x_lines-line.
                APPEND x_lines.

              ENDLOOP.
            ENDIF.

            IF wa_test-knz_spez_dok = 'X'.
              MOVE 'KNZ_SPEZ_DOK =1' TO x_lines-line+1.
              APPEND x_lines.
            ELSE.
              MOVE 'KNZ_SPEZ_DOK =' TO x_lines-line+1.
              APPEND x_lines.
            ENDIF.
            CONCATENATE 'VORLAGE_L_AND_L =' wa_test-vorlage_l_and_l
                                               INTO x_lines-line+1.
            APPEND x_lines.
            tmp_flag = 'X'.
          ENDIF.
**    New Modifications for drilling down ZCL_SL_TMP Details..end

        ENDIF.

      ENDLOOP.

      tmp_counter = tmp_counter + 1.

    ENDDO.
  ENDIF.

  e_last_path = i_last_path.

  LOOP AT x_lines.
    APPEND x_lines TO ot_rep_skel_lines.
  ENDLOOP.

  REFRESH x_lines.
  CLEAR x_lines.

ENDFUNCTION.
