FUNCTION /cideon/stamp_call_stmp_tool_r.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP
*"     VALUE(I_FILENAME_ZIEL) TYPE  FILEP
*"     VALUE(I_FILENAME_STEMPEL) TYPE  FILEP
*"     VALUE(I_STAMP_PROGRAM) TYPE  FILEP
*"     VALUE(I_START_VERZEICHNIS) TYPE  DSVASDOCID
*"     VALUE(I_ARBEITS_VERZEICHNIS) TYPE  DSVASDOCID
*"     VALUE(I_KONVERTER) TYPE  CHAR10
*"     VALUE(I_STAMP_PARAMETER) TYPE  ZCL_PWERT
*"     VALUE(I_STAMP_RFC_DESTINATION) TYPE  RFCDES-RFCDEST
*"     VALUE(I_STAMP_FTP_DESTINATION) TYPE  RFCDES-RFCDEST
*"     VALUE(I_STAMP_FTP_USER) TYPE  /CIDEON/FTP_USER
*"     VALUE(I_STAMP_FTP_PASSWD) TYPE  /CIDEON/FTP_PASSWD
*"     VALUE(I_STAMP_FTP_VERZEICHNIS) TYPE  FILEP
*"     VALUE(I_STAMP_DELAY) TYPE  I
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   - beim Stempeln über RFCEXEC ist zu beachten, daß in der
*     ConvertClient.ini der Filetransfer ausgeschaltet wird
*   - der Zeildateiname muß ein anderer sein, als der Name der
*     Quelldatei, ein Überschreiben funktioniert nur bei Filetransfer
*
*
*-----------------------------------------------------------------------
* Journal
* 12.11.2002 creation
* 13.11.2003 FTP
* 14.11.2003 Anpassung Stempeln
* 15.11.2003 Umstellung von RFC_REMOTE_EXEC auf RFC_REMOTE_PIPE

* 7.0.169.1  CKR
* 2014/08/04 Sulzer
  " EHP 7 - Ausbau FB
*-----------------------------------------------------------------------
*TYPES
  TYPES: BEGIN OF t_batch,
    line TYPE char600,
    END OF t_batch.
  TYPES: BEGIN OF t_ftp,
    line(150) TYPE c,
    END OF t_ftp.
*ITAB
  DATA: itab_batch TYPE TABLE OF t_batch.
  DATA: itab_ftp TYPE TABLE OF t_ftp.
  DATA: itab_return_pipe TYPE TABLE OF char100.
*WA
  DATA: wa_batch TYPE t_batch.
  DATA: wa_ftp TYPE t_ftp.
  DATA: wa_return_pipe TYPE char100.
*NORMAL
  DATA: return TYPE i.
  DATA: filename TYPE filep.
  DATA: filename_out TYPE filep.
  DATA: filename_stempel TYPE filep.
  DATA: commandline TYPE char600.
  DATA: len TYPE i.
  DATA: filename_batch TYPE filep.
  DATA: docid TYPE dsvasdocid.
  DATA: verzeichnis TYPE dsvasdocid.
  DATA: dateiname TYPE dsvasdocid.
  DATA: extension TYPE dsvasdocid.

  DATA: docid_stempel TYPE dsvasdocid.
  DATA: verzeichnis_stempel TYPE dsvasdocid.
  DATA: dateiname_stempel TYPE dsvasdocid.
  DATA: extension_stempel TYPE dsvasdocid.

  DATA: ftp_handle TYPE i.
  DATA: ftp_command(150) TYPE c.

  DATA: file_to_delete TYPE rlgrap-filename.

  DATA: convert_command(500) TYPE c.

  DATA: dateiname_tif TYPE dsvasdocid.
  DATA: dateiname_pdf TYPE dsvasdocid.
  DATA: dateiname_stempel_tif TYPE dsvasdocid.
  DATA: timestamp(14).
  DATA: dateiname_ohne_extension TYPE dsvasdocid.
  DATA: dateiname_rest TYPE dsvasdocid.
  DATA: punkt_extension TYPE dsvasdocid.
  DATA: fdpos TYPE i.
  DATA: laenge TYPE i.
  DATA: laenge_ohne_extension TYPE i.

  DATA: totif_dateiname_tif TYPE dsvasdocid.
  DATA: topdf_dateiname_tif TYPE dsvasdocid.

  DATA: zeit1(6) TYPE c.
  DATA: zeit2(6) TYPE c.
  DATA: delta(6) TYPE c.

  DATA: lokales_arbeitsverzeichnis TYPE dsvasdocid.

