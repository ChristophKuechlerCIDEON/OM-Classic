*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/LCDESK_MAT_BOM2F03                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  itm_category_read
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_POSTP  text
*      -->P_I_POTPR  text
*      -->P_CONST_FLG_NO  text
*      <--P_L_FLG_ITM_CHECK_ABORTED  text
*      <--P_L_FLG_CLS_ITEM  text
*      <--P_LS_T418  text
*----------------------------------------------------------------------*
FORM itm_category_read
        USING
            i_itm_class_data_postp     LIKE itm_class_data-postp
            i_itm_class_data_potpr     LIKE itm_class_data-potpr
            i_flg_postp_exist_check    LIKE csdata-xfeld
         CHANGING
            e_flg_itm_check_aborted LIKE csdata-xfeld
            e_flg_cls_item          LIKE csdata-xfeld
            e_t418                  STRUCTURE t418.

  CLEAR: e_flg_itm_check_aborted.

  CALL FUNCTION 'T418_READ_WITH_POTPR'
       EXPORTING
            postp          = i_itm_class_data_postp
            potpr          = i_itm_class_data_potpr
       IMPORTING
            struct         = e_t418
            flg_cls_item   = e_flg_cls_item
       EXCEPTIONS
            no_entry_postp = 1
            no_entry_potpr = 2.

  CHECK sy-subrc NE 0.

  IF i_flg_postp_exist_check IS INITIAL.
    e_flg_itm_check_aborted = cs_check-flg_yes.
    EXIT.
  ENDIF.

  CASE sy-subrc.
    WHEN 1.
*---- Positionstyp & ist nicht vorgesehen
      IF cs_check-flg_yes EQ cs_check-flg_switch.

        PERFORM message_collect
           USING
              message_type-error
              cs_check-msgid_29
              '883'
              i_itm_class_data_postp
              ' ' ' ' ' '.
        e_flg_itm_check_aborted = cs_check-flg_yes.
      ELSE.
        MESSAGE e883(29)
           WITH i_itm_class_data_postp.
*           raising item_category_error.
      ENDIF.
    WHEN 2.
*---- Resultierender Positionstyp & ist nicht vorgesehen
      IF cs_check-flg_yes EQ cs_check-flg_switch.

        PERFORM message_collect
           USING
              message_type-error
              cs_check-msgid_29
              '883'
              i_itm_class_data_potpr
              ' ' ' ' ' '.
        e_flg_itm_check_aborted = cs_check-flg_yes.
      ELSE.
        MESSAGE e883(29)
           WITH i_itm_class_data_potpr.
*           raising item_category_error.
      ENDIF.
  ENDCASE.

ENDFORM.                    " itm_category_read
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_COLLECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MESSAGE_TYPE_ERROR  text
*      -->P_CS_CHECK_MSGID_29  text
*      -->P_0075   text
*      -->P_I_ITM_CLASS_DATA_POSTP  text
*      -->P_0077   text
*      -->P_0078   text
*      -->P_0079   text
*----------------------------------------------------------------------*
FORM message_collect
           USING
           i_msgty LIKE balmi-msgty
           i_msgid LIKE balmi-msgid
           i_msgno LIKE balmi-msgno
           i_msgv1 TYPE any
           i_msgv2 TYPE any
           i_msgv3 TYPE any
           i_msgv4 TYPE any.

  MESSAGE ID i_msgid TYPE i_msgty NUMBER i_msgno
          WITH i_msgv1
               i_msgv2
               i_msgv3
               i_msgv4
          INTO g_msg_dummy.

  CALL FUNCTION 'CP_MC_MESSAGE_COLLECT'
       EXCEPTIONS
            message_not_collected = 1
            OTHERS                = 2.


