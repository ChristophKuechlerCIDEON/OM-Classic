FUNCTION /CIDEON/GET_STMP_RG_TELNR_LONG.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 05.07.2006 - Erstellung
*-----------------------------------------------------------------------
* SD Felder - auf Partnerrollen
* Name für Rolle AG
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: wa_partner_addr TYPE /cideon/sdpartner.
*NORMAL

  CLEAR o_stempel_wert.

  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  IF wa_plotjob-vbeln IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.


* Partner Rollen lesen
* Auswerten, ob Partnerrolle dabei
* Adressen lesen
  CLEAR wa_partner_addr.
  CALL FUNCTION '/CIDEON/PLOT_VA_GET_ADDR_'
       EXPORTING
            i_vbeln        = wa_plotjob-vbeln
            i_parvw        = 'RG'
       IMPORTING
            o_partner_addr = wa_partner_addr
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



* Feld befüllen
  o_stempel_wert = wa_partner_addr-TELNR_LONG.


ENDFUNCTION.
