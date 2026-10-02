*----------------------------------------------------------------------*
***INCLUDE ZCL_CALL_PLOT_AT_STATUS_INC001.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALL_CONV_AT_S1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form call_conv_at_s1.
  data: documentdata type bapi_doc_draw2.
  data: documentdatax type bapi_doc_drawx2.
  data: return type bapiret2.
  data: ret type i.
* innerhalb der Struktur DRAW sind die Dokumenteninformationen
* gespeichert

* Test auf zugelassene Dokumentenart D10
  if draw-dokar = 'D10'.
  else.
*   Nachfolgestatus setzen
*   S1 -> PT
*   keine Bestempelung

*   Eintrag in Tabelle vornehmen
    data: wa_css_job  type /cideon/css_job.

    clear wa_css_job.
    move-corresponding draw to wa_css_job.

    wa_css_job-dokst = 'S1'.
    wa_css_job-statusintern = 'PT'.
    wa_css_job-statusextern = 'PT'.

    wa_css_job-zclinsname = sy-uname.
    wa_css_job-zclinsdate = sy-datum.
    wa_css_job-zclinstime = sy-uzeit.
    wa_css_job-zclinsprog = 'ZCL_CALL_PLOT_AT_STATUS_INC001'.
    wa_css_job-zclupdname = sy-uname.
    wa_css_job-zclupddate = sy-datum.
    wa_css_job-zclupdtime = sy-uzeit.
    wa_css_job-zclupdprog = 'ZCL_CALL_PLOT_AT_STATUS_INC001'.

    insert into /cideon/css_job values wa_css_job.
    if sy-subrc ne 0.
    else.
    endif.


*   Job anstoßen lassen, da innerhalb dieser Verarbeitung
*   kein Status gesetzt werden kann !!!!!
    data: jobcount type tbtcjob-jobcount.
    data: jobname type tbtcjob-jobname.
    data: report type sy-repid.

    data: sdlstrtdt like  tbtcjob-sdlstrtdt.
    data: sdlstrttm like  tbtcjob-sdlstrttm.
    data: laststrtdt like  tbtcjob-laststrtdt.
    data: laststrttm like  tbtcjob-laststrttm.

*   Startdatum festsetzen
    sdlstrtdt = sy-datum.
    sdlstrttm = sy-uzeit + 100.

*    laststrtdt = sy-datum.
*    laststrttm = sy-uzeit + 3000.

    clear jobcount.
    clear jobname.
    clear report.
    jobname = 'S1->PT'.
    report = '/CIDEON/PROCESS_WORK_ENTRY_CSS'.

    clear return.
    call function 'JOB_OPEN'
      exporting
*       DELANFREP              = ' '
*       JOBGROUP               = ' '
        jobname                = jobname
*       SDLSTRTDT              = NO_DATE
*       SDLSTRTTM              = NO_TIME
*       JOBCLASS               =
      importing
        jobcount               = jobcount
      changing
        ret                    = ret
      exceptions
        cant_create_job        = 1
        invalid_job_data       = 2
        jobname_missing        = 3
        others                 = 4
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      message w500(26) with
        text-001 text-002 'Program: ZMIKRON1'.
      exit.
    else.
    endif.

    clear return.
    call function 'JOB_SUBMIT'
      exporting
*       ARCPARAMS                         =
        authcknam                         = sy-uname
*       COMMANDNAME                       = ' '
*       OPERATINGSYSTEM                   = ' '
*       EXTPGM_NAME                       = ' '
*       EXTPGM_PARAM                      = ' '
*       EXTPGM_SET_TRACE_ON               = ' '
*       EXTPGM_STDERR_IN_JOBLOG           = 'X'
*       EXTPGM_STDOUT_IN_JOBLOG           = 'X'
*       EXTPGM_SYSTEM                     = ' '
*       EXTPGM_RFCDEST                    = ' '
*       EXTPGM_WAIT_FOR_TERMINATION       = 'X'
        jobcount                          = jobcount
        jobname                           = jobname
*       LANGUAGE                          = SY-LANGU
*       PRIPARAMS                         = ' '
        report                            = report
*       VARIANT                           = ' '
*     IMPORTING
*       STEP_NUMBER                       =
      exceptions
        bad_priparams                     = 1
        bad_xpgflags                      = 2
        invalid_jobdata                   = 3
        jobname_missing                   = 4
        job_notex                         = 5
        job_submit_failed                 = 6
        lock_failed                       = 7
        program_missing                   = 8
        prog_abap_and_extpg_set           = 9
        others                            = 10
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      message w500(26) with
        text-003 text-002 'Program: ZMIKRON1'.
      exit.
    else.
    endif.

    clear return.
    call function 'JOB_CLOSE'
      exporting