ENDFORM.                    " MESSAGE_COLLECT
*&---------------------------------------------------------------------*
*&      Form  itm_comp_text_get
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OBJTY  text
*      -->P_I_IDNRK  text
*      -->P_I_KLART  text
*      -->P_I_CLASS  text
*      -->P_I_DOKAR  text
*      -->P_I_DOKNR  text
*      -->P_I_DOKTL  text
*      -->P_I_DOKVR  text
*      -->P_I_POTX1  text
*      -->P_I_ROMS1  text
*      -->P_I_ROMS2  text
*      -->P_I_ROMS3  text
*      -->P_I_ROMEI  text
*      -->P_I_RFORM  text
*      -->P_LS_T418  text
*      -->P_SY_DATUM  text
*      <--P_E_OBKTX  text
*      <--P_E_KTEXT  text
*----------------------------------------------------------------------*
FORM itm_comp_text_get
         USING
            i_itm_class_data_objty LIKE itm_class_data-objty
            i_itm_class_data_idnrk LIKE itm_class_data-idnrk
            i_itm_class_data_klart LIKE itm_class_data-klart
            i_itm_class_data_class LIKE itm_class_data-class
            i_itm_class_data_dokar LIKE itm_class_data-dokar
            i_itm_class_data_doknr LIKE itm_class_data-doknr
            i_itm_class_data_doktl LIKE itm_class_data-doktl
            i_itm_class_data_dokvr LIKE itm_class_data-dokvr
            i_itm_class_data_potx1 LIKE itm_class_data-potx1
            i_itm_class_data_roms1 LIKE itm_class_data-roms1
            i_itm_class_data_roms2 LIKE itm_class_data-roms2
            i_itm_class_data_roms3 LIKE itm_class_data-roms3
            i_itm_class_data_romei LIKE itm_class_data-romei
            i_itm_class_data_rform LIKE itm_class_data-rform
            i_t418                 STRUCTURE t418
            i_datuv                LIKE sy-datum
            i_spras                LIKE sy-langu
         CHANGING
            c_itm_class_data_obktx LIKE itm_class_data-obktx
            e_itm_class_data_ktext LIKE itm_class_data-ktext.

  DATA: BEGIN OF mc29s_tmp.
          INCLUDE STRUCTURE mc29s.
  DATA: END OF mc29s_tmp.

  DATA: BEGIN OF mtcor_tmp.
          INCLUDE STRUCTURE mtcor.
  DATA: END OF mtcor_tmp.

  DATA: BEGIN OF csxdoc_tmp.
          INCLUDE STRUCTURE csxdoc.
  DATA: END OF csxdoc_tmp.

  DATA: BEGIN OF klah_tmp.
          INCLUDE STRUCTURE klah.
  DATA: END OF klah_tmp.

  DATA: tmp_flg_itm_check_aborted LIKE csdata-xfeld,
        tmp_clstx LIKE klat-txtbz,
        tmp_doknr LIKE itm_class_data-doknr,
        tmp_doktl LIKE itm_class_data-doktl,
        tmp_dokvr LIKE itm_class_data-dokvr.

  CLEAR e_itm_class_data_ktext.

*- Kein Objekt (' ' alt, '2' neu)
  IF i_itm_class_data_objty EQ cs_check-blank1 OR
     i_itm_class_data_objty EQ cs_check-chr_2.
    IF i_t418-txpos EQ cs_check-cross OR
       i_t418-kzbsf NE cs_check-cross.
      e_itm_class_data_ktext = i_itm_class_data_potx1.
    ENDIF.
  ENDIF.

*- Material/Intramaterial ('M' alt, '1' neu)
  IF i_itm_class_data_objty EQ cs_check-chr_m OR
     i_itm_class_data_objty EQ cs_check-chr_1.
    IF c_itm_class_data_obktx IS INITIAL.
      PERFORM itm_material_read
         USING
            cs_check-ini_werks
            i_itm_class_data_idnrk
            i_t418
            i_datuv
            cs_check-blank1
            cs_check-flg_no
            cs_check-blank1
            i_spras
         CHANGING
            mc29s_tmp
            mtcor_tmp
            tmp_flg_itm_check_aborted.

      IF tmp_flg_itm_check_aborted IS INITIAL.
        c_itm_class_data_obktx = mc29s_tmp-maktx.
      ENDIF.
    ENDIF.
    IF i_t418-rtpos IS INITIAL.
      e_itm_class_data_ktext = c_itm_class_data_obktx.
    ENDIF.
  ENDIF.

*- Dokument
  IF i_itm_class_data_objty EQ cs_check-chr_3.
    IF c_itm_class_data_obktx IS INITIAL.
      tmp_doknr = i_itm_class_data_doknr.
      tmp_doktl = i_itm_class_data_doktl.
      tmp_dokvr = i_itm_class_data_dokvr.

      PERFORM document_read
         USING
            i_itm_class_data_dokar
            cs_check-flg_no
         CHANGING
            tmp_doknr
            tmp_doktl
            tmp_dokvr
            csxdoc_tmp
            tmp_flg_itm_check_aborted.

      IF tmp_flg_itm_check_aborted IS INITIAL.
        c_itm_class_data_obktx = csxdoc_tmp-dktxt.
      ENDIF.
    ENDIF.
    e_itm_class_data_ktext = c_itm_class_data_obktx.
  ENDIF.

