*&---------------------------------------------------------------------*
*& Report  /CIDEON/SEL_TO_CONVERT3                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON Anbindung neue Funktionalitäten in Konvertierungsserver
*  Konvertierungseinplanung
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           Chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 15.05.2007 - Erstellung
* 06.06.2007 - SP 05
*              Beauftragung einzelne Konvertierung
*              Dokumentenstatus nicht mitgeben
*              analog das Gleiche für Dokumentenstückliste
*-----------------------------------------------------------------------
report  /cideon/sel_to_convert3.

*TABLES
tables: convert_spec, /cideon/datetime, draw.

*ALVs
data: alv_docs type ref to cl_gui_alv_grid.
data: cont_alv_docs type ref to cl_gui_custom_container.
*LAYOUT
data: layout_alv_docs type lvc_s_layo.
data: x_save_docs value 'A'.
*Excludes
data: it_tb_ex_docs type ui_functions.
*ALVs  Titel
data: gc_alv_docs_title type string.



*LVC_T_ROW
data: it_index_sel_alv_docs type lvc_t_row.
data: wa_index_sel_alv_docs type lvc_s_row.

* MAIN ITAB
data: itab_ptx_draw type table of draw.
data: it_convert_spec type table of convert_spec.
*  MAIN WA
data: wa_ptx_draw type draw.
data: wa_convert_spec type convert_spec.

*** JOBS
data: lc_jobname type tbtcjob-jobname,
      lc_jobid type tbtcjob-jobcount,
      lc_jobname_temp type string.
***

*** TRIGGER
data: lc_conv_doc_structure(1) type c value 'X'.
data: lc_conv_doc(1) type c value ' '.
***

*** F4 Hilfe
data: gc_tab_ret_field type string,
      gc_dyn_field_name type string.

***


call screen 100.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0100 output.
set pf-status '100'.
set titlebar '100'.

*  Objekte erstellen , itab_ptx_draw -> ALV Tabelle
perform builup_objects.

loop at screen.
  case screen-name.
*  WS-Applikation
    when 'DRAW-DAPPL'.
      if lc_conv_doc eq 'X'.
        screen-input = '1'.
        modify screen.
      else.
        screen-input = '0'.
        modify screen.
      endif.
*  Name Konvertierungsregel
    when 'CONVERT_SPEC-NAME'.
      if lc_conv_doc eq 'X'.
        screen-input = '1'.
        modify screen.
      else.
        screen-input = '0'.
        modify screen.
      endif.
    when others.
  endcase.
endloop.

endmodule.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_CONV_PLAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module exit_conv_plan input.

case sy-ucomm.
  when 'CANCEL'.
    perform destroy_objects.
    leave to screen 0.
  when 'EXIT'.
    perform destroy_objects.
    leave to screen 0.
  when others.
endcase.

endmodule.                 " EXIT_CONV_PLAN  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.

case sy-ucomm.
  when 'PLAN'.
    perform plan_convert_jobs.
  when 'SEARCH'.
    perform search_documents.
  when 'BACK'.
    perform destroy_objects.
    leave to screen 0.
  when 'DOCSTRUC'.
    clear convert_spec-name.
    clear draw-dappl.
  when others.
endcase.


endmodule.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  builup_objects
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form builup_objects.

if alv_docs is initial.

*   ALV CONTAINER erzeugen
    create object cont_alv_docs
      exporting container_name = 'CONTAINER1'.
    if sy-subrc <> 0.
      exit.
    else.
    endif.

*   ALV erzeugen
    create object alv_docs
    exporting i_parent = cont_alv_docs.

    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    else.
    endif.

*    Titel
    perform create_title_for_alv.

*   Layout
    layout_alv_docs-sel_mode = 'A'.
    layout_alv_docs-grid_title = gc_alv_docs_title.

    call method alv_docs->set_table_for_first_display
      exporting
        i_structure_name              = 'DRAW'
*        is_variant                    = gs_variant_ap
        is_layout                     = layout_alv_docs
        i_save                        = x_save_docs
        i_default                     = 'X'
        it_toolbar_excluding          = it_tb_ex_docs
      changing
        it_outtab                     = itab_ptx_draw
      exceptions
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        others                        = 4.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

    call method alv_docs->get_frontend_layout
      importing
        es_layout = layout_alv_docs.
    layout_alv_docs-sel_mode = 'A'.

    call method alv_docs->set_frontend_layout
      exporting
        is_layout = layout_alv_docs.

