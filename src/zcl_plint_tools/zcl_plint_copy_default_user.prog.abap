*&---------------------------------------------------------------------*
*& Report  ZCL_PLINT_COPY_DEFAULT_USER                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Masterprogramm für Tools                                        *
*&---------------------------------------------------------------------*
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 28.11.2003 Erstellung
* 12.01.2004 Erweiterung für andere Tabellen für neue CLF
*              - ZCL_AOFILE_CLF10
*              - ZCL_JOBDAT_CLF10
*
*-----------------------------------------------------------------------
REPORT  zcl_plint_copy_default_user             .

*TYPES
*ITAB
DATA: itab_zcl_aofile_clf10 TYPE TABLE OF zcl_aofile_clf10.
DATA: itab_zcl_jobdat_clf10 TYPE TABLE OF zcl_jobdat_clf10.
DATA: itab_zcl_ghead_clf10 TYPE TABLE OF zcl_ghead_clf10.
DATA: itab_zcl_group_clf10 TYPE TABLE OF zcl_group_clf10.
DATA: itab_zcl_plint_alvs TYPE TABLE OF zcl_plint_alvs.
DATA: itab_zcl_plint_excalv TYPE TABLE OF zcl_plint_excalv.
DATA: itab_zcl_plint_usr_vw TYPE TABLE OF zcl_plint_usr_vw.
DATA: itab_zcl_skeleton TYPE TABLE OF zcl_skeleton.
DATA: itab_zcl_skel_clf TYPE TABLE OF zcl_skel_clf.
DATA: itab_zcl_skel_clf_lin TYPE TABLE OF zcl_skel_clf_lin.
DATA: itab_zcl_skel_lines TYPE TABLE OF zcl_skel_lines.
*WA
DATA: wa_zcl_aofile_clf10 TYPE zcl_aofile_clf10.
DATA: wa_zcl_jobdat_clf10 TYPE zcl_jobdat_clf10.
DATA: wa_zcl_ghead_clf10 TYPE zcl_ghead_clf10.
DATA: wa_zcl_group_clf10 TYPE zcl_group_clf10.
DATA: wa_zcl_plint_alvs TYPE zcl_plint_alvs.
DATA: wa_zcl_plint_excalv TYPE zcl_plint_excalv.
DATA: wa_zcl_plint_usr_vw TYPE zcl_plint_usr_vw.
DATA: wa_zcl_skeleton TYPE zcl_skeleton.
DATA: wa_zcl_skel_clf TYPE zcl_skel_clf.
DATA: wa_zcl_skel_clf_lin TYPE zcl_skel_clf_lin.
DATA: wa_zcl_skel_lines TYPE zcl_skel_lines.

*NORMAL




* Berechtigungscheck
AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
         ID 'ZCL_TA' FIELD sy-tcode
         ID 'ACTVT' FIELD '16'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
.
IF sy-subrc > 0.
  MESSAGE s099(zcl_plint_tools)
    WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
  LEAVE PROGRAM.
ELSE.
ENDIF.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_check AS CHECKBOX DEFAULT ''.
PARAMETERS: p_upt AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
PARAMETERS: pdef_alt TYPE xubname DEFAULT 'SAP*'.
PARAMETERS: pdef_neu TYPE xubname DEFAULT ''.
SELECTION-SCREEN END OF BLOCK bl2.

START-OF-SELECTION.

  IF p_check = 'X'.
    IF p_upt = 'X'.
      IF pdef_alt IS INITIAL.
        MESSAGE e150(zcl_plint_tools)
          WITH 'Defaultbenutzer alt' '' '' ''.  "
        EXIT.
      ELSE.
      ENDIF.
      IF pdef_neu IS INITIAL.
        MESSAGE e150(zcl_plint_tools)
          WITH 'Defaultbenutzer neu' '' '' ''.
        EXIT.
      ELSE.
      ENDIF.

