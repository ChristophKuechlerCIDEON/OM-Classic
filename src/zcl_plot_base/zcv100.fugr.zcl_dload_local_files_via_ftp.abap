FUNCTION zcl_dload_local_files_via_ftp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_DOWN_PATH) TYPE  STRING
*"     REFERENCE(LOCAL_FILE_PATH) TYPE  RLGRAP-FILENAME
*"     REFERENCE(CLF_FILE_NAME) TYPE  RLGRAP-FILENAME
*"     REFERENCE(I_FTP_DESTINATION) TYPE  FTP_DESTINATION
*"     REFERENCE(I_FTP_USER) TYPE  /CIDEON/FTP_USER
*"     REFERENCE(I_FTP_PASSWD) TYPE  /CIDEON/FTP_PASSWD
*"     REFERENCE(I_FTP_DOWN) TYPE  ZCL_KLIENT_DOWN_PFAD
*"  EXPORTING
*"     REFERENCE(DOWNLOADED_PATH) TYPE  FILEP
*"  EXCEPTIONS
*"      FTP_CONNECTION_ERROR
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Srinivas Mamillapalli
* Änderungen:
*           Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 06.07.2006 - Änderung / Auskommentieren, wegen UNICDOE
*              Vorbereitung der UNICODE Umstellung
*-----------------------------------------------------------------------


  DATA : lv_handle        TYPE i,
         lv_year(4)       TYPE c,
         lv_today(8)      TYPE c,
         lv_split1(132)   TYPE c,
         lv_split2(132)   TYPE c,
         lv_split3(132)   TYPE c,
         lv_command(70)   TYPE c.

  DATA : lv_file_path     LIKE rlgrap-filename,
         lv_stripped_name LIKE rlgrap-filename.

  DATA : BEGIN OF it_data OCCURS 0,
          line(132) TYPE c,
         END OF it_data.

* Work Area for it_data.
  DATA : wa_data TYPE line.

  DATA : lv_logic_file       LIKE rlgrap-filename,
         lv_timestamp        LIKE rlgrap-filename,
         lv_split_part1      LIKE rlgrap-filename,
         lv_split_part2      LIKE rlgrap-filename.

  DATA : lv_text_ele(12)     TYPE c.

* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  SPLIT clf_file_name AT '.' INTO lv_split_part1 lv_split_part2.

  MOVE text-100 TO lv_text_ele.
  SPLIT lv_split_part1 AT lv_text_ele INTO lv_logic_file lv_timestamp.

  lv_today = lv_timestamp+0(8).
  lv_year  = lv_timestamp+0(4).

**********
*  break mamillapalli.
  DATA : key TYPE i VALUE '26101957',
         dstlen TYPE i.

* UNICODE
*  DESCRIBE FIELD i_ftp_passwd LENGTH dstlen in character mode..
*  DESCRIBE FIELD i_ftp_passwd LENGTH dstlen.

  CALL 'AB_RFC_X_SCRAMBLE_STRING'
    ID 'SOURCE' FIELD i_ftp_passwd ID 'KEY'         FIELD key
    ID 'SCR'    FIELD 'X'          ID 'DESTINATION' FIELD i_ftp_passwd
    ID 'DSTLEN' FIELD dstlen.
**********


  CALL FUNCTION 'FTP_CONNECT'
    EXPORTING
      user                   = i_ftp_user
      password               = i_ftp_passwd
*     ACCOUNT                =
      host                   = i_ftp_destination
      rfc_destination        = 'SAPFTP'
*     GATEWAY_USER           =
*     GATEWAY_PASSWORD       =
*     GATEWAY_HOST           =
    IMPORTING
      handle                 = lv_handle
    EXCEPTIONS
      not_connected          = 1
      OTHERS                 = 2
            .
  IF sy-subrc <> 0.
    MESSAGE e103(zcvn) .
  ENDIF.

  CHECK sy-subrc EQ 0. " Proces further only if FTP Server connected.