*- Klasse
  IF i_itm_class_data_objty EQ cs_check-chr_4.
    IF c_itm_class_data_obktx IS INITIAL.
      PERFORM itm_class_read
         USING
            i_itm_class_data_klart
            i_itm_class_data_class
            i_datuv
            cs_check-flg_no
            cs_check-blank1
         CHANGING
            klah_tmp
            tmp_clstx
            tmp_flg_itm_check_aborted.
      IF tmp_flg_itm_check_aborted IS INITIAL.
        c_itm_class_data_obktx = tmp_clstx.
      ENDIF.
    ENDIF.
    e_itm_class_data_ktext = c_itm_class_data_obktx.
  ENDIF.

  CHECK i_t418-rtpos EQ cs_check-cross.

  DATA: BEGIN OF tcs03_tmp.
          INCLUDE STRUCTURE tcs03.
  DATA: END OF tcs03_tmp.

  DATA: BEGIN OF rt_txt,
           rform     LIKE rc29p-rform,
           dummy0    LIKE csdata-char1,
           roms1(17) TYPE c,
           dummy1    LIKE csdata-char1,
           roms2(17) TYPE c,
           dummy2    LIKE csdata-char1,
           roms3(17) TYPE c,
           dummy3    LIKE csdata-char1  VALUE  '[',
           romei(3)  TYPE c,
           dummy4    LIKE csdata-char1  VALUE  ']',
        END OF rt_txt.

  CALL FUNCTION 'TCS03_READ'
       IMPORTING
            struct   = tcs03_tmp
       EXCEPTIONS
            no_entry = 1
            OTHERS   = 2.

  IF sy-subrc NE 0.
    CLEAR tcs03_tmp.
  ENDIF.

  CASE tcs03_tmp-ritxt.
*- Positionstext, falls vorhanden, ansonsten Materialkurztext
    WHEN cs_check-blank1.
      IF NOT i_itm_class_data_potx1 IS INITIAL.
        e_itm_class_data_ktext = i_itm_class_data_potx1.
      ELSE.
        e_itm_class_data_ktext = c_itm_class_data_obktx.
      ENDIF.
*- Materialkurztext
    WHEN cs_check-chr_1.
      e_itm_class_data_ktext = c_itm_class_data_obktx.
*- Rohteilabmessungen
    WHEN cs_check-chr_2.
      IF NOT i_itm_class_data_roms1 IS INITIAL.
        WRITE i_itm_class_data_roms1
           TO rt_txt-roms1 UNIT i_itm_class_data_romei.
      ENDIF.
      IF NOT i_itm_class_data_roms2 IS INITIAL.
        WRITE i_itm_class_data_roms2
           TO rt_txt-roms2 UNIT i_itm_class_data_romei.
      ENDIF.
      IF NOT i_itm_class_data_roms3 IS INITIAL.
        WRITE i_itm_class_data_roms3
           TO rt_txt-roms3 UNIT i_itm_class_data_romei.
      ENDIF.
      rt_txt-rform  = i_itm_class_data_rform.
      rt_txt-romei  = i_itm_class_data_romei.
      IF i_itm_class_data_rform IS INITIAL.
        IF NOT i_itm_class_data_roms2 IS INITIAL.
          rt_txt-dummy1 = cs_check-star.
        ENDIF.
        IF NOT i_itm_class_data_roms3 IS INITIAL.
          rt_txt-dummy2 = cs_check-star.
        ENDIF.
      ENDIF.

      CONDENSE rt_txt.

      IF NOT rt_txt IS INITIAL.
        e_itm_class_data_ktext = rt_txt.
      ENDIF.
  ENDCASE.

