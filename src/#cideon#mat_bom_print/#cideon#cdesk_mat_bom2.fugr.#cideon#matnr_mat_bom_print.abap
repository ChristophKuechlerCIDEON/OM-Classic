FUNCTION /cideon/matnr_mat_bom_print.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(MATNR) TYPE  MARA-MATNR
*"     VALUE(BOM_PRINT) TYPE  /CIDEON/BOM_PRINT
*"     REFERENCE(TDDEST) TYPE  RSPOPNAME
*"     REFERENCE(TDPRINTER) TYPE  RSPOPTYPE
*"  EXPORTING
*"     REFERENCE(SPOOLIDS) TYPE  TSFSPOOLID
*"     REFERENCE(RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------
*       CIDEON Software GmbH
*       Peterstraße 1
*       02826 Görlitz
*----------------------------------------------------------------------
*       Selektion und Druck Materialstückliste
*----------------------------------------------------------------------
* ACHTUNG:  Programm einschließlich seiner Komponenten wurde für
*           Releases ab 4.6 C aufwärts konzipiert und ist nicht ohne
*           erheblichen Aufwand an 4.6 B anpassbar !!
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           04.01.2005
*
* Erweiterung:
*           Christoph Küchler
*-----------------------------------------------------------------------
* Journal   04.01.2005 Test Selektion Materialstückliste
*           14.01.2005 Umstellen UP in FB für Mehrfachnutzung
*           12.05.2005 Überarbeitung für Start aus Bestellung heraus
*                      und Rückgabe der Spool-ID
*           20.06.2005 Erweiterung um Parameter DATUV
*           03.02.1006 - BOMDATUV
*   PRE     18.10.2006 - Erweiterung um Parameter Ausgabesprache
*   CKR     26.10.2006 - Probleme mit CONV_UTIL_MATNR_EXT_TO_INT
*                      in einem DIMP System
*                      BUG: 1817
* SP 103
* 02.09.2009 - /CIDEON/MATNR_MAT_BOM_PRINT
*              Übergabe der Fehlermeldung
* SP 104
* CKR
* 28.09.2009 - Benutzung wa_bom_print-explv
*
* SP 105
* CKR
* 01.10.2009 - BOMTYPE
*-----------------------------------------------------------------------

  DATA: ls_output_options TYPE ssfcompop,
        ls_control_parameters TYPE ssfctrlop,
        ls_job_output_info TYPE ssfcrescl,
        ls_job_output_options TYPE ssfcresop,
        ls_bom_print TYPE /cideon/bom_print,
        ls_mat_dir TYPE /cideon/mat_dir,
        ls_draw TYPE draw,
        ls_return TYPE bapiret2,
        lc_objecttype TYPE bapi_doc_drad-objecttype,
        lc_objectkey TYPE bapi_doc_drad-objectkey,
        ls_documentlist TYPE bapi_doc_keys,
        lt_documentlist TYPE TABLE OF bapi_doc_keys,
        lc_matnr TYPE matnr,
        lc_matnr_e TYPE matnr,
        lc_index TYPE syindex,
        bapi_message LIKE messages.

  FIELD-SYMBOLS:  <doc_key> TYPE bapi_doc_keys,
                  <bom_pos> TYPE ANY, "stpox
                  <postp> TYPE ANY,
                  <dokar> TYPE ANY,
                  <doknr> TYPE ANY,
                  <dokvr> TYPE ANY,
                  <doktl> TYPE ANY,
                  <idnrk> TYPE ANY.

  MOVE: 'E' TO bapi_message-msg_type,
        '/CIDEON/MAT_BOM_PRIN' TO bapi_message-msg_id.

  PERFORM assign_break_point.
  break_point.                                             "#EC NOBREAK

* BOMDATUV anpassen
  IF bom_print-datuv = ''.
    CLEAR bom_print-datuv.
  ELSE.
  ENDIF.