else.

*    Titel
  if not layout_alv_docs is initial.
    perform create_title_for_alv.
    call method alv_docs->get_frontend_layout
          importing
            es_layout = layout_alv_docs.

    layout_alv_docs-grid_title = gc_alv_docs_title.

    call method alv_docs->set_frontend_layout
        exporting
          is_layout = layout_alv_docs.

  endif.

  call method alv_docs->refresh_table_display
*   EXPORTING
*     IS_STABLE      =
*     I_SOFT_REFRESH =
    exceptions
      finished       = 1
      others         = 2
              .
   if sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   endif.

endif.

endform.                    " builup_objects

*&---------------------------------------------------------------------*
*&      Form  plan_convert_jobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form plan_convert_jobs.

* Selektierten Eintrag holen
refresh it_index_sel_alv_docs.
call method alv_docs->get_selected_rows
  importing
    et_index_rows = it_index_sel_alv_docs.
*    ET_ROW_NO     =
.

if it_index_sel_alv_docs[] is initial.
  clear sy-ucomm.
  message e000(/cideon/css) with text-000.
endif.

if /cideon/datetime-datum is initial or
  /cideon/datetime-datum eq space.
  clear sy-ucomm.
  message e000(/cideon/css) with text-001.
endif.

if /cideon/datetime-zeit is initial or
  /cideon/datetime-zeit eq space.
  clear sy-ucomm.
  message e000(/cideon/css) with text-002.
endif.

if /cideon/datetime-datum < sy-datum.
  clear sy-ucomm.
  message e000(/cideon/css) with text-007.
endif.

if /cideon/datetime-datum eq sy-datum.
  if /cideon/datetime-zeit < sy-uzeit.
    clear sy-ucomm.
  message e000(/cideon/css) with text-007.
  endif.
endif.

if lc_conv_doc eq 'X'.
  if draw-dappl eq space and not convert_spec-name eq space.
    clear sy-ucomm.
    message e000(/cideon/css) with text-005.
  endif.
  if not draw-dappl eq space and convert_spec-name eq space.
    clear sy-ucomm.
    message e000(/cideon/css) with text-006.
  endif.
endif.



clear wa_index_sel_alv_docs.
loop at it_index_sel_alv_docs into wa_index_sel_alv_docs.
  read table itab_ptx_draw into wa_ptx_draw index wa_index_sel_alv_docs.

  clear lc_jobname_temp.
  concatenate wa_ptx_draw-dokar
              wa_ptx_draw-doknr
              wa_ptx_draw-doktl
              wa_ptx_draw-dokvr
                                    into lc_jobname_temp.
  clear lc_jobname.
  lc_jobname = lc_jobname_temp.

  call function 'JOB_OPEN'
    exporting
*     DELANFREP              = ' '
*     JOBGROUP               = ' '
      jobname                = lc_jobname
*     SDLSTRTDT              = NO_DATE
*     SDLSTRTTM              = NO_TIME
*     JOBCLASS               =
    importing
      jobcount               = lc_jobid
*   CHANGING
*     RET                    =
   exceptions
     cant_create_job        = 1
     invalid_job_data       = 2
     jobname_missing        = 3
     others                 = 4
            .
  if sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* CONV04
  if lc_conv_doc_structure eq 'X'.
    perform convert_doc_structure using wa_ptx_draw
                                        lc_jobname
                                        lc_jobid
                                        .
  endif.

* CONV02
  if lc_conv_doc eq 'X'.
    perform convert_doc using wa_ptx_draw
                              lc_jobname
                              lc_jobid
                              .
  endif.

  call function 'JOB_CLOSE'
    exporting
*     AT_OPMODE                         = ' '
*     AT_OPMODE_PERIODIC                = ' '
*     CALENDAR_ID                       = ' '
*     EVENT_ID                          = ' '
*     EVENT_PARAM                       = ' '
*     EVENT_PERIODIC                    = ' '
      jobcount                          = lc_jobid
      jobname                           = lc_jobname