ENDFORM.                    " itm_comp_text_get
*&---------------------------------------------------------------------*
*&      Form  ITM_MATERIAL_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CS_CHECK_INI_WERKS  text
*      -->P_I_ITM_CLASS_DATA_IDNRK  text
*      -->P_I_T418  text
*      -->P_I_DATUV  text
*      -->P_CS_CHECK_BLANK1  text
*      -->P_CS_CHECK_FLG_NO  text
*      -->P_CS_CHECK_BLANK1  text
*      <--P_MC29S_TMP  text
*      <--P_MTCOR_TMP  text
*      <--P_TMP_FLG_ITM_CHECK_ABORTED  text
*----------------------------------------------------------------------*
FORM itm_material_read
         USING
            i_werks                LIKE mbm_class_data-werks
            i_itm_class_data_idnrk LIKE itm_class_data-idnrk
            i_t418                 STRUCTURE t418
            i_datuv                LIKE mtcom-datum
            i_kzrfb                LIKE mtcom-kzrfb
            i_flg_mat_exist_check  LIKE csdata-xfeld
            value(i_diag_struc_name)
            i_spras                LIKE sy-langu
         CHANGING
            e_mc29s STRUCTURE mc29s
            e_mtcor STRUCTURE mtcor
            e_flg_itm_check_aborted LIKE csdata-xfeld.

  DATA: l_cursorfield(60) TYPE c,
        l_fieldname LIKE dd03l-fieldname.

  DATA:  l_subrc LIKE sy-subrc.

  DATA: BEGIN OF mc29m_tmp.
          INCLUDE STRUCTURE mc29m.
  DATA: END OF mc29m_tmp.

  CLEAR: e_flg_itm_check_aborted.

  CLEAR: e_mc29s,
         e_mtcor.

  CHECK NOT i_itm_class_data_idnrk IS INITIAL.

  IF i_t418-btpos EQ cs_check-cross.
    PERFORM material_read
        USING
           i_itm_class_data_idnrk
           cs_check-ini_werks
           i_datuv
           cs_check-blank1
           cs_check-ini_bwkey
           i_kzrfb
           cs_check-blank1
           cs_check-flg_no                      "flg_mat_exist_check
           i_spras
        CHANGING
           mc29m_tmp
           e_mc29s
           e_mtcor
           l_subrc
           e_flg_itm_check_aborted.

    MOVE-CORRESPONDING mc29m_tmp TO e_mc29s.
  ELSE.
    IF i_t418-inpos EQ cs_check-cross.
      PERFORM material_read
          USING
             i_itm_class_data_idnrk
             i_werks
             i_datuv
             cs_check-blank1
             cs_check-ini_bwkey
             i_kzrfb
             cs_check-cross
             cs_check-flg_no                   "flg_mat_exist_check
             i_spras
          CHANGING
             mc29m_tmp
             e_mc29s
             e_mtcor
             l_subrc
             e_flg_itm_check_aborted.

      IF e_mc29s IS INITIAL.
        MOVE-CORRESPONDING mc29m_tmp TO e_mc29s.
      ENDIF.
    ELSE.
      PERFORM material_read
          USING
             i_itm_class_data_idnrk
             i_werks
             i_datuv
             cs_check-blank1
             cs_check-ini_bwkey
             i_kzrfb
             cs_check-blank1
             cs_check-flg_no                   "flg_mat_exist_check
             i_spras
          CHANGING
             mc29m_tmp
             e_mc29s
             e_mtcor
             l_subrc
             e_flg_itm_check_aborted.

      IF i_werks IS INITIAL.
        MOVE-CORRESPONDING mc29m_tmp TO e_mc29s.
      ENDIF.
    ENDIF.
  ENDIF.

  CHECK NOT e_flg_itm_check_aborted IS INITIAL.
  CHECK NOT i_flg_mat_exist_check IS INITIAL.

  l_fieldname = 'IDNRK'.
  IF NOT i_diag_struc_name IS INITIAL.
    CONCATENATE i_diag_struc_name '-' l_fieldname
           INTO l_cursorfield.
    SET CURSOR FIELD l_cursorfield LINE sy-stepl.
  ENDIF.

  IF l_subrc EQ 1 OR l_subrc EQ 2 OR l_subrc EQ 6.      "note 521536
*---- Message E351(M3) Material & ist im Werk & nicht vorhanden
*---- Message E351(M3) Material & ist im Werk & nicht vorhanden
    IF cs_check-flg_yes EQ cs_check-flg_switch.
      PERFORM message_collect
         USING
            sy-msgty
            sy-msgid
            sy-msgno
            sy-msgv1
            sy-msgv2
            sy-msgv3
            sy-msgv4.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*                raising material_not_found.
    ENDIF.
  ENDIF.

  IF l_subrc EQ 3 OR l_subrc EQ 4 OR l_subrc EQ 5.
*---- Message E021(M3) Beim Sperren ist ein Systemfehler aufgetreten
*---- E022(M3) Konzerndaten sind durch einen anderen Benutzer gesperrt
*---- E023(M3) Werksdaten sind durch einen anderen Benutzer gesperrt
    IF cs_check-flg_yes EQ cs_check-flg_switch.
      PERFORM message_collect
         USING
            sy-msgty
            sy-msgid
            sy-msgno
            sy-msgv1
            sy-msgv2
            sy-msgv3
            sy-msgv4.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*                raising object_locked.
    ENDIF.
  ENDIF.


