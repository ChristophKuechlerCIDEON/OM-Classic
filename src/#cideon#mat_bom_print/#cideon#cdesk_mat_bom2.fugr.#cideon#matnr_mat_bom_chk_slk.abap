FUNCTION /cideon/matnr_mat_bom_chk_slk.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(MATNR) TYPE  MARA-MATNR
*"     REFERENCE(BOM_PRINT) TYPE  /CIDEON/BOM_PRINT
*"  EXPORTING
*"     REFERENCE(RETURN) TYPE  BAPIRET2
*"     REFERENCE(AENNR) TYPE  DAENR
*"     REFERENCE(STLNR) TYPE  STNUM
*"  EXCEPTIONS
*"      NO_STKO
*"----------------------------------------------------------------------
*       CIDEON Software GmbH
*       Peterstraße 1
*       02826 Görlitz
*----------------------------------------------------------------------
*  Testen der Materialstückliste, ob diese im Gültikeitszeitraum liegt
*
*----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*-----------------------------------------------------------------------
* Journal
* 03.02.2006 - Erstellung
* 31.03.2006 - Rückgabe von AENNR und STLNR
*
**7.0.173.1
*2014/11/18 -
*2015/02/06 - B. Krone Anpassung der Recherche der Änderungsnummer zur Stückliste
*           FB /CIDEON/MATNR_MAT_BOM_CHK_SLK
*
*-----------------------------------------------------------------------

  DATA:
        ls_t001w TYPE t001w,
        ls_makt TYPE makt,
        lt_mastb TYPE TABLE OF mastb,
        lt_stkob TYPE TABLE OF stkob,
        lt_stzub TYPE TABLE OF stzub,
        ls_stkob TYPE stkob.

  DATA: wa_stko TYPE stkob.

  CLEAR lt_mastb.
  CLEAR lt_stkob.
  CLEAR lt_stzub.

  CALL FUNCTION 'CS_BOMHEADERS_GET_MAT'
    EXPORTING
      matnr           = matnr
      stlal           = bom_print-stlal
      stlan           = bom_print-stlan
      werks           = bom_print-werks
      datuv           = bom_print-datuv
    TABLES
      mastb_wa        = lt_mastb
      stkob_wa        = lt_stkob
      stzub_wa        = lt_stzub
    EXCEPTIONS
      call_invalid    = 1
      no_record_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ELSE.
  ENDIF.

* Leerer Stücklistenkopf deutet auf eine Stückliste, welche sich nicht
* innerhalb des Stücklistengültigkeitszeitraumes befindet
  IF lt_stkob[] IS INITIAL.
    RAISE no_stko.
  ELSE.
  ENDIF.

* gegebenenfalls noch genauer untersuchen

* Rückgabe soll nur erfolgen, wenn nicht schon vorgefüllt


* Rückgabe von AENNR und STLNR
  CLEAR wa_stko.
  LOOP AT lt_stkob INTO wa_stko.
  ENDLOOP.
  IF sy-subrc NE 0.
  ELSE.
    IF aennr IS INITIAL.
      aennr = wa_stko-aennr.
    ELSE.
    ENDIF.

    IF stlnr IS INITIAL.
      stlnr = wa_stko-stlnr.
    ELSE.
    ENDIF.
  ENDIF.

  " 2015/02/06
  " Check über neuen Funktionsbaustein
  " Standard FB hatte bei B. Krone Probleme mit der Recherche
  "
*02	Materialstückliste
*03	Equipmentstückliste
*04	Dokumentstückliste
*05	TechnischerPlatzStückliste
*06	Standardstückliste
*07	Kundenauftragsstückliste
*08	Projektstückliste

  "Änderungnummer für diese Materialstückliste
  "02
  DATA: lr_data       TYPE REF TO data.
  FIELD-SYMBOLS: <fs_data> TYPE ANY.

  DATA: ls_mast       TYPE mast,
        ls_dost       TYPE dost,
        ls_aenr       TYPE aenr,
        ls_doc_key    TYPE dms_doc_key.

  CREATE DATA lr_data TYPE mast.
  ASSIGN lr_data->* TO <fs_data>.



  CLEAR ls_aenr.

  CLEAR ls_mast.
  ls_mast-matnr = matnr.
  ls_mast-werks = bom_print-werks.
  ls_mast-stlan = bom_print-stlan.
  ls_mast-stlal = bom_print-stlal.

  DATA lc_datuv LIKE bom_print-datuv.
  CLEAR lc_datuv.
  lc_datuv = bom_print-datuv.
  IF lc_datuv IS INITIAL.
    lc_datuv = sy-datum.
  ELSE.
  ENDIF.

  <fs_data> = ls_mast.

  CALL FUNCTION '/CIDEON/_GET_AENR_4_OBJ_2_DATE'
    EXPORTING
      ic_aetyp                = '02'
      i_data                  = lr_data
      ic_datuv                = lc_datuv
*      ic_datuv = bom_print-datuv
    IMPORTING
      es_valid_changeno       = ls_aenr
    EXCEPTIONS
      type_not_found          = 1
      missing_object          = 2
      no_object_found         = 3
      no_valid_change_numbers = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    aennr = ls_aenr-aennr.
    "noch recherhieren
    CLEAR ls_mast.
    SELECT SINGLE * FROM mast INTO ls_mast
      WHERE
        matnr = matnr
      AND werks = bom_print-werks
      AND stlan = bom_print-stlan
      AND stlal = bom_print-stlal
      .
    IF sy-subrc NE 0.
    ELSE.
      stlnr = ls_mast-stlnr.
    ENDIF.

  ENDIF.



ENDFUNCTION.
