FUNCTION zcl_proc_skel_aofile_clf10.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(WA_DOC_FILES2) TYPE  BAPI_DOC_FILES2 OPTIONAL
*"     VALUE(LV_STRIPPED_NAME) TYPE  STRING OPTIONAL
*"     VALUE(WA_TEST) TYPE  ZCL_S_PLOTLIST OPTIONAL
*"     VALUE(RFC_DEST_PATH) TYPE  FILEP OPTIONAL
*"     VALUE(WA_COMPONENTS) TYPE  BAPI_DOC_COMP OPTIONAL
*"  TABLES
*"      IT_AOFILE STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      IT_AOFILE_CLF STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 04.12.2003 - Änderungen grhhhhhhhhhh
* 21.07.2006 - Anpassung auf REDLINE
* 31.08.2008 - AO$_PAGE

* 7.0.167.1
* 2013/05/27 SM 8000014441 - Rofin
* Dateipfad länger als 128 Zeichen
* FB ZCL_GET_DOC_CLF10_DETAIL_DLOAD
*
*-----------------------------------------------------------------------


  DATA : wa_aofile     TYPE zcl_s_line_256,
         wa_stamps     TYPE zcl_s_stempel_value.

  DATA : lv_doc_info(46) TYPE c.

  DATA: tmp_string(255).

  IF NOT ( wa_doc_files2-documenttype EQ space ).
    CONCATENATE wa_doc_files2-documenttype '/'
                wa_doc_files2-documentnumber '/'
                wa_doc_files2-documentversion '/'
                wa_doc_files2-documentpart '/'
                wa_doc_files2-originaltype '/'
                wa_doc_files2-wsapplication INTO lv_doc_info.
  ELSE.
    CONCATENATE wa_test-dokar '/'
                wa_test-doknr '/'
                wa_test-dokvr '/'
                wa_test-doktl '/'
                wa_test-wsapplication '/' INTO lv_doc_info.
  ENDIF.

  IF wa_test-knz_multi_page IS INITIAL .
*   Kennzeichen für Multipage setzen, falls eine bestimmte Seite
*   angefordert wird
    IF ( ( NOT ( wa_test-seite IS INITIAL ) )
       )
    AND ( wa_test-knz_multi_page IS INITIAL ).
      wa_test-knz_multi_page = 'X'.
    ELSE.
    ENDIF.
  ENDIF.

  LOOP AT it_aofile INTO wa_aofile.

    IF wa_aofile-line CS '<AOF <AO$_NAMING>>'.
      APPEND wa_aofile TO it_aofile_clf.

    ELSEIF wa_aofile-line CS '%AO$_PATH%'.

      IF rfc_dest_path IS INITIAL .
        REPLACE '%AO$_PATH%' WITH wa_doc_files2-docfile
                                        INTO wa_aofile-line.
      ELSE.
        REPLACE '%AO$_PATH%' WITH rfc_dest_path
                                        INTO wa_aofile-line.
      ENDIF.
      APPEND wa_aofile TO it_aofile_clf.

    ELSEIF wa_aofile-line CS '%AO$_FORMAT%'.
*      REPLACE '%AO$_FORMAT%' WITH 'A4' INTO wa_aofile-line.
      REPLACE '%AO$_FORMAT%' WITH wa_test-format_ausgabe
                                        INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

    ELSEIF wa_aofile-line CS '%AO$_NAMING%'.
      REPLACE '%AO$_NAMING%' WITH lv_stripped_name INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

    ELSEIF wa_aofile-line CS '%AO$_SHEET%'.
*      REPLACE '%AO$_SHEET%' WITH 'Blatt ACAD1' INTO wa_aofile-line.
      REPLACE '%AO$_SHEET%' WITH ' ' INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

    ELSEIF wa_aofile-line CS '%AO$_DOCINFO%'.
      REPLACE '%AO$_DOCINFO%' WITH lv_doc_info INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

