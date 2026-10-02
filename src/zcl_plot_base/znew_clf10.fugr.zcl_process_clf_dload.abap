function zcl_process_clf_dload.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DEFAULT_USER) TYPE  XUBNAME OPTIONAL
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(I_CLF_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(FILTER) TYPE  C OPTIONAL
*"     VALUE(I_OUT_PROC) TYPE  C OPTIONAL
*"     VALUE(I_DELETE_ITEM) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_DELETE_STATUS) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_FORMAT_CHECKING) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA OPTIONAL
*"     VALUE(F_DYN_TOC) TYPE  CHAR1 OPTIONAL
*"     VALUE(F_DYN_COV) TYPE  CHAR1 OPTIONAL
*"     VALUE(LI_COUNTER_CLF) TYPE  I OPTIONAL
*"  TABLES
*"      ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"      ITAB_CLFLIST STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Srinivas Mamillapalli
*           Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 24.03.2004 - Weiterführung
* 28.03.2004 - Umstellung WS_DOWNLOAD auf DSVAS_DOC_WS_DOWNLOAD
*              DSVAS_DOC_WS_DOWNLOAD auf GUI_DOWNLOAD
* 23.02.2005 - Änderungen für JavaGUI
*              Dateiablage / Verzeichnistests
* 30.01.2006 - leere CLFs vermeiden
* 02.03.2009 - SP 91
*              Fehlerrückgabe
* 30.07.2009 - SP 98
*              BADI
*              CHG_CLF_GROUP
*              CHG_CLF_VF
* SP 113
* 27.11.2009 -
*              ZCL_PROCESS_CLF_DLOAD
*              Anpassungen, daß falls AO$_MERGE gesetzt ist,
*              daß dann dieses in die
*              Gruppe übernommen wird
* SP119
* 7.0.1.19
* 16.02.2010 - CONCAST
*              Reaktion auf nicht zugreifbare Dateien aus dem CS
*              -> Fehlblattgenerierung
*
* SP 146
* 24.01.2011 - CKR
* 7.0.146.1
*              /CIDEON/TMP_GUI_GET_FILE_EXIST
*              Test für Zugriffsbeschleunigung über
*              CL_GUI_FRONTEND_SERVICES
*-----------------------------------------------------------------------
  data : flag_dir_exist   type c,
         flag_process_clf type c.

  data : wa_test    type zcl_s_plotlist,
         wa_clflist type zcl_s_line_256.

  data : tmp_fname(150) type c,
         tmp_exist      type c,
         tmp_str        type string.

*  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  data : lv_rc                type i,
         lv_filelength        type i,
         lv_e_last_path       type filep,
         lv_i_last_path       type string,
         lv_new_dirname       type string,
         lv_downloaded_path   type string,
         lv_x_filename        like rlgrap-filename,
         lv_split_part1       like rlgrap-filename,
         lv_split_part2       like rlgrap-filename,
         lv_stripped_name     like rlgrap-filename,
         lv_file_path         like rlgrap-filename.

  data : itab_joblist_file             type table of zcl_s_plotlist,
         itab_clf_final_data           type table of zcl_s_line_256.

  data : itab_aofile_clf10 type table of zcl_s_line_256,
         itab_group_clf10  type table of zcl_s_line_256.

  data : it_aofile_clf type table of zcl_s_line_256,
         wa_aofile_clf type zcl_s_line_256.

*NORMAL
  data: knz_w32_gui.
  data: dir_name type rlgrap-filename.


* BADI Integration
* BADI
* /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND
  data: exit type ref to /cideon/if_ex_pre_main_001.
  data: return type bapiret2.

  call method cl_exithandler=>get_instance
    changing
      instance = exit.
  if sy-subrc ne 0.
  else.
  endif.


* Feststellen, ob JavaGUI oder normaler GUI
  clear knz_w32_gui.
  call function 'GUI_HAS_ACTIVEX'
    importing
      return = knz_w32_gui.


  if obj_frontend_services is initial.
    create object obj_frontend_services.
  endif.

  clear lv_i_last_path.


  move i_down_path to tmp_fname.

  clear tmp_exist.

  "CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
  call function '/CIDEON/TMP_GUI_GET_FILE_EXIST'
       exporting
            fname          = tmp_fname
       importing
            exist          = tmp_exist
*           isdir          =
*           filesize       =
       exceptions
            fileinfo_error = 1
            others         = 2
                .

*  IF sy-subrc NE 0.
*    IF sy-subrc = 1.
*      MESSAGE e009(zcvn) WITH
*        'fileinfo_error' 'TMP_GUI_GET_FILE_EXIST'
*        'Z_CL_NEW_PLOT_LIST_CLF' ''
*        RAISING error.
*    ELSE.
*      MESSAGE e009(zcvn) WITH
*        'OTHERS' 'TMP_GUI_GET_FILE_EXIST'
*        'Z_CL_NEW_PLOT_LIST_CLF' ''
*        RAISING error.
*    ENDIF.
*  ELSE.
*  ENDIF.


  if tmp_exist is initial.
***** Modif. on 13.12.2002..ende..Mamillapalli
    clear lv_rc.

    call method obj_frontend_services->directory_create
      exporting
        directory                = i_down_path
      changing
        rc                       = lv_rc
      exceptions
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        others                   = 8.
    if lv_rc gt 0.
      message e010(zcvn) with i_down_path '' '' ''
        raising error.
    endif.
  endif.

  call function 'SAPGUI_PROGRESS_INDICATOR'
    exporting
      percentage = 50
      text       = text-040.


  call function 'ZCL_UPLOAD_JOB_DATA_CLF10'
    exporting
      user           = default_user
    tables
      o_jobdat_clf10 = itab_group_clf10
    exceptions
      error          = 1
      others         = 2.

  if sy-subrc <> 0.
    message e099(zcvn) with 'ZCL_JOBDAT_CLF10' raising error.
  endif.


  call function 'ZCL_ULOAD_AOFILE_CLF10'
    exporting
      user             = default_user
    tables
      o_aofile_clf_tab = itab_aofile_clf10
    exceptions
      error            = 1
      others           = 2.
  if sy-subrc <> 0.
    message e099(zcvn) with 'ZCL_AOFILE_CLF10' raising error.
  endif.

  clear lv_x_filename.


*********  Geändert am 18.08.2003 (Start)..MAMILLAPALLI
  data : lv_logic_file    like rlgrap-filename,
         lv_timestamp     like rlgrap-filename,
         lv_year          like rlgrap-filename,
         lv_fname         type char255.

  data : lv_exist    type  c,
         lv_isdir    type  c.

  data : lv_result type abap_bool.

  call function 'SAPGUI_PROGRESS_INDICATOR'
    exporting
      percentage = 50
      text       = text-041.


* Get the CLF File name that has to be created , with
* the use of LOGICAL_FILENAME & PARAMETER_1.
  clear lv_x_filename.
  call function 'FILE_GET_NAME'
       exporting
         client                  = sy-mandt
         logical_filename        = 'ZZ_REPRO_CLF_STANDARD_NEW'
         operating_system        = sy-opsys
         parameter_1             = text-100
*        PARAMETER_2             = ' '
*        PARAMETER_3             = ' '
         use_presentation_server = 'X'
*        WITH_FILE_EXTENSION     = ' '
*        USE_BUFFER              = ' '
       importing
*        EMERGENCY_FLAG          =
*        FILE_FORMAT             =
         file_name               = lv_x_filename
       exceptions
         file_not_found          = 1
         others                  = 2
            .
  if sy-subrc <> 0.
    message e018(zcvn) raising error.
  endif.

  " 2009/08/14 MBH / CKR
  "WAIT UP TO 1 SECONDS.
  "Split und Zähler
  "li_counter_clf
  data: lc_counter_clf type char5.
  clear lc_counter_clf.
  lc_counter_clf = li_counter_clf.

  data: pf_file type draw-filep.
  data: pfx_file type draw-filep.
  data: pfx_dotextension type char20.

  clear pfx_file.
  clear pf_file.
  clear pfx_dotextension.

  pf_file = lv_x_filename.

  call function 'CV120_SPLIT_FILE'
    exporting
      pf_file                = pf_file
    importing
      pfx_file               = pfx_file
*      PFX_EXTENSION          =
      pfx_dotextension       = pfx_dotextension
            .

  concatenate pfx_file '_' lc_counter_clf pfx_dotextension
    into lv_x_filename .
  condense lv_x_filename  no-gaps.

  "CLEAR i_clf_down_path.
  concatenate i_clf_down_path lv_x_filename into i_clf_down_path.

* Problem mit "." innerhalb eines Nutzernamens
  data: itab_split type table of char255.
  data: wa_split type char255.
  data: lines type i.
  clear itab_split.
  clear wa_split.
  clear lines.

  split lv_x_filename at '.' into table itab_split.
  describe table itab_split lines lines.
  clear lv_split_part1.
  clear lv_split_part2.
  if lines = 2.
    split lv_x_filename at '.' into lv_split_part1 lv_split_part2.
  else.
    loop at itab_split into wa_split.
      if sy-tabix = lines.
        lv_split_part2 = wa_split.
      else.
        if lv_split_part1 is initial.
          lv_split_part1 = wa_split.
        else.
          concatenate lv_split_part1 wa_split
            into lv_split_part1 separated by '.'.
        endif.
      endif.
    endloop.
  endif.

*CKR  SPLIT lv_x_filename AT '.' INTO lv_split_part1 lv_split_part2.
* Problem mit "." innerhalb eines Nutzernamens ENDE

  split lv_split_part1 at text-100 into lv_logic_file lv_timestamp.

  lv_year = lv_timestamp+0(4).

  concatenate i_down_path lv_year into lv_fname.

  clear lv_exist.
  clear lv_isdir.

* Jahr
  "CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
  call function '/CIDEON/TMP_GUI_GET_FILE_EXIST'
    exporting
      fname                = lv_fname
   importing
     exist                = lv_exist
     isdir                = lv_isdir
*    filesize             =
   exceptions
     fileinfo_error       = 1
     others               = 2
            .

  if knz_w32_gui = 'X'.
  else.
*   Java
*   Verzeichnis einfach nochmal anlegen
    clear lv_exist.
    clear lv_isdir.
  endif.

  if ( lv_exist is initial and lv_isdir is initial ).
    move lv_fname to lv_new_dirname.

    call method obj_frontend_services->directory_create
      exporting
        directory                = lv_new_dirname
      changing
        rc                       = lv_rc
      exceptions
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        others                   = 8.

    if lv_rc gt 0.
      if knz_w32_gui = 'X'.
        message e010(zcvn) with lv_new_dirname '' '' ''
          raising error.
      else.
      endif.
    endif.
  endif.

  concatenate lv_fname '\' sy-datum into lv_fname.

  clear lv_exist.
  clear lv_isdir.

  "CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
  call function '/CIDEON/TMP_GUI_GET_FILE_EXIST'
    exporting
      fname                = lv_fname
    importing
      exist                = lv_exist
      isdir                = lv_isdir
*     filesize             =
    exceptions
      fileinfo_error       = 1
      others               = 2
            .

  if knz_w32_gui = 'X'.
  else.
*   Java
*   Verzeichnis einfach nochmal anlegen
    clear lv_exist.
    clear lv_isdir.
  endif.

  if ( lv_exist is initial and lv_isdir is initial ).
    move lv_fname to lv_new_dirname.

    call method obj_frontend_services->directory_create
      exporting
        directory                = lv_new_dirname
      changing
        rc                       = lv_rc
      exceptions
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        others                   = 8.

    if lv_rc gt 0.
      if knz_w32_gui = 'X'.
        message e010(zcvn) with lv_new_dirname '' '' ''
          raising error.
      else.
      endif.
    endif.
  endif.

  concatenate lv_fname '\' lv_split_part1 into lv_fname.

  clear lv_exist.
  clear lv_isdir.

  "CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
  call function '/CIDEON/TMP_GUI_GET_FILE_EXIST'
    exporting
      fname                = lv_fname
    importing
      exist                = lv_exist
      isdir                = lv_isdir
*     filesize             =
    exceptions
      fileinfo_error       = 1
      others               = 2
            .

  if knz_w32_gui = 'X'.
  else.
*   Java
*   Verzeichnis einfach nochmal anlegen
    clear lv_exist.
    clear lv_isdir.
  endif.

  if ( lv_exist is initial and lv_isdir is initial ).
    move lv_fname to lv_new_dirname.

    call method obj_frontend_services->directory_create
      exporting
        directory                = lv_new_dirname
      changing
        rc                       = lv_rc
      exceptions
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        others                   = 8.

    if lv_rc gt 0.
      if knz_w32_gui = 'X'.
        message e010(zcvn) with lv_new_dirname '' '' ''
          raising error.
      else.
      endif.
    endif.
  endif.
********  Geändert am 18.08.2003 (Ende) MAMILLAPALLI

  call function 'ZCL_PROC_SKEL_GROUP_CLF10'
*       EXPORTING
*            wa_draw      = wa_test
       tables
            it_group     = itab_group_clf10
            it_group_clf = itab_clflist
       exceptions
            error        = 1
            others       = 2.
  if sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  "BADI
  if exit is initial.
  else.
    data: it1 type /cideon/ttype_s_line_256.
    data: it2 type /cideon/ttype_s_line_256.
    data: it3 type /cideon/ttype_s_plotlist.

    clear it1.
    clear it2.
    clear it3.

    it1[] = itab_group_clf10[].
    it2[] = itab_clflist[].
    it3[] = itab_test[].

    call method exit->chg_clf_group
      changing
        itab_group_clf10 = it1
        itab_clflist     = it2
        itab_plotlist    = it3.

    itab_group_clf10[] = it1[].
    itab_clflist[] = it2[].
    itab_test[] = it3[].

  endif.



* Integration des dynamischen Inhaltsverzeichnisses
* <AOVF> etc.
* AO$_MERGE zurücksetzen

* CKR
* 2009/11/27
* Anpassungen, daß falls AO$_MERGE gesetzt ist, daß dann dieses in die
* Gruppe übernommen wird
  data: f_ao_merge.
  clear f_ao_merge.

  data: index_vf type i.
  clear index_vf.
  if f_dyn_toc = '1' or f_dyn_cov = '1'.
    loop at itab_clflist into wa_clflist.
      if wa_clflist cs 'AO$_MERGE'.

        "Sondereinbau 2009/11/27
        if wa_clflist cs '=' and wa_clflist cs '1'.
          f_ao_merge = 'X'.
        else.
        endif.

        wa_clflist = 'AO$_MERGE = 0'.
        modify itab_clflist from wa_clflist index sy-tabix.
      else.
      endif.

      if wa_clflist cs '<%AOFILE_CLF10%>'.
        index_vf = sy-tabix.
      else.
      endif.
    endloop.

    if f_dyn_toc = '1'.
      if index_vf is initial.
      else.
        index_vf = index_vf - 1.

        clear wa_clflist.
        wa_clflist = '</AOVF>'.
        insert wa_clflist into itab_clflist index index_vf.

        clear wa_clflist.
        concatenate '  AO$_VFTEMPLATE = ' i_user_data-vftemplate
          into wa_clflist
          separated by space.
        insert wa_clflist into itab_clflist index index_vf.

        clear wa_clflist.
        wa_clflist = '  AO$_MERGECONTENT = 1 '..
        insert wa_clflist into itab_clflist index index_vf.

        clear wa_clflist.
        concatenate '<AOVF' text-050
          '>'
          into wa_clflist
          separated by space.
        insert wa_clflist into itab_clflist index index_vf.


      endif.

    else.
    endif.

    if f_dyn_cov = '1'.
      if index_vf is initial.
      else.
        clear wa_clflist.
        wa_clflist = '</AOVF>'.
        insert wa_clflist into itab_clflist index index_vf.

        clear wa_clflist.
        concatenate '  AO$_VFTEMPLATE = ' i_user_data-vftemplate_toc
          into wa_clflist
          separated by space.
        insert wa_clflist into itab_clflist index index_vf.

        clear wa_clflist.
        concatenate '<AOVF' text-051
          '>'
          into wa_clflist
          separated by space.
        insert wa_clflist into itab_clflist index index_vf.

      endif.
    else.
    endif.

    if index_vf is initial.
    else.
      clear wa_clflist.
      if f_ao_merge = 'X'.
        wa_clflist = 'AO$_MERGE = 1'.
      else.
        wa_clflist = 'AO$_MERGE = 0'.
      endif.
      insert wa_clflist into itab_clflist index index_vf.
    endif.

  else.
  endif.


  "BADI
  if exit is initial.
  else.
    "DATA: it1 TYPE /cideon/ttype_s_line_256.
    "DATA: it2 TYPE /cideon/ttype_s_line_256.

    clear it1.
    clear it2.
    clear it3.

    it1[] = itab_group_clf10[].
    it2[] = itab_clflist[].
    it3[] = itab_test[].

    call method exit->chg_clf_vf
      changing
        itab_group_clf10 = it1
        itab_clflist     = it2
        itab_plotlist    = it3.

    itab_group_clf10[] = it1[].
    itab_clflist[] = it2[].
    itab_test[] = it3[].

  endif.

  data: index_itab_test type i.

  loop at itab_test into wa_test .
    index_itab_test = sy-tabix.
    call function 'SAPGUI_PROGRESS_INDICATOR'
      exporting
        percentage = 50
        text       = text-003.

    call method cl_gui_cfw=>flush
*      EXCEPTIONS
*        CNTL_SYSTEM_ERROR = 1
*        CNTL_ERROR        = 2
*        others            = 3
            .
    if sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.


    call function 'ZCL_GET_DOC_CLF10_DETAIL_DLOAD'
      exporting
        i_new_directory_name = lv_new_dirname
        wa_test              = wa_test
        i_last_path          = lv_i_last_path
        i_downloaded_path    = lv_i_last_path
      importing
        e_new_path           = lv_downloaded_path
        e_last_path          = lv_e_last_path
      tables
        it_aofile            = itab_aofile_clf10
        it_aofile_clf        = it_aofile_clf
        itab_stamps          = itab_stamps
      exceptions
        error                = 1
        no_checkout          = 2
        others               = 3.
* SP119
* Umbau auf Fehlblatt
    if sy-subrc ne 0.
      if sy-subrc = 2.
        "Fehlblatt setzen
        wa_test-knz_fehl_blatt = 'X'.
        modify itab_test from wa_test index index_itab_test.
      else.
        if sy-msgid is initial.
        else.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      endif.
    endif.
*/SP119

*    IF sy-subrc <> 0.
*      IF sy-msgid IS INITIAL.
*      ELSE.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*    ENDIF.
  endloop.


  loop at itab_clflist into wa_clflist.
    if wa_clflist cs '<%AOFILE_CLF10%>'.
      loop at it_aofile_clf into wa_aofile_clf.
        append wa_aofile_clf to itab_clf_final_data.
      endloop.
    else.
      append wa_clflist to itab_clf_final_data.
    endif.
  endloop.

* Test auf leere oder unvollständige CLF Datei
* kein Eintrag für Dateinnamen als Testkriterium
* AO$_PATH
  data: f_found.
  clear f_found.
  loop at itab_clf_final_data into wa_clflist.
    if wa_clflist cs 'AO$_PATH'.
      f_found = 'X'.
      exit.
    else.
    endif.
  endloop.
  if f_found = 'X'.
  else.
    message e034(zcvn) raising error.
  endif.

  "Löschen von temporären Dateien
  "Beachten, daß es auch einen Strukturdownload geben kann
  "



  "Test MBH
*  " \Mp6025537-011_A_printers_pdf.pdf
*  LOOP AT itab_clf_final_data INTO wa_clflist.
*    IF wa_clflist CS '\Mp6025537-011_A_printers_pdf.pdf'.
*      break bartsch.
*    ELSE.
*    ENDIF.
*  ENDLOOP.

* Download Reprolistdatei to the required destination.
* SEARCH itab_clf_final_data FOR 'AOFB'.
  if sy-subrc = 0.
    concatenate text-086  ' ' lv_x_filename into tmp_str.
    call function 'SAPGUI_PROGRESS_INDICATOR'
      exporting
        percentage = 50
        text       = tmp_str.


    data : tmp_clf_down_path like rlgrap-filename.
    move i_clf_down_path to tmp_clf_down_path.

*  The path of the destinatination to where the
*  CLF Data has to be downloaded.

    data: str_file_name type string.
    clear str_file_name.
    str_file_name = tmp_clf_down_path.

    if knz_w32_gui = 'X'.

**** Hotfix 20.12.2016 - SolMan 8000047463 - Karl Meyer - Japanische Schriftzeichen mit OM7 ----[>]
      data: lb_unicode   type  abap_bool,
            lc_codepage  type char20,
            lb_write_bom type abap_bool.

      call function '/CIDEON/UNICODE_SYSTEM'
        importing
          eb_unicode = lb_unicode.

      if lb_unicode = abap_true.
        lc_codepage = '4110'.
        lb_write_bom = abap_true.
      endif.
**** Hotfix 20.12.2016 - SolMan 8000047463 - Karl Meyer - Japanische Schriftzeichen mit OM7 ----[<]

      call function 'GUI_DOWNLOAD'
        exporting
*     BIN_FILESIZE                  =
          filename                      = str_file_name
          filetype                      = 'ASC'
*     APPEND                        = ' '
*     WRITE_FIELD_SEPARATOR         = ' '
*     HEADER                        = '00'
*     TRUNC_TRAILING_BLANKS         = ' '
*     WRITE_LF                      = 'X'
      codepage                      = lc_codepage
      write_bom                     = lb_write_bom
*     COL_SELECT                    = ' '
*     COL_SELECT_MASK               = ' '
*     DAT_MODE                      = ' '
*   IMPORTING
*     FILELENGTH                    =
        tables
          data_tab                      = itab_clf_final_data
       exceptions
         file_write_error              = 1
         no_batch                      = 2
         gui_refuse_filetransfer       = 3
         invalid_type                  = 4
         no_authority                  = 5
         unknown_error                 = 6
         header_not_allowed            = 7
         separator_not_allowed         = 8
         filesize_not_allowed          = 9
         header_too_long               = 10
         dp_error_create               = 11
         dp_error_send                 = 12
         dp_error_write                = 13
         unknown_dp_error              = 14
         access_denied                 = 15
         dp_out_of_memory              = 16
         disk_full                     = 17
         dp_timeout                    = 18
         file_not_found                = 19
         dataprovider_exception        = 20
         control_flush_error           = 21
         others                        = 22
                .
      if sy-subrc <> 0.
        data: lc_message type symsgv.
        clear lc_message.

        case sy-subrc.
          when '1'. lc_message = 'file_write_error'.
          when '2'. lc_message = 'no_batch'.
          when '3'. lc_message = 'gui_refuse_filetransfer'.
          when '4'. lc_message = 'invalid_type'.
          when '5'. lc_message = 'no_authority                  '.
          when '6'. lc_message = 'unknown_error                 '.
          when '7'. lc_message = 'header_not_allowed            '.
          when '8'. lc_message = 'separator_not_allowed         '.
          when '9'. lc_message = 'filesize_not_allowed          '.
          when '10'. lc_message = 'header_too_long              '.
          when '11'. lc_message = 'dp_error_create              '.
          when '12'. lc_message = 'dp_error_send                '.
          when '13'. lc_message = 'dp_error_write               '.
          when '14'. lc_message = 'unknown_dp_error             '.
          when '15'. lc_message = 'access_denied                '.
          when '16'. lc_message = 'dp_out_of_memory             '.
          when '17'. lc_message = 'disk_full                    '.
          when '18'. lc_message = 'dp_timeout                   '.
          when '19'. lc_message = 'file_not_found               '.
          when '20'. lc_message = 'dataprovider_exception       '.
          when '21'.
            lc_message = 'control_flush_error          '.
          when others.
        endcase.

        message e013(/cideon/plot_basis)
          with
          lc_message str_file_name
          'ZCL_PROCESS_CLF_DLOAD' 'GUI_DOWNLOAD'
          raising error.
*   Problem beim Schreiben der Transferdatei. & & & &

        "MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        "        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    else.
      data lc_fname type rs38l_fnam.
      clear lc_fname.
      lc_fname = 'WS_DOWNLOAD'.

      "CALL FUNCTION 'WS_DOWNLOAD'
      call function lc_fname
       exporting
*      BIN_FILESIZE                  = ' '
*      CODEPAGE                      = ' '
*      filename                      = lv_x_filename
         filename                      = tmp_clf_down_path
         filetype                      = 'ASC'
*      MODE                          = ' '
*      WK1_N_FORMAT                  = ' '
*      WK1_N_SIZE                    = ' '
*      WK1_T_FORMAT                  = ' '
*      WK1_T_SIZE                    = ' '
*      COL_SELECT                    = ' '
*      COL_SELECTMASK                = ' '
*      NO_AUTH_CHECK                 = ' '
       importing
         filelength                    = lv_filelength
       tables
         data_tab                      = itab_clf_final_data
*      FIELDNAMES                    =
       exceptions
         file_open_error               = 1
         file_write_error              = 2
         invalid_filesize              = 3
         invalid_type                  = 4
         no_batch                      = 5
         unknown_error                 = 6
         invalid_table_width           = 7
         gui_refuse_filetransfer       = 8
         customer_error                = 9
         others                        = 10
                .
      if sy-subrc <> 0.
        clear lc_message.

        case sy-subrc.
          when '1'. lc_message = 'file_open_error'.
          when '2'. lc_message = 'file_write_error'.
          when '3'. lc_message = 'invalid_filesize'.
          when '4'. lc_message = 'invalid_type'.
          when '5'. lc_message = 'no_authority'.
          when '6'. lc_message = 'unknown_error'.
          when '7'. lc_message = 'invalid_table_width'.
          when '8'. lc_message = 'gui_refuse_filetransfer'.
          when '9'. lc_message = 'customer_error'.

          when others.
        endcase.

        message e013(/cideon/plot_basis)
          with
          tmp_clf_down_path
          'ZCL_PROCESS_CLF_DLOAD' 'WS_DOWNLOAD'
          raising error.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      endif.

    endif.

*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**      BIN_FILESIZE                  = ' '
**      CODEPAGE                      = ' '
**      filename                      = lv_x_filename
*       filename                      = tmp_clf_down_path
*       filetype                      = 'ASC'
**      MODE                          = ' '
**      WK1_N_FORMAT                  = ' '
**      WK1_N_SIZE                    = ' '
**      WK1_T_FORMAT                  = ' '
**      WK1_T_SIZE                    = ' '
**      COL_SELECT                    = ' '
**      COL_SELECTMASK                = ' '
**      NO_AUTH_CHECK                 = ' '
*     IMPORTING
*       filelength                    = lv_filelength
*     TABLES
*       data_tab                      = itab_clf_final_data
**      FIELDNAMES                    =
*     EXCEPTIONS
*       file_open_error               = 1
*       file_write_error              = 2
*       invalid_filesize              = 3
*       invalid_type                  = 4
*       no_batch                      = 5
*       unknown_error                 = 6
*       invalid_table_width           = 7
*       gui_refuse_filetransfer       = 8
*       customer_error                = 9
*       OTHERS                        = 10
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
  else.
    message e034(zcvn) raising error.
  endif.

  refresh itab_test.
  clear itab_test.
  clear wa_test.
  refresh itab_clf_final_data.

endfunction.
