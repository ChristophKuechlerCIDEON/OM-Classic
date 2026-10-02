FUNCTION /cideon/add_client_data_3.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BATCH) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_USER) TYPE  XUBNAME OPTIONAL
*"  EXPORTING
*"     VALUE(O_G_DMS_MAX_TMP_FILES) TYPE  CHAR10
*"  TABLES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 19.07.2004 - Erstellung
* 15.12.2004 - BATCH Fähigkeit
* 27.02.2006 - g_dms_max_tmp_files wieder belebt / PLM 2006 Vegas
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.

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

* Parameter
  DATA: itab_parameter TYPE TABLE OF bapiparam.
  DATA: wa_parameter TYPE bapiparam.

* Benutzer
  DATA: benutzername TYPE xubname.

  CLEAR rc.
  CLEAR wa_address.
  CLEAR wa_company.
  CLEAR itab_addtel.
  CLEAR itab_addsmtp.

  CLEAR wa_parameter.
  CLEAR itab_parameter.

  CLEAR benutzername.
  benutzername = i_user.
  IF i_batch = 'X'.
    IF i_user IS INITIAL.
      benutzername = sy-uname.
    ELSE.
    ENDIF.
  ELSE.
    benutzername = sy-uname.
  ENDIF.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username             = benutzername
   IMPORTING
*     LOGONDATA            =
*     DEFAULTS             =
     address              = wa_address
     company              = wa_company
*     SNC                  =
*     REF_USER             =
*     alias                = wa_alias
    TABLES
      parameter            = itab_parameter
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

  CLEAR g_dms_max_tmp_files.
  LOOP AT itab_parameter INTO wa_parameter.
    IF wa_parameter-parid = 'DMS_MAX_TMP_FILES'.
      g_dms_max_tmp_files = wa_parameter-parva.
      o_g_dms_max_tmp_files = wa_parameter-parva.
    ELSE.
    ENDIF.
  ENDLOOP.

  LOOP AT itab_plotjobs INTO wa_plotjobs.
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
    wa_plotjobs-firma = wa_company-company.

    MODIFY itab_plotjobs FROM wa_plotjobs INDEX sy-tabix.

  ENDLOOP.


ENDFUNCTION.
