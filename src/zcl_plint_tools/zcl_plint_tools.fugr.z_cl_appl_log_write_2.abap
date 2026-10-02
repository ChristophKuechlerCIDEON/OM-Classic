FUNCTION z_cl_appl_log_write_2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_OBJECT) LIKE  BALHDR-OBJECT
*"     VALUE(I_SUBOBJ) LIKE  BALHDR-SUBOBJECT
*"     VALUE(I_NUMBER) TYPE  SYMSGNO
*"     VALUE(I_MSGTYP) TYPE  SYMSGTY
*"     VALUE(I_MSGID) TYPE  SYMSGID
*"     VALUE(I_MSGNO) TYPE  SYMSGNO
*"     VALUE(I_MSGV1) TYPE  SYMSGV DEFAULT SPACE
*"     VALUE(I_MSGV2) TYPE  SYMSGV DEFAULT SPACE
*"     VALUE(I_MSGV3) TYPE  SYMSGV DEFAULT SPACE
*"     VALUE(I_MSGV4) TYPE  SYMSGV DEFAULT SPACE
*"     VALUE(I_CLASS) TYPE  BALPROBCL DEFAULT SPACE
*"     VALUE(I_NEWHEAD) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_MESSHEAD) TYPE  CHAR1 DEFAULT SPACE
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------

  DATA: err_msg   LIKE balmi,
        t_balnri  LIKE balnri OCCURS 0 WITH HEADER LINE,
        s_balhdri LIKE balhdri,
        a_update_or_insert(1) TYPE c.
  DATA: doc_chng LIKE sodocchgi1,
        objpack LIKE sopcklsti1 OCCURS 2 WITH HEADER LINE,
        objtxt LIKE solisti1 OCCURS 10 WITH HEADER LINE,
        objbin LIKE solisti1 OCCURS 10 WITH HEADER LINE,
        reclist LIKE somlreci1 OCCURS 5 WITH HEADER LINE,
        sent_flag LIKE sonv-flag,
        tab_lines LIKE sy-tabix,
        new_id LIKE sofolenti1-object_id.
  DATA: wa_mail_cfg LIKE zcl_mail_cfg,
        wa_usr_grp LIKE zcl_usr_grp_tab OCCURS 0 WITH HEADER LINE.
  DATA: msgtext LIKE abapsource OCCURS 0 WITH HEADER LINE.
  DATA: wa_time_stamp(12),
        wa_file_name LIKE filename-fileintern,
        wa_path LIKE filename-fileintern,
        wa_file(255).
  DATA: t_extnumber(100).
  DATA: t_extnumber2(256).
  DATA: j_msgtyp LIKE sy-msgty.
  DATA: j_msgid  LIKE sy-msgid.
  DATA: j_msgno  LIKE sy-msgno.
  DATA: j_msgv1  LIKE sy-msgv1.
  DATA: j_msgv2  LIKE sy-msgv2.
  DATA: j_msgv3  LIKE sy-msgv3.
  DATA: j_msgv4  LIKE sy-msgv4.

  DATA: BEGIN OF stru,
          langu TYPE sy-langu,
          text  TYPE sy-xcode,
        END   OF stru.

  SET LOCALE LANGUAGE stru-langu.
  TRANSLATE i_object TO UPPER CASE.    "zur Sicherheit
  TRANSLATE i_subobj TO UPPER CASE.    "zur Sicherheit
  TRANSLATE i_msgid  TO UPPER CASE.    "zur Sicherheit
  SET LOCALE LANGUAGE space.


*  TRANSLATE i_object TO UPPER CASE.    "zur Sicherheit
*  TRANSLATE i_subobj TO UPPER CASE.    "zur Sicherheit
*  TRANSLATE i_msgid  TO UPPER CASE.    "zur Sicherheit

  IF i_messhead NE ' '.

    j_msgtyp = i_msgtyp.
    j_msgid  = i_msgid.
    j_msgno  = i_msgno.
    j_msgv1  = i_msgv1.
    j_msgv2  = i_msgv2.
    j_msgv3  = i_msgv3.
    j_msgv4  = i_msgv4.

    err_msg-msgty  = i_msgtyp.
    err_msg-msgid  = i_msgid.
    err_msg-msgno  = i_msgno.
    err_msg-msgv1  = i_msgv1.
    err_msg-msgv2  = i_msgv2.
    err_msg-msgv3  = i_msgv3.
    err_msg-msgv4  = i_msgv4.
    err_msg-probclass = i_class.

    CALL FUNCTION 'CUTC_GET_MESSAGE'
         EXPORTING
              msg_type       = err_msg-msgty
              msg_id         = err_msg-msgid
              msg_no         = err_msg-msgno
              msg_arg1       = err_msg-msgv1
              msg_arg2       = err_msg-msgv2
              msg_arg3       = err_msg-msgv3
              msg_arg4       = err_msg-msgv4
              language       = sy-langu
         IMPORTING
              raw_message    = t_extnumber2
         EXCEPTIONS
              msg_not_found  = 1
              internal_error = 2
              OTHERS         = 3.

    IF sy-subrc <> 0.