* Vorgehensweise
* Test RFC Destination
* UPLOAD der Dateien : I_FILENAME / I_FILENAME_STEMPEL auf FTP Server
* Löschen der Dateien lokal
* Aufruf des Konvertierungsprogrammes über RFCEXEC
*    - Hinweise: bitte keine Originaldateinamen verwenden
*                temporäre sind da besser
* DOWNLOAD der DATEI
* Löschen der Dateien auf dem SERVER
* Anzeige der Dateien
* eventuell Fehlermeldung, falls Probleme zwischendurch


* Beispiel des Aufrufs
* ConvertClient in="C:\temp\convert\test.tif"
* out="C:\temp\convert\test_2.tif" convparam="DPI=300"
* stampfile="c:\stamp.txt"



* Test RFC Destination
  CALL FUNCTION '/CIDEON/STAMP_CHECK_RFC_DEST'
    EXPORTING
      i_dest            = i_stamp_rfc_destination
    EXCEPTIONS
      error             = 1
      no_destination    = 2
      abbruch           = 3
      verbindungsfehler = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    CASE sy-subrc.
      WHEN '1'.
        MESSAGE e001(/cideon/stamp)
          WITH i_stamp_rfc_destination '' '' ''
          RAISING error.
*       Fehler mit RFC-Destination & & & &
      WHEN '2'.
        MESSAGE e002(/cideon/stamp)
          WITH i_stamp_rfc_destination '' '' ''
          RAISING error.
      WHEN '3'.
        MESSAGE e003(/cideon/stamp)
          WITH i_stamp_rfc_destination  '' '' ''
          RAISING error.
      WHEN '4'.
        MESSAGE e004(/cideon/stamp)
          WITH i_stamp_rfc_destination '' '' ''
          RAISING error.
      WHEN '5'.
        MESSAGE e001(/cideon/stamp)
          WITH i_stamp_rfc_destination '' '' ''
          RAISING error.
      WHEN OTHERS.
        MESSAGE e001(/cideon/stamp)
          WITH i_stamp_rfc_destination  '' '' ''
          RAISING error.
*       Fehler mit RFC-Destination & & & &
    ENDCASE.
  ENDIF.

* Timestamp
  CLEAR timestamp.
  CONCATENATE  sy-datum sy-uzeit INTO timestamp.


* UPLOAD der Dateien : I_FILENAME / I_FILENAME_STEMPEL auf FTP Server
* CONNECT
  DATA: hdl TYPE i,
        key TYPE i VALUE 26101957,
        dstlen TYPE i.
  DATA: ftp_passwd TYPE /cideon/ftp_passwd.

  ftp_passwd = i_stamp_ftp_passwd.
  DESCRIBE FIELD ftp_passwd LENGTH dstlen IN CHARACTER MODE .

  CALL 'AB_RFC_X_SCRAMBLE_STRING'
    ID 'SOURCE'      FIELD ftp_passwd    ID 'KEY'         FIELD key
    ID 'SCR'         FIELD 'X'    ID 'DESTINATION' FIELD ftp_passwd
    ID 'DSTLEN'      FIELD dstlen.



  CLEAR ftp_handle.
  CALL FUNCTION 'FTP_CONNECT'
    EXPORTING
      user                   = i_stamp_ftp_user
      password               = ftp_passwd "i_stamp_ftp_passwd
      account                = ''
      host                   = i_stamp_ftp_destination
      rfc_destination        = 'SAPFTP'
*     GATEWAY_USER           =
*     GATEWAY_PASSWORD       =
*     GATEWAY_HOST           =
    IMPORTING
      handle                 = ftp_handle
    EXCEPTIONS
      not_connected          = 1
      OTHERS                 = 2
            .
  IF sy-subrc <> 0.
    MESSAGE e005(/cideon/stamp)
      WITH i_stamp_ftp_destination i_stamp_ftp_user '' ''
      RAISING error.
  ENDIF.

  CLEAR itab_ftp.
  CLEAR wa_ftp.

  ftp_command = 'binary'.
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = ftp_handle
      command             = ftp_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = itab_ftp
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    MESSAGE e006(/cideon/stamp)
      WITH i_stamp_ftp_destination '' '' ''
      RAISING error.
  ENDIF.

  CLEAR itab_ftp.

* Dateiname ohne Pfad
* Pfad
  docid = i_filename.
  CLEAR verzeichnis.
  CLEAR dateiname.
  CLEAR extension.