*     Initialisieren der globalen Daten, vor allem bei
*     mehrfachem Programmstart in einer Session
  PERFORM clear_global_data.

*  Lesen der User-Daten in TCSPR bzw. User-Parameter oder DEFAULT
*  CALL FUNCTION '/CIDEON/SELECT_USER_DATA2'
*       IMPORTING
*            return  = return
*            bom_usr = gs_bom_usr.
*  IF return-type CA 'EA'.
  IF bom_print IS INITIAL.
    bapi_message-msg_no = '002'.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ELSE.
    g_plant = bom_print-werks.
    g_usage = bom_print-stlan.
    g_alternative = bom_print-stlal.
  ENDIF.
  IF NOT bom_print-datuv IS INITIAL.
    g_datuv = bom_print-datuv.
  ELSE.
    g_datuv = sy-datum.
  ENDIF.
  IF bom_print-spras IS INITIAL.
    g_spras = sy-langu.
  ELSE.
    g_spras = bom_print-spras.
  ENDIF.

  "CKR 28.09.2009
  IF bom_print-explv IS INITIAL.
    bom_print-explv = 99.
    g_stpst = bom_print-explv.
  ELSE.
    g_stpst = bom_print-explv.
  ENDIF.

  "CKR 01.10.2009
  "CAPID
  g_capid = bom_print-capid.

  "CKR 01.10.2009
  "BOMTYPE
  g_bomtype = bom_print-bomtype.

  IF NOT matnr IS INITIAL.
* CKR
*    CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
*         EXPORTING
*              i_material = matnr
*         IMPORTING
*              e_material = lc_matnr.
*    g_head_matnr = matnr.
    DATA: matnr_in TYPE csap_mbom-matnr.
    DATA: matnr_out TYPE mbm_class_data-matnr.
    CLEAR matnr_in.
    CLEAR matnr_out.
    matnr_in = matnr.
    CALL FUNCTION 'CONV_UTIL_MATNR_EXT_TO_INT'
         EXPORTING
              i_material = matnr_in
         IMPORTING
              e_material = matnr_out.
    lc_matnr = matnr_out.
    g_head_matnr = matnr_out.
* /CKR
  ELSE.
    bapi_message-msg_no = '002'.
    bapi_message-msg_v1 = matnr.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ENDIF.

*  Ermitteln der vollständigen Daten des Kopfmaterials
  CALL FUNCTION '/CIDEON/MAT_BOM_HEADER2'
       EXPORTING
            matnr    = g_head_matnr
            plant    = g_plant
            usage    = g_usage
            alter    = g_alternative
            aennr    = g_changeno
            datuv    = g_datuv
            spras    = g_spras
       IMPORTING
            return   = return
       TABLES
            head_mat = gt_head_mat.

  IF return-type CA 'EA'.
    bapi_message-msg_no = '003'.
    bapi_message-msg_v1 = matnr.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ENDIF.

*  Ermitteln der verknüpften Dokumente zum Kopf:
  MOVE:  'MARA' TO lc_objecttype,
         lc_matnr TO lc_objectkey.

*  Lesen der bereits vorm Speichern vorhandenen Objektverknüpfungen:

  CLEAR: ls_return, lt_documentlist.
  CALL FUNCTION 'BAPI_DOCUMENT_GETOBJECTDOCS'
    EXPORTING
      objecttype                = lc_objecttype
      objectkey                 = lc_objectkey
*   CURRENTVERSIONSONLY       =
*   DATE                      = SY-DATUM
     IMPORTING
       return                    = ls_return
    TABLES
      documentlist              = lt_documentlist.
  LOOP AT lt_documentlist ASSIGNING <doc_key>.
    CHECK <doc_key> IS ASSIGNED.
    MOVE-CORRESPONDING <doc_key> TO ls_mat_dir.
    MOVE lc_matnr TO ls_mat_dir-objky.
    APPEND ls_mat_dir TO gt_head_mat_dir.
  ENDLOOP.