* alte Variante (ohne Sortierung)
      DATA: t_text(73),  t_text1(73), t_text2(73), t_text3(73),
                         t_text4(73), t_text5(73),
            t_msgv1(50), t_msgv2(50), t_msgv3(50), t_msgv4(50).
      SELECT SINGLE text
        FROM t100
        INTO t_text
       WHERE sprsl = sy-langu
         AND arbgb = i_msgid
         AND msgnr = i_msgno.
      TRANSLATE t_text USING ' ^'.
      WRITE i_msgv1 LEFT-JUSTIFIED TO t_msgv1.
      WRITE i_msgv2 LEFT-JUSTIFIED TO t_msgv2.
      WRITE i_msgv3 LEFT-JUSTIFIED TO t_msgv3.
      WRITE i_msgv4 LEFT-JUSTIFIED TO t_msgv4.
      SPLIT t_text AT '&' INTO t_text1 t_text2
                               t_text3 t_text4 t_text5.
      CONCATENATE t_text1 t_msgv1 t_text2 t_msgv2  t_text3 t_msgv3
                  t_text4 t_msgv4 t_text5 INTO t_extnumber.
      TRANSLATE t_extnumber USING '^ '.
    ELSE.
      t_extnumber = t_extnumber2. " sonst Typkonflikt
    ENDIF.
  ELSE.
    t_extnumber = i_number.
  ENDIF.

* Anwendungslog schreiben *
  err_msg-msgty  = i_msgtyp.
  err_msg-msgid  = i_msgid.
  err_msg-msgno  = i_msgno.
  err_msg-msgv1  = i_msgv1.
  err_msg-msgv2  = i_msgv2.
  err_msg-msgv3  = i_msgv3.
  err_msg-msgv4  = i_msgv4.
  err_msg-probclass = i_class.
*
  CLEAR s_balhdri.
  s_balhdri-object     = i_object.
  s_balhdri-subobject  = i_subobj.
  s_balhdri-extnumber  = t_extnumber.
  s_balhdri-aldate     = sy-datum.
  s_balhdri-altime     = sy-uzeit.
  s_balhdri-aluser     = sy-uname.
  s_balhdri-altcode    = sy-tcode.
  s_balhdri-alprog     = sy-repid.
  s_balhdri-aldate_del = sy-datum + 7.
  s_balhdri-del_before = 'X'.

  IF i_newhead NE ' '.                 "lokales Gedächtnis FG löschen
    CALL FUNCTION 'APPL_LOG_INIT'      "-> neuer Header
         EXPORTING
              object              = i_object
              subobject           = i_subobj
         EXCEPTIONS
              object_not_found    = 1
              subobject_not_found = 2
              OTHERS              = 3.
  ENDIF.
  CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
       EXPORTING
            header              = s_balhdri
       IMPORTING
            update_or_insert    = a_update_or_insert
       EXCEPTIONS
            object_not_found    = 1
            subobject_not_found = 2
            OTHERS              = 3.
*
  CALL FUNCTION 'APPL_LOG_WRITE_SINGLE_MESSAGE'
       EXPORTING
            object              = s_balhdri-object
            subobject           = s_balhdri-subobject
            MESSAGE             = err_msg
       EXCEPTIONS
            object_not_found    = 1
            subobject_not_found = 2
            OTHERS              = 3.
*
  CALL FUNCTION 'APPL_LOG_WRITE_DB'
       EXPORTING
            object                = s_balhdri-object
            subobject             = s_balhdri-subobject
       TABLES
            object_with_lognumber = t_balnri
       EXCEPTIONS
            object_not_found      = 1
            subobject_not_found   = 2
            internal_error        = 3
            OTHERS                = 4.
* Anwendungslog geschrieben *

* ggf. Mail schicken *
  SELECT SINGLE * FROM zcl_mail_cfg INTO wa_mail_cfg
                  WHERE msgid = i_msgid
                    AND msgno = i_msgno.

* Eintrag fuer Fehlermeldung vorhanden.
  IF sy-subrc = 0.
* SAP-Mail verschicken
    IF wa_mail_cfg-knz_mail = c_mail_sap_normal OR
       wa_mail_cfg-knz_mail = c_mail_sap_express.
* Erstellen des Dokumentes *

      doc_chng-obj_name = text-001.
