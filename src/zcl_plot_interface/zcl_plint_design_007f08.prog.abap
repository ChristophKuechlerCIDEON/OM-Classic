*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F08 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_for_not_allowed_dis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_not_allowed_dis.
* itab_search checken, ob DIS enthalten, welche für den Nutzer
* nicht zugänglich sein sollen
  DATA: itab_search_check LIKE itab_search.
  DATA: itab_search_deny LIKE itab_search.


  IF user_data-knz_check_dis = 'X'.
*   nach Klassendaten checken

    IF f_update_itab_search = 'X'.
    ELSE.
      EXIT.
    ENDIF.


    CLEAR itab_search_check.
    CLEAR itab_search_deny.

    itab_search_check[] = itab_search[].

    IF user_data-knz_check_dis_class = 'X'.
    ELSE.
    ENDIF.

*   nach Dokumentenarten checken
    IF user_data-knz_check_dis_dokar = 'X'.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


ENDFORM.                    " check_for_not_allowed_dis
*&---------------------------------------------------------------------*
*&      Form  clean_up_documents
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clean_up_documents.
* DIS bereinigen
*ITAB
  DATA: itab_class_data_no_use TYPE TABLE OF zcl_v_ug_cl_n_u.
*WA
  DATA: wa_draw_check TYPE draw.
*NORMAL
  DATA: akt_index TYPE i.

  IF user_data-knz_check_dis = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF user_data-knz_check_dis_class = 'X'.
  ELSE.
    EXIT.
  ENDIF.

* Merkmale für die nicht geplottet werden soll
  CLEAR itab_class_data_no_use.
  CALL FUNCTION '/CIDEON/GET_CLASS_NO_USE'
       EXPORTING
            i_nutzer                 = sy-uname
            i_default_nutzer         = default_data-default_nutzer
       TABLES
            o_itab_class_data_no_use = itab_class_data_no_use
       EXCEPTIONS
            error                    = 1
            OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF itab_class_data_no_use IS INITIAL.
*   halt nichts zu tun
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_search INTO wa_search.
    akt_index = sy-tabix.

    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    CLEAR wa_draw_check.
    wa_draw_check-dokar = wa_search-dokar.
    wa_draw_check-doknr = wa_search-doknr.
    wa_draw_check-doktl = wa_search-doktl.
    wa_draw_check-dokvr = wa_search-dokvr.

    CALL FUNCTION '/CIDEON/CHECK_DIS_FOR_CLASS'
         EXPORTING
              i_wa_draw                = wa_draw_check
         TABLES
              i_itab_class_data_no_use = itab_class_data_no_use
         EXCEPTIONS
              error                    = 1
              do_not_use_dis           = 2
              OTHERS                   = 3.
    IF sy-subrc <> 0.
      IF sy-subrc = 2.
        MESSAGE s003(/cideon/druck_basis)
          WITH wa_draw_check-dokar wa_draw_check-doknr
          wa_draw_check-doktl wa_draw_check-dokvr.
        DELETE itab_search INDEX akt_index.
      ELSE.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " clean_up_documents
*&---------------------------------------------------------------------*
*&      Form  maintain_UG_CLS_N_USE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_ug_cls_n_use.
* verbotenene DIS - Zuordnung Nutzergruppe zu Merkmal

  CALL TRANSACTION 'Z_CL_MNTN_UG_CLS_N_U'.

ENDFORM.                    " maintain_UG_CLS_N_USE
*&---------------------------------------------------------------------*
*&      Form  maintain_G_CLS_N_USE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_g_cls_n_use.
* verbotenene DIS - Zuordnung Nutzer zu Nutzergruppe zu Merkmal

  CALL TRANSACTION 'Z_CL_MNTN_G_CLS_N_US'.

ENDFORM.                    " maintain_G_CLS_N_USE
*&---------------------------------------------------------------------*
*&      Form  GET_DRAWING_FROM_BOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_drawing_from_bom.
* holt sich zu einem angegebenen IAM / IPT entsprechende Zeichnungen
* search in a document part list
*ITAB
  DATA: itab_draw TYPE TABLE OF draw.

  DATA: itab_documentstructure TYPE TABLE OF bapi_doc_structure.
*WA
  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.
  DATA: wa_draw TYPE draw.
  DATA: wa_stored_search TYPE zcl_psb_tmp.

  DATA: return TYPE bapiret2.
  DATA: wa_documentstructure TYPE bapi_doc_structure.
*NORMAL
  DATA: laenge TYPE i.
  DATA: char25(25).
  DATA: anzahl TYPE i.
  DATA: aennr TYPE aennr.
  DATA: ccdat TYPE ccdat.

  REFRESH itab_search_tmp.