*  CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
*    EXPORTING
*      pf_docid     = docid
*    IMPORTING
*      pf_directory = verzeichnis
*      pf_filename  = dateiname
*      pf_extension = extension.

  "Umbau auf CVx
  DATA pfx_path TYPE draw-filep.
  DATA pfx_file TYPE draw-filep.
  CLEAR pfx_path.
  CLEAR pfx_file.

  CALL FUNCTION 'CV120_SPLIT_PATH'
    EXPORTING
      pf_path  = i_filename
    IMPORTING
      pfx_path = pfx_path
      pfx_file = pfx_file.

  CALL FUNCTION 'CV120_SPLIT_FILE'
    EXPORTING
      pf_file                = i_filename
    IMPORTING
*   PFX_FILE               =
      pfx_extension          = extension
*   PFX_DOTEXTENSION       =
            .



  verzeichnis = pfx_path.
  dateiname = pfx_file.




* Timestampverarbeitung

  CLEAR dateiname_tif.
  CLEAR dateiname_pdf.
  CLEAR dateiname_ohne_extension.
  CLEAR dateiname_rest.
  CLEAR punkt_extension.
  CLEAR fdpos.

  CONCATENATE '.' extension INTO punkt_extension.

  IF extension IS INITIAL.
*   Meldung : keine Extension -> kein Stempeln
  ELSE.
    IF dateiname CS punkt_extension  .
      fdpos = sy-fdpos.
      dateiname_ohne_extension = dateiname(fdpos).

      CONCATENATE dateiname_ohne_extension '_'
        timestamp punkt_extension
        INTO dateiname_tif.
    ELSE.
    ENDIF.
  ENDIF.


  lokales_arbeitsverzeichnis = verzeichnis.

  ftp_command = 'lcd'.
  CONCATENATE ftp_command lokales_arbeitsverzeichnis
    INTO ftp_command SEPARATED BY space.
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = ftp_handle
      command             = ftp_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = itab_ftp
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    MESSAGE e006(/cideon/stamp)
      WITH i_stamp_ftp_destination ftp_command '' ''
      RAISING error.
  ENDIF.


  ftp_command = 'put'.
  CONCATENATE ftp_command dateiname dateiname_tif
    INTO ftp_command SEPARATED BY space.
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = ftp_handle
      command             = ftp_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = itab_ftp
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    MESSAGE e006(/cideon/stamp)
      WITH i_stamp_ftp_destination ftp_command '' ''
      RAISING error.
  ENDIF.

* Stempeldateien
  docid_stempel = i_filename_stempel.
  CLEAR verzeichnis_stempel.
  CLEAR dateiname_stempel.
  CLEAR extension_stempel.

*  CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
*    EXPORTING
*      pf_docid     = docid_stempel
*    IMPORTING
*      pf_directory = verzeichnis_stempel
*      pf_filename  = dateiname_stempel
*      pf_extension = extension_stempel.


  CLEAR pfx_path.
  CLEAR pfx_file.

  CALL FUNCTION 'CV120_SPLIT_PATH'
    EXPORTING
      pf_path  = i_filename_stempel
    IMPORTING
      pfx_path = pfx_path
      pfx_file = pfx_file.

  verzeichnis_stempel = pfx_path.
  dateiname_stempel = pfx_file.


  CALL FUNCTION 'CV120_SPLIT_FILE'
    EXPORTING
      pf_file                = i_filename
    IMPORTING
*   PFX_FILE               =
      pfx_extension          = extension_stempel
*   PFX_DOTEXTENSION       =
  .



  CLEAR dateiname_ohne_extension.
  CLEAR dateiname_rest.
  CLEAR punkt_extension.
  CLEAR fdpos.

  CONCATENATE '.' extension_stempel INTO punkt_extension.

  IF extension IS INITIAL.
*   Meldung : keine Extension -> kein Stempeln
  ELSE.
    IF dateiname_stempel CS punkt_extension  .
      fdpos = sy-fdpos.
      dateiname_ohne_extension = dateiname_stempel(fdpos).

      CONCATENATE dateiname_ohne_extension '_'
        timestamp punkt_extension
        INTO dateiname_stempel_tif.
    ELSE.
    ENDIF.
  ENDIF.


  CLEAR itab_ftp.
  CLEAR wa_ftp.

  ftp_command = 'ascii'.
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = ftp_handle
      command             = ftp_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = itab_ftp
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    MESSAGE e006(/cideon/stamp)
      WITH i_stamp_ftp_destination '' '' ''
      RAISING error.
  ENDIF.

  CLEAR itab_ftp.


  ftp_command = 'put'.
  CONCATENATE ftp_command dateiname_stempel dateiname_stempel_tif
    INTO ftp_command SEPARATED BY space.
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = ftp_handle
      command             = ftp_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = itab_ftp
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    MESSAGE e006(/cideon/stamp)
      WITH i_stamp_ftp_destination ftp_command '' ''
      RAISING error.
  ENDIF.



