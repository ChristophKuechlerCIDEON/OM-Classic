FUNCTION /cideon/plot_va_rvador01.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_RESULT) TYPE  ITCPP
*"     VALUE(I_VBDKA) TYPE  VBDKA
*"  TABLES
*"      LT_VBDPA STRUCTURE  VBDPA
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
************************************************************************
*        Druckroutinen für Verkaufsbelege                              *
************************************************************************
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:

*-----------------------------------------------------------------------
* Journal
* 26.04.2007 - SP 36
*            - Erstellung / Kopie
* 27.04.2007 - Weiterführung
* 01.08.2007 - SP 44
*              Übergabe der Position des Verkaufsbeleges
* 21.01.2008 - SP 62
*              BADI Implementierungen
*-----------------------------------------------------------------------
* toDo
* BADI integrieren

*-----------------------------------------------------------------------
*WA
  DATA: wa_default_data TYPE /cideon/plot_defaultdata.
  DATA: wa_user_data TYPE /cideon/plot_userdata.

  DATA: wa_item TYPE zcl_pdm_objects_fa_int.
  DATA: itab_item TYPE TABLE OF zcl_pdm_objects_fa_int.

  DATA: exit_pre TYPE REF TO /cideon/if_ex_pre_main_001.

  DATA: wa_vbdpa TYPE vbdpa.

* Daten übergeben
  CLEAR wa_item.
  CLEAR itab_item.

* BADI Integrieren

  CLEAR exit_pre.
  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = exit_pre.


* Einstellungen lesen
  CLEAR wa_user_data.
  CLEAR wa_default_data.


  DATA: f_batch.
  IF sy-cprog = 'RSM13000'.
    f_batch = 'X'.
  ELSE.
  ENDIF.

  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = f_batch
       IMPORTING
            o_default_data = wa_default_data.


  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = wa_default_data
            i_batch        = sy-batch
       IMPORTING
            o_user_data    = wa_user_data.

* Übergabe der Spool ID
* TDSPOOLID
  CLEAR wa_item.

  wa_item-tdspoolid = i_result-tdspoolid.
  wa_item-tcode = '/CIDEON/PLOT_VA_RVADOR01'.

* weitere Übergabe von Werten notwendig
* VBELN, Kreditor, etc.
* Name Adresse muß noch folgen ...


  wa_item-vbeln = i_vbdka-vbeln.

  wa_item-verteiler = wa_user_data-default_verteiler_vbeln.




  APPEND wa_item TO itab_item.



  CALL FUNCTION 'Z_CL_INT_WRITE_PLOT_PSB_SPOOL'
* EXPORTING
*   F_AUT_PROCESS       = 'X'
    TABLES
      i_itab_items        = itab_item
    EXCEPTIONS
      error               = 1
      OTHERS              = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Bearbeitung der weiteren Dokumente
* Dokumente zu
*  - Position
*  - Material
*  - Materialposition innerhalb der Stückliste

  CLEAR itab_item.

  LOOP AT lt_vbdpa INTO wa_vbdpa.
* Dokumente zur Position
* Verknüpfung VBAP
    DATA: it_drad TYPE TABLE OF drad.
    DATA: wa_drad TYPE drad.
    DATA: drad_objky TYPE drad-objky.

    IF wa_user_data-knz_vbeln_pos IS INITIAL.
    ELSE.
*     Lesen der Dokumentverknüpfungen
      CLEAR it_drad.
      CLEAR drad_objky.

      CONCATENATE
        i_vbdka-vbeln wa_vbdpa-posnr
        INTO drad_objky.

      SELECT * FROM drad INTO TABLE it_drad
        WHERE dokob = 'VBAP'
        AND objky = drad_objky
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT it_drad INTO wa_drad.
        CLEAR wa_item.

        wa_item-vbeln = i_vbdka-vbeln.
        wa_item-tcode = '/CIDEON/PLOT_VA_RVADOR01'.

        wa_item-verteiler = wa_user_data-default_verteiler_vbeln.

        wa_item-dokar = wa_drad-dokar.
        wa_item-doknr = wa_drad-doknr.
        wa_item-doktl = wa_drad-doktl.
        wa_item-dokvr = wa_drad-dokvr.

