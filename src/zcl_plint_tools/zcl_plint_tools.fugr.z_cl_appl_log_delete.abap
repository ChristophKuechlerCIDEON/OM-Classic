FUNCTION z_cl_appl_log_delete.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DAYS) TYPE  I
*"  EXCEPTIONS
*"      ERROR
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

  DATA: date_to TYPE balhdr-aldate.
  DATA: time_to TYPE balhdr-altime.

  DATA: del_log TYPE i.
  DATA: non_del_log TYPE i.

  DATA: akt_date TYPE sy-datum.


  akt_date = sy-datum.
  date_to = akt_date - i_days.


  CALL FUNCTION 'APPL_LOG_DELETE'
    EXPORTING
      object                           = 'Z_CIDEON'
*      subobject                        = 'Z_PLOT'
*      EXTERNAL_NUMBER                  = '*'
      date_to                          = date_to
      time_to                          = time_to
*     LOG_CLASS                        = '4'
*     I_WITH_COMMIT_WORK               = 'X'
   IMPORTING
     number_of_deleted_logs           = del_log
     number_of_non_deleted_logs       = non_del_log
   EXCEPTIONS
     no_authority                     = 1
     OTHERS                           = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    PERFORM appl_log_write USING
      'S' '015' 'ZCL_PLINT_TOOLS'
      del_log non_del_log '' ''.
    MESSAGE s015(zcl_plint_tools)
      WITH del_log non_del_log '' ''.
  ENDIF.





ENDFUNCTION.
