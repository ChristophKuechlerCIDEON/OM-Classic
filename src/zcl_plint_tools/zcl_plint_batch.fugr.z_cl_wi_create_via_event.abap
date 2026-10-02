FUNCTION z_cl_wi_create_via_event.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"     VALUE(EXCEPTIONS_ALLOWED) LIKE  SWEFLAGS-EXC_OK DEFAULT SPACE
*"  EXPORTING
*"     VALUE(REC_ID) LIKE  SWELOG-RECID
*"     VALUE(E_OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"     VALUE(E_USER) LIKE  SY-UNAME
*"     VALUE(E_OLD_STATUS) LIKE  DRAW-DOKST
*"     VALUE(E_NEW_STATUS) LIKE  DRAW-DOKST
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      READ_FAILED
*"      CREATE_FAILED
*"----------------------------------------------------------------------

  DATA: wa_event_container TYPE swcont.

  CALL FUNCTION 'SWW_WI_CREATE_VIA_EVENT'
       EXPORTING
            event              = event
            rectype            = rectype
            objtype            = objtype
            objkey             = objkey
            exceptions_allowed = exceptions_allowed
       IMPORTING
            rec_id             = rec_id
       TABLES
            event_container    = event_container
       EXCEPTIONS
            read_failed        = 1
            create_failed      = 2
            OTHERS             = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  e_objkey = objkey.
*  swc_get_element event_container 'DOCUMENTSTATUS'     e_new_status.
*  swc_get_element event_container 'DOCUMENTSTATUS_OLD' e_old_status.
*
*  READ TABLE event_container
*      WITH KEY element =  '_EVT_CREATOR                    '.
*  e_user = event_container-value+2. " ohne value +44.
*
*  CLEAR wa_event_container.
*  wa_event_container-element = '_EVT_DOCUMENTSTATUS_NEW'.
*  wa_event_container-value   = e_new_status.
*  APPEND wa_event_container TO event_container.
*
*  CLEAR wa_event_container.
*  wa_event_container-element = '_EVT_DOCUMENTSTATUS_OLD'.
*  wa_event_container-value   = e_old_status.
*  APPEND wa_event_container TO event_container.
*
*  CLEAR wa_event_container.
*  wa_event_container-element = '_EVT_USER'.
*  wa_event_container-value   = e_user.
*  APPEND wa_event_container TO event_container.
*
*
  COMMIT WORK.


ENDFUNCTION.