*       AT_OPMODE                         = ' '
*       AT_OPMODE_PERIODIC                = ' '
*       CALENDAR_ID                       = ' '
*       EVENT_ID                          = ' '
*       EVENT_PARAM                       = ' '
*       EVENT_PERIODIC                    = ' '
        jobcount                          = jobcount
        jobname                           = jobname
*        laststrtdt                        = laststrtdt
*        laststrttm                        = laststrttm
*       PRDDAYS                           = 0
*       PRDHOURS                          = 0
*       PRDMINS                           = 0
*       PRDMONTHS                         = 0
*       PRDWEEKS                          = 0
*       PREDJOB_CHECKSTAT                 = ' '
*       PRED_JOBCOUNT                     = ' '
*       PRED_JOBNAME                      = ' '
        sdlstrtdt                         = sdlstrtdt
        sdlstrttm                         = sdlstrttm
*       STARTDATE_RESTRICTION             = BTC_PROCESS_ALWAYS
*       STRTIMMED                         = ' '
*       TARGETSYSTEM                      = ' '
*       START_ON_WORKDAY_NOT_BEFORE       = SY-DATUM
*       START_ON_WORKDAY_NR               = 0
*       WORKDAY_COUNT_DIRECTION           = 0
*       RECIPIENT_OBJ                     =
*       TARGETSERVER                      = ' '
*       DONT_RELEASE                      = ' '
*       DIRECT_START                      =
*     IMPORTING
*       JOB_WAS_RELEASED                  =
      changing
        ret                               = ret
      exceptions
        cant_start_immediate              = 1
        invalid_startdate                 = 2
        jobname_missing                   = 3
        job_close_failed                  = 4
        job_nosteps                       = 5
        job_notex                         = 6
        lock_failed                       = 7
        others                            = 8
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      message w500(26) with
        text-005 text-002 'Program: ZMIKRON1'.
      exit.
    else.
    endif.

    exit.
  endif.

* Test auf zugelassene Dokumentenart D10
  if draw-dokar = 'D10'.
  else.
    exit.
  endif.

* Aufruf der Konvertierung mit den Dokumenteninformationen
* Transaktion "CONV01" mit DIS Schlüsseln und Status S1 / S2
  data: wa_draw type draw.

  wa_draw = draw.

  submit conv_convert_document
    with dokar eq wa_draw-dokar
    with doknr eq wa_draw-doknr
    with doktl eq wa_draw-doktl
    with dokvr eq wa_draw-dokvr
*    WITH dokst EQ wa_draw-dokst
    with wsappl = 'TIF'
    with convers = 'TIFF nach TIFF bei D10 bei S1 / S2'
    and return
    .

endform.                    " CALL_CONV_AT_S1
*&---------------------------------------------------------------------*
*&      Form  call_conv_at_s2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form call_conv_at_s2.
  data: documentdata type bapi_doc_draw2.
  data: documentdatax type bapi_doc_drawx2.
  data: return type bapiret2.
  data: ret type i.

* innerhalb der Struktur DRAW sind die Dokumenteninformationen
* gespeichert

* Test auf zugelassene Dokumentenart D10
  if draw-dokar = 'D10'.
  else.
*   Nachfolgestatus setzen
*   S2 -> FR
*   keine Bestempelung

*   Eintrag in Tabelle vornehmen
    data: wa_css_job  type /cideon/css_job.

    clear wa_css_job.
    move-corresponding draw to wa_css_job.

    wa_css_job-dokst = 'S2'.
    wa_css_job-statusintern = 'FR'.
    wa_css_job-statusextern = 'FR'.

    wa_css_job-zclinsname = sy-uname.
    wa_css_job-zclinsdate = sy-datum.
    wa_css_job-zclinstime = sy-uzeit.
    wa_css_job-zclinsprog = 'ZCL_CALL_PLOT_AT_STATUS_INC001'.
    wa_css_job-zclupdname = sy-uname.
    wa_css_job-zclupddate = sy-datum.
    wa_css_job-zclupdtime = sy-uzeit.
    wa_css_job-zclupdprog = 'ZCL_CALL_PLOT_AT_STATUS_INC001'.


    insert into /cideon/css_job values wa_css_job.
    if sy-subrc ne 0.
    else.
    endif.