* Split the local file path as to get the path of the directory
* on the local System...
  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
       EXPORTING
            full_name     = local_file_path
       IMPORTING
            stripped_name = lv_stripped_name
            file_path     = lv_file_path
       EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE e049(zcvn) WITH local_file_path RAISING error.
  ENDIF.

* § -------- FTP Commands on Local System --------
* Change the local directory to the directory of the local file in which
* it is existing.

  CLEAR lv_command.
  CONCATENATE 'lcd' lv_file_path INTO lv_command SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = lv_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = it_data
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    READ TABLE it_data INDEX 2 INTO wa_data.
    MESSAGE e104(zcvn) WITH wa_data-line RAISING error.
  ENDIF.
  CLEAR wa_data.
  REFRESH it_data.


* § -------- FTP Commands on Remote System [ FTP Server ]-----
  CLEAR lv_command.
  lv_command = 'pwd'.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = lv_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = it_data
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    READ TABLE it_data INDEX 2 INTO wa_data.
    MESSAGE e104(zcvn) WITH wa_data-line RAISING error.
  ENDIF.
  CLEAR wa_data.
  REFRESH it_data.

* Change Directory to send files on to the Remote FTP Server..
* 'TEST' is the only directory having Authorizations..........
  CLEAR lv_command.
  CONCATENATE 'cd' i_ftp_down INTO lv_command SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = lv_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
   TABLES
     data                = it_data
   EXCEPTIONS
     tcpip_error         = 1
     command_error       = 2
     data_error          = 3
     OTHERS              = 4
           .
  IF sy-subrc <> 0.
    READ TABLE it_data INDEX 2 INTO wa_data.
    MESSAGE e104(zcvn) WITH wa_data-line RAISING error.
  ENDIF.

  CLEAR wa_data.

  REFRESH it_data.

*******Check directory 'LV_YEAR [2003]' exists ?
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = 'ls'
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = it_data
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
           .
  IF sy-subrc <> 0.
    MESSAGE e104(zcvn) WITH '' RAISING error.
  ENDIF.

* Search for the directory with name 'LV_YEAR' [ 2003 ]
  SEARCH it_data FOR lv_year.

****** Create a dir with name 'LV_YEAR' [ 2003 ]
  IF sy-subrc <> 0.
    CLEAR lv_command.
    CONCATENATE 'mkdir' lv_year INTO lv_command SEPARATED BY space.
    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
      EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CLEAR lv_command.
* Change Directory to last created directory [2003]
* on to the Remote FTP Server..
    CONCATENATE 'cd' lv_year INTO lv_command SEPARATED BY space.
    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
      EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
* Already the directory 'LV_YEAR [2003]' exists on FTP Server...
    CLEAR lv_command.
    CONCATENATE 'cd' lv_year INTO lv_command SEPARATED BY space.
    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
     EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.


* List out all the files that R existing in the directory 'LV_YEAR'
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = 'ls'
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = it_data
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
           .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  SEARCH it_data FOR lv_today.
* Search for the directory with name LV_TODAY (i.e. 20031110 )

  IF sy-subrc <> 0.
*   Create a dir with name 'LV_TODAY' [20031110]

    CLEAR lv_command.
    CONCATENATE 'mkdir' lv_today INTO lv_command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
      EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CLEAR lv_command.
* Change Directory to last created directory 'LV_TODAY'
* on to the Remote FTP Server..
    CONCATENATE 'cd' lv_today INTO lv_command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
     EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
* Already the directory 'LV_TODAY [20031110]' exists on FTP Server...
    CLEAR lv_command.
    CONCATENATE 'cd' lv_today INTO lv_command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
      EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.


* Search for the directory with name 'LV_SPLIT_PART1[CLF Filename]'
  SEARCH it_data FOR lv_split_part1.

  IF sy-subrc <> 0.
*   * Create a dir with name 'CLF Filename'
*   *(i.e. *MAMILLAPALLI_SAP_DMS_LIST20031110145117  )
    CLEAR lv_command.
    CONCATENATE 'mkdir' lv_split_part1 INTO lv_command
                                            SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
      EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CLEAR lv_command.
