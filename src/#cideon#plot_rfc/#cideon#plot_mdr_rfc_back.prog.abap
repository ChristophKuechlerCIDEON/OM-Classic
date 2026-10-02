*&---------------------------------------------------------------------*
*& Report  /CIDEON/PLOT_MDR_RFC_BACK                                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  /cideon/plot_mdr_rfc_back     .

*-----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* MDR Datei wieder ins SAP bringen
* DIS anlegen
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
*-----------------------------------------------------------------------
* Journal
* 16.08.2007 - Erstellung
* 21.08.2007 - Test der RFC Verbindungen
* 03.09.2007 - Verschieben der verarbeiteten Daten in die Verzeichnisse
*              OK und Error
* 12.09.2007 - Sulzer: Fehler beim Checkin mehrerer Dateien
*              Ursache IT_DOC_FILES nicht neu initialisiert
*-----------------------------------------------------------------------
* to do
*
* Batch Fähigkeiten überprüfen
* Applicationslog schreiben
* Verschieben der Dateien,
*   welche nicht verarbeitet werden können
*   welche verarbeitet wurden
*
*-----------------------------------------------------------------------
* ITAB
DATA: lt_file_in TYPE TABLE OF /cideon/s_rfc_svr_file_info.
DATA: lt_file_out TYPE TABLE OF /cideon/s_rfc_svr_file_info.
DATA: lt_file_in2 TYPE TABLE OF /cideon/s_rfc_svr_file_info.
DATA: lt_file_out2 TYPE TABLE OF /cideon/s_rfc_svr_file_info.
* WA
DATA: wa_file_in TYPE /cideon/s_rfc_svr_file_info.
DATA: wa_file_out TYPE /cideon/s_rfc_svr_file_info.
DATA: wa_file_in2 TYPE /cideon/s_rfc_svr_file_info.
DATA: wa_file_out2 TYPE /cideon/s_rfc_svr_file_info.

* NORMAL
DATA: return TYPE bapiret2.

DATA: badi_om_ps_01 TYPE REF TO /cideon/if_ex_om_ps_01.

SELECTION-SCREEN BEGIN OF BLOCK rfc
  WITH FRAME TITLE text-001.
PARAMETERS: rfcdest TYPE rfcattrib-rfcdest DEFAULT 'CKR'.
PARAMETERS: rfc_sh TYPE rfcattrib-rfcdest DEFAULT 'CKR_SAPHTTP'.
PARAMETERS: rfc_sf TYPE rfcattrib-rfcdest DEFAULT 'CKR_SAPFTP'.
SELECTION-SCREEN END OF BLOCK rfc.

SELECTION-SCREEN BEGIN OF BLOCK dir
  WITH FRAME TITLE text-002.
PARAMETERS pdir TYPE /cideon/s_rfc_svr_file_info-filename
  DEFAULT 'c:\temp'.
PARAMETERS ptrenn TYPE char1 DEFAULT ','.
PARAMETERS pdirok TYPE /cideon/s_rfc_svr_file_info-filename
  DEFAULT 'c:\temp\ok'.
PARAMETERS pdirerr TYPE /cideon/s_rfc_svr_file_info-filename
DEFAULT 'c:\temp\error'.
SELECTION-SCREEN END OF BLOCK dir.

SELECTION-SCREEN BEGIN OF BLOCK mdr
  WITH FRAME TITLE text-003.
PARAMETERS pdokar TYPE draw-dokar DEFAULT 'MDR'.
PARAMETERS pdoknr TYPE draw-doknr DEFAULT '*'.
PARAMETERS pdoktl TYPE draw-doktl DEFAULT '000'.
PARAMETERS pdokvr TYPE draw-dokvr DEFAULT '00'.
PARAMETERS pdappl TYPE dappl DEFAULT 'PDF'.
PARAMETERS pstor TYPE cv_storage_cat DEFAULT 'Z_CAD_GR_2'.
SELECTION-SCREEN END OF BLOCK mdr.



