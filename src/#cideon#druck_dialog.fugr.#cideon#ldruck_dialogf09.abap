*---------------------------------------------------------------------*
*       FORM check_for_multipage                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_for_multipage.
*
*ITAB
  DATA: itab_page_format TYPE TABLE OF zcl_orig_format.
  DATA: itab_docs TYPE TABLE OF bapi_doc_files2.
*WA
  DATA: wa_page_format TYPE zcl_orig_format.
  DATA: wa_docs TYPE bapi_doc_files2.
* NORMAL
  DATA: lines TYPE i.

  REFRESH itab_tmp_plotjobs_3.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.

*   über BAPI_DOCUMENT_GET_DETAIL nachsehen, ob für die WSAPPL nur
*   ein Eintrag vorhanden ....
*   falls ja, dann diesen FILEP benutzen

    REFRESH itab_docs.

    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_plotjobs-dokar
        documentnumber             = wa_plotjobs-doknr
        documentpart               = wa_plotjobs-doktl
        documentversion            = wa_plotjobs-dokvr
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
        getactivefiles             = 'X'
*       GETCLASSIFICATION          = ' '
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
*     IMPORTING
*       DOCUMENTDATA               =
*       RETURN                     =
      TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
        documentfiles              = itab_docs
*       COMPONENTS                 =
*       CHARACTERISTICVALUES       =
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
              .
    DELETE itab_docs
      WHERE wsapplication <> wa_plotjobs-wsapplication
      .
    DESCRIBE TABLE itab_docs LINES lines.
    IF lines = 1.
    ELSE.
      APPEND wa_plotjobs TO itab_tmp_plotjobs_3.
      CONTINUE.
    ENDIF.

    READ TABLE itab_docs INTO wa_docs INDEX 1.

*   Check for existence
    SELECT SINGLE * FROM zcl_orig_format INTO wa_page_format
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      AND wsapplication = wa_plotjobs-wsapplication
      AND docfile  = wa_docs-docfile
        "wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    IF sy-subrc NE 0.
      APPEND wa_plotjobs TO itab_tmp_plotjobs_3.
      CONTINUE.
    ELSE.
    ENDIF.

    REFRESH itab_page_format.
*   get the intervals
    SELECT * FROM zcl_orig_format INTO TABLE itab_page_format
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      AND wsapplication = wa_plotjobs-wsapplication
      AND docfile  = wa_docs-docfile
        "wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

    LOOP AT itab_page_format INTO wa_page_format.
      wa_plotjobs-knz_multi_page = 'X'.
      wa_plotjobs-seite_von = wa_page_format-pagefrom.
      wa_plotjobs-seite_bis = wa_page_format-pageto.
      wa_plotjobs-format_ausgabe = wa_page_format-pageformat.
      APPEND wa_plotjobs TO itab_tmp_plotjobs_3.
    ENDLOOP.


  ENDLOOP.

  REFRESH itab_tmp_plotjobs.
  LOOP AT itab_tmp_plotjobs_3 INTO wa_plotjobs.
    APPEND wa_plotjobs TO itab_tmp_plotjobs.
  ENDLOOP.

  REFRESH itab_tmp_plotjobs_3.

ENDFORM.                    " check_for_multipage