*   Kopien
    ELSEIF wa_aofile-line CS '%AO$_COPIES%'.
      CLEAR tmp_string.
      tmp_string = wa_test-kopien.
      SHIFT tmp_string LEFT DELETING LEADING space.
      REPLACE '%AO$_COPIES%' WITH tmp_string
        INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

*   Projekt
    ELSEIF wa_aofile-line CS '%AO$_PROJECT%'.
      REPLACE '%AO$_PROJECT%' WITH ''
        INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

*   Kommision
    ELSEIF wa_aofile-line CS '%AO$_COMMISION%'.
      REPLACE '%AO$_COMMISION%' WITH ''
        INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

*   Nummer
    ELSEIF wa_aofile-line CS '%AO$_NUMBER%'.
      CLEAR tmp_string.
      CONCATENATE wa_test-dokar '/' wa_test-doknr '/'
        wa_test-doktl '/' wa_test-dokvr '/'
        INTO tmp_string.
      REPLACE '%AO$_NUMBER%' WITH tmp_string
        INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

*   Applikation
    ELSEIF wa_aofile-line CS '%AO$_APPLICATION%'.
      REPLACE '%AO$_APPLICATION%' WITH text-999
        INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

*   KNZ_MULTIPAGE
    ELSEIF wa_aofile-line CS '%AO$_MULTIPAGE%'.
      IF wa_test-knz_multi_page IS INITIAL.
        REPLACE '%AO$_MULTIPAGE%' WITH '0'
          INTO wa_aofile-line.
        APPEND wa_aofile TO it_aofile_clf.
      ELSE.
        REPLACE '%AO$_MULTIPAGE%' WITH '1'
          INTO wa_aofile-line.
        APPEND wa_aofile TO it_aofile_clf.
      ENDIF.

*   Komponenten / Redlining
*   SPSO_COMP
    ELSEIF wa_aofile-line CS '%SPSO_COMP%'.
      REPLACE '%SPSO_COMP%'
        WITH wa_components-docfile
        INTO wa_aofile-line.

      APPEND wa_aofile TO it_aofile_clf.

*   Seite
    ELSEIF wa_aofile-line CS '%AO$_PAGE%'.
*     CKR 31.08.2006
*     falls SEITE leer ist .....
*
      IF wa_test-seite IS INITIAL.
        wa_test-seite = wa_test-seite_von.
      ELSE.
      ENDIF.

      REPLACE '%AO$_PAGE%' WITH wa_test-seite
        INTO wa_aofile-line.
      APPEND wa_aofile TO it_aofile_clf.

    ELSEIF wa_aofile-line CS '</AOF>'.
      CLEAR wa_aofile.
*      SHIFT wa_test-cont LEFT DELETING LEADING 0.
      SHIFT wa_test-cont LEFT DELETING LEADING '0'.

      LOOP AT itab_stamps INTO wa_stamps
                    WHERE zeile_plotjob = wa_test-cont.
        IF sy-subrc = 0.
          CONCATENATE wa_stamps-stempel_name ' = '
              wa_stamps-stempel_wert INTO wa_aofile-line+9.
          APPEND wa_aofile TO it_aofile_clf.
        ENDIF.
      ENDLOOP.

      MOVE '</AOF>' TO wa_aofile-line+6.
      APPEND wa_aofile TO it_aofile_clf.

    ENDIF.

  ENDLOOP.

ENDFUNCTION.


*    SHIFT wa_test-cont LEFT DELETING LEADING 0.
*
*    LOOP AT itab_stamps INTO wa_stamps
*                  WHERE zeile_plotjob = wa_test-cont.
*      IF sy-subrc = 0.
*        CONCATENATE wa_stamps-stempel_name ' = '
*            wa_stamps-stempel_wert INTO x_lines-line+1.
*        APPEND x_lines.
*      ENDIF.
*    ENDLOOP.