*   Change Directory to last created directory
*   'LV_SPLIT_PART1[CLF Filename]' on to the Remote FTP Server..
    CONCATENATE 'cd' lv_split_part1 INTO lv_command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
     EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
*   Already the directory 'LV_SPLIT_PART1[CLF Filename]'
*   exists on FTP Server...
    CLEAR lv_command.
    CONCATENATE 'cd' lv_split_part1 INTO lv_command SEPARATED BY space.

    CALL FUNCTION 'FTP_COMMAND'
      EXPORTING
        handle              = lv_handle
        command             = lv_command
*       COMPRESS            =
*       VERIFY              =
*     IMPORTING
*       FILESIZE            =
*       FILEDATE            =
*       FILETIME            =
      TABLES
        data                = it_data
      EXCEPTIONS
        tcpip_error         = 1
        command_error       = 2
        data_error          = 3
        OTHERS              = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.


* Refresh the internal in order to find out the path of the FTP
* Downloading files directory.
  REFRESH it_data.

* Retrieving the path of the FTP Downloading files directory
* into internal table.
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = 'pwd'
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = it_data
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Append Downloading files directory path to Internal table.
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = 'ls'
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = it_data
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  break mamillapalli.

********* FTP Local file to destination...
  CLEAR lv_command.
  CONCATENATE 'put' lv_stripped_name INTO lv_command SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle              = lv_handle
      command             = lv_command
*     COMPRESS            =
*     VERIFY              =
*   IMPORTING
*     FILESIZE            =
*     FILEDATE            =
*     FILETIME            =
    TABLES
      data                = it_data
    EXCEPTIONS
      tcpip_error         = 1
      command_error       = 2
      data_error          = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


* IT_DATA[2] will be having the Downloading files directory.
  READ TABLE it_data INDEX 2 INTO wa_data.

  SPLIT wa_data AT '"' INTO lv_split1 lv_split2.

  CLEAR lv_split1.

  SPLIT lv_split2 AT '"' INTO lv_split1 lv_split3.

  WHILE sy-subrc EQ 0.
    SEARCH lv_split1 FOR '/'.
    IF sy-subrc EQ 0.
      REPLACE '/' WITH '\' INTO lv_split1.
    ENDIF.
  ENDWHILE.

  DATA : tmp_lv_fdpos       TYPE sy-fdpos,
         tmp_lv_split1_len  TYPE i,
         tmp_lv_path_length TYPE i.

  DATA : tmp_lv_path TYPE rlgrap-filename.

  tmp_lv_split1_len   = strlen( lv_split1 ).

  SEARCH lv_split1 FOR '\'.

  IF sy-fdpos EQ 0.

    tmp_lv_fdpos = sy-fdpos + 1.

    lv_split1 = lv_split1+tmp_lv_fdpos(tmp_lv_split1_len).

    SEARCH lv_split1 FOR '\'.
    IF sy-subrc EQ 0.

      CLEAR tmp_lv_fdpos.

      tmp_lv_fdpos = sy-fdpos + 1.

      lv_split1 = lv_split1+tmp_lv_fdpos(tmp_lv_split1_len).

    ENDIF.

  ENDIF.


  DATA : lv_path_closing  TYPE c,
         lv_directory_sep TYPE c VALUE '\'.


  tmp_lv_path_length  = strlen( i_down_path ).

  tmp_lv_path_length  = tmp_lv_path_length - 1.

  lv_path_closing = i_down_path+tmp_lv_path_length(1).

  IF lv_directory_sep EQ lv_path_closing.
    CONCATENATE i_down_path lv_split1 '\' lv_stripped_name
      INTO downloaded_path.
  ELSE.
    CONCATENATE i_down_path '\' lv_split1 '\' lv_stripped_name
      INTO downloaded_path.
  ENDIF.

* Disconnect the FTP Connection with Remote System. ( BYE )
  CALL FUNCTION 'FTP_DISCONNECT'
       EXPORTING
            handle = lv_handle.

  REFRESH it_data.

ENDFUNCTION.
