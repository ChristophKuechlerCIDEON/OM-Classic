*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LSTAMP_BASISF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  parameter_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM parameter_check.
  IF keep_luw <> space.
    dump = 'X'.
  ENDIF.
ENDFORM.                    " parameter_check
*&---------------------------------------------------------------------*
*&      Form  send
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P__1  text
*----------------------------------------------------------------------*
FORM send USING
            count        TYPE i.
*ORM SEND USING COUNT.
  DATA : size TYPE i.
  DATA : repcnt TYPE i.
  DATA : mintime TYPE f VALUE 1000000000.
  DATA : rfc_mess(80).
  DATA : t(10) TYPE p.

  FREE rfctab.
  IF count > 0 .
    DO count TIMES.
      rfctab = rfctest.
      rfctab-rfcint4  = count.
      APPEND rfctab.
    ENDDO.
    repcnt = repeat.
  ELSE.
    repcnt = 1.
  ENDIF.
  DO repcnt TIMES.
    GET RUN TIME FIELD ta.
    IF authchk = space.                "Ping Without authority check
      IF dump = space.
        CALL FUNCTION  'RFC_PING' DESTINATION dest
             TABLES rfctab40 = rfctab
             EXCEPTIONS system_failure = 1
                        MESSAGE rfc_mess
                        communication_failure = 2
                        MESSAGE rfc_mess.
      ELSEIF keep_luw <> space.
        CALL FUNCTION  'RFC_PING' DESTINATION dest
             KEEPING LOGICAL UNIT OF WORK
             TABLES rfctab40 = rfctab
             EXCEPTIONS system_failure = 1
                        MESSAGE rfc_mess
                        communication_failure = 2
                        MESSAGE rfc_mess.

      ELSE.
        CALL FUNCTION  'RFC_PING' DESTINATION dest
             TABLES rfctab40 = rfctab.
      ENDIF.
    ELSE.                              "Ping with authorithy check
* RFC-Systemcall (SRFC-FunGr) damit das RFC-Anmeldebild nicht erscheint
      CALL FUNCTION  'RFC_PING' DESTINATION dest
           TABLES rfctab40 = rfctab
           EXCEPTIONS system_failure = 1
                      MESSAGE rfc_mess
                      communication_failure = 2
                      MESSAGE rfc_mess.

      IF dump = space.
        CALL FUNCTION  'RFCPING' DESTINATION dest
           TABLES rfctab40 = rfctab
           EXCEPTIONS system_failure = 1
                      MESSAGE rfc_mess
                      communication_failure = 2
                      MESSAGE rfc_mess.
      ELSEIF keep_luw <> space.
        CALL FUNCTION  'RFCPING' DESTINATION dest
          KEEPING LOGICAL UNIT OF WORK
          EXCEPTIONS system_failure = 1
                     MESSAGE rfc_mess
                     communication_failure = 2
                     MESSAGE rfc_mess.

      ELSE.
        CALL FUNCTION  'RFCPING' DESTINATION dest
              TABLES rfctab40 = rfctab.
      ENDIF.
    ENDIF.                             "authorithy check
    l_subrc = syst-subrc.
    GET RUN TIME FIELD te.
    IF l_subrc <> 0.
*     len = strlen( rfc_mess ) + 5.
*     new-page line-size len no-heading.
      CALL FUNCTION 'TH_ERR_GET'
           IMPORTING
                call      = call
                component = component
                counter   = counter
                detail    = detail
                errno     = errno
                errno_txt = errno_txt
                error     = error
                line      = line
                location  = location
                module    = module
                rc        = rc
                release   = release
                subrc     = subrc
                time      = time
                version   = version.
      IF subrc = 0.
*        error <> space or location <> space or detail <> space or
*        call <> space or component <> space.
        cpic_detail_available = 'X'.
      ELSE.
        CLEAR cpic_detail_available.
      ENDIF.
      EXIT.
    ELSE.
      tx = te - ta.
      IF mintime > tx.
        mintime = tx.
      ENDIF.
    ENDIF.
    syst-subrc = 0.
  ENDDO.

  IF l_subrc = 1.
    raise abbruch.
  else.
    IF l_subrc = 2.
      raise verbindungsfehler.
    else.
    ENDIF.
  ENDIF.

ENDFORM.                    " send
*&---------------------------------------------------------------------*
*&      Form  CPIC_DETAIL_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RFC_MESS  text
*----------------------------------------------------------------------*
FORM cpic_detail_help USING    p_rfc_mess.

ENDFORM.                    " CPIC_DETAIL_HELP
