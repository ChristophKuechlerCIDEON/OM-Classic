*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_ADMIN_TOOL000_FR3 .
*----------------------------------------------------------------------*
form get_stamp_values.
* get the values for the stamps
  data: index_itab_plotjobs_2 type sy-tabix.
* itab_tmp_plotjobs_2
* itab_stempel_wert

  refresh itab_stempel_default.
  select * from zcl_stamp_defaul
    into table itab_stempel_default
    where status = c_status_aktiv
    .
  if sy-subrc ne 0.
  else.
  endif.

  refresh itab_stempel_user.
  select * from zcl_stamp_user
    into table itab_stempel_user
    where status = c_status_aktiv
    and uname = sy-uname
    .
  if sy-subrc ne 0.
  else.
  endif.


  refresh itab_stempel_wert.

  loop at itab_tmp_plotjobs_2 into wa_plotjobs.
    refresh itab_stempel_voreinstellung.
    select * from zcl_stamp_vorein
      into table itab_stempel_voreinstellung
      where status = c_status_aktiv
      and voreinstellung = wa_plotjobs-voreinstellung
      .
    if sy-subrc ne 0.
    else.
    endif.
    if user_data-knz_use_post = 'X'.
    else.
      "bei CLF bei Voreinstellungen
      refresh itab_stempel_voreinstellung.
    endif.

    refresh itab_stempel_verteiler.
    select * from zcl_stamp_vertei
      into table itab_stempel_verteiler
      where status = c_status_aktiv
      and verteiler = wa_plotjobs-verteiler
      .
    if sy-subrc ne 0.
    else.
    endif.


    index_itab_plotjobs_2 = sy-tabix.

*   default stamps
    loop at itab_stempel_default into wa_stempel_default.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_default-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_default-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        continue.
      endif.
      call function wa_stempel_default-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_default-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.

*   user stamps
    loop at itab_stempel_user into wa_stempel_user.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_user-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_user-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      endif.
      call function wa_stempel_user-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_user-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.

*   Voreinstellung stamps
    loop at itab_stempel_voreinstellung into wa_stempel_voreinstellung.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_voreinstellung-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_vor'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_voreinstellung-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      endif.
      call function wa_stempel_user-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_voreinstellung-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.

*   Verteiler stamps
    loop at itab_stempel_verteiler into wa_stempel_verteiler.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_verteiler-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_vert'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_verteiler-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      endif.
      call function wa_stempel_user-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_verteiler-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.
  endloop.
endform.                    " get_stamp_values
*---------------------------------------------------------------------*
*       FORM appl_log_write                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(TYP)                                                    *
*  -->  VALUE(NUMMER)                                                 *
*  -->  VALUE(KLASSE)                                                 *
*  -->  VALUE(MESSAGE1)                                               *
*  -->  VALUE(MESSAGE2)                                               *
*  -->  VALUE(MESSAGE3)                                               *
*  -->  VALUE(MESSAGE4)                                               *
*---------------------------------------------------------------------*
form appl_log_write using    value(typ)
                             value(nummer)
                             value(klasse)
                             value(message1)
                             value(message2)
                             value(message3)
                             value(message4).
  data: number(3) type n.
  data: msgno type symsgno.

  clear msgv1.
  clear msgv2.
  clear msgv3.
  clear msgv4.
  msgv1 = message1.
  msgv2 = message2.
  msgv3 = message3.
  msgv4 = message4.
  number = nummer.
  msgno = nummer.

  call function '/CIDEON/APPL_LOG_WRITE_2'
       exporting
            i_object   = 'Z_CIDEON'
            i_subobj   = 'Z_PLOT'
            i_number   = msgno
            i_msgtyp   = typ
            i_msgid    = klasse
            i_msgno    = msgno
            i_msgv1    = msgv1
            i_msgv2    = msgv2
            i_msgv3    = msgv3
            i_msgv4    = msgv4
            i_class    = ' '
            i_newhead  = ' '
            i_messhead = ' '
       exceptions
            error      = 1
            others     = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " appl_log_write