*     ZCL_AOFILE_CLF10
      SELECT * FROM zcl_aofile_clf10
        INTO TABLE itab_zcl_aofile_clf10
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_aofile_clf10 INTO wa_zcl_aofile_clf10.
        wa_zcl_aofile_clf10-nutzer = pdef_neu.
        MODIFY zcl_aofile_clf10 FROM wa_zcl_aofile_clf10.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_JOBDAT_CLF10
      SELECT * FROM zcl_jobdat_clf10
        INTO TABLE itab_zcl_jobdat_clf10
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_jobdat_clf10 INTO wa_zcl_jobdat_clf10.
        wa_zcl_jobdat_clf10-nutzer = pdef_neu.
        MODIFY zcl_jobdat_clf10 FROM wa_zcl_jobdat_clf10.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_GHEAD_CLF10
      SELECT * FROM zcl_ghead_clf10
        INTO TABLE itab_zcl_ghead_clf10
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_ghead_clf10 INTO wa_zcl_ghead_clf10.
        wa_zcl_ghead_clf10-nutzer = pdef_neu.
        MODIFY zcl_ghead_clf10 FROM wa_zcl_ghead_clf10.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_GROUP_CLF10
      SELECT * FROM zcl_group_clf10
        INTO TABLE itab_zcl_group_clf10
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_group_clf10 INTO wa_zcl_group_clf10.
        wa_zcl_group_clf10-nutzer = pdef_neu.
        MODIFY zcl_group_clf10 FROM wa_zcl_group_clf10.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_PLINT_ALVS
      SELECT * FROM zcl_plint_alvs
        INTO TABLE itab_zcl_plint_alvs
        WHERE uname = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_plint_alvs INTO wa_zcl_plint_alvs.
        wa_zcl_plint_alvs-uname = pdef_neu.
        MODIFY zcl_plint_alvs FROM wa_zcl_plint_alvs.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_PLINT_EXCALV
      SELECT * FROM zcl_plint_excalv
        INTO TABLE itab_zcl_plint_excalv
        WHERE uname = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_plint_excalv INTO wa_zcl_plint_excalv.
        wa_zcl_plint_excalv-uname = pdef_neu.
        MODIFY zcl_plint_excalv FROM wa_zcl_plint_excalv.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_PLINT_USR_VW
      SELECT * FROM zcl_plint_usr_vw
        INTO TABLE itab_zcl_plint_usr_vw
        WHERE uname = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_plint_usr_vw INTO wa_zcl_plint_usr_vw.
        wa_zcl_plint_usr_vw-uname = pdef_neu.
        MODIFY zcl_plint_usr_vw FROM wa_zcl_plint_usr_vw.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.


*     ZCL_SKELETON
      SELECT * FROM zcl_skeleton
        INTO TABLE itab_zcl_skeleton
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_skeleton INTO wa_zcl_skeleton.
        wa_zcl_skeleton-nutzer = pdef_neu.
        MODIFY zcl_skeleton FROM wa_zcl_skeleton.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.


**     ZCL_SKEL_CLF
      SELECT * FROM zcl_skel_clf
        INTO TABLE itab_zcl_skel_clf
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_skel_clf INTO wa_zcl_skel_clf.
        wa_zcl_skel_clf-nutzer = pdef_neu.
        MODIFY zcl_skel_clf FROM wa_zcl_skel_clf.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_SKEL_CLF_LIN
      SELECT * FROM zcl_skel_clf_lin
        INTO TABLE itab_zcl_skel_clf_lin
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_skel_clf_lin INTO wa_zcl_skel_clf_lin.
        wa_zcl_skel_clf_lin-nutzer = pdef_neu.
        MODIFY zcl_skel_clf_lin FROM wa_zcl_skel_clf_lin.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

*     ZCL_SKEL_LINES
      SELECT * FROM zcl_skel_lines INTO TABLE itab_zcl_skel_lines
        WHERE nutzer = pdef_alt
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_zcl_skel_lines INTO wa_zcl_skel_lines.
        wa_zcl_skel_lines-nutzer = pdef_neu.
        MODIFY zcl_skel_lines FROM wa_zcl_skel_lines.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e151(zcl_plint_tools)
            WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ENDLOOP.

      MESSAGE s155(zcl_plint_tools)
        WITH '' '' '' ''.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.





*