* Löschen der Dateien lokal
  file_to_delete = i_filename.
  CALL FUNCTION 'GUI_DELETE_FILE'
    EXPORTING
      file_name = file_to_delete
    EXCEPTIONS
      failed    = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  file_to_delete = i_filename_stempel.
  CALL FUNCTION 'GUI_DELETE_FILE'
    EXPORTING
      file_name = file_to_delete
    EXCEPTIONS
      failed    = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.






* Aufruf des Konvertierungsprogrammes über RFCEXEC
*    - Hinweise: bitte keine Originaldateinamen verwenden
*                temporäre sind da besser

* Beispiel des Aufrufs
* ConvertClient in="C:\temp\convert\test.tif"
* out="C:\temp\convert\test_2.tif" convparam="DPI=300"
* stampfile="c:\stamp.txt"

*  DATA: filename TYPE filep.
*  DATA: filename_out TYPE filep.
*  DATA: filename_stempel TYPE filep.

  CLEAR convert_command.
  CLEAR filename.
  CLEAR filename_out.
  CLEAR filename_stempel.

  CLEAR totif_dateiname_tif.
  CLEAR topdf_dateiname_tif.


  CONCATENATE i_konverter dateiname_tif
    INTO totif_dateiname_tif.

  CONCATENATE 'in="' i_stamp_ftp_verzeichnis dateiname_tif '"'
    INTO filename.

  CONCATENATE 'out="' i_stamp_ftp_verzeichnis
    totif_dateiname_tif '"'
    INTO filename_out.

  CONCATENATE 'stampfile="' i_stamp_ftp_verzeichnis
    dateiname_stempel_tif '"'
    INTO filename_stempel.

  CONCATENATE i_stamp_program filename filename_out
    filename_stempel i_stamp_parameter 'converter='
    INTO convert_command SEPARATED BY space.



* Aufrufen des ConvertClient zum Stempeln
* möglicherweise auch gleichzeitiges Konvertieren in ein
* stempelfähiges Format

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = text-050.


  CLEAR itab_return_pipe.
  CALL FUNCTION 'RFC_REMOTE_PIPE'
    DESTINATION i_stamp_rfc_destination
    EXPORTING
      command  = convert_command
      read     = 'X'
    TABLES
      pipedata = itab_return_pipe.

  IF sy-subrc NE 0.                                         "#EC *
    WRITE sy-subrc.
  ELSE.
  ENDIF.
  IF itab_return_pipe[] IS INITIAL.
  ELSE.
    READ TABLE itab_return_pipe INTO wa_return_pipe INDEX 1.
    MESSAGE e020(/cideon/stamp)
      WITH wa_return_pipe '' '' ''      .
  ENDIF.

*  CALL FUNCTION 'RFC_REMOTE_EXEC'
*      DESTINATION i_stamp_rfc_destination
*    EXPORTING
*      command = convert_command
*      .
*
*  IF sy-subrc NE 0.
*    WRITE sy-subrc.
*  ELSE.
*  ENDIF.


* etwas warten lassen, damit Datei vorhanden ist
*  CLEAR zeit1.
*  CLEAR zeit2.
*
*  zeit1 = sy-uzeit.
*  zeit2 = sy-uzeit.
*  delta = zeit2 - zeit1.
*  WHILE delta < i_stamp_delay.
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              text = ''.
*
*    COMMIT WORK AND WAIT.
*    zeit2 = sy-uzeit.
*    delta = zeit2 - zeit1.
*  ENDWHILE.



