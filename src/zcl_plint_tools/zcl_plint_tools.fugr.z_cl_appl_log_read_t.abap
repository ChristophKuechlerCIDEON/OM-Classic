FUNCTION z_cl_appl_log_read_t.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DATE) LIKE  SY-DATUM
*"     VALUE(I_TIME) LIKE  SY-UZEIT
*"     VALUE(I_DIFF) DEFAULT '0600'
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------

  DATA: date_from LIKE sy-datum.
  DATA: date_to   LIKE sy-datum.
  DATA: time_from LIKE sy-uzeit.
  DATA: time_to   LIKE sy-uzeit.

  time_from = i_time - i_diff.
  IF time_from > i_time.
    date_from = i_date - 1.
  ELSE.
    date_from = i_date.
  ENDIF.
  time_to = i_time + i_diff.
  IF time_to < i_time.
    date_to = i_date + 1.
  ELSE.
    date_to = i_date.
  ENDIF.

  CALL FUNCTION 'APPL_LOG_DISPLAY'
       EXPORTING
            object                         = ' '
            subobject                      = ' '
            external_number                = ' '
            object_attribute               = 0
            subobject_attribute            = 0
            external_number_attribute      = 0
            date_from                      = date_from
            time_from                      = time_from
            date_to                        = date_to
            time_to                        = time_to
            title_selection_screen         = ' '
            title_list_screen              = ' '
*            column_selection               = '11112221122   '
            suppress_selection_dialog      = 'X'
            column_selection_msg_jump      = '1'
            external_number_display_length = 20
*           i_s_display_profile            =
            i_variant_report               = ' '
*      importing
*           number_of_protocols            =
       EXCEPTIONS
            no_authority                   = 1
            OTHERS                         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFUNCTION.
