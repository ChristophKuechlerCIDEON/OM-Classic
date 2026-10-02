FUNCTION /cideon/make_send_log_entries.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_MSGID) TYPE  SYMSGID
*"     VALUE(I_MSGNO) TYPE  SYMSGNO
*"  TABLES
*"      I_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   - erstellt Einträge im Applikation LOG
*   - 'ZCL_PLINT_MESSAGE_01'
*-----------------------------------------------------------------------
* Journal
* 24.06.2003
* 22.11.2004 - Eintragung für Verteiler
*              Eintragung in LOG Tabelle /CIDEON/PL_LOG
* 10.05.2005 - MATNR
* 10.01.2006 - LOG ID dem Ploteintrag mitgeben
* 13.11.2006 - SP 56
*              BADI Integration
*-----------------------------------------------------------------------

* ITAB
  DATA: itab_tmp_plotjobs TYPE TABLE OF zcl_s_plotlist.
* WA
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
  DATA: wa_pl_log TYPE /cideon/pl_log.
  DATA: wa_pl_log2 TYPE /cideon/pl_log2.

* Normal
  DATA: text1 TYPE symsgv.
  DATA: text2 TYPE symsgv.
  DATA: text3 TYPE symsgv.
  DATA: text4 TYPE symsgv.
  DATA: f_new_head TYPE c.
  DATA: f_first TYPE c.
  DATA: c_2(2).
  DATA: id_plot_log TYPE /cideon/pl_log-id.
  DATA: index TYPE i.

*  BADI
* /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  itab_tmp_plotjobs[] = i_itab_plotjobs[].

* Eintrag in Plot LOG / Audit Trail
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    index = sy-tabix.
    CLEAR wa_pl_log.
    MOVE-CORRESPONDING wa_plotjobs TO wa_pl_log.
    wa_pl_log-zclinsname = sy-uname.
    wa_pl_log-zclinsdate = sy-datum.
    wa_pl_log-zclinstime = sy-uzeit.
    wa_pl_log-zclinsprog = '/CIDEON/MAKE_SEND_LOG_ENTRIES'.
    wa_pl_log-zclupdname = sy-uname.
    wa_pl_log-zclupddate = sy-datum.
    wa_pl_log-zclupdtime = sy-uzeit.
    wa_pl_log-zclupdprog = '/CIDEON/MAKE_SEND_LOG_ENTRIES'.

    wa_pl_log-status = c_plot_log_entry_created.

    CALL FUNCTION '/CIDEON/ID_PL_LOG_GET_NEXT'
         EXPORTING
              i_numrange_object   = '/CIDEON/PL'
              i_numrange_interval = '01'
         IMPORTING
              e_number            = id_plot_log.

    wa_pl_log-id = id_plot_log.

    CLEAR wa_pl_log2.
    MOVE-CORRESPONDING wa_plotjobs TO wa_pl_log2.
    MOVE-CORRESPONDING wa_pl_log TO wa_pl_log2.

*   BADI
    IF badi_main_pre_001 IS INITIAL.
    ELSE.
      CALL METHOD badi_main_pre_001->chg_log_at_log
        CHANGING
          plot_item = wa_plotjobs
          log_item  = wa_pl_log
          log_item_2   = wa_pl_log2
          .

    ENDIF.

    MODIFY /cideon/pl_log FROM wa_pl_log.
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    MODIFY /cideon/pl_log2 FROM wa_pl_log2.
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

*   ID des LOG wegspeichern
    wa_plotjobs-id_plotlog = id_plot_log.

    MODIFY itab_tmp_plotjobs
      FROM wa_plotjobs
      INDEX index.
  ENDLOOP.

  f_first = 'X'.
  CLEAR f_new_head.
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    CLEAR text1.
    CLEAR text2.
    CLEAR text3.
    CLEAR text4.

    IF NOT f_first IS INITIAL.
      f_new_head = 'X'.
    ELSE.
      CLEAR f_new_head.
    ENDIF.

    IF f_first = 'X'.
*   Mitloggen des Nutzers und des PreProcessors
      CONCATENATE wa_plotjobs-verteiler ''
        INTO text1.
      text2 = sy-uname.

      CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
           EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = i_msgno
                i_msgtyp   = 'I'
                i_msgid    = 'ZCL_PLINT_MESSAGE_01'
                i_msgno    = 102
                i_msgv1    = text1
                i_msgv2    = text2
                i_msgv3    = text3
                i_msgv4    = text4
                i_class    = ' '
                i_newhead  = f_new_head
                i_messhead = 'X'
           EXCEPTIONS
                error      = 1
                OTHERS     = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      CLEAR f_new_head.
    ELSE.
    ENDIF.


    CONCATENATE wa_plotjobs-dokar wa_plotjobs-doknr wa_plotjobs-dokvr
      wa_plotjobs-doktl INTO text1.
    text2 = wa_plotjobs-filep.

    CLEAR c_2.
    c_2 = wa_plotjobs-kopien.
    CONCATENATE  c_2 text-001
      INTO text3.
*    IF NOT f_first IS INITIAL.
*      f_new_head = 'X'.
*    ELSE.
*      CLEAR f_new_head.
*    ENDIF.


    CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
         EXPORTING
              i_object   = 'Z_CIDEON'
              i_subobj   = 'Z_PLOT'
              i_number   = i_msgno
              i_msgtyp   = 'I'
              i_msgid    = i_msgid
              i_msgno    = i_msgno
              i_msgv1    = text1
              i_msgv2    = text2
              i_msgv3    = text3
              i_msgv4    = text4
              i_class    = ' '
              i_newhead  = f_new_head
              i_messhead = 'X'
         EXCEPTIONS
              error      = 1
              OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR f_first.

  ENDLOOP.


  COMMIT WORK AND WAIT.

* Rückgabe der Werte
  i_itab_plotjobs[] = itab_tmp_plotjobs[].


ENDFUNCTION.
