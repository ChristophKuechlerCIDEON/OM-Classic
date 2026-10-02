FUNCTION /cideon/display_spool_id.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_SPOOLID) TYPE  RSPOID
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 01.01.2004 - Erstellung
*-----------------------------------------------------------------------

*TYPES
  TYPES: BEGIN OF sp01r_id,
           id LIKE tsp01-rqident.
          INCLUDE STRUCTURE alsysid.
  TYPES: END OF sp01r_id.
*ITAB
  DATA: itab_id_list TYPE TABLE OF sp01r_id.
*WA
  DATA: wa_id_list TYPE sp01r_id.
*NORMAL
  DATA: spool_req_not_found TYPE i.

  CLEAR itab_id_list.
  CLEAR wa_id_list.

  wa_id_list-id = i_spoolid.

  APPEND wa_id_list TO itab_id_list.

  CALL FUNCTION 'RSPO_RID_SPOOLREQ_DISP'
       EXPORTING
            id_list            = itab_id_list
       IMPORTING
            spoolreq_not_found = spool_req_not_found
       EXCEPTIONS
            error              = 1
            OTHERS             = 2.
  IF sy-subrc <> 0.
    RAISE error.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.














ENDFUNCTION.