* Testen der Verbindungen
PERFORM test_rfc_dest USING rfcdest.
PERFORM test_rfc_dest USING rfc_sh.
PERFORM test_rfc_dest USING rfc_sf.

* Lesen der Verzeichnisse und Dateien
* /CIDEON/RFC_SVR_FILE_MAN

*   BADI initialisieren
IF badi_om_ps_01 IS INITIAL.
  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_om_ps_01.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
ELSE.
ENDIF.



CLEAR return.
CLEAR lt_file_in.
CLEAR lt_file_out.

CLEAR wa_file_in.
wa_file_in-filename = pdir.
APPEND wa_file_in TO lt_file_in.

CALL FUNCTION '/CIDEON/RFC_SVR_FILE_MAN'
  DESTINATION rfcdest
  EXPORTING
*    fcode                       = 'LIST_DIRECTORY'
    fcode                       = 'LIST_DIRECTORY_SPL'
  IMPORTING
    return                      = return
   TABLES
     filetab1                    = lt_file_in
     filetab2                    = lt_file_out
   EXCEPTIONS
     system_failure              = 1
     communication_failure       = 2
     OTHERS                      = 3
          .
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.


* Aufbereiten der Dateiliste
* alle anderen Extensionen und Verzeichnisse rauswerfen
DATA: pfx_path TYPE draw-filep.
DATA: pfx_file TYPE draw-filep.
DATA: pf_path TYPE filep.
LOOP AT lt_file_out INTO wa_file_out.
  CLEAR pfx_path.
  CLEAR pfx_file.

  IF wa_file_out-isdir = 'X'.
    DELETE lt_file_out INDEX sy-tabix.
    CONTINUE.
  ELSE.
  ENDIF.

  pf_path = wa_file_out-filename.

  CALL FUNCTION 'CV120_SPLIT_PATH'
       EXPORTING
            pf_path  = pf_path
       IMPORTING
            pfx_path = pfx_path
            pfx_file = pfx_file.

  DATA: pf_file TYPE filep.
  DATA: pfx_extension TYPE filep.

  CLEAR pfx_extension.
  pf_file = pfx_file.
  CALL FUNCTION 'CV120_SPLIT_FILE'
    EXPORTING
      pf_file                = pf_file
    IMPORTING
      pfx_file               = pfx_file
      pfx_extension          = pfx_extension
*     PFX_DOTEXTENSION       =
            .
  IF pfx_extension = 'PDF'
    OR pfx_extension = 'pdf'
    .
  ELSE.
    DELETE lt_file_out INDEX sy-tabix.
    PERFORM move_error USING wa_file_out.
    PERFORM appl_log_write USING
      'E' '005' '/CIDEON/PLOT_RFC'
      wa_file_out-filename pdirerr '' ''.
    CONTINUE.
  ENDIF.
ENDLOOP.

* bereinigte Tabelle bearbeiten
IF lt_file_out[] IS INITIAL.
  EXIT.
ELSE.
ENDIF.

DATA: wa_root_dir TYPE draw.
LOOP AT lt_file_out INTO wa_file_out.
*  WRITE:  wa_file_out-filename.
  pf_path = wa_file_out-filename.

  CALL FUNCTION 'CV120_SPLIT_PATH'
       EXPORTING
            pf_path  = pf_path
       IMPORTING
            pfx_path = pfx_path
            pfx_file = pfx_file.

  CLEAR pfx_extension.
  pf_file = pfx_file.
  CALL FUNCTION 'CV120_SPLIT_FILE'
    EXPORTING
      pf_file                = pf_file
    IMPORTING
      pfx_file               = pfx_file
      pfx_extension          = pfx_extension
*     PFX_DOTEXTENSION       =
    .

* Root DIS auslesen
  CLEAR wa_root_dir.
  SPLIT pfx_file
    AT ptrenn
    INTO wa_root_dir-dokar wa_root_dir-doknr
    wa_root_dir-doktl wa_root_dir-dokvr
    .