*   Job anstoßen lassen, da innerhalb dieser Verarbeitung
*   kein Status gesetzt werden kann !!!!!
    data: jobcount type tbtcjob-jobcount.
    data: jobname type tbtcjob-jobname.
    data: report type sy-repid.

    data: sdlstrtdt like  tbtcjob-sdlstrtdt.
    data: sdlstrttm like  tbtcjob-sdlstrttm.
    data: laststrtdt like  tbtcjob-laststrtdt.
    data: laststrttm like  tbtcjob-laststrttm.

*   Startdatum festsetzen
    sdlstrtdt = sy-datum.
    sdlstrttm = sy-uzeit + 100.

*    laststrtdt = sy-datum.
*    laststrttm = sy-uzeit + 3000.

    clear jobcount.
    clear jobname.
    clear report.
    jobname = 'S2->FR'.
    report = '/CIDEON/PROCESS_WORK_ENTRY_CSS'.

    clear return.
    call function 'JOB_OPEN'
      exporting
*       DELANFREP              = ' '
*       JOBGROUP               = ' '
        jobname                = jobname
*       SDLSTRTDT              = NO_DATE
*       SDLSTRTTM              = NO_TIME
*       JOBCLASS               =
      importing
        jobcount               = jobcount
      changing
        ret                    = ret
      exceptions
        cant_create_job        = 1
        invalid_job_data       = 2
        jobname_missing        = 3
        others                 = 4
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      message w500(26) with
        text-001 text-002 'Program: ZMIKRON1'.
      exit.
    else.
    endif.

    clear return.
    call function 'JOB_SUBMIT'
      exporting
*       ARCPARAMS                         =
        authcknam                         = sy-uname
*       COMMANDNAME                       = ' '
*       OPERATINGSYSTEM                   = ' '
*       EXTPGM_NAME                       = ' '
*       EXTPGM_PARAM                      = ' '
*       EXTPGM_SET_TRACE_ON               = ' '
*       EXTPGM_STDERR_IN_JOBLOG           = 'X'
*       EXTPGM_STDOUT_IN_JOBLOG           = 'X'
*       EXTPGM_SYSTEM                     = ' '
*       EXTPGM_RFCDEST                    = ' '
*       EXTPGM_WAIT_FOR_TERMINATION       = 'X'
        jobcount                          = jobcount
        jobname                           = jobname
*       LANGUAGE                          = SY-LANGU
*       PRIPARAMS                         = ' '
        report                            = report
*       VARIANT                           = ' '
*     IMPORTING
*       STEP_NUMBER                       =
      exceptions
        bad_priparams                     = 1
        bad_xpgflags                      = 2
        invalid_jobdata                   = 3
        jobname_missing                   = 4
        job_notex                         = 5
        job_submit_failed                 = 6
        lock_failed                       = 7
        program_missing                   = 8
        prog_abap_and_extpg_set           = 9
        others                            = 10
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      message w500(26) with
        text-003 text-002 'Program: ZMIKRON1'.
      exit.
    else.
    endif.

    clear return.
    call function 'JOB_CLOSE'
      exporting
*       AT_OPMODE                         = ' '
*       AT_OPMODE_PERIODIC                = ' '
*       CALENDAR_ID                       = ' '
*       EVENT_ID                          = ' '
*       EVENT_PARAM                       = ' '
*       EVENT_PERIODIC                    = ' '
        jobcount                          = jobcount
        jobname                           = jobname
*        laststrtdt                        = laststrtdt
*        laststrttm                        = laststrttm
*       PRDDAYS                           = 0
*       PRDHOURS                          = 0
*       PRDMINS                           = 0
*       PRDMONTHS                         = 0
*       PRDWEEKS                          = 0
*       PREDJOB_CHECKSTAT                 = ' '
*       PRED_JOBCOUNT                     = ' '
*       PRED_JOBNAME                      = ' '
        sdlstrtdt                         = sdlstrtdt
        sdlstrttm                         = sdlstrttm
*       STARTDATE_RESTRICTION             = BTC_PROCESS_ALWAYS
*       STRTIMMED                         = ' '
*       TARGETSYSTEM                      = ' '
*       START_ON_WORKDAY_NOT_BEFORE       = SY-DATUM
*       START_ON_WORKDAY_NR               = 0
*       WORKDAY_COUNT_DIRECTION           = 0
*       RECIPIENT_OBJ                     =
*       TARGETSERVER                      = ' '
*       DONT_RELEASE                      = ' '
*       DIRECT_START                      =
*     IMPORTING
*       JOB_WAS_RELEASED                  =
      changing
        ret                               = ret
      exceptions
        cant_start_immediate              = 1
        invalid_startdate                 = 2
        jobname_missing                   = 3
        job_close_failed                  = 4
        job_nosteps                       = 5
        job_notex                         = 6
        lock_failed                       = 7
        others                            = 8
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      message w500(26) with
        text-005 text-002 'Program: ZMIKRON1'.
      exit.
    else.
    endif.

    exit.
  endif.