* Löschen nicht mehr benötigter Dateien
  CLEAR itab_ftp.
  CLEAR wa_ftp.

  ftp_command = 'delete'.
  CONCATENATE ftp_command dateiname_tif
    INTO ftp_command SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = ftp_handle
      command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
    TABLES
      data                = itab_ftp
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    MESSAGE w006(/cideon/stamp)
      WITH i_stamp_ftp_destination ftp_command '' ''
      .
  ENDIF.

  CLEAR itab_ftp.
  CLEAR wa_ftp.

  ftp_command = 'delete'.
  CONCATENATE ftp_command dateiname_stempel_tif
    INTO ftp_command SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = ftp_handle
      command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
    TABLES
      data                = itab_ftp
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    MESSAGE w006(/cideon/stamp)
      WITH i_stamp_ftp_destination ftp_command '' ''
      .
  ENDIF.



* Unterscheidung in TOTIFF / TOPDF
  CASE i_konverter.
    WHEN 'TOTIF'.
*     nach erster Konvertierung alles ok.
*     Download nach lokal
      CLEAR itab_ftp.
      CLEAR wa_ftp.

      ftp_command = 'binary'.
      CALL FUNCTION 'FTP_COMMAND'
        EXPORTING
          handle              = ftp_handle
          command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
        TABLES
          data                = itab_ftp
        EXCEPTIONS
          tcpip_error         = 1
          command_error       = 2
          data_error          = 3
          OTHERS              = 4
                .
      IF sy-subrc <> 0.
        MESSAGE e006(/cideon/stamp)
          WITH i_stamp_ftp_destination ftp_command '' ''
          RAISING error.
      ENDIF.

      CLEAR itab_ftp.
      CLEAR wa_ftp.

      ftp_command = 'get'.
      CONCATENATE ftp_command totif_dateiname_tif dateiname
        INTO ftp_command SEPARATED BY space.

      CALL FUNCTION 'FTP_COMMAND'
        EXPORTING
          handle              = ftp_handle
          command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
        TABLES
          data                = itab_ftp
        EXCEPTIONS
          tcpip_error         = 1
          command_error       = 2
          data_error          = 3
          OTHERS              = 4
                .
      IF sy-subrc <> 0.
        MESSAGE e006(/cideon/stamp)
          WITH i_stamp_ftp_destination ftp_command '' ''
          RAISING error.
      ENDIF.

*     löschen auf dem FTP Server
*     normales File
      CLEAR itab_ftp.
      CLEAR wa_ftp.

      ftp_command = 'delete'.
      CONCATENATE ftp_command totif_dateiname_tif
        INTO ftp_command SEPARATED BY space.

      CALL FUNCTION 'FTP_COMMAND'
        EXPORTING
          handle              = ftp_handle
          command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
        TABLES
          data                = itab_ftp
        EXCEPTIONS
          tcpip_error         = 1
          command_error       = 2
          data_error          = 3
          OTHERS              = 4
                .
      IF sy-subrc <> 0.
        MESSAGE w006(/cideon/stamp)
          WITH i_stamp_ftp_destination ftp_command '' ''
          .
      ENDIF.

    WHEN 'TOPDF'.
*     nochmal Konvertierung starten mit Konverter nach PDF
      CLEAR convert_command.
      CLEAR filename.
      CLEAR filename_out.
      CLEAR filename_stempel.

      CONCATENATE i_konverter totif_dateiname_tif
        INTO topdf_dateiname_tif.

      CONCATENATE 'in="' i_stamp_ftp_verzeichnis totif_dateiname_tif '"'
                                   INTO filename.

      CONCATENATE 'out="' i_stamp_ftp_verzeichnis
        topdf_dateiname_tif '"'
        INTO filename_out.


      CONCATENATE i_stamp_program filename filename_out
         i_stamp_parameter
        INTO convert_command SEPARATED BY space.

      CONCATENATE convert_command 'converter='
        INTO convert_command SEPARATED BY space.

      CONCATENATE convert_command i_konverter
        INTO convert_command.

*     Aufruf der Konvertierung nach PDF
*      CALL FUNCTION 'RFC_REMOTE_EXEC'
*          DESTINATION i_stamp_rfc_destination
*        EXPORTING
*          command = convert_command
*          .
*
*      IF sy-subrc NE 0.
*        WRITE sy-subrc.
*      ELSE.
*      ENDIF.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          text = text-051.

      CLEAR itab_return_pipe.
      CALL FUNCTION 'RFC_REMOTE_PIPE'
        DESTINATION i_stamp_rfc_destination
        EXPORTING
          command  = convert_command
          read     = 'X'
        TABLES
          pipedata = itab_return_pipe.

      IF sy-subrc NE 0.                                     "#EC *
        WRITE sy-subrc.
      ELSE.
      ENDIF.

      IF itab_return_pipe[] IS INITIAL.
      ELSE.
        READ TABLE itab_return_pipe INTO wa_return_pipe INDEX 1.
        MESSAGE e020(/cideon/stamp)
          WITH wa_return_pipe '' '' ''      .
      ENDIF.

