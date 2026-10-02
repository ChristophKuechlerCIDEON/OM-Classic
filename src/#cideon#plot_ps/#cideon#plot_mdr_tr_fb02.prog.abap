*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_MDR_TR_FB02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_chapter_desc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_chapter_desc.

  SELECT SINGLE dktxt FROM drat
    INTO wa_objects-kapitel
    WHERE dokar = wa_draw_easy-dokar
    AND doknr = wa_draw_easy-doknr
    AND doktl = wa_draw_easy-doktl
    AND dokvr = wa_draw_easy-dokvr
    AND langu = sy-langu
    .
  IF sy-subrc NE 0.
*   Sprachen
    CASE sy-langu.
      WHEN 'D'.
        SELECT SINGLE dktxt FROM drat
          INTO wa_objects-kapitel
          WHERE dokar = wa_draw_easy-dokar
          AND doknr = wa_draw_easy-doknr
          AND doktl = wa_draw_easy-doktl
          AND dokvr = wa_draw_easy-dokvr
          AND langu = 'EN'
          .
      WHEN 'E'.
        SELECT SINGLE dktxt FROM drat
          INTO wa_objects-kapitel
          WHERE dokar = wa_draw_easy-dokar
          AND doknr = wa_draw_easy-doknr
          AND doktl = wa_draw_easy-doktl
  AND dokvr = wa_draw_easy-dokvr
  AND langu = 'DE'
  .
    ENDCASE.
  ELSE.
  ENDIF.


ENDFORM.                    " get_chapter_desc
*&---------------------------------------------------------------------*
*&      Form  set_chapter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_chapter.


  CLEAR wa_objects.

  wa_objects-object_type = 'DOCUMENT'.
  wa_objects-dokar = wa_mdr_tr-sep_dokar.
  wa_objects-doknr = wa_mdr_tr-sep_doknr.
  wa_objects-doktl = wa_mdr_tr-sep_doktl.
  wa_objects-dokvr = wa_mdr_tr-sep_dokvr.

  PERFORM get_chapter_desc.

  APPEND wa_objects TO it_objects.

ENDFORM.                    " set_chapter
*&---------------------------------------------------------------------*
*&      Form  get_easy_doc_root
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_easy_doc_root.
* Wurzel für Easy DMS Dokumentation lesen

  READ TABLE it_wbs INTO wa_wbs INDEX 1.
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  DATA: key TYPE drad-objky.
  DATA: doktab TYPE TABLE OF drad.

  DATA: wa_prps TYPE prps.
  DATA: wa_doktab TYPE drad.

* Konvertierungsexit benutzen
  DATA: flg_exists_abpsp.
  CALL FUNCTION 'FUNCTION_EXISTS'
       EXPORTING
            funcname           = 'CONVERSION_EXIT_KONPR_INPUT'
       EXCEPTIONS
            function_not_exist = 1.

  IF sy-subrc <> 0.
    CLEAR flg_exists_abpsp.
  ELSE.
    flg_exists_abpsp = 'X'.
  ENDIF.

  IF flg_exists_abpsp = 'X'.
    DATA: ps_posnr TYPE ps_posnr.
    CLEAR ps_posnr.
   CALL FUNCTION 'CONVERSION_EXIT_KONPR_INPUT'              "#EC EXISTS
          EXPORTING
               input  = wa_wbs-wbs_element
          IMPORTING
               output = ps_posnr
          EXCEPTIONS
               not_found = 1.

    CLEAR key.
    key = ps_posnr.

  ELSE.
    CLEAR wa_prps.
    SELECT SINGLE * FROM prps INTO wa_prps
      WHERE posid = wa_wbs-wbs_element
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    CLEAR key.
    "key = wa_wbs-wbs_element.
    key = wa_prps-pspnr.
  ENDIF.




  CLEAR doktab.

  CALL FUNCTION 'DOKUMENTE_ZU_OBJEKT'
    EXPORTING
      key                       = key
    objekt                    = 'PRPS'
*     MANDT                     = SY-MANDT
*     CHECK_BUFFER_AND_DB       = ' '
  TABLES
    doktab                    = doktab
  EXCEPTIONS
    kein_dokument             = 1
    OTHERS                    = 2
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE doktab INTO wa_doktab INDEX 1..
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  wa_mdr_tr-root_dokar = wa_doktab-dokar.
  wa_mdr_tr-root_doknr = wa_doktab-doknr.
  wa_mdr_tr-root_doktl = wa_doktab-doktl.
  wa_mdr_tr-root_dokvr = wa_doktab-dokvr.



ENDFORM.                    " get_easy_doc_root
*&---------------------------------------------------------------------*
*&      Form  anzeige_struktur_docu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM anzeige_struktur_docu.
* Anzeige der Struktur der Dokumentation über den CAD Desktop

  DATA: return TYPE bapiret2.
  DATA: document TYPE bapi_doc_keys.

  CLEAR return.
  CLEAR document.
  document-documenttype = wa_mdr_tr-root_dokar.
  document-documentnumber = wa_mdr_tr-root_doknr.
  document-documentpart = wa_mdr_tr-root_doktl.
  document-documentversion = wa_mdr_tr-root_dokvr.

  CALL FUNCTION 'CDESK_SHOW'
    EXPORTING
      initial_view             = 'SAPSTRUCT'
*       WORKDIRECTORY            = ' '
*       CHANGENO                 = ' '
*       VALIDFROM                = SY-DATUM
      document                 = document
      sap_view_only            = 'X'
*       HOSTNAME                 = ' '
      cadsystem                = 'NONE'
     callback                 = ''
    IMPORTING
      return                   =  return
*     TABLES
*       CAD_REL_APPLS            =
*       ADD_CHECKIN_APPLS        =
*       ADD_CHECKOUT_APPLS       =
*       ADD_COPY_APPLS           =
            .
  IF return IS INITIAL.
  ELSE.
  ENDIF.



ENDFORM.                    " anzeige_struktur_docu
*&---------------------------------------------------------------------*
*&      Form  add_drawings_to_MDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_drawings_to_mdr.
* Zeichnungen hinzufügen.

  CLEAR wa_draw_item_tr.
  LOOP AT it_draw_item_tr INTO wa_draw_item_tr.
    CLEAR wa_objects.

    wa_objects-object_type = 'DOCUMENT'.
    wa_objects-dokar = wa_draw_item_tr-dokar.
    wa_objects-doknr = wa_draw_item_tr-doknr.
    wa_objects-doktl = wa_draw_item_tr-doktl.
    wa_objects-dokvr = wa_draw_item_tr-dokvr.

    APPEND wa_objects TO it_objects.

  ENDLOOP.

ENDFORM.                    " add_drawings_to_MDR
