*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF08 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  add_object_key
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_object_key.
  CALL FUNCTION 'Z_CL_MAKE_OBJECT_KEY'
       EXPORTING
            i_dokar = wa_plotjobs-dokar
            i_doknr = wa_plotjobs-doknr
            i_dokvr = wa_plotjobs-dokvr
            i_doktl = wa_plotjobs-doktl
       IMPORTING
            o_objky = wa_plotjobs-objky
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " add_object_key


*---------------------------------------------------------------------*
*       FORM add_compression_field                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM add_compression_field.
  DATA: tmp_kompression LIKE zcl_comp_tiff-typ_kompression.
  DATA: langu TYPE sy-langu.


  CLEAR tmp_kompression.
  SET LOCALE LANGUAGE langu.
  TRANSLATE wa_plotjobs-typ TO UPPER CASE.
  SET LOCALE LANGUAGE space.
  SELECT SINGLE typ_kompression FROM zcl_comp_tiff
    INTO tmp_kompression
    WHERE typ_tiff = wa_plotjobs-typ
    .
  IF sy-subrc NE 0.
    wa_plotjobs-kompression = 'KEINE'.
  ELSE.
    wa_plotjobs-kompression = tmp_kompression.
  ENDIF.


ENDFORM.                    " add_compression_field
*&---------------------------------------------------------------------*
*&      Form  check_prio
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_prio.
  IF wa_plotjobs-prio > user_data-prio_bis.
    wa_plotjobs-prio = user_data-prio_bis.
  ELSE.
  ENDIF.
  IF wa_plotjobs-prio < user_data-prio_von.
    wa_plotjobs-prio = user_data-prio_von.
  ELSE.
  ENDIF.

ENDFORM.                    " check_prio
