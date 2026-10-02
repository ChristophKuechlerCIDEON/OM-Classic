*&---------------------------------------------------------------------*
*& Report  /CIDEON/_PRINT_CS_DOC_LINKS                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*  Serviceauftragsdruck Plot Dokumente zum FHM Dokumente
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           24.08.2004
*-----------------------------------------------------------------------
* Journal
*
*-----------------------------------------------------------------------

REPORT  /cideon/_print_cs_doc_links .

************************************************************************
* Print Drive ABAP for CONTROL TICKET                                  *
*                                                                      *
* Standard FORM is  PM_COMMOM                                          *
*                                                                      *
*----------------------------------------------------------------------*
* ABAP STEPS:                                                          *
*    1: IMPORT data to print.                                          *
*                                                                      *
*    2: Parse of Data to print FORM.                                   *
*       The external text tables will be read as necessary.            *
*                                                                      *
*    3: Save Print-Protocol records in PMPL                            *
************************************************************************
*$*$  D A T A    S E C T I O N    I N C L U D E S ---------------------*
INCLUDE riprid01.                      " General DATA and TABLE struct.
DATA:  lt_drad TYPE TABLE OF drad WITH HEADER LINE,
       gf_nodrad.

*------------------*
START-OF-SELECTION.
*------------------*
 PERFORM print_paper.  "can be started via SUBMIT or PERFORM PRINT_PAPER

*$*$ ................ M A I N     F O R M .............................*
*... DATA STRUCTURE: ..................................................*
*...                                                                   *
*...    CAUFVD (AFIH AUFK AFKO plus other dialog fields: ORDER HEADER) *
*...     |                                                             *
*...     |-- AFVGD       (AFVC AFVV plus dialog fields) Order operatns *
*...     |   |                                                         *
*...     |   |-- The sub operations also stored AFVGD and are pre      *
*...     |       sorted. The SUMNR fields distinguishes Main operaitons*
*...     |       and sub operations                                    *
*...     |                                                             *
*...     |-- RESBD                 Materials                           *
*...     |-- RIPW0                 Object list dialog area
*             ------VIQMEL         First Notification from Object list
*...     |-- IHPAD                 Partners to Orders                  *
*...
*......................................................................*

*----------------------------------------------------------------------*
*       FORM PRINT_PAPER                                               *
*----------------------------------------------------------------------*
*       Main driving Form behind the Printing of Papers                *
*       All information is imported from MEMORY                        *
*----------------------------------------------------------------------*
*  -->  FORM        Name of SAPSCRIPT form to use.                     *
*  -->  WWORKPAPER  Print options for SAPSCRIPT.                       *
*                   Structure command to define wworkpaper so the      *
*                   individual fields can be addressed.                *
*  -->  DATA STRUCTURES    See form DATA_IMPORT INCLUDE RIPRID01       *
*----------------------------------------------------------------------*
*$*$ -   P  R  I  N   T       P  A  P  E  R
FORM print_paper.                      " This form name must be used !!
*$*$ -  STARTED BY EXTERNAL PERFORM

*  break schulte.
  PERFORM order_data_import.           " See INCLUDE RIPRIf02
  PERFORM read_fh_doc_links.              " Read document links

  IF gf_nodrad IS INITIAL.

***** CIDEON Integration ************************************
* Schreiben der Spool ID in ZCL_PSB_TMP oder ins Memory
* OBJECT_TYPE : SPOOL
* Counter normal gefüllt
*WA
    DATA: wa_default_data TYPE /cideon/plot_defaultdata.
    DATA: wa_user_data TYPE /cideon/plot_userdata.

* Einstellungen lesen
    CLEAR wa_user_data.
    CLEAR wa_default_data.

    CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
         EXPORTING
              i_batch        = ''
         IMPORTING
              o_default_data = wa_default_data.


    CALL FUNCTION '/CIDEON/READ_USERDATA'
         EXPORTING
              i_default_data = wa_default_data
         IMPORTING
              o_user_data    = wa_user_data.


    DATA: wa_item TYPE zcl_pdm_objects_fa_int.
    DATA: itab_item TYPE TABLE OF zcl_pdm_objects_fa_int.

* Daten übergeben
    CLEAR wa_item.
    CLEAR itab_item.

    "CKR
    " 14.04.2011 Übergabe der Werte
    LOOP AT iaffhd.
      CHECK iaffhd-fhmar = 'D'.

      MOVE-CORRESPONDING iaffhd TO wa_item.
      wa_item-tdotftype = itcpp-tdotftype.
      wa_item-tdspoolid = itcpp-tdspoolid.


* Projektsystem Informationen
      wa_item-projn = caufvd-projn.
*   mglw. Nachlesen der ID
      IF wa_item-projn IS INITIAL.
        DATA: wa_afpo TYPE afpo.
        SELECT SINGLE projn
          INTO wa_item-projn
          FROM afpo
          WHERE aufnr = caufvd-aufnr
          .
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.

      wa_item-aufnr_cs = caufvd-aufnr.
      wa_item-verteiler = wa_user_data-default_verteiler_cs.

      APPEND wa_item TO itab_item.

    ENDLOOP.


*    loop at lt_drad.
*
*      move-corresponding lt_drad to wa_item.
*      wa_item-tdotftype = itcpp-tdotftype.
*      wa_item-tdspoolid = itcpp-tdspoolid.
*
*
** Projektsystem Informationen
*      wa_item-projn = caufvd-projn.
**   mglw. Nachlesen der ID
*      if wa_item-projn is initial.
*        data: wa_afpo type afpo.
*        select single projn
*          into wa_item-projn
*          from afpo
*          where aufnr = caufvd-aufnr
*          .
*        if sy-subrc ne 0.
*        else.
*        endif.
*      else.
*      endif.
*
*      wa_item-aufnr_cs = caufvd-aufnr.
*      wa_item-verteiler = wa_user_data-default_verteiler_cs.
*
*      append wa_item to itab_item.
*    endloop.

* Aufruf des FBs
    IF itab_item IS INITIAL.
    ELSE.
      CALL FUNCTION 'Z_CL_INT_WRITE_PLOT_PSB_NO_STR'
           EXPORTING
                f_aut_process = wa_user_data-knz_auto_cs
           TABLES
                i_itab_items  = itab_item
           EXCEPTIONS
                error         = 1
                OTHERS        = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
      ENDIF.
    ENDIF.

  ELSE.
    EXPORT gf_nodrad TO MEMORY ID 'NODRAD'.
  ENDIF.

***** /CIDEON Integration ************************************

ENDFORM.
*$*$   F O R M    R O U T I N E S -------------------------------------*
*...   Includes for General and Sepcific form routines
INCLUDE riprif01.                      " General PRINT routines
INCLUDE riprif02.                      " General PRINT routines ORDERS
*.......................................................................
*$*$ G E N E R A L     F O R M     R O U T I N E S ....................
*ENDFORM.                    " EXTEND_VERT_LINES

*&---------------------------------------------------------------------*
*&      Form  read_fh_doc_links
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_fh_doc_links.

  IF NOT iaffhd[] IS INITIAL.
    CLEAR lt_drad.
    LOOP AT iaffhd.
      CHECK iaffhd-fhmar = 'D'.  " Dokumentverknüpfung !
      MOVE-CORRESPONDING iaffhd TO lt_drad.
      APPEND lt_drad.
      CLEAR lt_drad.
    ENDLOOP.
  ENDIF.

  IF lt_drad[] IS INITIAL.
    gf_nodrad = 'X'.
  ELSE.
    CLEAR gf_nodrad .
  ENDIF.

ENDFORM.                    " read_doc_links
