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
*&      Form  drawings_to_plot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM drawings_to_plot.
* Alle Zeichungen in die Übergabetabelle übergeben

  LOOP AT it_drad_psp INTO wa_drad_psp.
    CLEAR wa_objects.
    MOVE-CORRESPONDING wa_drad_psp TO wa_objects.

    wa_objects-object_type = 'DOCUMENT'.

    APPEND wa_objects TO it_objects.
  ENDLOOP.

ENDFORM.                    " drawings_to_plot
*&---------------------------------------------------------------------*
*&      Form  get_prst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_prst.
* holen der Projektstücklisten   PRST

  CLEAR it_prst.
  SELECT * FROM prst INTO TABLE it_prst
    WHERE pspnr = wa_mdr_tr-pspnr
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


ENDFORM.                    " get_prst
