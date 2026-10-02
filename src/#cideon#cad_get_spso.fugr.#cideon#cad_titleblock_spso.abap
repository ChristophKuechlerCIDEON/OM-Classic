FUNCTION /cideon/cad_titleblock_spso.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(E_RETURN) LIKE  CAD_RETURN-VALUE
*"     REFERENCE(E_MESSAGE) LIKE  MESSAGE-MSGTX
*"  TABLES
*"      IMPORT_DATA STRUCTURE  RFCDMSDATA
*"      OBJECTLINKS STRUCTURE  BAPI_DOC_DRAD
*"      DOCUMENTDESCRIPTIONS STRUCTURE  BAPI_DOC_DRAT
*"      LONGTEXTS STRUCTURE  BAPI_DOC_TEXT
*"      STATUSLOG STRUCTURE  CAD_DOC_DRAP
*"      CLASS_DATA STRUCTURE  CLS_CHARAC
*"      EXPORT_DATA STRUCTURE  RFCDMSDATA
*"      USER_DATA STRUCTURE  RFCDMSDATA
*"  CHANGING
*"     REFERENCE(DOCUMENTDATA) LIKE  BAPI_DOC_DRAW STRUCTURE
*"        BAPI_DOC_DRAW
*"     REFERENCE(ECMDATA) LIKE  AENR_API02 STRUCTURE  AENR_API02
*"----------------------------------------------------------------------

************************************************************************
* CIDEON
* Lesen von Stempelfeldern und Mitgabe über Zeichnungskopf EXIT
*-----------------------------------------------------------------------
* Author :
*          Christoph Küchler
*          chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 13.02.2006 - Erstellung
************************************************************************

* WA
  DATA: default_data TYPE /cideon/plot_defaultdata. "t_defaultdata.
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: wa_tdwst TYPE tdwst.

*ITAB
  DATA: itab_plotjobs TYPE TABLE OF  zcl_s_plotlist.
  DATA: itab_stempel_wert TYPE TABLE OF zcl_s_stempel_value.


  DATA: itab_aenr TYPE TABLE OF aenr.
  DATA: wa_aenr TYPE aenr.
  DATA: itab_draw TYPE TABLE OF draw.
  DATA: wa_draw TYPE draw.
  DATA: max_aennr TYPE i.
  DATA: delta_aennr TYPE i.
  DATA: count TYPE i.
  DATA: tmp_str TYPE char40.
  DATA: tmp_char.


*Bsp.
*  wa_user_data-fieldmulti = 'STMP_PT_ZAEHLER'.
*  wa_user_data-fieldname = '='.
*  wa_user_data-fieldvalue = tmp_str.

  CLEAR default_data.

  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
*DATA: tmp_str(255).

* DEFAULT_NUTZER
  CLEAR tmp_str.
  pname = 'DEFAULT_NUTZER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_nutzer = 'SAP*'.
  ELSE.
    default_data-default_nutzer = tmp_str.
  ENDIF.


* WA mappen
  CLEAR wa_plotjob.
  MOVE-CORRESPONDING documentdata TO wa_plotjob.
  wa_plotjob-dokar =  documentdata-documenttype.
  wa_plotjob-doknr = documentdata-documentnumber.
  wa_plotjob-dokvr = documentdata-documentversion.
  wa_plotjob-doktl = documentdata-documentpart.


* Konvertierung in internes Format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
            input  = wa_plotjob-doknr
       IMPORTING
            output = wa_plotjob-doknr.


  wa_plotjob-stabk = documentdata-statusextern.
  wa_plotjob-dokst = documentdata-statusintern.

*Statustext DOSTX
* ergänzt STABK / Sprachabhängige Stati
*DATA: wa_tdwst TYPE tdwst.

  SELECT SINGLE * FROM tdwst INTO wa_tdwst
    WHERE  cvlang = sy-langu
    AND dokst = wa_plotjob-dokst
    .
  IF sy-subrc NE 0.
  ELSE.
    wa_plotjob-stabk = wa_tdwst-stabk.
    wa_plotjob-dostx = wa_tdwst-dostx.
  ENDIF.

*Objectkey
  CALL FUNCTION 'Z_CL_MAKE_OBJECT_KEY'
       EXPORTING
            i_dokar = wa_plotjob-dokar
            i_doknr = wa_plotjob-doknr
            i_dokvr = wa_plotjob-dokvr
            i_doktl = wa_plotjob-doktl
       IMPORTING
            o_objky = wa_plotjob-objky
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  APPEND wa_plotjob TO itab_plotjobs.

* Stamps
  CALL FUNCTION '/CIDEON/GET_STAMP_DATA'
       EXPORTING
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_plotjobs
            o_itab_stamp_data = itab_stempel_wert
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Class
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
            i_itab_plotjobs   = itab_plotjobs
            o_itab_class_data = itab_class_data
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Anhängen, dann Sortieren
  LOOP AT itab_class_data INTO wa_class_data.
    CLEAR wa_stempel_wert.
    MOVE-CORRESPONDING wa_class_data TO wa_stempel_wert.
    APPEND wa_stempel_wert TO itab_stempel_wert.
  ENDLOOP.

  SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.


* result Stamps
* besorgt die resultierenden Stempeldaten, welche aus den normalen
* Stempelwerten und den Klassifizierungswerten gebildet werden können

  DATA: itab_res_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: wa_res_data TYPE zcl_s_stempel_value.

  CALL FUNCTION '/CIDEON/GET_RESULT_STAMP_DATA'
       EXPORTING
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_plotjobs
            i_itab_stamp_data = itab_stempel_wert
            o_itab_stamp_data = itab_res_data
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Anhängen, dann Sortieren
  LOOP AT itab_res_data INTO wa_res_data.
    CLEAR wa_stempel_wert.
    MOVE-CORRESPONDING wa_res_data TO wa_stempel_wert.
    APPEND wa_stempel_wert TO itab_stempel_wert.
  ENDLOOP.

  SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.


*Stempeltabellenform erstellen
  CLEAR wa_stempel_wert.
  LOOP AT itab_stempel_wert INTO wa_stempel_wert.
    user_data-fieldmulti = wa_stempel_wert-stempel_name.
    user_data-fieldname = '='.
    user_data-fieldvalue = wa_stempel_wert-stempel_wert.

    APPEND user_data.

  ENDLOOP.

ENDFUNCTION.
