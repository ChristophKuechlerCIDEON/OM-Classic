FUNCTION z_cl_event_check_rel_status.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"     VALUE(EVENT) LIKE  SWEINSTCOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      NO_RELEASED_STATUS
*"      NO_STATUS_CHANGE
*"      STATUS_NOT_FOUND
*"      DELETE_FLAG_SET
*"      NO_AUTHORIZED_USER
*"----------------------------------------------------------------------

  TABLES: tdws.

  DATA: l_old_status LIKE draw-dokst,
        l_new_status LIKE draw-dokst,
        l_return.
  DATA:  draw_key LIKE cvdidrawkey.

  swc_get_element event_container 'DOCUMENTSTATUS'     l_new_status.
  swc_get_element event_container 'DOCUMENTSTATUS_OLD' l_old_status.

  READ TABLE event_container
      WITH KEY element =  '_EVT_CREATOR                    '.
  g_user = event_container-value+2. " ohne value +44.


  IF NOT g_user = 'SCHULTE'.
    RAISE no_authorized_user.
  ENDIF.

*  aus noch nicht erklärbaren Gründen werden oft zwei Events ausgelöst,
*  eines mit 'DOCUMENTSTATUS_OLD' und eines ohne

  IF l_old_status IS INITIAL.
    RAISE no_released_status.
  ENDIF.

* no status change
  IF l_new_status = l_old_status.
    RAISE no_status_change.
  ENDIF.

  draw_key = objkey.

* read status information from customizing table tdws
  SELECT SINGLE * FROM tdws WHERE dokar = draw_key-dokar
                            AND   dokst = l_new_status.
  IF sy-subrc <> 0.
    RAISE status_not_found.
  ENDIF.

*  check if new status is EP
*  IF NOT l_new_status = 'EP'.
*    RAISE no_released_status.
*  ENDIF.
** check if status is a release status
*    IF tdws-frknz IS INITIAL.
*      RAISE no_released_status.
*    ENDIF.

* check if delete flag is set for document
  SELECT SINGLE * FROM draw WHERE dokar = draw_key-dokar
                            AND   doknr = draw_key-doknr
                            AND   dokvr = draw_key-dokvr
                            AND   doktl = draw_key-doktl
                            AND   loedk = 'X'.
  IF sy-subrc = 0.
    RAISE delete_flag_set.
  ENDIF.

ENDFUNCTION.