* Testen, ob der ROOT DIS Existiert
  DATA: mandt TYPE mandt.
  SELECT SINGLE mandt FROM draw INTO mandt
    WHERE dokar = wa_root_dir-dokar
    AND doknr = wa_root_dir-doknr
    AND doktl = wa_root_dir-doktl
    AND dokvr = wa_root_dir-dokvr
    .
  IF sy-subrc NE 0.
    DELETE lt_file_out INDEX sy-tabix.
    PERFORM move_error USING wa_file_out.
    PERFORM appl_log_write USING
      'E' '005' '/CIDEON/PLOT_RFC'
      wa_file_out-filename pdirerr '' 'NO ROOT DIR'.
    CONTINUE.
  ELSE.
  ENDIF.

* Erstelllen des DIS
* DIS
  DATA: documentdata TYPE bapi_doc_draw2.
  DATA: document TYPE bapi_doc_aux.

* Datei
  DATA: it_doc_files TYPE TABLE OF bapi_doc_files2.
  DATA: wa_doc_files TYPE bapi_doc_files2.

  CLEAR document.

  CLEAR documentdata.
  documentdata-documenttype = pdokar.
  documentdata-documentnumber =  pdoknr. "'*'.
  documentdata-documentpart = pdoktl.
  documentdata-documentversion = pdokvr.

  CONCATENATE text-004
    sy-datum sy-uzeit
    INTO documentdata-description
    SEPARATED BY space.

  CLEAR it_doc_files.
  CLEAR wa_doc_files.
  wa_doc_files-wsapplication = pdappl. "'PDF'.
  wa_doc_files-storagecategory = pstor. "'Z_M19X_CS'.
  wa_doc_files-docfile = wa_file_out-filename.

  wa_doc_files-description = documentdata-description.

  APPEND wa_doc_files TO it_doc_files.

  DATA: it_char_val TYPE TABLE OF bapi_characteristic_values.
  DATA: it_class_alloc TYPE TABLE OF bapi_class_allocation.
  DATA: it_doc_desc TYPE TABLE OF bapi_doc_drat.

  CLEAR it_char_val.
  CLEAR it_class_alloc.
  CLEAR it_doc_desc.

*   BADI für TR DIS erstellen
  IF badi_om_ps_01 IS INITIAL.
  ELSE.
    CALL METHOD badi_om_ps_01->chg_mdr_dis_data_before_create
      CHANGING
        documentdata   = documentdata
        it_doc_files   = it_doc_files
        it_char_val    = it_char_val
        it_class_alloc = it_class_alloc
        it_doc_desc    = it_doc_desc
        .
  ENDIF.

  CLEAR return.
  CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
    EXPORTING
      documentdata               = documentdata
*     HOSTNAME                   =
*     DOCBOMCHANGENUMBER         =
*     DOCBOMVALIDFROM            =
*     DOCBOMREVISIONLEVEL        =
*     CAD_MODE                   = ' '
      pf_ftp_dest                = rfc_sf "' '
      pf_http_dest               = rfc_sh "' '
   IMPORTING
      documenttype               = document-doctype
      documentnumber             = document-docnumber
      documentpart               = document-docpart
      documentversion            = document-docversion
      return                     = return
    TABLES
    characteristicvalues       = it_char_val
    classallocations           = it_class_alloc
    documentdescriptions       = it_doc_desc
*     OBJECTLINKS                =
*     DOCUMENTSTRUCTURE          =
      documentfiles              = it_doc_files
*     LONGTEXTS                  =
*     COMPONENTS                 =
            .

  IF return-type CA 'EA'.
    MESSAGE ID return-id
      TYPE return-type NUMBER return-number
        .
    "RAISE error.
  ELSE.
    PERFORM appl_log_write USING
    'I' '004' '/CIDEON/PLOT_RFC'
    document-doctype document-docnumber
    document-docpart document-docversion.
  ENDIF.

  COMMIT WORK AND WAIT.


* DIS an den ROOT DIS anhängen

