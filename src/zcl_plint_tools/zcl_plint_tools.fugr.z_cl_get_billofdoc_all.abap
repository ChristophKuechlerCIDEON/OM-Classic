FUNCTION Z_CL_GET_BILLOFDOC_ALL.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOKAR) TYPE  DRAW-DOKAR
*"     VALUE(I_DOKNR) TYPE  DRAW-DOKNR
*"     VALUE(I_DOKVR) TYPE  DRAW-DOKVR
*"     VALUE(I_DOKTL) TYPE  DRAW-DOKTL
*"  TABLES
*"      O_ITAB_DRAW STRUCTURE  DRAW
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
*-----------------------------------------------------------------------
*TYPES
  TYPES:
    BEGIN OF t_default_data,
      mat_capid TYPE tc04-capid,
    END OF t_default_data.
  TYPES:
    BEGIN OF t_user_data,
      mat_capid TYPE tc04-capid,
      uname TYPE sy-uname,
    END OF t_user_data.
*ITAB
  DATA: itab_stb TYPE TABLE OF stpox.
  DATA: itab_doccat type table of CSCDOC.
*WA
  DATA: wa_stb TYPE stpox.
  DATA: wa_mara TYPE mara.
  DATA: wa_draw type draw.
  DATA: default_data TYPE t_default_data.
  DATA: user_data TYPE t_user_data.

*NORMAL
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).


* Initialisieren
  REFRESH itab_stb.
  REFRESH o_itab_draw.

* Einstellungen einlesen
* Stückliste abfragen
  CALL FUNCTION 'CS_BOM_EXPL_DOC_V1'
    EXPORTING
      DATUV                          = sy-datum
      docnr                          = i_doknr
      docar                          = i_dokar
      doctl                          = i_doktl
      docvr                          = i_dokvr
      MEHRS                          = 'X'
*     MMORY                          = ' '
*     POSTP                          = ' '
*     RLDET                          = ' '
*     SANKO                          = ' '
*     SANIN                          = ' '
*     EMENG                          = 0
*     VDTON                          = ' '
*     VDTAO                          = 'X'
*     VDTRO                          = 'X'
*   IMPORTING
*     TOPDOC                         =
    tables
      stb                            = itab_stb
      doccat                         = itab_doccat
   EXCEPTIONS
     CALL_INVALID                   = 1
     DOCUMENT_NOT_FOUND             = 2
     MISSING_AUTHORIZATION          = 3
     NO_BOM_FOUND                   = 4
     NO_SUITABLE_BOM_FOUND          = 5
     BOM_NOT_ACTIVE                 = 6
     BOM_FLAGGED_FOR_DELETION       = 7
     BOM_WITHOUT_POSITIONS          = 8
     OTHERS                         = 9
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  LOOP AT itab_stb INTO wa_stb.
    CLEAR wa_draw.
    wa_draw-dokar = wa_stb-dokar.
    wa_draw-doknr = wa_stb-doknr.
    wa_draw-dokvr = wa_stb-dokvr.
    wa_draw-doktl = wa_stb-doktl.
    APPEND wa_draw TO o_itab_draw.
  ENDLOOP.

ENDFUNCTION.