*  Ermitteln der vollständigen Daten der BOM-Positionen
  CALL FUNCTION '/CIDEON/MAT_BOM_POSITION2'
       EXPORTING
            matnr   = g_head_matnr
            plant   = g_plant
            usage   = g_usage
            alter   = g_alternative
            aennr   = g_changeno
            datuv   = g_datuv
            spras   = g_spras
       IMPORTING
            return  = return
       TABLES
            mat_bom = gt_mat_bom.
  IF return-type CA 'EA'.
    bapi_message-msg_no = '004'.
    bapi_message-msg_v1 = matnr.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ENDIF.

*  Auseinandersteuern der verschiedenen BOM-Ausprägungen_:
*  Kopf sollte überall gleich sein:
  READ TABLE gt_head_mat INTO gs_head_mat INDEX 1.

*  Rumpf sollte der jeweiligen Struktur im
*  SmartForms-Baustein entsprechen:

  CALL FUNCTION '/CIDEON/GET_BOM_VARIANT2'
       EXPORTING
            bom_print      = bom_print
       IMPORTING
            return         = return
       TABLES
            mat_bom_i      = gt_mat_bom
            mat_bom_cs03_a = gt_mat_bom_cs03_a
            mat_bom_cs03_d = gt_mat_bom_cs03_d
            mat_bom_cs03_m = gt_mat_bom_cs03_m
            mat_bom_cs11   = gt_mat_bom_cs11
            mat_bom_cs12   = gt_mat_bom_cs12
            mat_bom_cs13   = gt_mat_bom_cs13.

  IF return-type CA 'EA'.
    bapi_message-msg_no = '005'.
    bapi_message-msg_v1 = matnr.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ENDIF.

  CASE bom_print-bomtype.
    WHEN 'CS03'.
      CASE bom_print-bomausp.
        WHEN 'A'.
          formname = '/CIDEON/MAT_BOM_CS03_A2_D'.
          ASSIGN gt_mat_bom_cs03_a[] TO <mat_bom>.
        WHEN 'D'.
          formname = '/CIDEON/MAT_BOM_CS03_D2_D'.
          ASSIGN gt_mat_bom_cs03_d[] TO <mat_bom>.
        WHEN 'M'.
          formname = '/CIDEON/MAT_BOM_CS03_M2_D'.
          ASSIGN gt_mat_bom_cs03_m[] TO <mat_bom>.
      ENDCASE.
    WHEN 'CS11'.
      formname = '/CIDEON/MAT_BOM_CS11_D'.
      ASSIGN gt_mat_bom_cs11[] TO <mat_bom>.
    WHEN 'CS12'.
      formname = '/CIDEON/MAT_BOM_CS12_D'.
      ASSIGN gt_mat_bom_cs12[] TO <mat_bom>.
    WHEN 'CS13'.
      formname = '/CIDEON/MAT_BOM_CS13_D'.
      ASSIGN gt_mat_bom_cs13[] TO <mat_bom>.
    WHEN OTHERS.
      CLEAR formname.
  ENDCASE.

  IF NOT bom_print-formname IS INITIAL.
    MOVE bom_print-formname TO formname.
  ENDIF.

  IF <mat_bom> IS ASSIGNED.
    CALL FUNCTION '/CIDEON/SELECT_MAT_DIR'
         EXPORTING
              bom_print    = bom_print
         TABLES
              mat_bom      = <mat_bom>
              posi_mat_dir = gt_posi_mat_dir.

  ELSE.
    bapi_message-msg_no = '002'.
    bapi_message-msg_v1 = formname.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ENDIF.