*     etwas warten lassen, damit Datei vorhanden ist
*      CLEAR zeit1.
*      CLEAR zeit2.
*
*      zeit1 = sy-uzeit.
*      zeit2 = sy-uzeit.
*      delta = zeit2 - zeit1.
*      WHILE delta < i_stamp_delay.
*        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*             EXPORTING
*                  text = ''.
*
*        COMMIT WORK AND WAIT.
*        zeit2 = sy-uzeit.
*        delta = zeit2 - zeit1.
*      ENDWHILE.

*     Dateien holen
*     Dateien löschen
      CLEAR itab_ftp.
      CLEAR wa_ftp.

      ftp_command = 'binary'.
      CALL FUNCTION 'FTP_COMMAND'
        EXPORTING
          handle              = ftp_handle
          command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
        TABLES
          data                = itab_ftp
        EXCEPTIONS
          tcpip_error         = 1
          command_error       = 2
          data_error          = 3
          OTHERS              = 4
                .
      IF sy-subrc <> 0.
        MESSAGE e006(/cideon/stamp)
          WITH i_stamp_ftp_destination ftp_command '' ''
          RAISING error.
      ENDIF.

      CLEAR itab_ftp.
      CLEAR wa_ftp.

      ftp_command = 'get'.
      CONCATENATE ftp_command topdf_dateiname_tif
         dateiname
        INTO ftp_command SEPARATED BY space.

      CALL FUNCTION 'FTP_COMMAND'
        EXPORTING
          handle              = ftp_handle
          command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
        TABLES
          data                = itab_ftp
        EXCEPTIONS
          tcpip_error         = 1
          command_error       = 2
          data_error          = 3
          OTHERS              = 4
                .
      IF sy-subrc <> 0.
        MESSAGE e006(/cideon/stamp)
          WITH i_stamp_ftp_destination ftp_command '' ''
          RAISING error.
      ENDIF.

*     löschen auf dem FTP Server
*     normales File
      CLEAR itab_ftp.
      CLEAR wa_ftp.

      ftp_command = 'delete'.
      CONCATENATE ftp_command topdf_dateiname_tif
        INTO ftp_command SEPARATED BY space.

      CALL FUNCTION 'FTP_COMMAND'
        EXPORTING
          handle              = ftp_handle
          command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
        TABLES
          data                = itab_ftp
        EXCEPTIONS
          tcpip_error         = 1
          command_error       = 2
          data_error          = 3
          OTHERS              = 4
                .
      IF sy-subrc <> 0.
        MESSAGE w006(/cideon/stamp)
          WITH i_stamp_ftp_destination ftp_command '' ''
          .
      ENDIF.

      CLEAR itab_ftp.
      CLEAR wa_ftp.

      ftp_command = 'delete'.
      CONCATENATE ftp_command totif_dateiname_tif
        INTO ftp_command SEPARATED BY space.

      CALL FUNCTION 'FTP_COMMAND'
        EXPORTING
          handle              = ftp_handle
          command             = ftp_command
*         COMPRESS            =
*         VERIFY              =
*       IMPORTING
*         FILESIZE            =
*         FILEDATE            =
*         FILETIME            =
        TABLES
          data                = itab_ftp
        EXCEPTIONS
          tcpip_error         = 1
          command_error       = 2
          data_error          = 3
          OTHERS              = 4
                .
      IF sy-subrc <> 0.
        MESSAGE w006(/cideon/stamp)
          WITH i_stamp_ftp_destination ftp_command '' ''
          .
      ENDIF.

    WHEN OTHERS.
  ENDCASE.




* DOWNLOAD der DATEI
* Löschen der Dateien auf dem SERVER
* Anzeige der Dateien
* eventuell Fehlermeldung, falls Probleme zwischendurch



  CALL FUNCTION 'FTP_DISCONNECT'
    EXPORTING
      handle = ftp_handle.





* per RFC starten

* temporäre Dateien löschen
* Stempeldateien
* Startdateien


*  file_to_delete = filename_batch.
*  CALL FUNCTION 'GUI_DELETE_FILE'
*       EXPORTING
*            file_name = file_to_delete
*       EXCEPTIONS
*            failed    = 1
*            OTHERS    = 2.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.



ENDFUNCTION.
