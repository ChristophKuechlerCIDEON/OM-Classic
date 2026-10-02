FUNCTION z_cl_doc_change_check_batch .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      ANY_EXCEPTION
*"----------------------------------------------------------------------

  f_new_head = 'X'.
  CLEAR text1.
  CLEAR text2.
  CLEAR text3.
  CLEAR text4.
  text1 = objtype.
  text2 = event.

  READ TABLE event_container
      WITH KEY element =  '_EVT_CREATOR                    '.
  g_user = event_container+44.

  IF g_user = 'SCHULTE'.

    READ TABLE event_container
        WITH KEY element =  '_EVT_OBJKEY                     '.

    g_draw_key = event_container+42.

    SELECT SINGLE * FROM draw INTO wa_draw
        WHERE dokar = g_draw_key-dokar
        AND   doknr = g_draw_key-doknr
        AND   doktl = g_draw_key-doktl
        AND   dokvr = g_draw_key-dokvr.
    IF sy-subrc = 0.

      READ TABLE event_container
          WITH KEY element =  'DOCUMENTSTATUS_OLD              '.
      g_documentstatus = event_container+42.

      IF sy-subrc = 0.

        READ TABLE event_container
             WITH KEY element =  'DOCUMENTSTATUS                  '.

        g_documentstatus_old = event_container+42.

        IF sy-subrc = 0.

          IF g_documentstatus = g_documentstatus_old.
            RAISE any_exception.
            text3 = 'Status not changed'.
            CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_RFC'
                 EXPORTING
                      i_object   = 'Z_CIDEON'
                      i_subobj   = 'Z_PLOT'
                      i_number   = 101
                      i_msgtyp   = 'S'
                      i_msgid    = '26'
                      i_msgno    = '500'
                      i_msgv1    = text1
                      i_msgv2    = text2
                      i_msgv3    = text3
                      i_msgv4    = text4
                      i_class    = ' '
                      i_newhead  = f_new_head
                      i_messhead = 'X'.
            IF sy-subrc <> 0.
            ENDIF.

          ENDIF.

        ELSE.
          RAISE any_exception.
          text3 = 'Status not changed'.
          CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_RFC'
               EXPORTING
                    i_object   = 'Z_CIDEON'
                    i_subobj   = 'Z_PLOT'
                    i_number   = 101
                    i_msgtyp   = 'S'
                    i_msgid    = '26'
                    i_msgno    = '500'
                    i_msgv1    = text1
                    i_msgv2    = text2
                    i_msgv3    = text3
                    i_msgv4    = text4
                    i_class    = ' '
                    i_newhead  = f_new_head
                    i_messhead = 'X'.
          IF sy-subrc <> 0.
          ENDIF.

        ENDIF.

      ELSE.
        RAISE any_exception.
        text3 = 'Status not changed'.
        CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_RFC'
             EXPORTING
                  i_object   = 'Z_CIDEON'
                  i_subobj   = 'Z_PLOT'
                  i_number   = 101
                  i_msgtyp   = 'S'
                  i_msgid    = '26'
                  i_msgno    = '500'
                  i_msgv1    = text1
                  i_msgv2    = text2
                  i_msgv3    = text3
                  i_msgv4    = text4
                  i_class    = ' '
                  i_newhead  = f_new_head
                  i_messhead = 'X'.
        IF sy-subrc <> 0.
        ENDIF.
      ENDIF.

    ELSE.
      RAISE any_exception.
      text3 = 'Document not existent'.
      CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_RFC'
           EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = 101
                i_msgtyp   = 'S'
                i_msgid    = '26'
                i_msgno    = '500'
                i_msgv1    = text1
                i_msgv2    = text2
                i_msgv3    = text3
                i_msgv4    = text4
                i_class    = ' '
                i_newhead  = f_new_head
                i_messhead = 'X'.
      IF sy-subrc <> 0.
      ENDIF.
    ENDIF.

  ELSE.
    RAISE any_exception.
    text3 = 'User not authorized'.
    CALL FUNCTION 'Z_CL_APPL_LOG_WRITE_RFC'
         EXPORTING
              i_object   = 'Z_CIDEON'
              i_subobj   = 'Z_PLOT'
              i_number   = 101
              i_msgtyp   = 'S'
              i_msgid    = '26'
              i_msgno    = '500'
              i_msgv1    = text1
              i_msgv2    = text2
              i_msgv3    = text3
              i_msgv4    = text4
              i_class    = ' '
              i_newhead  = f_new_head
              i_messhead = 'X'.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.

ENDFUNCTION.