* Test auf zugelassene Dokumentenart D10
  if draw-dokar = 'D10'.
  else.
    exit.
  endif.

* Aufruf der Konvertierung mit den Dokumenteninformationen
* Transaktion "CONV01" mit DIS Schlüsseln und Status S1 / S2
  data: wa_draw type draw.

  wa_draw = draw.

  submit conv_convert_document
    with dokar eq wa_draw-dokar
    with doknr eq wa_draw-doknr
    with doktl eq wa_draw-doktl
    with dokvr eq wa_draw-dokvr
*    WITH dokst EQ wa_draw-dokst
    with wsappl = 'TIF'
    with convers = 'TIFF nach TIFF bei D10 bei S1 / S2'
    and return
    .
endform.                    " call_conv_at_s2
*&---------------------------------------------------------------------*
*&      Form  start_plot_interface
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form start_plot_interface.
* Übergabe der Dokumentdaten und Starten des Plotinterfaces
*TYPES
*ITAB
  data: itab_items_fauf type table of zcl_pdm_objects_fa_int.
*WA
  data: wa_default_data type /cideon/plot_defaultdata.
  data: wa_user_data type /cideon/plot_userdata.
  data: wa_item_fauf type zcl_pdm_objects_fa_int.
*NORMAL

* Einstellungen lesen
  clear wa_user_data.
  clear wa_default_data.

  call function '/CIDEON/READ_DEFAULTDATA'
       exporting
            i_batch        = ''
       importing
            o_default_data = wa_default_data.


  call function '/CIDEON/READ_USERDATA'
       exporting
            i_default_data = wa_default_data
       importing
            o_user_data    = wa_user_data.

* Übergabe der Daten
  clear wa_item_fauf.

  move-corresponding draw to wa_item_fauf.
  wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.

  append wa_item_fauf to itab_items_fauf.


* Aufruf des FBs
  if itab_items_fauf[] is initial.
  else.
    call function 'Z_CL_INT_WRITE_PLOT_PSB'
         exporting
              f_aut_process = wa_user_data-knz_auto_fauf
         tables
              i_itab_items  = itab_items_fauf
         exceptions
              error         = 1
              others        = 2.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
  endif.

** mglw. automatischer Durchlauf durch PlotInterface
*  IF wa_user_data-knz_auto_fauf = 'X'.
*    SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
*  ELSE.
*    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
*  ENDIF.
*
** Aufruf des PlotInterfaces
*  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
*  CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.
*
*
** Einstellungen zurücksetzen
*  SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
*  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.




endform.                    " start_plot_interface
*&---------------------------------------------------------------------*
*&      Form  start_plot_interface_auto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form start_plot_interface_auto.
* Übergabe der Dokumentdaten und Starten des Plotinterfaces
*TYPES
*ITAB
  data: itab_items_fauf type table of zcl_pdm_objects_fa_int.
*WA
  data: wa_default_data type /cideon/plot_defaultdata.
  data: wa_user_data type /cideon/plot_userdata.
  data: wa_item_fauf type zcl_pdm_objects_fa_int.
*NORMAL

* Einstellungen lesen
  clear wa_user_data.
  clear wa_default_data.

  call function '/CIDEON/READ_DEFAULTDATA'
       exporting
            i_batch        = ''
       importing
            o_default_data = wa_default_data.


  call function '/CIDEON/READ_USERDATA'
       exporting
            i_default_data = wa_default_data
       importing
            o_user_data    = wa_user_data.

* Übergabe der Daten
  clear wa_item_fauf.

  move-corresponding draw to wa_item_fauf.
  wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.

  append wa_item_fauf to itab_items_fauf.

* automatischer Durchlauf
  wa_user_data-knz_auto_fauf = 'X'.

* Aufruf des FBs
  if itab_items_fauf[] is initial.
  else.
    call function 'Z_CL_INT_WRITE_PLOT_PSB'
         exporting
              f_aut_process = wa_user_data-knz_auto_fauf
         tables
              i_itab_items  = itab_items_fauf
         exceptions
              error         = 1
              others        = 2.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
  endif.


endform.                    " start_plot_interface_auto