*     LASTSTRTDT                        = NO_DATE
*     LASTSTRTTM                        = NO_TIME
*     PRDDAYS                           = 0
*     PRDHOURS                          = 0
*     PRDMINS                           = 0
*     PRDMONTHS                         = 0
*     PRDWEEKS                          = 0
*     PREDJOB_CHECKSTAT                 = ' '
*     PRED_JOBCOUNT                     = ' '
*     PRED_JOBNAME                      = ' '
     sdlstrtdt                         = /cideon/datetime-datum "NO_DATE
     sdlstrttm                         = /cideon/datetime-zeit "NO_TIME
*     STARTDATE_RESTRICTION             = BTC_PROCESS_ALWAYS
*     STRTIMMED                         = ' '
*     TARGETSYSTEM                      = ' '
*     START_ON_WORKDAY_NOT_BEFORE       = SY-DATUM
*     START_ON_WORKDAY_NR               = 0
*     WORKDAY_COUNT_DIRECTION           = 0
*     RECIPIENT_OBJ                     =
*     TARGETSERVER                      = ' '
*     DONT_RELEASE                      = ' '
*     DIRECT_START                      =
*   IMPORTING
*     JOB_WAS_RELEASED                  =
*   CHANGING
*     RET                               =
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
   message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.

  endif.

endloop.

message i000(/cideon/css) with text-003.

endform.                    " plan_convert_jobs

*&---------------------------------------------------------------------*
*&      Form  convert_doc_structure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_PTX_DRAW  text
*      -->P_LC_JOBNAME  text
*      -->P_LC_JOBID  text
*----------------------------------------------------------------------*
form convert_doc_structure using    p_wa_ptx_draw type draw
                                    p_lc_jobname type tbtcjob-jobname
                                    p_lc_jobid type tbtcjob-jobcount.
data: lc_int_docst type tdwst-stabk.

* Nicht notwendig CKR
*perform get_internal_status using p_wa_ptx_draw-dokst
*                            changing lc_int_docst.

submit conv_convert_doc_structure
    user sy-uname via job p_lc_jobname number p_lc_jobid
                  with dokar = p_wa_ptx_draw-dokar
                  with doknr = p_wa_ptx_draw-doknr
                  with doktl = p_wa_ptx_draw-doktl
                  with dokvr = p_wa_ptx_draw-dokvr
*                  with chanr = p_wa_ptx_draw-aennr
*                  with keydate = /cideon/datetime-datum
*                  with dokst = lc_int_docst
                  and return.

endform.                    " convert_doc_structure

*&---------------------------------------------------------------------*
*&      Form  convert_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_PTX_DRAW  text
*      -->P_LC_JOBNAME  text
*      -->P_LC_JOBID  text
*----------------------------------------------------------------------*
form convert_doc using    p_wa_ptx_draw type draw
                          p_lc_jobname type tbtcjob-jobname
                          p_lc_jobid type tbtcjob-jobcount.

data: lc_int_docst type tdwst-stabk,
      ls_return2 type bapiret2,
      lt_files type table of bapi_doc_files2,
      ls_files type bapi_doc_files2.

* nicht notwendig CKR
*perform get_internal_status using p_wa_ptx_draw-dokst
*                            changing lc_int_docst.


* Anmerkung CKR
* entweder Dokumentenstatus / oder WSA und Regel angeben
* / CKR

*IF NOT DRAW-DAPPL EQ SPACE.
  submit conv_convert_document
   user sy-uname via job p_lc_jobname number p_lc_jobid
                 with dokar = p_wa_ptx_draw-dokar
                 with doknr = p_wa_ptx_draw-doknr
                 with doktl = p_wa_ptx_draw-doktl
                 with dokvr = p_wa_ptx_draw-dokvr
*                 with dokst = lc_int_docst
                 with wsappl = draw-dappl
                 with convers = convert_spec-name
                 and return.
