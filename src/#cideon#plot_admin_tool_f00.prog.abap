*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_ADMIN_TOOL_F00 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  view_dis_original
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_dis_original.

* Anzeige des DIS Originals

* Spoolbehandlung
*  IF wa_v_adm_01-object_type = 'SPOOL'.
*    CALL METHOD alv_plotjobs->set_visible( ' ' ).
**    call method cl_gui_cfw=>flush.
*    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
*         EXPORTING
*              i_spoolid = wa_v_adm_01-tdspoolid
*         EXCEPTIONS
*              error     = 1
*              OTHERS    = 2.
*    IF sy-subrc <> 0.
**      EXIT.
*    ENDIF.
*    CALL METHOD alv_plotjobs->set_visible( 'X' ).
**    EXIT.
*  ELSE.
**    SET PARAMETER ID 'CV1' FIELD wa_v_adm_01-doknr.
**    SET PARAMETER ID 'CV2' FIELD wa_v_adm_01-dokar.
**    SET PARAMETER ID 'CV3' FIELD wa_v_adm_01-dokvr.
**    SET PARAMETER ID 'CV4' FIELD wa_v_adm_01-doktl.
**
**    CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
*
*    "Anzeige des Originals
*
*  ENDIF.


  CASE wa_v_adm_01-object_type.
    WHEN 'SPOOL'.
      CALL METHOD alv_plotjobs->set_visible( ' ' ).
*    call method cl_gui_cfw=>flush.
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
           EXPORTING
                i_spoolid = wa_v_adm_01-tdspoolid
           EXCEPTIONS
                error     = 1
                OTHERS    = 2.
      IF sy-subrc <> 0.
*      EXIT.
      ENDIF.
      CALL METHOD alv_plotjobs->set_visible( 'X' ).
    WHEN 'URL'.
      CALL FUNCTION '/CIDEON/OM_ITEM_SHOW_URL'
           EXPORTING
                i_url = wa_v_adm_01-url.

    WHEN OTHERS.
      SET PARAMETER ID 'CV1' FIELD wa_v_adm_01-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_v_adm_01-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_v_adm_01-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_v_adm_01-doktl.


* HOSTNAME holen
      DATA: hostname(20).
      CALL FUNCTION 'CV120_GET_HOSTNAME'
           EXPORTING
                pf_batch          = ' '
           IMPORTING
                pfx_host          = hostname
           EXCEPTIONS
                error             = 1
                no_valid_frontend = 2
                OTHERS            = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      DATA: lt_files TYPE TABLE OF cvapi_doc_file.
      DATA: ls_files TYPE cvapi_doc_file.


      CLEAR lt_files.
      CLEAR ls_files.

      CALL FUNCTION 'CVAPI_DOC_GETDETAIL'
        EXPORTING
*   PF_BATCHMODE          = ' '
*   PF_HOSTNAME           = ' '
          pf_dokar              = wa_v_adm_01-dokar
          pf_doknr              = wa_v_adm_01-doknr
          pf_dokvr              = wa_v_adm_01-dokvr
          pf_doktl              = wa_v_adm_01-doktl
*   PF_READ_DRAD          = ' '
*   PF_READ_DRAP          = ' '
         pf_active_files       = 'X'
*   PF_READ_COMP          = ' '
         pf_read_kpro          = 'X'
         pf_read_drat          = 'X'
* IMPORTING
*   PSX_DRAW              =
*   PFX_DESCRIPTION       =
       TABLES
         pt_files              = lt_files
*   PT_COMP               =
*   PT_DRAP               =
*   PT_DRAD               =
*   PT_DRAT               =
       EXCEPTIONS
         not_found             = 1
         no_auth               = 2
         error                 = 3
         OTHERS                = 4
                .
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      READ TABLE lt_files INTO ls_files
        WITH KEY appnr = wa_v_adm_01-originaltype.


      CALL FUNCTION 'CVAPI_DOC_VIEW'
        EXPORTING
          pf_dokar               = wa_v_adm_01-dokar
          pf_doknr               = wa_v_adm_01-doknr
          pf_dokvr               = wa_v_adm_01-dokvr
          pf_doktl               = wa_v_adm_01-doktl
          pf_hostname            = hostname
          pf_appl_start          = 'X'
*     PF_GET_URL             = ' '
          pf_apptp               = '1'
*     PF_ASK_FILENAME        = ' '
*     PF_FILENAME            = ' '
          ps_file                = ls_files
*     PF_PARENT              =
*     PF_USE_DYNP            = ' '
*     PS_DRAP_AUDIT          =
*   IMPORTING
*     PFX_FILE               =
*     PFX_URL                =
*     PFX_VIEW_INPLACE       =
       EXCEPTIONS
          error                  = 1
          not_found              = 2
          no_auth                = 3
          no_original            = 4
          OTHERS                 = 5
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.




  ENDCASE.


ENDFORM.                    " view_dis_original