*      DOC_CHNG-OBJ_DESCR = 'Anwendungsmeldung'.
      doc_chng-skip_scren = ' '.

      CALL FUNCTION 'RS_MSG_TEXT'
           EXPORTING
                msgid              = err_msg-msgid
                msgno              = err_msg-msgno
                msgv1              = err_msg-msgv1
                msgv2              = err_msg-msgv2
                msgv3              = err_msg-msgv3
                msgv4              = err_msg-msgv4
           TABLES
                msgtext            = msgtext
           EXCEPTIONS
                message_not_exists = 1
                OTHERS             = 2.


*      concatenate i_msgid i_msgno i_msgv1 i_msgv2 i_msgv3 i_msgv4
*                  into objtxt separated by space.
      LOOP AT msgtext.                            "Neu 11.12.2001 SEY
        CONCATENATE msgtext(48) '..' INTO doc_chng-obj_descr.
        EXIT.
      ENDLOOP.

      LOOP AT msgtext.
        objtxt = msgtext.
        APPEND objtxt.
      ENDLOOP.
*      append objtxt.
      DESCRIBE TABLE objtxt LINES tab_lines.
      READ TABLE objtxt INDEX tab_lines.
      doc_chng-doc_size = ( tab_lines - 1 ) * 255 + STRLEN( objtxt ).
      CLEAR objpack-transf_bin.
      objpack-head_start = 1.
      objpack-head_num   = 0.
      objpack-body_start = 1.
      objpack-body_num   = tab_lines.
      objpack-doc_type   = 'RAW'.
      APPEND objpack.

      reclist-rec_type = 'B'.
* Express-Mail
      IF wa_mail_cfg-knz_mail = c_mail_sap_express.
        reclist-express = 'X'.
      ELSE.
        reclist-express = ''.
      ENDIF.
* Benutzer zusammenstellen
      IF wa_mail_cfg-sap_user IS INITIAL.
        SELECT * FROM zcl_usr_grp_tab INTO TABLE wa_usr_grp
                 WHERE sap_usr_group = wa_mail_cfg-sap_usr_group
                   AND state         = '00'.
        LOOP AT wa_usr_grp.
          reclist-receiver = wa_usr_grp-sap_user.
          APPEND reclist.
        ENDLOOP.
      ELSE.
        reclist-receiver = wa_mail_cfg-sap_user.
        APPEND reclist.
      ENDIF.

      CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
           EXPORTING
                document_data              = doc_chng
           IMPORTING
                sent_to_all                = sent_flag
                new_object_id              = new_id
           TABLES
                packing_list               = objpack
                contents_txt               = objtxt
                receivers                  = reclist
           EXCEPTIONS
                too_many_receivers         = 1
                document_not_sent          = 2
                document_type_not_exist    = 3
                operation_no_authorization = 4
                parameter_error            = 5
                x_error                    = 6
                enqueue_error              = 7
                OTHERS                     = 8.


    ELSEIF wa_mail_cfg-knz_mail = c_mail_user.
* User definiert, hier Erstellung einer Datei mit dem Fehlertext.
      wa_time_stamp(6)   = sy-datum+2(6).
      wa_time_stamp+6(6) = sy-uzeit.
      CALL FUNCTION 'FILE_GET_NAME'
           EXPORTING
*               CLIENT                  = SY-MANDT
                logical_filename        = 'ZDPS_USER_MAIL'
*               operating_system        = sy-opsys
*               parameter_1             = ' '
*               PARAMETER_2             = ' '
*               USE_PRESENTATION_SERVER = ' '
*               WITH_FILE_EXTENSION     = ' '
*               USE_BUFFER              = ' '
           IMPORTING
*               EMERGENCY_FLAG          =
*               FILE_FORMAT             =
                file_name               = wa_path
           EXCEPTIONS
                file_not_found          = 1
                OTHERS                  = 2.
      CALL FUNCTION 'RS_MSG_TEXT'
           EXPORTING
                msgid              = err_msg-msgid
                msgno              = err_msg-msgno
                msgv1              = err_msg-msgv1
                msgv2              = err_msg-msgv2
                msgv3              = err_msg-msgv3
                msgv4              = err_msg-msgv4
           TABLES
                msgtext            = msgtext
           EXCEPTIONS
                message_not_exists = 1
                OTHERS             = 2.
      CONCATENATE wa_path 'P' wa_time_stamp INTO wa_file.
      CONDENSE wa_file NO-GAPS.
      wa_file_name = wa_file.
*     OPEN DATASET wa_file_name FOR OUTPUT.
*     READ DATASET wa_file_name INTO msgtext.
      OPEN DATASET wa_file_name FOR APPENDING IN BINARY MODE.
      TRANSFER msgtext TO wa_file_name.
      CLOSE DATASET wa_file_name.
    ENDIF.
  ENDIF.

ENDFUNCTION.