*   Einfügen des erstellten Dokumentes in die Ordnerstruktur
  DATA: wa_doc_struc TYPE bapi_doc_aux.
  DATA: documentdatax TYPE bapi_doc_drawx2.

  DATA: it_doc_struc TYPE TABLE OF bapi_doc_structure.
  DATA: wa_it_doc_struc TYPE bapi_doc_structure.

* erst die Struktur holen
  CLEAR it_doc_struc.

  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = wa_root_dir-dokar
      documentnumber             = wa_root_dir-doknr
      documentpart               = wa_root_dir-doktl
      documentversion            = wa_root_dir-dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
*     GETSTATUSLOG               = ' '
*     GETLONGTEXTS               = ' '
*     GETACTIVEFILES             = 'X'
*     GETDOCDESCRIPTIONS         = 'X'
*     GETDOCFILES                = 'X'
*     GETCLASSIFICATION          = ' '
      getstructure               = 'X'
*     GETWHEREUSED               = ' '
*     HOSTNAME                   = ' '
*   IMPORTING
*     DOCUMENTDATA               =
*     RETURN                     =
    TABLES
*     OBJECTLINKS                =
*     DOCUMENTDESCRIPTIONS       =
*     LONGTEXTS                  =
*     STATUSLOG                  =
*     DOCUMENTFILES              =
*     COMPONENTS                 =
*     CHARACTERISTICVALUES       =
*     CLASSALLOCATIONS           =
      documentstructure          = it_doc_struc
*     WHEREUSEDLIST              =
            .

  CLEAR wa_doc_struc.
  wa_doc_struc-doctype = wa_root_dir-dokar.
  wa_doc_struc-docnumber = wa_root_dir-doknr.
  wa_doc_struc-docversion = wa_root_dir-dokvr.
  wa_doc_struc-docpart = wa_root_dir-doktl.

  CLEAR wa_it_doc_struc.
  wa_it_doc_struc-documenttype = document-doctype.
  wa_it_doc_struc-documentnumber = document-docnumber.
  wa_it_doc_struc-documentpart = document-docpart.
  wa_it_doc_struc-documentversion = document-docversion.
  APPEND wa_it_doc_struc TO it_doc_struc.

  CLEAR documentdata.
  CLEAR documentdatax.

  CLEAR return.
* in Stückliste integrieren
  CALL FUNCTION 'BAPI_DOCUMENT_CHANGE2'
    EXPORTING
      documenttype               = wa_doc_struc-doctype
      documentnumber             = wa_doc_struc-docnumber
      documentpart               = wa_doc_struc-docpart
      documentversion            = wa_doc_struc-docversion
      documentdata               = documentdata
      documentdatax              = documentdatax
*   HOSTNAME                   =
*   DOCBOMCHANGENUMBER         =
*   DOCBOMVALIDFROM            =
*   DOCBOMREVISIONLEVEL        =
*   SENDCOMPLETEBOM            = ' '
*   PF_FTP_DEST                = ' '
*   PF_HTTP_DEST               = ' '
*   CAD_MODE                   = ' '
    IMPORTING
      return                     = return
  TABLES
*   CHARACTERISTICVALUES       =
*   CLASSALLOCATIONS           =
*   DOCUMENTDESCRIPTIONS       =
*   OBJECTLINKS                =
    documentstructure          = it_doc_struc
*   DOCUMENTFILES              =
*   LONGTEXTS                  =
*   COMPONENTS                 =
            .


  IF return IS INITIAL.
  ELSE.
  ENDIF.

  COMMIT WORK AND WAIT.

* Falls alles in Ordnung, dann Datei verschieben in Verzeichnis
* für verarbeitete Dateien
* pdirok und pdirerr benutzen
  PERFORM move_ok USING wa_file_out.
  PERFORM appl_log_write USING
    'I' '003' '/CIDEON/PLOT_RFC'
    wa_file_out-filename '' '' ''.


  COMMIT WORK AND WAIT.

ENDLOOP.


PERFORM appl_log_write USING
  'I' '006' '/CIDEON/PLOT_RFC'
  '' '' '' ''.

INCLUDE /cideon/plot_mdr_rfc_back_f01.