ENDFORM.                    " ITM_MATERIAL_READ
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ITM_CLASS_DATA_IDNRK  text
*      -->P_CS_CHECK_INI_WERKS  text
*      -->P_I_DATUV  text
*      -->P_CS_CHECK_BLANK1  text
*      -->P_CS_CHECK_INI_BWKEY  text
*      -->P_I_KZRFB  text
*      -->P_CS_CHECK_BLANK1  text
*      -->P_CS_CHECK_FLG_NO  text
*      <--P_MC29M_TMP  text
*      <--P_E_MC29S  text
*      <--P_E_MTCOR  text
*      <--P_L_SUBRC  text
*      <--P_E_FLG_ITM_CHECK_ABORTED  text
*----------------------------------------------------------------------*
FORM material_read
        USING
           i_matnr                        LIKE marc-matnr
           i_werks                        LIKE marc-werks
           i_datuv                        LIKE mtcom-datum
           i_novor                        LIKE mtcom-novor
           i_bwkey                        LIKE mtcom-bwkey
           i_kzrfb                        LIKE mtcom-kzrfb
           i_flg_mc29m_if_plant_not_exist LIKE csdata-xfeld
           i_flg_mat_exist_check          LIKE csdata-xfeld
           i_spras                        LIKE sy-langu
        CHANGING
           e_mc29m                        STRUCTURE mc29m
           e_mc29s                        STRUCTURE mc29s
           e_mtcor                        STRUCTURE mtcor
           e_subrc                        LIKE sy-subrc
           e_flg_mat_check_aborted        LIKE csdata-xfeld.

  TABLES: mtcom,
          mtcor.

  DATA: tmp_subrc LIKE sy-subrc.

  CLEAR: e_flg_mat_check_aborted.

  CLEAR: e_mc29s,
         e_mc29m,
         e_mtcor.

  CHECK NOT i_matnr IS INITIAL.

  IF i_werks IS INITIAL.
    PERFORM mc29m_fill
       USING
          i_matnr
          i_datuv
          i_kzrfb
          i_spras
       CHANGING
          tmp_subrc
          e_mc29m
          e_mtcor.
  ELSE.
    PERFORM mc29s_fill
       USING
          i_matnr
          i_werks
          i_datuv
          i_novor
          i_bwkey
          i_kzrfb
          i_spras
       CHANGING
          tmp_subrc
          e_mc29s
          e_mtcor.

    IF tmp_subrc EQ 2 AND
       i_flg_mc29m_if_plant_not_exist EQ cs_check-flg_yes.
      CLEAR: tmp_subrc,
             e_mc29s,
             e_mtcor.

      PERFORM mc29m_fill
         USING
            i_matnr
            i_datuv
            i_kzrfb
            i_spras
         CHANGING
            tmp_subrc
            e_mc29m
            e_mtcor.
    ENDIF.
  ENDIF.

  CHECK NOT tmp_subrc IS INITIAL.
  e_subrc = tmp_subrc.

  IF i_flg_mat_exist_check IS INITIAL.
    e_flg_mat_check_aborted = cs_check-flg_yes.
    EXIT.
  ENDIF.

  IF tmp_subrc EQ 1 OR tmp_subrc EQ 2 OR tmp_subrc EQ 6.
*---- Message E305(M3) Material & ist nicht vorhanden
*---- Message E351(M3) Material & ist im Werk & nicht vorhanden
    IF cs_check-flg_yes EQ cs_check-flg_switch.
      PERFORM message_collect
         USING
            sy-msgty
            sy-msgid
            sy-msgno
            sy-msgv1
            sy-msgv2
            sy-msgv3
            sy-msgv4.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*                raising material_not_found.
    ENDIF.
  ENDIF.

  IF tmp_subrc EQ 3 OR tmp_subrc EQ 4 OR tmp_subrc EQ 5.
*---- Message E021(M3) Beim Sperren ist ein Systemfehler aufgetreten
*---- E022(M3) Konzerndaten sind durch einen anderen Benutzer gesperrt
*---- E023(M3) Werksdaten sind durch einen anderen Benutzer gesperrt
    IF cs_check-flg_yes EQ cs_check-flg_switch.
      PERFORM message_collect
         USING
            sy-msgty
            sy-msgid
            sy-msgno
            sy-msgv1
            sy-msgv2
            sy-msgv3
            sy-msgv4.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*                raising object_locked.
    ENDIF.
  ENDIF.

