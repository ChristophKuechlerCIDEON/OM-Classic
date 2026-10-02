FUNCTION /cideon/add_cost_center_2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
* 19.07.2004 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.

* try to get the cost center for the user
  DATA: kostl LIKE wa_plotjobs-kostl.

  IF i_wa_user_data-knz_use_kostl = 'X'.
  ELSE.
    EXIT.
  ENDIF.


  CALL FUNCTION 'Z_CL_ASK_FOR_COSTCENTER'
       EXPORTING
            i_user          = sy-uname
       IMPORTING
            o_kostl         = kostl
       EXCEPTIONS
            error           = 1
            pernr_not_found = 2
            kostl_not_found = 3
            OTHERS          = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  make LOG entry
    CLEAR text1.
    CLEAR text2.
    CLEAR text3.
    CLEAR text4.
    text1 = sy-uname.

    CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
         EXPORTING
              i_object   = 'Z_CIDEON'
              i_subobj   = 'Z_PLOT'
              i_number   = 067
              i_msgtyp   = 'W'
              i_msgid    = 'ZCL_PLINT_MESSAGE_01'
              i_msgno    = 067
              i_msgv1    = text1
              i_msgv2    = text2
              i_msgv3    = text3
              i_msgv4    = text4
              i_class    = ' '
              i_newhead  = 'X'
              i_messhead = 'X'
         EXCEPTIONS
              error      = 1
              OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    EXIT.
  ENDIF.


  LOOP AT itab_plotjobs INTO wa_plotjobs.
    wa_plotjobs-kostl = kostl.
    MODIFY itab_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.



ENDFUNCTION.
