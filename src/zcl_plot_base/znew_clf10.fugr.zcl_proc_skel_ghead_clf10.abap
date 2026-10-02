FUNCTION zcl_proc_skel_ghead_clf10.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PROCESS_CLF) TYPE  C OPTIONAL
*"     VALUE(WA_DRAW) LIKE  ZCL_S_PLOTLIST STRUCTURE  ZCL_S_PLOTLIST
*"       OPTIONAL
*"     VALUE(I_DELETE_ITEM) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_DELETE_STATUS) TYPE  CHAR1 OPTIONAL
*"  TABLES
*"      IT_GHEAD STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      OT_CLFLIST STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      IT_NOTIZ TYPE  /CIDEON/TTYPE_S_STEMPEL_WERT OPTIONAL
*"      IT_STAMPS TYPE  /CIDEON/TTYPE_S_STEMPEL_VALUE OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           Sriniva Mamillapalli
*
* Kontakt über:   https://service.cideon.com
*                 HELPDESK@CIDEON-SOFTWARE.DE
*-----------------------------------------------------------------------
* Journal
* 04.12.2003 - Änderungen grhhhhhhhhhh
* 18.04.2005 - AO$_MERGE = =0 / 1 / 2
*              kein / 1.Wert / letzter Wert
*              nur innerhalb der neuen CLF
* 10.01.2006 - AO$_JOBGUID
* 11.09.2006 - KNZ_CREATE_TOC
*            - KNZ_SEND_TOC
*            - EMAIL_TOC
* 29.11.2006 - Notiz Tabelle
* 08.02.2007 - Übergabe von Informationen für das Fax bei Lieferanten
*              LIF_TEL_NUMBER
*              LIF_TEL_EXTENS
*              LIF_TELNR_LONG
*              LIF_FAX_NUMBER
*              LIF_FAX_EXTENS
*              LIF_FAXNR_LONG
*              LIF_SMTP_ADDR
*              LIF_SMTP_SRCH
* 05.07.2007 - Änderungen für Übergabe Stempel
*              BADI
*              Übergabe der Stempelwerte des zuletzt bearbeiteten
*              Eintrages in dies globalen Werte
* SP 104
* 07.09.2009 - Satzanzahl in CLF
*              ZCL_PROC_SKEL_GHEAD_CLF10
*              Parameter DEFAULT_SATZ_ANZAHL
* SP 117
* 28.01.2010 - AO$_JOBCOUNT
*              Satzanzahl
*-----------------------------------------------------------------------
* Informationen
*
* für die Mitgabe von Informationen, wie Faxangabe des Empfängers aus
* der Bestellung etc. wird der letzte Datensatz in der Tabelle der
* Plotliste benutzt
*
*-----------------------------------------------------------------------
* to DO
*-----------------------------------------------------------------------

  DATA : wa_ghead TYPE zcl_s_line_256.
  DATA:  wa_ghead_tmp LIKE wa_ghead.

  DATA : ao_datum(10) TYPE c,
         ao_print TYPE c.

  DATA: wa_notiz TYPE zcl_stempel_wert.
  DATA: anzahl TYPE i.
  DATA: index TYPE i.
  DATA: str_tmp TYPE string.

  LOOP AT it_ghead INTO wa_ghead.

    MOVE wa_ghead TO ot_clflist.



    IF ot_clflist-line CS '%AO$_SENDER%'.
      REPLACE '%AO$_SENDER%' WITH sy-uname INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_DATE%'.
      WRITE sy-datum TO ao_datum DD/MM/YYYY.
      REPLACE '%AO$_DATE%' WITH ao_datum INTO ot_clflist-line.
      APPEND ot_clflist.

*   AO$_JOBGUID
    ELSEIF ot_clflist-line CS '%AO$_JOBGUID%'.
      REPLACE '%AO$_JOBGUID%' WITH wa_draw-id_plotjob_32
        INTO ot_clflist-line.
      APPEND ot_clflist.

*   KNZ_CREATE_TOC
    ELSEIF ot_clflist-line CS '%KNZ_CREATE_TOC%'.
      REPLACE '%KNZ_CREATE_TOC%' WITH wa_draw-knz_create_toc
        INTO ot_clflist-line.
      APPEND ot_clflist.

*   KNZ_SEND_TOC
    ELSEIF ot_clflist-line CS '%KNZ_SEND_TOC%'.
      REPLACE '%KNZ_SEND_TOC%' WITH wa_draw-knz_send_toc
        INTO ot_clflist-line.
      APPEND ot_clflist.

*   EMAIL_TOC
    ELSEIF ot_clflist-line CS '%EMAIL_TOC%'.
      REPLACE '%EMAIL_TOC%' WITH wa_draw-smtp_addr
        INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_COMISSION%'.
      REPLACE '%AO$_COMISSION%' WITH ' ' INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_COST%'.
      REPLACE '%AO$_COST%' WITH wa_draw-kostl INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_PROJECT%'.
      REPLACE '%AO$_PROJECT%' WITH wa_draw-pspid INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_MERGE%'.
      IF wa_draw-ao_merge IS INITIAL.
        wa_draw-ao_merge = '0'.
      ELSE.
      ENDIF.
      REPLACE '%AO$_MERGE%' WITH wa_draw-ao_merge
        INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_JOBNAME%'.
      REPLACE '%AO$_JOBNAME%' WITH wa_draw-id_plotjob
        INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_DISTRIBUTOR%'.
      REPLACE '%AO$_DISTRIBUTOR%' WITH wa_draw-verteiler
                                        INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_CLIENT%'.
      REPLACE '%AO$_CLIENT%' WITH wa_draw-firma INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_SEND%'.

      IF NOT ( i_process_clf IS INITIAL ).
        REPLACE '%AO$_SEND%' WITH '1' INTO ot_clflist-line.
      ELSE.
        REPLACE '%AO$_SEND%' WITH '0' INTO ot_clflist-line.
      ENDIF.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_ERASE%'.
      REPLACE '%AO$_ERASE%' WITH i_delete_item INTO ot_clflist-line.
      APPEND ot_clflist.