*       Verkaufsbelegposition ergänzen
        wa_item-posnr = wa_vbdpa-posnr.


*       Materialnummer übergeben
        wa_item-matnr = wa_vbdpa-matnr.

        IF exit_pre IS INITIAL.
        ELSE.
          CALL METHOD exit_pre->chg_sd_doc_vbelnp
            CHANGING
              wa_item = wa_item
              .
        ENDIF.

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

        APPEND wa_item TO itab_item.
      ENDLOOP.


    ENDIF.

* Dokumente zum Material der Position
    IF wa_user_data-knz_vbeln_mat IS INITIAL.
    ELSE.
      CLEAR it_drad.
      CLEAR drad_objky.

      drad_objky = wa_vbdpa-matnr.

      SELECT * FROM drad INTO TABLE it_drad
        WHERE dokob = 'MARA'
        AND objky = drad_objky
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT it_drad INTO wa_drad.
        CLEAR wa_item.

        wa_item-vbeln = i_vbdka-vbeln.
        wa_item-tcode = '/CIDEON/PLOT_VA_RVADOR01'.

        wa_item-verteiler = wa_user_data-default_verteiler_vbeln.

        wa_item-dokar = wa_drad-dokar.
        wa_item-doknr = wa_drad-doknr.
        wa_item-doktl = wa_drad-doktl.
        wa_item-dokvr = wa_drad-dokvr.

*       Nummer der Verkaufsbelegposition
*       Verkaufsbelegposition ergänzen
        wa_item-posnr = wa_vbdpa-posnr.



*       Materialnummer übergeben
        wa_item-matnr = wa_vbdpa-matnr.

        IF exit_pre IS INITIAL.
        ELSE.
          CALL METHOD exit_pre->chg_sd_doc_mat_vbelnp
            CHANGING
              wa_item = wa_item
              .
        ENDIF.

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

        APPEND wa_item TO itab_item.
      ENDLOOP.

    ENDIF.


* Dokumente zu dem Position der aufgelösten Stückliste
    IF wa_user_data-knz_vbeln_bom IS INITIAL.
    ELSE.
      IF exit_pre IS INITIAL.
      ELSE.
        CALL METHOD exit_pre->chg_sd_doc_matpos_vbelnp
        CHANGING
          wa_item = wa_item
          .

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.
      ENDIF.

    ENDIF.

* Dialogeinträge
*   spezielles Dokument für Aufruf des Dialoges
*   zur Auswahl der zu druckenden Dokumente
*   siehe Plotservices
    IF wa_user_data-knz_vbeln_dialog IS INITIAL.
    ELSE.
      IF exit_pre IS INITIAL.
      ELSE.
        CALL METHOD exit_pre->chg_sd_doc_dialog_vbelnp
          CHANGING
            wa_item = wa_item
            .

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.







* Schreiben der Einträge in Übergabetabelle
  CALL FUNCTION 'Z_CL_INT_WRITE_PLOT_PSB_NO_STR'
       EXPORTING
            f_aut_process = ''
       TABLES
            i_itab_items  = itab_item
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.

* Rückmeldung per Expressmail
  IF wa_user_data-knz_vbeln_expressmail = 'X'.
    CALL FUNCTION '/CIDEON/SEND_MAIL_VBELN_PLOT'
         EXPORTING
              i_user   = sy-uname
              i_vbdka  = i_vbdka
         TABLES
              lt_vbdpa = lt_vbdpa
         EXCEPTIONS
              error    = 1
              OTHERS   = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


  ELSE.
  ENDIF.


ENDFUNCTION.