ENDFORM.                    " MATERIAL_READ
*&---------------------------------------------------------------------*
*&      Form  DOCUMENT_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ITM_CLASS_DATA_DOKAR  text
*      -->P_CS_CHECK_FLG_NO  text
*      <--P_TMP_DOKNR  text
*      <--P_TMP_DOKTL  text
*      <--P_TMP_DOKVR  text
*      <--P_CSXDOC_TMP  text
*      <--P_TMP_FLG_ITM_CHECK_ABORTED  text
*----------------------------------------------------------------------*
FORM document_read
       USING
           value(i_dokar)          LIKE draw-dokar
           i_flg_doc_exist_check   LIKE csdata-xfeld
        CHANGING
           c_doknr                 LIKE draw-doknr
           c_doktl                 LIKE draw-doktl
           c_dokvr                 LIKE draw-dokvr
           e_csxdoc                STRUCTURE csxdoc
           e_flg_doc_check_aborted LIKE csdata-xfeld.

  CLEAR: e_flg_doc_check_aborted.

  CHECK NOT i_dokar IS INITIAL AND
        NOT c_doknr IS INITIAL.

*- Konvertieren Dokumentnummer abhängig von Dokumentart
  CALL FUNCTION 'DOCNUMBER_CHECK_IN_EXIT'
       EXPORTING
            ex_doknr = c_doknr
            ex_dokar = i_dokar
       IMPORTING
            doknr    = c_doknr
       EXCEPTIONS
            OTHERS   = 1.

  IF sy-subrc NE 0.
  ENDIF.

  PERFORM doc_field_convert CHANGING c_doktl.
  PERFORM doc_field_convert CHANGING c_dokvr.

*- Dokument lesen
  CALL FUNCTION 'DOCUMENT_READ_CS_EXTRACT'
       EXPORTING
            ddokar      = i_dokar
            ddoknr      = c_doknr
            ddoktl      = c_doktl
            ddokvr      = c_dokvr
       IMPORTING
            ecsxdoc     = e_csxdoc
       EXCEPTIONS
            no_document = 01.

  CHECK sy-subrc EQ 1.
  IF i_flg_doc_exist_check IS INITIAL.
    e_flg_doc_check_aborted = cs_check-flg_yes.
    EXIT.
  ENDIF.

  IF sy-subrc EQ 1.
*---- Dokument & & & & ist nicht vorhanden
    IF cs_check-flg_yes EQ cs_check-flg_switch.
      PERFORM message_collect
         USING
            message_type-error
            cs_check-msgid_29
            '350'
            c_doknr
            i_dokar
            c_doktl
            c_dokvr.
      e_flg_doc_check_aborted = cs_check-flg_yes.
    ELSE.
      MESSAGE ID     cs_check-msgid_29
              TYPE   message_type-error
              NUMBER 350
*         message e350(cs_check-msgid_29)
         WITH c_doknr i_dokar c_doktl c_dokvr.
*           raising document_not_found.
    ENDIF.
  ENDIF.

ENDFORM.                    " DOCUMENT_READ
*&---------------------------------------------------------------------*
*&      Form  ITM_CLASS_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ITM_CLASS_DATA_KLART  text
*      -->P_I_ITM_CLASS_DATA_CLASS  text
*      -->P_I_DATUV  text
*      -->P_CS_CHECK_FLG_NO  text
*      -->P_CS_CHECK_BLANK1  text
*      <--P_KLAH_TMP  text
*      <--P_TMP_CLSTX  text
*      <--P_TMP_FLG_ITM_CHECK_ABORTED  text
*----------------------------------------------------------------------*
FORM itm_class_read
         USING
            i_itm_class_data_klart LIKE itm_class_data-klart
            i_itm_class_data_class LIKE itm_class_data-class
            i_datuv                LIKE sy-datum
            i_flg_cls_exist_check  LIKE csdata-xfeld
            value(i_diag_struc_name)
         CHANGING
            e_klah  STRUCTURE klah
            e_clstx LIKE klat-txtbz
            e_flg_itm_check_aborted LIKE csdata-xfeld.

  DATA: l_cursorfield(60) TYPE c,
        l_fieldname LIKE dd03l-fieldname.

  DATA: tmp_cls_val_err LIKE csdata-xfeld,
        tmp_cls_stat_err LIKE csdata-xfeld,
        tmp_cls_auth_err LIKE csdata-xfeld.

  CLEAR: e_flg_itm_check_aborted.

  CHECK NOT i_itm_class_data_klart IS INITIAL AND
        NOT i_itm_class_data_class IS INITIAL.

  l_fieldname = 'CLASS'.
  IF NOT i_diag_struc_name IS INITIAL.
    CONCATENATE i_diag_struc_name '-' l_fieldname
           INTO l_cursorfield.
    SET CURSOR FIELD l_cursorfield LINE sy-stepl.
  ENDIF.

  PERFORM class_read
     USING
        cs_check-ini_clint
        i_itm_class_data_klart
        i_itm_class_data_class
        i_datuv
        i_flg_cls_exist_check
     CHANGING
        e_klah
        e_clstx
        tmp_cls_val_err
        tmp_cls_stat_err
        tmp_cls_auth_err
        e_flg_itm_check_aborted.


