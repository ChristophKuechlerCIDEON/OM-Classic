FUNCTION Z_CL_BAPI_DOC_CHECKOUTVIEW2 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DOCUMENTTYPE) LIKE  BAPI_DOC_AUX-DOCTYPE
*"     VALUE(DOCUMENTNUMBER) LIKE  BAPI_DOC_AUX-DOCNUMBER
*"     VALUE(DOCUMENTPART) LIKE  BAPI_DOC_AUX-DOCPART
*"     VALUE(DOCUMENTVERSION) LIKE  BAPI_DOC_AUX-DOCVERSION
*"     VALUE(DOCUMENTFILE) LIKE  BAPI_DOC_FILES2 STRUCTURE
*"        BAPI_DOC_FILES2
*"     VALUE(GETSTRUCTURE) LIKE  BAPI_DOC_AUX-FLAG DEFAULT '1'
*"     VALUE(GETCOMPONENTS) LIKE  BAPI_DOC_AUX-FLAG DEFAULT 'X'
*"     VALUE(ORIGINALPATH) LIKE  BAPI_DOC_AUX-FILENAME DEFAULT SPACE
*"     VALUE(HOSTNAME) LIKE  BAPI_DOC_AUX-HOSTNAME DEFAULT SPACE
*"     VALUE(GETHEADER) LIKE  BAPI_DOC_AUX-FLAG DEFAULT 'X'
*"     VALUE(DOCBOMCHANGENUMBER) LIKE  BAPI_DOC_DRAW2-ECNUMBER OPTIONAL
*"     VALUE(DOCBOMVALIDFROM) LIKE  BAPI_DOC_DRAW2-VALIDFROMDATE
*"       OPTIONAL
*"     VALUE(DOCBOMREVISIONLEVEL) LIKE  BAPI_DOC_DRAW2-REVLEVEL
*"       OPTIONAL
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      DOCUMENTSTRUCTURE STRUCTURE  BAPI_DOC_STRUCTURE OPTIONAL
*"      DOCUMENTFILES STRUCTURE  BAPI_DOC_FILES2 OPTIONAL
*"      COMPONENTS STRUCTURE  BAPI_DOC_COMP OPTIONAL
*"----------------------------------------------------------------------
*  DATA: lf_error(1)   TYPE c,
*        lf_multilevel LIKE bapi_doc_aux-flag.
*
*  DATA: lf_destination LIKE  rfcdes-rfcdest,
*        lf_gui_exists.
*
*  DATA: lsx_message    LIKE messages,
*        ls_api_control TYPE cvapi_api_control.
*
*  DATA: filename(310)     TYPE c,
*        originalname(310) TYPE c.
*
*  DATA: lt_originals      LIKE cvapi_doc_file OCCURS 0 WITH HEADER LINE
*,
*        lt_tmp_originals  LIKE cvapi_doc_file OCCURS 0 WITH HEADER LINE
*,
*        lt_components     LIKE cvapi_doc_comp OCCURS 0 WITH HEADER LINE
*,
*        lt_bapi_originals LIKE bapi_doc_files2
*                                             OCCURS 0 WITH HEADER LINE,
*        lt_bapi_comp LIKE bapi_doc_comp OCCURS 0 WITH HEADER LINE,
*        lt_aux_doc   LIKE bapi_doc_structure OCCURS 0 WITH HEADER LINE.
**
*----------------------------------------------------------------------
*
*  PERFORM clear_global_data.
*
*  CLEAR: return, documentfiles, components.
*  REFRESH: documentfiles, components.
*
**
*----------------------------------------------------------------------
** Convert the key´s to uppercase
**
*----------------------------------------------------------------------
*  TRANSLATE documenttype    TO UPPER CASE.               "#EC TRANSLANG
*  TRANSLATE documentnumber  TO UPPER CASE.               "#EC TRANSLANG
*  TRANSLATE documentversion TO UPPER CASE.               "#EC TRANSLANG
*  TRANSLATE documentpart    TO UPPER CASE.               "#EC TRANSLANG
*
**
*----------------------------------------------------------------------
** get the document-structure
**
*----------------------------------------------------------------------
*  CLEAR: lt_aux_doc.  REFRESH: lt_aux_doc.
*  IF getstructure = '2'.
*    lf_multilevel = 'X'.
*  ELSE.
*    CLEAR lf_multilevel.
*  ENDIF.
*
*  IF getstructure = '1' OR getstructure = '2'.
*    CALL FUNCTION 'BAPI_DOCUMENT_GETSTRUCTURE'
*         EXPORTING: documenttype           = documenttype
*                    documentnumber         = documentnumber
*                    documentpart           = documentpart
*                    documentversion        = documentversion
*                    multilevelexplosion    = lf_multilevel
*                    docbomchangenumber     = docbomchangenumber
*                    docbomvalidfrom        = docbomvalidfrom
*                    docbomrevisionlevel    = docbomrevisionlevel
*         IMPORTING: return                 = return
*         TABLES:    documentstructure      = lt_aux_doc.
*    LOOP AT lt_aux_doc WHERE cad_pos <> ' '.
*      DELETE lt_aux_doc WHERE
*          documentnumber = lt_aux_doc-documentnumber AND
*          documenttype = lt_aux_doc-documenttype AND
*          documentpart = lt_aux_doc-documentpart AND
*          documentversion = lt_aux_doc-documentversion AND
*          cad_pos = ' '.
*    ENDLOOP.
*
*    IF sy-subrc <> 0.
*    ENDIF.
*    CLEAR return.
*  ELSE.
*    CLEAR documentstructure.
*  ENDIF.
*
**
*----------------------------------------------------------------------
** If entries in the imported documentstructure -> CheckOut only these
** files but first check, if they are valid members of the structure
**
*----------------------------------------------------------------------
*  IF NOT documentstructure[] IS INITIAL.
*    SORT lt_aux_doc BY documenttype
*                       documentnumber
*                       documentpart
*                       documentversion.
*
*    LOOP AT documentstructure.
*      READ TABLE lt_aux_doc
*      WITH KEY documenttype    = documentstructure-documenttype
*               documentnumber  = documentstructure-documentnumber
*               documentpart    = documentstructure-documentpart
*               documentversion = documentstructure-documentversion
*      BINARY SEARCH.
*
*      IF sy-subrc = 0.
*        lt_aux_doc-deletevalue = 'X'.  " Sign for CheckOut
*        MODIFY lt_aux_doc INDEX sy-tabix.
*
** Document is not a member !!!
*      ELSE.
*        bapi_message-msg_id = c_message_id_26.
*        bapi_message-msg_type = 'E'.
*        bapi_message-msg_no = 251.
*        bapi_message-msg_v1 = documentstructure-documenttype.
*        bapi_message-msg_v2 = documentstructure-documentnumber.
*        bapi_message-msg_v3 = documentstructure-documentpart.
*        bapi_message-msg_v4 = documentstructure-documentversion.
*        lf_error = 'X'.                " Not found !!!!!
*      ENDIF.
*      CHECK lf_error IS INITIAL.
*    ENDLOOP.
*
** CheckOut all
*  ELSE.
*    lt_aux_doc-deletevalue = 'X'.      " Sign for CheckOut
*    MODIFY lt_aux_doc TRANSPORTING deletevalue
*    WHERE deletevalue IS INITIAL.
*  ENDIF.
*
** All documents found ?
*  IF lf_error = 'X'.
*    PERFORM fill_bapi_return2
*        USING 0 bapi_message
*        CHANGING return.
*    EXIT.
*  ENDIF.
*
**
*----------------------------------------------------------------------
** if header-document should not be checked out -> check if it's given
** in documentstructure
**
*----------------------------------------------------------------------
*  IF getheader IS INITIAL AND NOT documentstructure[] IS INITIAL.
*    READ TABLE documentstructure
*    WITH KEY documenttype    = documenttype
*             documentnumber  = documentnumber
*             documentpart    = documentpart
*             documentversion = documentversion.
*    IF sy-subrc = 0.
*      getheader = 'X'.
*    ENDIF.
*  ENDIF.
*
** Insert main-document at the first position
*  IF getheader = 'X'.
*    CLEAR lt_aux_doc.
*    lt_aux_doc-documenttype    = documenttype.
*    lt_aux_doc-documentnumber  = documentnumber.
*    lt_aux_doc-documentpart    = documentpart.
*    lt_aux_doc-documentversion = documentversion.
*    lt_aux_doc-deletevalue = 'X'.
*    INSERT lt_aux_doc INDEX 1.
*  ENDIF.
*
**
*----------------------------------------------------------------------
** select "DOCUMENTFILE-WSAPPLICATION"-specified documentfiles from the
** internal table LT_AUX_DOC and initialize their checkout-path.
**
*----------------------------------------------------------------------
*  CALL FUNCTION 'CV120_FTP_START_REG_SERVER'
*       EXPORTING: pf_check_gui    = 'X'
*       IMPORTING: pfx_destination = lf_destination
*                  pfx_gui_exist   = lf_gui_exists
*       EXCEPTIONS: error          = 1
*                   OTHERS         = 2.
*  IF sy-subrc <> 0.
*    CLEAR lsx_message.
*    PERFORM fill_bapi_message_from_syst CHANGING lsx_message.
*    PERFORM fill_bapi_return2 USING 0 lsx_message CHANGING return.
*    EXIT.
*  ENDIF.
*
**
*----------------------------------------------------------------------
** tell ftp to keep open, it it will be used
**
*----------------------------------------------------------------------
*  CALL FUNCTION 'CV120_FTP_OPEN'
*       EXPORTING:  pf_show_progress = 'X'
*                   pf_collect_cmd   = ''
*"                   PF_VAULT         = 'TXT'
*       EXCEPTIONS: error            = 1
*                   OTHERS           = 2.
*
*  LOOP AT lt_aux_doc WHERE deletevalue = 'X'.
*    CALL FUNCTION 'CVAPI_DOC_GETDETAIL'
*         EXPORTING: pf_batchmode     = 'X'
*                    pf_hostname      = hostname
*                    pf_dokar        = lt_aux_doc-documenttype
*                    pf_doknr        = lt_aux_doc-documentnumber
*                    pf_dokvr        = lt_aux_doc-documentversion
*                    pf_doktl        = lt_aux_doc-documentpart
*                    pf_active_files = 'X'
*                    pf_read_comp    = getcomponents
*        TABLES:     pt_files        = lt_tmp_originals
*        EXCEPTIONS: not_found       = 1
*                    no_auth         = 2
*                    error           = 3
*                    OTHERS          = 4.
*    IF sy-subrc <> 0.
*      CLEAR lsx_message.
*      PERFORM fill_bapi_message_from_syst CHANGING lsx_message.
*      PERFORM fill_bapi_return2 USING 0 lsx_message CHANGING return.
*      EXIT.
*    ENDIF.
*
*    CLEAR: lt_originals, lf_error.
*    REFRESH lt_originals.
*
**
*----------------------------------------------------------------------
** only checkout the given application -> delete all other from the list
**
*----------------------------------------------------------------------
*    IF documentfile-wsapplication IS INITIAL.
*      documentfile-wsapplication = '*'.
*    ENDIF.
*
*    IF documentfile-wsapplication <> '*'.
*      DELETE lt_tmp_originals
*      WHERE dappl <> documentfile-wsapplication.
*    ENDIF.
*
*    IF NOT documentfile-originaltype IS INITIAL OR (
*       NOT documentfile-application_id IS INITIAL AND
*       NOT documentfile-file_id IS INITIAL ).
*
*      LOOP AT lt_tmp_originals.
*        IF lt_tmp_originals-appnr EQ
*                               documentfile-originaltype AND
*            lt_tmp_originals-lo_objid EQ
*                               documentfile-application_id AND
*              lt_tmp_originals-ph_objid EQ
*                               documentfile-file_id.
*          MOVE lt_tmp_originals TO lt_originals.
*
*          MOVE lt_tmp_originals TO lt_originals.
*          CLEAR: lt_originals-filename,
*                 lt_originals-dttrg.
*          MOVE originalpath TO lt_originals-pathname.
*          APPEND lt_originals.
*          lf_error = 'X'.
*        ENDIF.
*
*        IF lf_error = 'X'.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
*
*    ELSE.
*      LOOP AT lt_tmp_originals.
*        MOVE lt_tmp_originals TO lt_originals.
*
*        CLEAR: lt_originals-filename,
*               lt_originals-dttrg.
*        MOVE originalpath TO lt_originals-pathname.
*        APPEND lt_originals.
*      ENDLOOP.
*    ENDIF.
*
*    ls_api_control-comp_get = getcomponents.
*    "CALL FUNCTION 'CVAPI_DOC_CHECKOUTVIEW'
*    CALL FUNCTION 'ZCL_PLINT_CVAPI_DOC_CHECKOUTVW'
*         EXPORTING: pf_dokar       = lt_aux_doc-documenttype
*                    pf_doknr       = lt_aux_doc-documentnumber
*                    pf_dokvr       = lt_aux_doc-documentversion
*                    pf_doktl       = lt_aux_doc-documentpart
*                    pf_ftp_dest    = lf_destination
*                    pf_hostname    = hostname
*                    ps_api_control = ls_api_control
*         IMPORTING: psx_message    = lsx_message
*         TABLES:    pt_files       = lt_originals
*                    ptx_components = lt_components.
*
*    IF lsx_message-msg_type CA 'EA'.
*      PERFORM fill_bapi_return2
*          USING 0 lsx_message
*          CHANGING return.
*      EXIT.
*
*    ELSE.
*      CALL FUNCTION 'MAP2E_API_FILE_TO_BAPI_FILE2'
*           TABLES: api_doc_file  = lt_originals
*                   bapi_doc_file = lt_bapi_originals.
*      LOOP AT lt_bapi_originals.
*        lt_bapi_originals-documentnumber = lt_aux_doc-documentnumber.
*        lt_bapi_originals-documenttype = lt_aux_doc-documenttype.
*        lt_bapi_originals-documentpart = lt_aux_doc-documentpart.
*        lt_bapi_originals-documentversion = lt_aux_doc-documentversion.
*        MODIFY lt_bapi_originals.
*      ENDLOOP.
*      APPEND LINES OF lt_bapi_originals TO documentfiles.
*
*      IF getcomponents = 'X'.
*        CALL FUNCTION 'MAP2E_API_COMP_TO_BAPI_COMP'
*             TABLES: api_doc_comp  = lt_components
*                     bapi_doc_comp = lt_bapi_comp.
*        APPEND LINES OF lt_bapi_comp TO components.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
**
*----------------------------------------------------------------------
** stop ftp
**
*----------------------------------------------------------------------
*  CALL FUNCTION 'CV120_FTP_EXEC_CMD_LIST'
*       EXCEPTIONS: error  = 1
*                   OTHERS = 2.
*  IF sy-subrc <> 0.
*    CLEAR lsx_message.
*    PERFORM fill_bapi_message_from_syst CHANGING lsx_message.
*    PERFORM fill_bapi_return2 USING 0 lsx_message CHANGING return.
*    EXIT.
*  ENDIF.
*
*  CALL FUNCTION 'CV120_FTP_CLOSE'.
*  IF lf_gui_exists IS INITIAL.
*    CALL FUNCTION 'CV120_FTP_STOP_REG_SERVER'
*         EXPORTING: pf_destination = lf_destination.
*  ENDIF.
*
*** Exit Programm
*  CHECK return-type NA 'EA'.
*
*** Delete the main-document form the structure
*  DELETE lt_aux_doc INDEX 1.
*
*** Reset the flag & move the document-structure to external data
*  CLEAR lt_aux_doc-deletevalue.
*  MODIFY lt_aux_doc TRANSPORTING deletevalue
*  WHERE deletevalue = 'X'.
*  documentstructure[] = lt_aux_doc[].
ENDFUNCTION.
