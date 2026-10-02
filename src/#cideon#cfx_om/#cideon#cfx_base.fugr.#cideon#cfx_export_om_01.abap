FUNCTION /cideon/cfx_export_om_01.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"     VALUE(I_FAULT) TYPE  STRING
*"  TABLES
*"      LT_PLOTJOB STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*           Christoph.Kuechler@cideon.com
*
* Anpassungen:

*-----------------------------------------------------------------------
* Journal
* 15.03.2008 - Erstellung
*              Anpassung wegen gleichen Dateinamen
*
* 24.01.2011 - CKR
* 7.0.146.3
*              SR 11048 Deutsche Menutexte Spezial - Output to cFolders
*              FB /CIDEON/CFX_EXPORT_OM_01
*-----------------------------------------------------------------------
* toDo
*
*    - lokale Dateien
*    - Fehlblätter
*-----------------------------------------------------------------------
  DATA: i_cfolder_rfc  TYPE /cideon/cfx_cfolders_om.
  DATA: i_answer TYPE char4.
  DATA: i_cancel TYPE xfeld.

  DATA: l_root_folder_id TYPE sysuuid_c,
        l_neutr_id       TYPE sysuuid_c,
        l_orig_id        TYPE sysuuid_c,
        l_mat_folder_id  TYPE sysuuid_c,
        l_bom_id         TYPE sysuuid_c,
        l_doc_id         TYPE sysuuid_c,
        l_mat_doc_id     TYPE sysuuid_c,
        l_name           TYPE string,
        l_name_mat       TYPE string,
        l_doc_descr      TYPE string,
        l_docdata        TYPE bapi_doc_draw2,
        lt_descr         TYPE TABLE OF bapi_doc_drat,
        lt_files2        TYPE TABLE OF bapi_doc_files2,
        l_descr          TYPE bapi_doc_drat,
*        l_files2         TYPE bapi_doc_files2,
        lt_doccat        TYPE TABLE OF cscdoc,
        l_topdoc         TYPE cstdoc,
        l_topmat         TYPE cstmat,
        l_name_cnt(3)    TYPE n,
        l_phio          TYPE sdokobject,
        lt_file_attrib  TYPE TABLE OF sdokfilaci,
        l_file_attrib   TYPE sdokfilaci OCCURS 0 WITH HEADER LINE,
        lt_cnt_bin      TYPE TABLE OF sdokcntbin
        .

  DATA: name TYPE string,
        descr TYPE string,
        file_name TYPE string,
        file_size TYPE string.

  DATA: lc_plotjob TYPE zcl_s_plotlist.

* cFolders Verbindungen abfragen
  CLEAR i_cfolder_rfc.
  CLEAR i_answer.
  PERFORM show_popup_cfolders CHANGING i_cfolder_rfc
                                       i_answer.

  IF i_answer = 'A' OR i_cfolder_rfc IS INITIAL
                    OR ok_code = 'CANCEL1200'.
    EXIT.
  ENDIF.

  IF radio_1 IS INITIAL.
    PERFORM show_collaborations USING i_cfolder_rfc
                             CHANGING l_root_folder_id
                                      i_cancel.

    IF NOT i_cancel IS INITIAL.
      EXIT.
    ENDIF.

  ELSE.
    PERFORM create_collaboration USING i_cfolder_rfc
                             CHANGING l_root_folder_id
                                      i_fault.
  ENDIF.

  IF NOT i_fault IS INITIAL.
    MESSAGE e000(26) WITH i_fault.
  ENDIF.


* Create folder
  "MOVE: text-218 TO name.
  CONCATENATE text-218 sy-datum sy-uzeit INTO name.
  CONCATENATE text-221 sy-datum sy-uzeit INTO descr.

  CALL FUNCTION 'CFX_API_FOLDER_CREATE'
    DESTINATION i_cfolder_rfc-rfc_destination
    EXPORTING
      i_parent_folder_id = l_root_folder_id
      i_name             = name
      i_description      = descr
    IMPORTING
      e_faultstring      = i_fault
      e_folder_id        = l_neutr_id.

  IF NOT i_fault IS INITIAL.
    MESSAGE e000(26) WITH i_fault.
    EXIT.
  ENDIF.


  "break kuechler.

* Export der Dokumente
* Fehlblätter beachten
  LOOP AT lt_plotjob INTO lc_plotjob
    WHERE checked = 'X'.


* get filesize & content of the created document
    CLEAR l_phio.
    CLEAR lt_file_attrib.
    CLEAR lt_cnt_bin.

    MOVE: 'DMS_PCD1'       TO l_phio-class,
          lc_plotjob-file_id TO l_phio-objid.

    CALL FUNCTION 'SDOK_PHIO_LOAD_CONTENT'
         EXPORTING
              object_id           = l_phio
         TABLES
              file_access_info    = lt_file_attrib
              file_content_binary = lt_cnt_bin
         EXCEPTIONS
              not_existing        = 1
              not_authorized      = 2
              no_content          = 3
              bad_storage_type    = 4
              OTHERS              = 5.
    IF sy-subrc <> 0.
      MESSAGE e000(26) WITH i_fault.
      EXIT.
    ENDIF.

    READ TABLE lt_file_attrib INTO l_file_attrib INDEX 1.

    CLEAR: name, descr.
    MOVE: '*' TO name,
          l_docdata-description TO descr,
          l_file_attrib-file_name TO file_name,
          l_file_attrib-file_size TO file_size.

    CLEAR l_name.
    l_name = lc_plotjob-filep.
    l_name = file_name.
    CONCATENATE file_name '-' lc_plotjob-cont
      INTO l_name.

    CLEAR l_doc_descr.
    l_doc_descr = lc_plotjob-filep.



    CALL FUNCTION 'CFX_API_DOC_CREATE'
      DESTINATION i_cfolder_rfc-rfc_destination
      EXPORTING
        i_parent_folder_id = l_neutr_id
        i_name             = l_name
        i_backend_system   = i_cfolder_rfc-bs_name
        i_description      = l_doc_descr
        i_doc_type         = 'doc'
      IMPORTING
        e_faultstring      = i_fault
        e_doc_id           = l_doc_id.
    IF NOT i_fault IS INITIAL.
      MESSAGE e000(26) WITH i_fault.
      EXIT.
    ENDIF.



    CALL FUNCTION 'CFX_API_DOC_DOCUMENT_WRITE'
      DESTINATION i_cfolder_rfc-rfc_destination
      EXPORTING
        i_doc_id                 = l_doc_id
        i_file_path              = file_name
        i_file_size              = file_size
        i_change_current_version = 'no'
        i_version_name           = name
        i_version_description    = descr
      IMPORTING
        e_faultstring            = i_fault
      TABLES
        it_content               = lt_cnt_bin.
    .
    IF NOT i_fault IS INITIAL.
      MESSAGE e000(26) WITH i_fault.
      EXIT.
    ELSE.
    ENDIF.



  ENDLOOP.

  COMMIT WORK AND WAIT.

ENDFUNCTION.