* BADI-Erweiterung
  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = mat_bom_print.

  MOVE bom_print TO ls_bom_print.
  CALL METHOD mat_bom_print->change_table
    EXPORTING
      bom_print      = ls_bom_print
    CHANGING
      mat_bom_tab    =  <mat_bom>
      head_mat_struc = gs_head_mat
    EXCEPTIONS
      error          = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
    bapi_message-msg_no = '006'.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ELSE.
  ENDIF.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname                 = formname
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
   IMPORTING
     fm_name                  = fm_name
  EXCEPTIONS
   no_form                  = 1
   no_function_module       = 2
   OTHERS                   = 3
            .
  IF sy-subrc <> 0.
    bapi_message-msg_no = '001'.
    bapi_message-msg_v1 = formname.
    CLEAR return.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
         EXPORTING:  type       = bapi_message-msg_type
                     cl         = bapi_message-msg_id
                     number     = bapi_message-msg_no
                     par1       = bapi_message-msg_v1
                     par2       = bapi_message-msg_v2
                     par3       = bapi_message-msg_v3
                     par4       = bapi_message-msg_v4
                     row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
        IMPORTING : return = return.
    EXIT.
  ENDIF.


  ls_control_parameters-device = 'PRINTER'.
* ls_control_parameters-getotf = 'X'.
  ls_control_parameters-no_dialog = 'X'.
*  ls_control_parameters-PREVIEW = 'X'.
  IF ls_bom_print-spras IS INITIAL.
    ls_control_parameters-langu = sy-langu.
  ELSE.
    ls_control_parameters-langu = ls_bom_print-spras.
  ENDIF.

  MOVE tddest TO ls_output_options-tddest.
  MOVE tdprinter TO ls_output_options-tdprinter.
  ls_output_options-tdimmed = space.
  ls_output_options-tddelete = space.
  ls_output_options-tdnewid = 'X'.
  ls_output_options-tdlifetime = '8'.
  ls_output_options-tdfinal = 'X'.

  CALL FUNCTION fm_name
    EXPORTING
*        ARCHIVE_INDEX              =
*        ARCHIVE_INDEX_TAB          =
*        ARCHIVE_PARAMETERS         =
         control_parameters         = ls_control_parameters
*        MAIL_APPL_OBJ              =
*        MAIL_RECIPIENT             =
*        MAIL_SENDER                =
         output_options             = ls_output_options
         user_settings              = space
         head_mat                   = gs_head_mat
       IMPORTING
*        DOCUMENT_OUTPUT_INFO       =
         job_output_info            = ls_job_output_info
         job_output_options         = ls_job_output_options
       TABLES
         gt_mat_bom                 = <mat_bom>
         gt_head_mat_dir            = gt_head_mat_dir
         gt_posi_mat_dir            = gt_posi_mat_dir
       EXCEPTIONS
         formatting_error           = 1
         internal_error             = 2
         send_error                 = 3
         user_canceled              = 4
         OTHERS                     = 5.
  IF sy-subrc <> 0.

    " CKR
    " 2009/09/02
                                                            " BUG7267
    IF sy-msgid IS INITIAL.
      bapi_message-msg_no = '001'.
      bapi_message-msg_v1 = fm_name.
      CLEAR return.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
           EXPORTING:  type       = bapi_message-msg_type
                       cl         = bapi_message-msg_id
                       number     = bapi_message-msg_no
                       par1       = bapi_message-msg_v1
                       par2       = bapi_message-msg_v2
                       par3       = bapi_message-msg_v3
                       par4       = bapi_message-msg_v4
                       row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
          IMPORTING : return = return.
    ELSE.
      bapi_message-msg_no = sy-msgno.
      bapi_message-msg_v1 = sy-msgv1.
      CLEAR return.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
           EXPORTING:  type       = sy-msgty
                       cl         = sy-msgid
                       number     = sy-msgno
                       par1       = sy-msgv1
                       par2       = sy-msgv2
                       par3       = sy-msgv3
                       par4       = sy-msgv4
                       row        = 0
*                  LOG_NO     = ' '
*                  LOG_MSG_NO = ' '
          IMPORTING : return = return.


    ENDIF.

    EXIT.
  ELSE.
    MOVE ls_job_output_info-spoolids TO spoolids.

  ENDIF.

  PERFORM unassign_field_symbols.

ENDFUNCTION.