ENDFORM.                    " ITM_CLASS_READ
*&---------------------------------------------------------------------*
*&      Form  mc29m_fill
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MATNR  text
*      -->P_I_DATUV  text
*      -->P_I_KZRFB  text
*      <--P_TMP_SUBRC  text
*      <--P_E_MC29M  text
*      <--P_E_MTCOR  text
*----------------------------------------------------------------------*
FORM mc29m_fill
       USING
           i_matnr LIKE mara-matnr
           i_datuv LIKE mtcom-datum
           i_kzrfb LIKE mtcom-kzrfb
           i_spras LIKE sy-langu
        CHANGING
           e_subrc LIKE sy-subrc
           e_mc29m STRUCTURE mc29m
           e_mtcor STRUCTURE mtcor.

  CLEAR: mtcom.

*  fill
  mtcom-matnr = i_matnr.
  mtcom-kenng = 'MC29M'.
  mtcom-spras = i_spras.
  mtcom-datum = i_datuv.
  mtcom-kzrfb = i_kzrfb.

*  read material data
  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING schluessel = mtcom
*d      importing return     = mtcor                 "note 700734
       IMPORTING return     = e_mtcor               "note 700734
                 matdaten   = e_mc29m
       EXCEPTIONS material_not_found = 1
                  plant_not_found    = 2
                  lock_on_material   = 3
                  lock_on_plant      = 4
                  lock_system_error  = 5
                  OTHERS             = 6.

  e_subrc = sy-subrc.
ENDFORM.                    " mc29m_fill
*&---------------------------------------------------------------------*
*&      Form  mc29s_fill
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MATNR  text
*      -->P_I_WERKS  text
*      -->P_I_DATUV  text
*      -->P_I_NOVOR  text
*      -->P_I_BWKEY  text
*      -->P_I_KZRFB  text
*      <--P_TMP_SUBRC  text
*      <--P_E_MC29S  text
*      <--P_E_MTCOR  text
*----------------------------------------------------------------------*
FORM mc29s_fill
        USING
           i_matnr LIKE marc-matnr
           i_werks LIKE marc-werks
           i_datuv LIKE mtcom-datum
           i_novor LIKE mtcom-novor
           i_bwkey LIKE mtcom-bwkey
           i_kzrfb LIKE mtcom-kzrfb
           i_spras LIKE sy-langu
        CHANGING
           e_subrc LIKE sy-subrc
           e_mc29s STRUCTURE mc29s
           e_mtcor STRUCTURE mtcor.

  CLEAR: mtcom.

*  fill mtcom
  mtcom-matnr = i_matnr.
  mtcom-werks = i_werks.
  mtcom-novor = i_novor.
  mtcom-kenng = 'MC29S'.
  mtcom-spras = i_spras.
  mtcom-bwkey = i_bwkey.
  mtcom-datum = i_datuv.
  mtcom-kzrfb = i_kzrfb.

*  read material/plant data
  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel         = mtcom
       IMPORTING
            return             = e_mtcor
            matdaten           = e_mc29s
       EXCEPTIONS
            material_not_found = 1
            plant_not_found    = 2
            lock_on_material   = 3
            lock_on_plant      = 4
            lock_system_error  = 5
            OTHERS             = 6.

  e_subrc = sy-subrc.

ENDFORM.                    " mc29s_fill
*&---------------------------------------------------------------------*
*&      Form  doc_field_convert
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_C_DOKTL  text
*----------------------------------------------------------------------*
FORM doc_field_convert
        CHANGING
           c_field TYPE any.

  CHECK c_field IS INITIAL.                                 "QSE46B

*  CHECK C_FIELD CO ' 0123456789'.                             "QSE46B
*  IF C_FIELD IS INITIAL.                                      "QSE46B
  c_field = '0'.
*  ENDIF.                                                      "QSE46B

  CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
       EXPORTING
            input  = c_field
       IMPORTING
            output = c_field.