*  CALL FUNCTION 'Z_CL_PLINT_ASK_DOCUMENT_NR'
*       IMPORTING
*            o_doknr = document
*            o_dokar = doc_type
*            o_dokvr = doc_vers
*            o_doktl = doc_part
*       EXCEPTIONS
*            error   = 1
*            OTHERS  = 2.
*  IF sy-subrc <> 0.
*    EXIT.
*  ENDIF.

  CLEAR aennr.
  CLEAR ccdat.

  CALL FUNCTION '/CIDEON/ASK_DOCUMENT_NR'
       IMPORTING
            o_doknr = document
            o_dokar = doc_type
            o_dokvr = doc_vers
            o_doktl = doc_part
            o_aennr = aennr
            o_ccdat = ccdat
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.



  CLEAR wa_stored_search.
  wa_stored_search-dokar = doc_type.
  wa_stored_search-doknr = document.
  wa_stored_search-dokvr = doc_vers.
  wa_stored_search-doktl = doc_part.

  CLEAR itab_draw.

  CALL FUNCTION '/CIDEON/GET_DRAWINGS_FOR_STRUC'
       EXPORTING
            i_dokar          = wa_stored_search-dokar
            i_doknr          = wa_stored_search-doknr
            i_doktl          = wa_stored_search-doktl
            i_dokvr          = wa_stored_search-dokvr
            i_knz_multilevel = 'X'
            I_AENNR          = aennr
            I_CCDAT          = ccdat
       TABLES
            o_itab_draw      = itab_draw
       EXCEPTIONS
            error            = 1
            OTHERS           = 2.
  IF sy-subrc <> 0.
  ELSE.
  ENDIF.

  IF itab_draw[] IS INITIAL.
    MESSAGE s045(zcl_plint_message_01)
    WITH wa_stored_search-dokar wa_stored_search-doknr
    wa_stored_search-doktl wa_stored_search-dokvr.
  ELSE.
  ENDIF.

  LOOP AT itab_draw INTO wa_draw.
    SELECT SINGLE * FROM draw INTO
      CORRESPONDING FIELDS OF wa_search
      WHERE doknr = wa_draw-doknr
      AND dokar = wa_draw-dokar
      AND doktl = wa_draw-doktl
      AND dokvr = wa_draw-dokvr
      .
    IF sy-subrc NE 0.
      wa_search-doknr = wa_draw-doknr.
      wa_search-dokar = wa_draw-dokar.
      wa_search-doktl = wa_draw-doktl.
      wa_search-dokvr = wa_draw-dokvr.
      APPEND wa_search TO itab_search.
    ELSE.
      APPEND wa_search TO itab_search.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " GET_DRAWING_FROM_BOM
*&---------------------------------------------------------------------*
*&      Form  clean_up_documents_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clean_up_documents_2.
* DIS bereinigen
*ITAB
  DATA: itab_class_data_no_use TYPE TABLE OF zcl_v_ug_cl_n_u.
*WA
  DATA: wa_draw_check TYPE draw.
*NORMAL
  DATA: akt_index TYPE i.

  IF user_data-knz_check_dis = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF user_data-knz_check_dis_class = 'X'.
  ELSE.
    EXIT.
  ENDIF.

* Merkmale für die nicht geplottet werden soll
  CLEAR itab_class_data_no_use.
  CALL FUNCTION '/CIDEON/GET_CLASS_NO_USE'
       EXPORTING
            i_nutzer                 = sy-uname
            i_default_nutzer         = default_data-default_nutzer
       TABLES
            o_itab_class_data_no_use = itab_class_data_no_use
       EXCEPTIONS
            error                    = 1
            OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF itab_class_data_no_use IS INITIAL.
*   halt nichts zu tun
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_search_tmp INTO wa_search.
    akt_index = sy-tabix.

    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    CLEAR wa_draw_check.
    wa_draw_check-dokar = wa_search-dokar.
    wa_draw_check-doknr = wa_search-doknr.
    wa_draw_check-doktl = wa_search-doktl.
    wa_draw_check-dokvr = wa_search-dokvr.

    CALL FUNCTION '/CIDEON/CHECK_DIS_FOR_CLASS'
         EXPORTING
              i_wa_draw                = wa_draw_check
         TABLES
              i_itab_class_data_no_use = itab_class_data_no_use
         EXCEPTIONS
              error                    = 1
              do_not_use_dis           = 2
              OTHERS                   = 3.
    IF sy-subrc <> 0.
      IF sy-subrc = 2.
        MESSAGE i004(/cideon/druck_basis)
          WITH wa_draw_check-dokar wa_draw_check-doknr
          wa_draw_check-doktl wa_draw_check-dokvr.
        DELETE itab_search_tmp INDEX akt_index.
      ELSE.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " clean_up_documents_2
*&---------------------------------------------------------------------*
*&      Form  maintain_grp_dis_not_stamp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_grp_dis_not_stamp.
* DIS nicht Stempeln - Zuordnung Nutzer zu Nutzergruppe zu Merkmal

  CALL TRANSACTION 'Z_CL_MNTNG_CL_N_US_S'.

ENDFORM.                    " maintain_grp_dis_not_stamp
*&---------------------------------------------------------------------*
*&      Form  maintain_usr_grp_dis_not_stamp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_usr_grp_dis_not_stamp.
* DIS nicht Stempeln - Zuordnung Nutzergruppe zu Merkmal

  CALL TRANSACTION 'Z_CL_MNTNUG_CL_N_U_S'.

ENDFORM.                    " maintain_usr_grp_dis_not_stamp
