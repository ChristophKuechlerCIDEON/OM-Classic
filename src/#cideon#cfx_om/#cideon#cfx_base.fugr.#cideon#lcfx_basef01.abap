*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LCFX_BASEF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  show_popup_cfolders
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_CFOLDER_RFC  text
*      <--P_I_ANSWER  text
*----------------------------------------------------------------------*
FORM show_popup_cfolders CHANGING l_cfc TYPE /cideon/cfx_cfolders_om
                                  l_answer TYPE char4.

  DATA: lt_cfc         TYPE TABLE OF /cideon/cfx_cfolders_om,
        lt_pop_sel     TYPE TABLE OF spopli,
        l_pop_sel      TYPE spopli,
        l_tabname TYPE char12 VALUE 'CFX_CFOLDERS'.

* Get cFolders Destination from Customizing
  SELECT * FROM (l_tabname) INTO CORRESPONDING FIELDS OF TABLE lt_cfc.
  LOOP AT lt_cfc INTO l_cfc.
    MOVE: l_cfc-name TO l_pop_sel-varoption.
    APPEND l_pop_sel TO lt_pop_sel.
  ENDLOOP.

  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
       EXPORTING
            textline1          = text-197
            titel              = text-196
       IMPORTING
            answer             = l_answer
       TABLES
            t_spopli           = lt_pop_sel
       EXCEPTIONS
            not_enough_answers = 1
            too_much_answers   = 2
            too_much_marks     = 3
            OTHERS             = 4.
  IF sy-subrc <> 0.
    IF sy-subrc = 1.
      MESSAGE e078(/cideon/cfx_om).
    ENDIF.
    EXIT.
  ENDIF.

* Check if user wants to cancel export
  CHECK NOT l_answer = 'A'.

* fill l_cfc with data of choosen cFolder system
  READ TABLE lt_cfc INTO l_cfc INDEX l_answer.

  CALL SCREEN 1400 STARTING AT 35 5 ENDING AT 112 14.

ENDFORM.                    " show_popup_cfolders
*&---------------------------------------------------------------------*
*&      Form  show_collaborations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_CFOLDER_RFC  text
*      <--P_L_ROOT_FOLDER_ID  text
*      <--P_I_CANCEL  text
*----------------------------------------------------------------------*
FORM show_collaborations USING l_cfc TYPE /cideon/cfx_cfolders_om
                         CHANGING ls_root_folder_id TYPE sysuuid_c
                                  lv_cancel TYPE xfeld.

  TYPES: BEGIN OF cdesk_cfol_table,
           id TYPE sysuuid_c,
           name TYPE string,
         END OF cdesk_cfol_table.

  DATA: lt_cfol_tab TYPE TABLE OF cdesk_cfol_table,
        line TYPE i.

  TYPES: BEGIN OF cdesk_cfol_original,
           scenario TYPE string,
           col_id TYPE sysuuid_c,
           area_id TYPE sysuuid_c,
           collaboration TYPE string,
           area TYPE string,
           folder_tab LIKE lt_cfol_tab,
         END OF cdesk_cfol_original.

  DATA: ls_doc_file       TYPE cdesk_cfol_original,
        ls_fol_id_name      TYPE cdesk_cfol_table.

  DATA: ls_funcname_refresh TYPE char40 VALUE
                          'CFX_BI_RI_CF_DELETE_CONTAINER',
        ls_funcname_select TYPE char40 VALUE
                          'CFX_BI_RI_CF_SELECT_FOLDER'.

  CLEAR: lv_cancel,
         ls_doc_file.

* Free memory
  CALL FUNCTION ls_funcname_refresh.

* User Interface for cFolders Objects
* Shows popup with all Collaborations and Folders existing in the system
  ls_doc_file-scenario = 'Collaboration'.                   "#EC NOTEXT
  CALL FUNCTION ls_funcname_select
       EXPORTING
            is_cfolders    = l_cfc
       IMPORTING
            e_cancel       = lv_cancel
       CHANGING
            c_scenario     = ls_doc_file-scenario
            c_col_id       = ls_doc_file-col_id
            c_area_id      = ls_doc_file-area_id
            c_col_name     = ls_doc_file-collaboration
            c_area_name    = ls_doc_file-area
            ct_fol_id_name = ls_doc_file-folder_tab[].

  IF lv_cancel IS INITIAL.
    DESCRIBE TABLE ls_doc_file-folder_tab LINES line.
    READ TABLE ls_doc_file-folder_tab INTO ls_fol_id_name INDEX line.
    ls_root_folder_id = ls_fol_id_name-id.
  ELSE.
    EXIT.
  ENDIF.

ENDFORM.                    " show_collaborations
*&---------------------------------------------------------------------*
*&      Form  create_collaboration
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_CFOLDER_RFC  text
*      <--P_L_ROOT_FOLDER_ID  text
*      <--P_I_FAULT  text
*----------------------------------------------------------------------*
FORM create_collaboration  USING    l_cfc TYPE /cideon/cfx_cfolders_om
                           CHANGING l_root_fol_id TYPE sysuuid_c
                                    i_fault TYPE string.

  DATA:   l_col TYPE string,
          l_col_descr TYPE string,
          l_map TYPE string,
          l_map_descr TYPE string,
          l_pub_ar_id      TYPE sysuuid_c,
          l_coll_id        TYPE sysuuid_c,
          l_folder_id      TYPE sysuuid_c.

  l_col = cfol_field01.
  l_col_descr = cfol_field02.
  l_map = cfol_field03.
  l_map_descr = cfol_field04.

* Create new collaboration named by user
  CALL FUNCTION 'CFX_API_COLLABORATION_CREATE'
    DESTINATION l_cfc-rfc_destination
    EXPORTING
      i_name             = l_col
      i_description      = l_col_descr
    IMPORTING
      e_faultstring      = i_fault
      e_collaboration_id = l_coll_id
      e_public_area_id   = l_pub_ar_id
      e_root_folder_id   = l_root_fol_id.
  IF NOT i_fault IS INITIAL.
    EXIT.
  ENDIF.

* create new folder named by user. All new folders and documents will be
* created among this folder!
  IF NOT l_map IS INITIAL.
    CALL FUNCTION 'CFX_API_FOLDER_CREATE'
      DESTINATION l_cfc-rfc_destination
      EXPORTING
        i_parent_folder_id = l_root_fol_id
        i_name             = l_map
        i_description      = l_map_descr
      IMPORTING
        e_faultstring      = i_fault
        e_folder_id        = l_folder_id.
    IF NOT i_fault IS INITIAL.
      EXIT.
    ENDIF.

    l_root_fol_id = l_folder_id.
  ENDIF.

ENDFORM.                    " create_collaboration