*ELSE.
*
*  REFRESH lt_files.
*  CLEAR ls_return2.
*  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
*    EXPORTING
*      documenttype               = p_wa_ptx_draw-DOKAR
*      documentnumber             = p_wa_ptx_draw-DOKNR
*      documentpart               = p_wa_ptx_draw-DOKTL
*      documentversion            = p_wa_ptx_draw-DOKVR
**     GETOBJECTLINKS             = ' '
**     GETCOMPONENTS              = ' '
**     GETSTATUSLOG               = ' '
**     GETLONGTEXTS               = ' '
**     GETACTIVEFILES             = 'X'
**     GETDOCDESCRIPTIONS         = 'X'
**     GETDOCFILES                = 'X'
**     GETCLASSIFICATION          = ' '
**     GETSTRUCTURE               = ' '
**     GETWHEREUSED               = ' '
**     HOSTNAME                   = ' '
*    IMPORTING
**     DOCUMENTDATA               =
*      RETURN                     = ls_return2
*    TABLES
**     OBJECTLINKS                =
**     DOCUMENTDESCRIPTIONS       =
**     LONGTEXTS                  =
**     STATUSLOG                  =
*      DOCUMENTFILES              = lt_files
**     COMPONENTS                 =
**     CHARACTERISTICVALUES       =
**     CLASSALLOCATIONS           =
**     DOCUMENTSTRUCTURE          =
**     WHEREUSEDLIST              =
*            .
*
*  IF ls_return2-TYPE EQ 'E'.
*    MESSAGE ID ls_return2-ID TYPE ls_return2-TYPE
*    NUMBER ls_return2-NUMBER
*    WITH ls_return2-MESSAGE_V1 ls_return2-MESSAGE_V2
*         ls_return2-MESSAGE_V3 ls_return2-MESSAGE_V4.
*  ENDIF.
*
*  LOOP AT lt_files INTO ls_files.
*    IF ls_files-WSAPPLICATION = DRAW-DAPPL.
*      SUBMIT CONV_CONVERT_DOCUMENT
*       USER sy-uname VIA JOB p_lc_jobname NUMBER p_lc_jobid
*                     WITH dokar = p_wa_ptx_draw-DOKAR
*                     WITH doknr = p_wa_ptx_draw-DOKNR
*                     WITH doktl = p_wa_ptx_draw-DOKTL
*                     WITH dokvr = p_wa_ptx_draw-DOKVR
*                     WITH dokst = lc_int_docst
*                     WITH wsappl = DRAW-DAPPL
*                     WITH convers = CONVERT_SPEC-NAME
*                     AND RETURN.
*    ENDIF.
*  ENDLOOP.
*
*ENDIF.

endform.                    " convert_doc

*&---------------------------------------------------------------------*
*&      Form  get_internal_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_WA_PTX_DRAW_DOKST  text
*      <--P_LC_INT_DOCST  text
*----------------------------------------------------------------------*
form get_internal_status using    p_dokst type draw-dokst
                         changing p_int_docst type tdwst-stabk.

data: ls_tdwst type tdwst.


clear ls_tdwst.
if not p_dokst eq space.
  select single * from tdwst client specified into ls_tdwst
                  where mandt = sy-mandt and
                        cvlang = sy-langu and
                        dokst = p_dokst.

  if sy-subrc eq 0.
    p_int_docst = ls_tdwst-stabk.
  endif.
endif.

endform.                    " get_internal_status

*&---------------------------------------------------------------------*
*&      Module  convert_spec_request  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module convert_spec_request input.

refresh it_convert_spec.
clear wa_convert_spec.
select * from convert_spec client specified
                      into table it_convert_spec
                      where mandt = sy-mandt.
sort it_convert_spec by name.

gc_tab_ret_field = 'NAME'.
gc_dyn_field_name = 'CONVERT_SPEC-NAME'.

perform show_values  tables it_convert_spec
                     using gc_tab_ret_field
                           gc_dyn_field_name
                    changing convert_spec-name.


endmodule.                 " convert_spec_request  INPUT

*&---------------------------------------------------------------------*
*&      Form  show_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_CONVERT_SPEC  text
*      -->P_GC_TAB_RET_FIELD  text
*      -->P_GC_DYN_FIELD_NAME  text
*      <--P_CONVERT_SPEC_NAME  text
*----------------------------------------------------------------------*
form show_values tables   p_value_tab
                 using    p_gc_tab_ret_field type string
                          p_gc_dyn_field_name type string
                 changing p_spec_auto_start_value.

data: p_lt_fields_temp type table of dfies,
      p_lt_fields type table of dfies,
      p_ls_field type dfies,
      p_lt_helptable type table of ddshretval,
      p_ls_helptable type ddshretval,
      p_li_helptable_records type i value 0,
      p_lc_retfield type dfies-fieldname,
      p_lc_value type string.


data: p_lt_dynupd type table of dynpread,
      p_ls_dynupd type dynpread.

