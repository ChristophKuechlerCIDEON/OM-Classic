*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF11 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  add_client_data_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_client_data_2.
* Adds special client data to plotjobs
  DATA: wa_kna1 LIKE kna1.
  DATA: mailadresse TYPE ad_smtpadr.
  DATA: n10(10) TYPE n.

  CLEAR wa_kna1.
  CLEAR mailadresse.


  DATA: rc TYPE TABLE OF bapiret2.
  DATA: wa_address TYPE bapiaddr3.
  DATA: wa_company TYPE bapiuscomp.

  DATA: itab_addtel TYPE TABLE OF bapiadtel.
  DATA: itab_addsmtp TYPE TABLE OF bapiadsmtp.

  CLEAR rc.
  CLEAR wa_address.
  CLEAR wa_company.
  CLEAR itab_addtel.
  CLEAR itab_addsmtp.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username             = sy-uname
   IMPORTING
*     LOGONDATA            =
*     DEFAULTS             =
     address              = wa_address
     company              = wa_company
*     SNC                  =
*     REF_USER             =
*     alias                = wa_alias
    TABLES
*     PARAMETER            =
*     PROFILES             =
*     ACTIVITYGROUPS       =
      return               = rc
      addtel               = itab_addtel
*     ADDFAX               =
*     ADDTTX               =
*     ADDTLX               =
      addsmtp              = itab_addsmtp
*     ADDRML               =
*     ADDX400              =
*     ADDRFC               =
*     ADDPRT               =
*     ADDSSF               =
*     ADDURI               =
*     ADDPAG               =
*     ADDCOMREM            =
*     GROUPS               =
            .


  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-name1 = wa_address-firstname.
    wa_plotjobs-name2 = wa_address-lastname.
*    "wa_plotjobs-firma = wa_kna1-
*    "wa_plotjobs-abteilung = wa_kna1-
*    wa_plotjobs-stras = wa_kna1-stras.
*    wa_plotjobs-ort1 = wa_kna1-ort01.
*    wa_plotjobs-pstlz = wa_kna1-pstlz.
    CONCATENATE wa_address-tel1_numbr ' / ' wa_address-tel1_ext
      INTO wa_plotjobs-telf1.
*    wa_plotjobs-telf1 = .
*    wa_plotjobs-telfx = wa_kna1-telfx.
    wa_plotjobs-smtp_addr = wa_address-e_mail.
*
*
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.

  ENDLOOP.


ENDFORM.                    " add_client_data_2
