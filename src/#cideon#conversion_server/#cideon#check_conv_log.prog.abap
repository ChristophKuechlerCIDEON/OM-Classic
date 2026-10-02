*&---------------------------------------------------------------------*
*& Report  /CIDEON/CHECK_CONV_LOG                                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:
*
*-----------------------------------------------------------------------
* Journal
* 19.04.2005 - Erstellung
* 20.04.2005 - Umstellung auf /CIDEON/MAIL_CFG
*              /CIDEON/USRGRPTB
*-----------------------------------------------------------------------
* to do
*
*-----------------------------------------------------------------------

REPORT  /cideon/check_conv_log        .

PARAMETERS pdatum TYPE sy-datum DEFAULT sy-datum.

* ITAB
DATA: itab_balhdr TYPE TABLE OF balhdr.
DATA: itab_draw TYPE TABLE OF draw.
DATA: itab_usr_grp_tab TYPE TABLE OF /cideon/usrgrptb.

* WA
DATA: wa_balhdr TYPE balhdr.
DATA: wa_draw TYPE draw.
DATA: wa_mail_cfg TYPE /cideon/mail_cfg.
DATA: wa_usr_grp_tab TYPE /cideon/usrgrptb.

* BALDHRD lesen
SELECT * FROM balhdr INTO TABLE itab_balhdr
  WHERE object = 'CONV'
  AND aldate = pdatum
* ABORT oder EXCEPTION Meldungen
  AND ( msg_cnt_a <> '000000'
        OR msg_cnt_e <> '000000'
      )
  .
IF sy-subrc NE 0.
* keine Eintragungen
* keine Notwendigkeit, eine Mail zu senden
  EXIT.
ELSE.
ENDIF.

* gefundene Einträge nach itab_ptx_draw (DRAW)
* konvertieren

* EXT_NUMBER splitten
CLEAR itab_draw.
CLEAR wa_draw.
LOOP AT itab_balhdr INTO wa_balhdr.
  CLEAR wa_draw.
  SPLIT wa_balhdr-extnumber AT '_'
    INTO
    wa_draw-doknr wa_draw-dokar
    wa_draw-doktl wa_draw-dokvr
    .
  APPEND wa_draw TO itab_draw.
ENDLOOP.

* doppelte Einträge löschen
SORT itab_draw BY dokar doknr doktl dokvr.
DELETE ADJACENT DUPLICATES FROM itab_draw.

* Nutzergruppen / Nutzer lesen
* /CIDEON/USRGRPTB
* /CIDEON/MAIL_CFG

*MSGID
*MSGNO
*KNZ_MAIL
*E_MAIL_ADDR
*SAP_USER
*SAP_USR_GROUP

SELECT SINGLE * FROM /cideon/mail_cfg INTO wa_mail_cfg
  WHERE msgid = 'CONV'
  AND msgno = '000'
  AND knz_mail = '2'
  .
IF sy-subrc NE 0.
  WRITE: / text-001.
  EXIT.
ELSE.
ENDIF.


*MANDT
*SAP_USR_GROUP
*SAP_USER
*STATE

SELECT * FROM /cideon/usrgrptb INTO
  TABLE itab_usr_grp_tab
  WHERE sap_usr_group = wa_mail_cfg-sap_usr_group
  .
IF sy-subrc NE 0.
  WRITE: / text-002.
  EXIT.
ELSE.
ENDIF.


* SAP Expressmail senden
DATA: doc_chng LIKE sodocchgi1,
      objpack LIKE sopcklsti1 OCCURS 2 WITH HEADER LINE,
      objtxt LIKE solisti1 OCCURS 10 WITH HEADER LINE,
      objbin LIKE solisti1 OCCURS 10 WITH HEADER LINE,
      reclist LIKE somlreci1 OCCURS 5 WITH HEADER LINE,
      sent_flag LIKE sonv-flag,
      tab_lines LIKE sy-tabix,
      new_id LIKE sofolenti1-object_id.

*append objtxt.
CLEAR objtxt.
CALL FUNCTION 'CONVERSION_EXIT_MODAT_OUTPUT'
     EXPORTING
          input  = sy-datum
     IMPORTING
          output = objtxt.

CONCATENATE text-009 objtxt
  INTO objtxt SEPARATED BY space.
APPEND objtxt.



CLEAR objtxt.
objtxt = text-005.
APPEND objtxt.

CLEAR objtxt.
objtxt = ''.
APPEND objtxt.

LOOP AT itab_draw INTO wa_draw.
  CLEAR objtxt.
  CONCATENATE wa_draw-dokar '/' wa_draw-doknr '/'
    wa_draw-doktl '/' wa_draw-dokvr
    INTO objtxt SEPARATED BY space.
  APPEND objtxt.
ENDLOOP.

CLEAR objtxt.
objtxt = ''.
APPEND objtxt.

CLEAR objtxt.
objtxt = text-006.
APPEND objtxt.

CLEAR objtxt.
objtxt = text-007.
APPEND objtxt.

CLEAR objtxt.
objtxt = text-008.
APPEND objtxt.


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

doc_chng-obj_name = text-010.
doc_chng-obj_descr = text-011.
doc_chng-skip_scren = ' '.


reclist-rec_type = 'B'.
* Express-Mail
reclist-express = 'X'.

LOOP AT itab_usr_grp_tab INTO wa_usr_grp_tab.
  reclist-receiver = wa_usr_grp_tab-sap_user.
  APPEND reclist.
ENDLOOP.


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
*
