FUNCTION /cideon/del_wsa.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DRAW) TYPE  DRAW
*"     VALUE(WSA) TYPE  DAPPL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Test auf vorhandene Datei und Löschen der Datei am DIS
***********************************************************************
* Journal
* 31.07.2007 - Kopie

***********************************************************************
* to do
*
***********************************************************************
* Information:
*
***********************************************************************
* ITAB
  DATA: pt_files_x TYPE TABLE OF cvapi_doc_file.
  DATA: itab_documentfiles TYPE TABLE OF bapi_doc_files2.

*WA
  DATA: return TYPE bapiret2.
  DATA: ps_api_control TYPE cvapi_api_control.
  DATA: psx_message TYPE messages.
  DATA: wa_pt_files_x TYPE cvapi_doc_file.
  DATA: wa_documentfiles TYPE bapi_doc_files2.
  DATA: ps_draw TYPE draw.

* NORMAL
  DATA: f_found(1).
  DATA: index TYPE i.

* Datei nur ersetzen, falls gleiche WSA vorhanden
* ist

* Test auf vorhandene Konvertierungsergebnisse
  CLEAR itab_documentfiles.
  CLEAR return.

* Dateien holen
  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = draw-dokar
      documentnumber             = draw-doknr
      documentpart               = draw-doktl
      documentversion            = draw-dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
*     GETSTATUSLOG               = ' '
*     GETLONGTEXTS               = ' '
      getactivefiles             = 'X'
*     GETCLASSIFICATION          = ' '
*     GETSTRUCTURE               = ' '
*     GETWHEREUSED               = ' '
*     HOSTNAME                   = ' '
    IMPORTING
*     DOCUMENTDATA               =
      return                     = return
    TABLES
*     OBJECTLINKS                =
*     DOCUMENTDESCRIPTIONS       =
*     LONGTEXTS                  =
*     STATUSLOG                  =
      documentfiles              = itab_documentfiles
*     COMPONENTS                 =
*     CHARACTERISTICVALUES       =
*     CLASSALLOCATIONS           =
*     DOCUMENTSTRUCTURE          =
*     WHEREUSEDLIST              =
            .

  IF return IS INITIAL.
  ELSE.
  ENDIF.

  CLEAR index.
  LOOP AT itab_documentfiles INTO wa_documentfiles.
    index = sy-tabix.
*   Test auf WSA
    IF wa_documentfiles-wsapplication NE wsa.
*       Löschen aus Tabelle - also nicht weiter beachten
      DELETE itab_documentfiles INDEX index.
      CONTINUE.
    ELSE.
      wa_documentfiles-deletevalue = 'X'.
      MODIFY itab_documentfiles FROM wa_documentfiles INDEX index.
    ENDIF.
  ENDLOOP.

  IF itab_documentfiles IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.


* Datei ersetzen
  CASE sy-saprl.
    WHEN '46B'.
    WHEN '46C'.
      CALL FUNCTION 'CVAPI_INIT'.
    WHEN '610'.
      CALL FUNCTION 'CVAPI_INIT'.
    WHEN '620'.
      CALL FUNCTION 'CVAPI_INIT'.
    WHEN OTHERS.
      CALL FUNCTION 'CVAPI_INIT'.
  ENDCASE.

  CLEAR psx_message.
  CLEAR pt_files_x.
  CLEAR wa_pt_files_x.

  CLEAR ps_api_control.
  ps_api_control-check_level = '0'.

* Originalbelegung
  ps_api_control-commit_flag    = ' '.
  ps_api_control-no_update_task = 'X'.
  ps_api_control-save_flag      = 'X'.
  ps_api_control-api_mode       = 'X'.
  ps_api_control-tcode = 'CV02'.
  ps_api_control-check_level    = '0'.
  ps_api_control-not_dequeue_all = 'X'.
* \Originalbelegung

  LOOP AT itab_documentfiles INTO wa_documentfiles.
*    MOVE-CORRESPONDING wa_documentfiles TO wa_pt_files_x.

    wa_pt_files_x-dappl = wa_documentfiles-wsapplication.

    IF wa_documentfiles-deletevalue = 'X'.
      wa_pt_files_x-updateflag = 'D'.
    ELSE.
    ENDIF.

    wa_pt_files_x-lo_objid = wa_documentfiles-application_id.
    wa_pt_files_x-ph_objid = wa_documentfiles-file_id.

    APPEND wa_pt_files_x TO pt_files_x.
  ENDLOOP.

  CLEAR ps_draw.
  ps_draw-dokar = draw-dokar.
  ps_draw-doknr = draw-doknr.
  ps_draw-doktl = draw-doktl.
  ps_draw-dokvr = draw-dokvr.

  CALL FUNCTION 'CVAPI_DOC_CHANGE'
    EXPORTING
      ps_draw              = ps_draw
*     PF_STATUSLOG         = ' '
*     PF_REVLEVEL          =
      ps_api_control       = ps_api_control
*     PF_FTP_DEST          = ' '
*     PF_HTTP_DEST         = ' '
*     PF_HOSTNAME          = ' '
    IMPORTING
      psx_message          = psx_message
    TABLES
*     PT_DRAD_X            =
*     PT_DRAT_X            =
      pt_files_x           = pt_files_x
*     PT_COMP_X            =
            .
  IF psx_message IS INITIAL.
  ELSE.

  ENDIF.


*
*
*
*

  COMMIT WORK AND WAIT.


ENDFUNCTION.