*   Copies / Satzanzahl
      " laut Info MZZ ist dieser Parameter möglicherweise nicht als
      " Satzanzahl zu verstehen ..

    ELSEIF ot_clflist-line CS '%AO$_COPIES%'.
      "REPLACE '%AO$_COPIES%' WITH '1' INTO ot_clflist-line.
      " 2009/09/07
      DATA: tmp_str TYPE string.
      CLEAR tmp_str.
      "tmp_str = wa_draw-satzanzahl .
      tmp_str = wa_draw-kopien.

      REPLACE '%AO$_COPIES%' WITH tmp_str INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_DELETE%'.
      REPLACE '%AO$_DELETE%' WITH i_delete_status INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSEIF ot_clflist-line CS '%AO$_PRINT%'.
      REPLACE '%AO$_PRINT%' WITH '0' INTO ot_clflist-line.
      APPEND ot_clflist.

    ELSE.
      APPEND ot_clflist.

    ENDIF.

  ENDLOOP.

* letzte Tabellenzeile holen und sichern
  CLEAR anzahl.
  DESCRIBE TABLE ot_clflist LINES anzahl.
  CLEAR wa_ghead.

  READ TABLE ot_clflist INTO wa_ghead INDEX anzahl.
  IF sy-subrc NE 0.
  ELSE.
    DELETE ot_clflist INDEX anzahl.
  ENDIF.

* Satzanzahl
* AO$_JOBCOUNT
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'AO$_JOBCOUNT'.
  CLEAR str_tmp.
  str_tmp = wa_draw-satzanzahl.
  CONCATENATE
    wa_ghead_tmp
    '=' str_tmp
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.


* Informationen über den Lieferanten für die Fax-Ausgabe
* LIF_TEL_NUMBER
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_TEL_NUMBER'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_tel_number
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.

* LIF_TEL_EXTENS
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_TEL_EXTENS'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_tel_extens
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.

* LIF_TELNR_LONG
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_TELNR_LONG'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_telnr_long
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.

* LIF_FAX_NUMBER
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_FAX_NUMBER'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_fax_number
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.

* LIF_FAX_EXTENS
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_FAX_EXTENS'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_fax_extens
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.

* LIF_FAXNR_LONG
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_FAXNR_LONG'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_faxnr_long
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.

* LIF_SMTP_ADDR
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_SMTP_ADDR'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_smtp_addr
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.

* LIF_SMTP_SRCH
  CLEAR wa_ghead_tmp.
  wa_ghead_tmp = 'LIF_SMTP_SRCH'.
  CONCATENATE
    wa_ghead_tmp
    '=' wa_draw-lif_smtp_srch
    INTO wa_ghead_tmp SEPARATED BY space.
  APPEND wa_ghead_tmp TO ot_clflist.


  APPEND wa_ghead TO ot_clflist.

* Integration der Notiztabelle
* letzte Tabellenzeile holen und sichern
  IF it_notiz[] IS INITIAL.
    "EXIT.
  ELSE.
  ENDIF.

  CLEAR anzahl.
  DESCRIBE TABLE ot_clflist LINES anzahl.
  CLEAR wa_ghead.

  READ TABLE ot_clflist INTO wa_ghead INDEX anzahl.
  IF sy-subrc NE 0.
  ELSE.
    DELETE ot_clflist INDEX anzahl.
  ENDIF.

  CLEAR wa_ghead_tmp.
  LOOP AT it_notiz INTO wa_notiz.
    index = sy-tabix.
    str_tmp = index.
    CONCATENATE text-200 '_' str_tmp
      INTO wa_ghead_tmp.
    CONCATENATE
      wa_ghead_tmp
      '=' wa_notiz
      INTO wa_ghead_tmp SEPARATED BY space.
    APPEND wa_ghead_tmp TO ot_clflist.
  ENDLOOP.


* Globalen Teil um Stempelwerte auffrischen
  DATA: wa_stamps TYPE zcl_s_stempel_value.
  LOOP AT it_stamps INTO wa_stamps
    WHERE zeile_plotjob = wa_draw-cont.
    CLEAR wa_ghead_tmp.

    CONCATENATE 'G_'
      wa_stamps-stempel_name
      INTO wa_ghead_tmp.
    CONCATENATE
      wa_ghead_tmp
      '=' wa_stamps-stempel_wert
      INTO wa_ghead_tmp SEPARATED BY space.
    APPEND wa_ghead_tmp TO ot_clflist.
  ENDLOOP.


* Abschlußzeichen wieder setzen
  APPEND wa_ghead TO ot_clflist.


* BADI Integration
* BADI
* /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  DATA: it TYPE /cideon/ttype_s_line_256.
  DATA: it2 TYPE /cideon/ttype_s_stempel_value.

  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CLEAR it.
    CLEAR it2.

    it[] = ot_clflist[].
    it2[] = it_stamps[].

    CALL METHOD badi_main_pre_001->chg_clf_ghead
      EXPORTING
        i_plotjob = wa_draw
      CHANGING
        it_ghead  = it "ot_clflist
        it_stamps = it2 "it_stamps
        .
    ot_clflist[] = it.
    it_stamps[] = it2[].

  ENDIF.


ENDFUNCTION.