data: p_lt_dynread type table of dynpread,
      p_ls_dynread type dynpread.

refresh: p_lt_helptable,
         p_lt_fields,
         p_lt_fields_temp,
         p_lt_dynupd.

p_lc_retfield = p_gc_tab_ret_field.

*ATTRIBUT NAME FEST CODIERT****
if p_gc_tab_ret_field eq 'NAME'.
  call function 'DDIF_FIELDINFO_GET'
         exporting
           tabname              = 'CONVERT_SPEC'
         tables
           dfies_tab            = p_lt_fields_temp
         exceptions
           not_found            = 1
           internal_error       = 2
           others               = 3
                  .
        if sy-subrc <> 0.
          exit.
        endif.
        loop at p_lt_fields_temp into p_ls_field.
          case p_ls_field-fieldname.
            when p_gc_tab_ret_field. "'NAME'.
               append p_ls_field to p_lt_fields.
          endcase.
        endloop.
endif.

   call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
*     DDIC_STRUCTURE         = ' '
      retfield               = p_lc_retfield
*     PVALKEY                = ' '
*     DYNPPROG               = ' '
*    DYNPNR                 = ' '
*     DYNPROFIELD            = ' '
*     STEPL                  = 0
*    WINDOW_TITLE           =
*     VALUE                  = ' '
      value_org              = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY                = ' '
*    CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     MARK_TAB               =
*  IMPORTING
*     USER_RESET             =
    tables
      value_tab              = p_value_tab
      field_tab              = p_lt_fields
      return_tab             = p_lt_helptable
*    DYNPFLD_MAPPING        =
    exceptions
      parameter_error        = 1
      no_values_found        = 2
    others                 = 3
          .
   if sy-subrc <> 0.
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   endif.


read table p_lt_helptable into p_ls_helptable index 1.

*  entfernen wenn values auch manuell geschrieben werden sollen
   describe table p_lt_helptable lines p_li_helptable_records.

   if not p_li_helptable_records eq 0.
      p_ls_dynupd-fieldname = p_gc_dyn_field_name.
      p_ls_dynupd-stepl = 0.
      p_ls_dynupd-fieldvalue = p_ls_helptable-fieldval.
      p_ls_dynupd-fieldinp = ' '.

      append p_ls_dynupd to p_lt_dynupd.
      clear p_ls_dynupd.

*     /CIDEON/T_ORDERS-AUFTRNR = p_ls_helptable-fieldval.
      p_spec_auto_start_value = p_ls_helptable-fieldval.
      call function 'DYNP_VALUES_UPDATE'
        exporting
          dyname                     = sy-cprog
          dynumb                     = '0100'
        tables
          dynpfields                 = p_lt_dynupd.
   endif.
endform.                    " show_values

*&---------------------------------------------------------------------*
*&      Form  destroy_objects
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form destroy_objects.

if not alv_docs is initial.
  call method alv_docs->free
    exceptions
      cntl_error        = 1
      cntl_system_error = 2
      others            = 3
          .
  if sy-subrc <> 0.
   message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  clear alv_docs.
endif.

if not cont_alv_docs is initial.
  call method cont_alv_docs->free
    exceptions
      cntl_error        = 1
      cntl_system_error = 2
      others            = 3
          .
  if sy-subrc <> 0.
   message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  clear cont_alv_docs.
endif.


endform.                    " destroy_objects

*&---------------------------------------------------------------------*
*&      Form  search_documents
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form search_documents.

* Aufruf der Standardsuche
  refresh itab_ptx_draw.

  call function 'CV100_DOC_SEARCH'
   exporting
      pf_cv04_list_type       = '2'
*     PF_WEB_LIST_TYPE        =
      api_flag                = 'X'
   tables
     ptx_draw                = itab_ptx_draw
            .

*IF NOT itab_ptx_draw[] IS INITIAL.
*
*ENDIF.

endform.                    " search_documents
*&---------------------------------------------------------------------*
*&      Form  create_title_for_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_title_for_alv.

data: p_lc_temp_record_count type string,
      li_records type i value 0.

  describe table itab_ptx_draw lines li_records.
  p_lc_temp_record_count = li_records.

  clear gc_alv_docs_title.
  concatenate text-004 p_lc_temp_record_count into gc_alv_docs_title
                                              separated by ' '.

endform.                    " create_title_for_alv