ENDFORM.                    " doc_field_convert
*&---------------------------------------------------------------------*
*&      Form  class_read
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CS_CHECK_INI_CLINT  text
*      -->P_I_ITM_CLASS_DATA_KLART  text
*      -->P_I_ITM_CLASS_DATA_CLASS  text
*      -->P_I_DATUV  text
*      -->P_I_FLG_CLS_EXIST_CHECK  text
*      <--P_E_KLAH  text
*      <--P_E_CLSTX  text
*      <--P_TMP_CLS_VAL_ERR  text
*      <--P_TMP_CLS_STAT_ERR  text
*      <--P_TMP_CLS_AUTH_ERR  text
*      <--P_E_FLG_ITM_CHECK_ABORTED  text
*----------------------------------------------------------------------*
FORM class_read
         USING
            i_clint               LIKE klah-clint
            i_klart               LIKE klah-klart
            i_class               LIKE klah-class
            i_datuv               LIKE sy-datum
            i_flg_cls_exist_check LIKE csdata-xfeld
         CHANGING
            e_klah STRUCTURE klah
            e_clstx LIKE klat-txtbz
            e_cls_val_err LIKE csdata-xfeld
            e_cls_stat_err LIKE csdata-xfeld
            e_cls_auth_err LIKE csdata-xfeld
            e_flg_cls_check_aborted LIKE csdata-xfeld.

  DATA: hlp_ret_code LIKE sy-subrc.

  DATA: BEGIN OF klah_tmp.
          INCLUDE STRUCTURE klah.
  DATA: END OF klah_tmp.

  CLEAR: e_flg_cls_check_aborted.

  CHECK NOT i_clint IS INITIAL OR
        ( NOT i_klart IS INITIAL AND
          NOT i_class IS INITIAL ).

*- Klasse lesen
  CALL FUNCTION 'CLMA_CLASS_EXIST'
       EXPORTING
            class               = i_class
            classnumber         = i_clint
            classtype           = i_klart
            language            = sy-langu
            date                = i_datuv
            mode                = 'S'
       IMPORTING
            class_description   = e_clstx
            not_valid           = e_cls_val_err
            no_active_status    = e_cls_stat_err
            no_authority_select = e_cls_auth_err
            ret_code            = hlp_ret_code
            xklah               = klah_tmp
       EXCEPTIONS
            no_valid_sign       = 3.

  e_klah = klah_tmp.

  CHECK sy-subrc NE 0 OR
  hlp_ret_code EQ 1 OR
  hlp_ret_code EQ 2.

  IF i_flg_cls_exist_check IS INITIAL.
    IF i_flg_cls_exist_check IS INITIAL.
      e_flg_cls_check_aborted = cs_check-flg_yes.
      EXIT.
    ENDIF.
  ENDIF.

  IF sy-subrc EQ 3.
*---- Klasse & & enthält ungültige Zeichen
    IF cs_check-flg_yes EQ cs_check-flg_switch.
      PERFORM message_collect
         USING
            message_type-error
            cs_check-msgid_29
            '385'
            i_klart
            i_class
            ' ' ' '.
      e_flg_cls_check_aborted = cs_check-flg_yes.
    ELSE.
      MESSAGE ID     cs_check-msgid_29
              TYPE   message_type-error
              NUMBER '385'
         WITH i_klart
              i_class.
*           raising class_error.
    ENDIF.
  ENDIF.

  CHECK e_flg_cls_check_aborted IS INITIAL.

  CASE hlp_ret_code.
    WHEN 2.
*---- Klasse & & ist nicht vorhanden
      IF cs_check-flg_yes EQ cs_check-flg_switch.
        PERFORM message_collect
           USING
              message_type-error
              cs_check-msgid_29
              '376'
              i_klart
              i_class
              ' ' ' '.
        e_flg_cls_check_aborted = cs_check-flg_yes.
      ELSE.
        MESSAGE ID    cs_check-msgid_29
                TYPE  message_type-error
                NUMBER '376'
           WITH i_klart
                i_class.
*           raising class_error.
      ENDIF.
    WHEN 1.
*---- Klasse & & ist in Sprache & nicht vorhanden
      IF cs_check-flg_yes EQ cs_check-flg_switch.
        PERFORM message_collect
           USING
              message_type-warning
              cs_check-msgid_29
              '377'
              i_klart
              i_class
              sy-langu
              ' '.
      ELSE.
        MESSAGE ID    cs_check-msgid_29
                TYPE  message_type-warning
                NUMBER '377'
           WITH i_klart
                i_class
                sy-langu.
      ENDIF.
  ENDCASE.

ENDFORM.                    " class_read
