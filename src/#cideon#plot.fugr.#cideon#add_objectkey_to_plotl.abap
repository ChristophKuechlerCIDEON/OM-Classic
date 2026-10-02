FUNCTION /cideon/add_objectkey_to_plotl.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      ITAB_TMP_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
* 12.07.2004 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    CALL FUNCTION 'Z_CL_MAKE_OBJECT_KEY'
         EXPORTING
              i_dokar = wa_plotjobs-dokar
              i_doknr = wa_plotjobs-doknr
              i_dokvr = wa_plotjobs-dokvr
              i_doktl = wa_plotjobs-doktl
         IMPORTING
              o_objky = wa_plotjobs-objky
         EXCEPTIONS
              error   = 1
              OTHERS  = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

ENDFUNCTION.
