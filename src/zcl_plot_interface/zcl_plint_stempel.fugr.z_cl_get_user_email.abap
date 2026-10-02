FUNCTION z_cl_get_user_email.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* ITAB
  DATA: itab_return TYPE TABLE OF bapiret2.
* WA
  DATA: wa_adress TYPE bapiaddr3.
  DATA: wa_company TYPE bapiuscomp.



  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username             = sy-uname
  IMPORTING
*   LOGONDATA            =
*   DEFAULTS             =
    address              = wa_adress
    company              = wa_company
*   SNC                  =
*   REF_USER             =
*   ALIAS                =
    TABLES
*   PARAMETER            =
*   PROFILES             =
*   ACTIVITYGROUPS       =
      return               = itab_return
*   ADDTEL               =
*   ADDFAX               =
*   ADDTTX               =
*   ADDTLX               =
*   ADDSMTP              =
*   ADDRML               =
*   ADDX400              =
*   ADDRFC               =
*   ADDPRT               =
*   ADDSSF               =
*   ADDURI               =
*   ADDPAG               =
*   ADDCOMREM            =
*   GROUPS               =
            .

  o_stempel_wert = wa_adress-e_mail.

ENDFUNCTION.
