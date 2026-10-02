FUNCTION z_cl_psbrw_write_psb_tmp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      I_ITAB_OBJECTS STRUCTURE  PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*  Schreibt Einträge in Tabelle ZCL_PSB_TMP
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 03.09.2002 - Erstellung
* 06.11.2006 - Übergabe der Änderungsnummer
*
* SP 119
* 7.0.1.20
* 18.02.2010 - Übergabe der Materialnummer aus dem PSB
*              Umbau auf /CIDEON/PSBRW_WRT_PSB_TMP_FRTA
*              in Z_CL_PSBRW_WRITE_PSB_TMP
*              KMO
*
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_objects TYPE TABLE OF pdm_exp_objects.
*WA
  DATA: wa_objects TYPE pdm_exp_objects.
*NORMAL
  DATA: counter TYPE zcl_psb_tmp-counter.


  REFRESH itab_objects.
  CLEAR wa_objects.

  itab_objects[] = i_itab_objects[].

* 2010/02/18
  "Benutzung der Funktion /CIDEON/PSBRW_WRT_PSB_TMP_FRTA
  DATA: lt_objects_new TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: ls_objects_new TYPE zcl_pdm_exp_objects.

  CLEAR lt_objects_new.
  CLEAR ls_objects_new.

  LOOP AT itab_objects INTO wa_objects.
    CLEAR ls_objects_new.
    MOVE-CORRESPONDING wa_objects TO ls_objects_new.
    APPEND ls_objects_new TO lt_objects_new.
  ENDLOOP.

  CALL FUNCTION '/CIDEON/PSBRW_WRT_PSB_TMP_FRTA'
    TABLES
      i_itab_objects       = lt_objects_new
*   EXCEPTIONS
*     ERROR                = 1
*     OTHERS               = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  EXIT.

* 2010/02/18
* /Ende








*  CLEAR wa_stored_search.
*  wa_stored_search-uname = sy-uname.
*  wa_stored_search-zclinsname = sy-uname.
*  wa_stored_search-zclinsdate = sy-datum.
*  wa_stored_search-zclinstime = sy-uzeit.
*  wa_stored_search-zclinsprog = sy-repid.
*  wa_stored_search-zclupdname = sy-uname.
*  wa_stored_search-zclupddate = sy-datum.
*  wa_stored_search-zclupdtime = sy-uzeit.
*  wa_stored_search-zclupdprog = sy-repid.
*
*  LOOP AT itab_objects INTO wa_objects.
*    wa_stored_search-dokar = wa_objects-dokar.
*    wa_stored_search-doknr = wa_objects-doknr.
*    wa_stored_search-dokvr = wa_objects-dokvr.
*    wa_stored_search-doktl = wa_objects-doktl.
*    wa_stored_search-object_type = wa_objects-object_type.
*
**   Änderungsnummer
*    wa_stored_search-aennr = wa_objects-aennr.
*
*
*    CLEAR counter.
*
*    CALL FUNCTION 'Z_CL_PLOT_ID_SL_GET_NEXT'
*         EXPORTING
*              i_numrange_object   = 'ZCL_ID_PSB'
*              i_numrange_interval = '01'
*         IMPORTING
*              e_number            = counter.
*
*
**    select max( counter ) from ZCL_PSB_TMP
**      into counter
**      where uname = wa_stored_search-uname
**      and dokar = wa_stored_search-dokar
**      and doknr = wa_stored_search-doknr
**      and dokvr = wa_stored_search-dokvr
**      and doktl = wa_stored_search-doktl
**      .
**    if sy-subrc ne 0.
**      clear counter.
**    else.
**      counter = counter + 1.
**    endif.
*
*    wa_stored_search-counter = counter.
*
*    INSERT zcl_psb_tmp FROM wa_stored_search.
**    MODIFY zcl_psb_tmp FROM wa_stored_search.
*    IF sy-subrc NE 0.
*      CLEAR text1. CLEAR text2. CLEAR text3. CLEAR text4.
*      text1 = 'ZCL_PSB_TMP'.
*      CONCATENATE wa_stored_search-dokar wa_stored_search-doknr
*        wa_stored_search-dokvr wa_stored_search-doktl
*        INTO text2.
*      CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
*           EXPORTING
*                i_object   = 'Z_CIDEON'
*                i_subobj   = 'Z_PLOT'
*                i_number   = 150
*                i_msgtyp   = 'S'
*                i_msgid    = 'ZCL_PLINT_MESSAGE_01'
*                i_msgno    = 150
*                i_msgv1    = text1
*                i_msgv2    = text2
*                i_msgv3    = text3
*                i_msgv4    = text4
*                i_class    = ' '
*                i_newhead  = 'X'
*                i_messhead = 'X'
*           EXCEPTIONS
*                error      = 1
*                OTHERS     = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*    ELSE.
*
*    ENDIF.
*  ENDLOOP.


ENDFUNCTION.
